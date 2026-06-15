# -*- coding: utf-8 -*-
"""Generiert Word-Dokumentation und PowerPoint fuer den ALZ-Kickoff."""
import datetime
from docx import Document
from docx.shared import Pt, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

from pptx import Presentation
from pptx.util import Inches as PInches, Pt as PPt, Emu
from pptx.dml.color import RGBColor as PRGB
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR

OUT = "/home/user/azure-landing-zone/docs/kickoff"
DATE = "15.06.2026"

# Farbpalette
BLUE = RGBColor(0x00, 0x78, 0xD4)
DARK = RGBColor(0x24, 0x3A, 0x5E)
GREY = RGBColor(0x60, 0x5E, 0x5C)
PBLUE = PRGB(0x00, 0x78, 0xD4)
PDARK = PRGB(0x24, 0x3A, 0x5E)
PLIGHT = PRGB(0xF2, 0xF6, 0xFB)
PWHITE = PRGB(0xFF, 0xFF, 0xFF)
PGREY = PRGB(0x60, 0x5E, 0x5C)

# =====================================================================
# WORD-DOKUMENTATION
# =====================================================================

def shade_cell(cell, hex_color):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear'); shd.set(qn('w:color'), 'auto'); shd.set(qn('w:fill'), hex_color)
    tcPr.append(shd)

def set_cell_text(cell, text, bold=False, color=None, size=9.5, white=False):
    cell.text = ""
    p = cell.paragraphs[0]; p.paragraph_format.space_after = Pt(2); p.paragraph_format.space_before = Pt(2)
    r = p.add_run(text); r.bold = bold; r.font.size = Pt(size)
    if white: r.font.color.rgb = RGBColor(0xFF,0xFF,0xFF)
    elif color: r.font.color.rgb = color

def add_table(doc, headers, rows, widths=None):
    t = doc.add_table(rows=1, cols=len(headers)); t.alignment = WD_TABLE_ALIGNMENT.CENTER
    t.style = 'Light Grid Accent 1'
    for i, h in enumerate(headers):
        set_cell_text(t.rows[0].cells[i], h, bold=True, white=True)
        shade_cell(t.rows[0].cells[i], '0078D4')
    for row in rows:
        cells = t.add_row().cells
        for i, val in enumerate(row):
            set_cell_text(cells[i], val)
    if widths:
        for i, w in enumerate(widths):
            for row in t.rows:
                row.cells[i].width = Inches(w)
    doc.add_paragraph()
    return t

def add_toc(doc):
    p = doc.add_paragraph(); run = p.add_run()
    fld = OxmlElement('w:fldChar'); fld.set(qn('w:fldCharType'), 'begin')
    instr = OxmlElement('w:instrText'); instr.set(qn('xml:space'), 'preserve'); instr.text = 'TOC \\o "1-2" \\h \\z \\u'
    sep = OxmlElement('w:fldChar'); sep.set(qn('w:fldCharType'), 'separate')
    t = OxmlElement('w:t'); t.text = "Inhaltsverzeichnis – in Word mit Strg+A, dann F9 aktualisieren."
    end = OxmlElement('w:fldChar'); end.set(qn('w:fldCharType'), 'end')
    for e in (fld, instr, sep, t, end): run._r.append(e)

def body(doc, text):
    p = doc.add_paragraph(text); p.paragraph_format.space_after = Pt(6)
    return p

def bullet(doc, text, bold_prefix=None):
    p = doc.add_paragraph(style='List Bullet')
    if bold_prefix:
        r = p.add_run(bold_prefix + ": "); r.bold = True
    p.add_run(text)
    return p

def build_docx():
    doc = Document()
    n = doc.styles['Normal']; n.font.name = 'Calibri'; n.font.size = Pt(10.5)
    for lvl, col, sz in [('Heading 1', DARK, 16), ('Heading 2', BLUE, 13), ('Heading 3', DARK, 11.5)]:
        st = doc.styles[lvl]; st.font.color.rgb = col; st.font.name = 'Calibri'; st.font.size = Pt(sz)

    # Titelseite
    for _ in range(3): doc.add_paragraph()
    t = doc.add_paragraph(); t.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = t.add_run("Azure Landing Zone"); r.bold = True; r.font.size = Pt(30); r.font.color.rgb = BLUE
    s = doc.add_paragraph(); s.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = s.add_run("Technische Dokumentation & Architektur"); r.font.size = Pt(15); r.font.color.rgb = DARK
    s2 = doc.add_paragraph(); s2.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = s2.add_run("Bicep / Azure Verified Modules · Hub-and-Spoke"); r.font.size = Pt(11); r.font.color.rgb = GREY
    for _ in range(8): doc.add_paragraph()
    m = doc.add_paragraph(); m.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = m.add_run(f"Stand: {DATE} · Version 1.0 · Vorbereitung Kickoff"); r.font.size = Pt(10); r.font.color.rgb = GREY
    doc.add_page_break()

    doc.add_heading("Inhaltsverzeichnis", level=1)
    add_toc(doc)
    doc.add_page_break()

    # 1 Management Summary
    doc.add_heading("1. Management Summary", level=1)
    body(doc, "Dieses Dokument beschreibt die Azure Landing Zone (ALZ) – das standardisierte, "
              "richtlinien­gesteuerte Fundament für den Betrieb von Workloads in Azure. Die Umsetzung "
              "erfolgt vollständig als Infrastructure-as-Code (Bicep, basierend auf Azure Verified Modules) "
              "und wird über eine CI/CD-Pipeline (GitHub Actions, passwortlose OIDC-Anmeldung) ausgerollt.")
    body(doc, "Die Landing Zone liefert von Beginn an eine konsistente Management-Group-Hierarchie, "
              "zentrale Protokollierung, Netzwerk-Konnektivität nach dem Hub-and-Spoke-Muster mit Azure "
              "Firewall, Governance-Guardrails über Azure Policy, rollenbasierte Zugriffe (RBAC) sowie eine "
              "Security-Baseline mit Microsoft Defender for Cloud. Workload-Subscriptions werden automatisiert "
              "platziert (Subscription Vending).")
    body(doc, "Ziel des Kickoffs ist es, den technischen Ansprechpartnern des Kunden den Aufbau, den "
              "aktuellen Umsetzungsstand und die noch zu treffenden Entscheidungen vorzustellen (siehe "
              "Kapitel 10).")

    # 2 Ziele & Prinzipien
    doc.add_heading("2. Zielsetzung & Design-Prinzipien", level=1)
    for bp, tx in [
        ("Richtliniengesteuerte Governance", "Leitplanken (Guardrails) werden zentral per Azure Policy auf Management-Group-Ebene erzwungen, nicht pro Ressource."),
        ("Subscription-Demokratisierung", "Die Subscription ist die Einheit der Skalierung; Workloads werden in dedizierte Landing-Zone-Subscriptions platziert."),
        ("Einheitliche Steuerungsebene", "Eine konsistente Hierarchie und zentrales Logging/Monitoring über alle Subscriptions hinweg."),
        ("Sicherheit von Grund auf", "Defender for Cloud, Netzwerksegmentierung über Azure Firewall, private Namensauflösung und Zero-Trust-Prinzipien."),
        ("Automatisierung & Wiederholbarkeit", "Alles als Code (Bicep), versioniert, per Pipeline reproduzierbar und über What-If vorab prüfbar."),
        ("Erweiterbarkeit", "Modularer Aufbau; einzelne Domänen lassen sich unabhängig erweitern (z. B. ExpressRoute, Virtual WAN, Sentinel)."),
    ]:
        bullet(doc, tx, bp)

    # 3 Architektur
    doc.add_heading("3. Architekturüberblick", level=1)
    body(doc, "Die Landing Zone folgt der offiziellen Microsoft-ALZ-Referenz. Die Management-Group-Hierarchie "
              "unterhalb der Tenant Root strukturiert Plattform- und Workload-Subscriptions:")
    mono = doc.add_paragraph()
    rr = mono.add_run(
        "Tenant Root\n"
        "└─ alz  (Intermediate Root)\n"
        "   ├─ alz-platform\n"
        "   │   ├─ alz-platform-connectivity   → Hub-Netzwerk, Firewall, DNS\n"
        "   │   ├─ alz-platform-identity       → Identity-Dienste\n"
        "   │   ├─ alz-platform-management     → Logging, Monitoring\n"
        "   │   └─ alz-platform-security       → Security-Tooling\n"
        "   ├─ alz-landingzones\n"
        "   │   ├─ alz-landingzones-corp       → interne Workloads\n"
        "   │   ├─ alz-landingzones-online     → internetseitige Workloads\n"
        "   │   └─ alz-landingzones-local      → souveräne/vertrauliche Workloads\n"
        "   ├─ alz-sandbox                     → Experimente (lockere Policies)\n"
        "   └─ alz-decommissioned              → Stilllegung (gesperrt)")
    rr.font.name = 'Consolas'; rr.font.size = Pt(9); rr.font.color.rgb = DARK
    body(doc, "Primärregion ist Germany West Central, Sekundärregion North Europe. Plattform-Dienste laufen in "
              "den Subscriptions Management (Logging) und Connectivity (Netzwerk); Identity ist vorgesehen.")

    # 4 Domänen
    doc.add_heading("4. Domänen im Detail", level=1)

    doc.add_heading("4.1 Governance (Management Groups, Policy, RBAC)", level=2)
    body(doc, "Die Management-Group-Hierarchie wird auf Tenant-Ebene per Bicep erstellt. Governance-Guardrails "
              "werden als Azure-Policy-Zuweisungen auf den passenden Ebenen verankert (schlankes, wirksames "
              "Custom-Set; bei Bedarf auf das vollständige ALZ-Policy-Set erweiterbar):")
    add_table(doc, ["Guardrail", "Wirkung", "Ebene"], [
        ["Allowed Locations", "Deny – nur erlaubte Regionen", "alz (Root)"],
        ["Require-RG-Tag (Environment)", "Deny – Pflicht-Tag auf Resource Groups", "alz (Root)"],
        ["Secure Transfer Storage", "Deny – HTTPS für Storage erzwingen", "alz (Root)"],
        ["Deny NIC Public IP", "Deny – keine öffentlichen IPs an NICs", "landingzones-corp"],
        ["Deny aller Ressourcentypen", "Deny – keine Neuanlage (Sperre)", "decommissioned"],
        ["Tag-Ausnahme (Exemption)", "Lockerung für Experimente", "sandbox"],
    ], widths=[2.6, 2.8, 1.7])
    body(doc, "RBAC: Ein wiederverwendbares Modul weist die Built-in-Rollen Owner/Contributor/Reader an "
              "Entra-ID-Gruppen je Management Group zu. Object-IDs werden injiziert (keine Hardcodes); ein "
              "leeres Set ist ein gefahrloser No-Op.")

    doc.add_heading("4.2 Identity", level=2)
    body(doc, "Die Management Group alz-platform-identity sowie eine Identity-Subscription sind vorgesehen. "
              "Konkrete Identity-Ressourcen (z. B. Entra-ID-Diagnose an Log Analytics, hybride Anbindung, "
              "Domänendienste) sind Teil der Roadmap und werden gemäß Kundenanforderung ausgestaltet "
              "(siehe Beratungspunkte, Kapitel 10).")

    doc.add_heading("4.3 Management & Monitoring (Logging)", level=2)
    body(doc, "Zentrale Protokollierung in der Management-Subscription:")
    for bp, tx in [
        ("Log Analytics Workspace", "law-alz-<Region>, Aufbewahrung 365 Tage, SKU PerGB2018."),
        ("Data Collection Rules", "VM Insights, Change Tracking und Defender-for-SQL (DCR-basiert)."),
        ("Managed Identity", "User-Assigned Identity für Datensammlung/Automatisierung."),
        ("Solutions", "ChangeTracking; Microsoft Sentinel per Schalter aktivierbar."),
        ("Automation Account", "Optional zuschaltbar (Update-/Konfigurationsmanagement)."),
    ]:
        bullet(doc, tx, bp)

    doc.add_heading("4.4 Security", level=2)
    body(doc, "Security-Baseline je Subscription (Microsoft Defender for Cloud):")
    for bp, tx in [
        ("Defender-Pläne", "VMs, Storage, Key Vault, ARM, Container, App Service, SQL, Open-Source-DB, Cosmos DB – Tier konfigurierbar (Standard/Free)."),
        ("Security Contacts", "Zentrale Sicherheits-E-Mail mit Alarm-Benachrichtigungen (Schweregrad-Schwelle, Benachrichtigung nach Rolle)."),
        ("Activity-Log → Log Analytics", "Subscription-Aktivitätsprotokolle (Administrative, Security, Policy, ResourceHealth …) zentral im Workspace."),
        ("Microsoft Sentinel", "Onboarding über Log-Analytics-Schalter; Data Connectors und Analyseregeln nach Bedarf."),
    ]:
        bullet(doc, tx, bp)

    doc.add_heading("4.5 Connectivity (Hub-and-Spoke)", level=2)
    body(doc, "Das Hub-Netzwerk in der Connectivity-Subscription bildet das Rückgrat. Spokes (Workloads) "
              "werden an den Hub gepeert und leiten ausgehenden Verkehr über die Azure Firewall.")
    for bp, tx in [
        ("Hub-VNets", "Primär 10.0.0.0/22 (Germany West Central), Sekundär 10.1.0.0/22 (North Europe)."),
        ("Azure Firewall + Policy", "Zentrale Firewall mit Basisregelwerk (DNS-Proxy, Azure-DNS, NTP, AzureCloud-HTTPS, Windows-Update; restlicher Verkehr = Deny)."),
        ("Azure Bastion", "Sicherer RDP/SSH-Zugang ohne öffentliche IPs."),
        ("Private DNS Zones", "37 privatelink-Zonen für Private Endpoints, mit dem Hub verknüpft."),
        ("DNS Private Resolver", "Optional – nutzt delegierte Inbound-/Outbound-Subnetze (hybride Namensauflösung)."),
        ("Hub-Peering", "Bidirektionales Peering zwischen Primär- und Sekundär-Hub."),
        ("Gateways & DDoS", "VPN-/ExpressRoute-Gateway und DDoS-Schutz vorbereitet, standardmäßig deaktiviert (kosten-/bedarfsgesteuert)."),
    ]:
        bullet(doc, tx, bp)

    doc.add_heading("4.6 Landing Zones & Subscription Vending", level=2)
    body(doc, "Workload-Landing-Zones erhalten ein Spoke-VNet mit Route Table (Default-Route über die Firewall), "
              "bidirektionalem Hub-Peering und Verknüpfung zu den zentralen Private-DNS-Zonen. Neue oder "
              "bestehende Subscriptions werden über das AVM-Pattern „Subscription Vending“ automatisiert in die "
              "richtige Management Group platziert – standardmäßig im Placement-Modus (ohne Billing-Rechte), "
              "optional als Neuanlage (EA/MCA).")

    # 5 IaC & CI/CD
    doc.add_heading("5. Infrastructure as Code & CI/CD", level=1)
    for bp, tx in [
        ("Bicep + AVM", "Deklarative Templates auf Basis der Azure Verified Modules aus der öffentlichen Microsoft-Registry."),
        ("deploy.ps1", "PowerShell-Orchestrierung mit gestaffelten Schritten und optionalen Schaltern (Spoke, Vending, Security)."),
        ("GitHub Actions", "Pipeline mit Jobs: validate (Build), what-if (Vorschau), preflight (Secret-Check), deploy (gated nach Scope)."),
        ("OIDC Federated Identity", "Passwortlose Anmeldung; vier Secrets, drei Federated Credentials (PR, environment:production, master)."),
        ("Scopes", "Deployments auf Tenant- (MGs/Policies/RBAC), Subscription- (Logging/Netzwerk/Security) und MG-Ebene (Vending)."),
    ]:
        bullet(doc, tx, bp)

    # 6 Naming & IP
    doc.add_heading("6. Namens- & Adresskonzept", level=1)
    add_table(doc, ["Element", "Konvention / Bereich"], [
        ["Management Groups", "alz, alz-platform-*, alz-landingzones-*"],
        ["Resource Groups", "rg-alz-<zweck>-<region>"],
        ["Ressourcen", "law-/mi-/afw-/bas-/vnet-/afwp-alz-<region>"],
        ["Hub primär / sekundär", "10.0.0.0/22 / 10.1.0.0/22"],
        ["Spoke (Beispiel)", "10.2.0.0/24 (überlappungsfrei zu Hubs/On-Prem)"],
        ["Regionen", "germanywestcentral (primär), northeurope (sekundär)"],
    ], widths=[2.4, 4.6])

    # 7 Betrieb
    doc.add_heading("7. Betrieb & Verifikation", level=1)
    body(doc, "Ein gestaffeltes Smoke-Run-Runbook führt von der statischen Validierung über What-If (ohne "
              "Änderungen) bis zum echten Deployment – nach Risiko/Kosten geordnet:")
    add_table(doc, ["Stufe", "Inhalt", "Azure-Wirkung"], [
        ["0 Statisch", "bicep build aller Templates (CI)", "keine"],
        ["1 What-If", "Vorschau je Scope", "keine"],
        ["2 Management Groups", "Hierarchie + Policies + RBAC", "kostenlos"],
        ["3 Logging", "Log Analytics + DCRs", "gering"],
        ["4 Networking", "VNets, Firewall, Bastion, DNS", "kostenrelevant"],
        ["5/6 Spoke & Vending", "Workload-Netz, Subscription-Platzierung", "gering"],
    ], widths=[1.7, 3.5, 1.8])
    body(doc, "Aktueller Verifikationsstand: alle Templates bauen fehlerfrei (Bicep 0.44.1, 0 Errors / 0 Warnings); "
              "die CI-Validierung läuft grün.")

    # 8 Status
    doc.add_heading("8. Umsetzungsstatus", level=1)
    add_table(doc, ["Domäne", "Status"], [
        ["Management Groups + Hierarchie", "Umgesetzt"],
        ["Governance-Policies (schlankes Set)", "Umgesetzt"],
        ["RBAC-Modul", "Umgesetzt (Gruppen-IDs durch Kunde)"],
        ["Logging / Log Analytics / DCRs", "Umgesetzt"],
        ["Security-Baseline (Defender, Contacts, Activity-Log)", "Umgesetzt"],
        ["Hub-Networking, Firewall+Policy, Bastion, DNS, Peering", "Umgesetzt"],
        ["DNS Private Resolver", "Umgesetzt (optional, aus)"],
        ["Spoke-Template & Subscription Vending", "Umgesetzt"],
        ["CI/CD + OIDC", "Umgesetzt"],
        ["Identity-Ressourcen", "Roadmap"],
        ["Sentinel-Onboarding (Connectors/Regeln)", "Roadmap"],
        ["VPN/ExpressRoute, DDoS, Virtual WAN", "Vorbereitet / optional"],
    ], widths=[4.6, 2.4])

    # 9 Roadmap
    doc.add_heading("9. Roadmap / nächste Schritte", level=1)
    for tx in [
        "Smoke Run im Kunden-Tenant (What-If → Management Groups → Logging → Networking).",
        "Identity-Domäne ausgestalten (Entra-Diagnose, hybride Anbindung nach Bedarf).",
        "Sentinel-Onboarding mit Data Connectors und Analyseregeln.",
        "On-Prem-Konnektivität (VPN oder ExpressRoute) je nach Entscheidung aktivieren.",
        "Governance bei Bedarf auf vollständiges ALZ-Policy-Set / Compliance-Frameworks erweitern.",
        "Optionale Härtung: Resource Locks, erweiterte Diagnostics, Cost Management.",
    ]:
        bullet(doc, tx)

    # 10 Entscheidungspunkte
    doc.add_heading("10. Entscheidungs- & Beratungspunkte (Kickoff)", level=1)
    body(doc, "Folgende Punkte sind gemeinsam mit dem Kunden zu klären – sie bestimmen Ausprägung, Kosten und "
              "Compliance der Landing Zone:")
    add_table(doc, ["Thema", "Zu klären", "Empfehlung"], [
        ["Netzwerk-Topologie", "Hub-and-Spoke vs. Virtual WAN", "Hub-and-Spoke (umgesetzt)"],
        ["IP-Adresskonzept", "Bereiche, Überlappung mit On-Prem", "Frühzeitig abstimmen"],
        ["Regionen / Datenresidenz", "Primär/Sekundär, Compliance", "GWC + NE bestätigen"],
        ["On-Prem-Anbindung", "VPN oder ExpressRoute", "Nach Bandbreite/SLA"],
        ["DDoS Protection", "Aktiv? (Kostenfaktor)", "Für Internet-facing prüfen"],
        ["Identity", "Entra-only / hybrid / AD DS", "Anforderungsabhängig"],
        ["RBAC-Modell", "Entra-Gruppen, PIM", "Gruppen je MG definieren"],
        ["Policy-Tiefe", "Schlank vs. volles ALZ-Set", "Bei Compliance-Pflicht erweitern"],
        ["Defender-Tier", "Standard vs. Free je Plan", "Standard für Prod"],
        ["Sentinel", "Onboarding & Connectors", "Bei SIEM-Bedarf"],
        ["Subscription Vending", "Placement vs. Neuanlage (Billing)", "Placement zum Start"],
        ["Log-Aufbewahrung", "365 Tage / Kosten", "Nach Compliance"],
    ], widths=[1.8, 2.9, 2.3])

    # 11 Voraussetzungen
    doc.add_heading("11. Voraussetzungen", level=1)
    for tx in [
        "Tenant-Berechtigungen: Management Group Contributor / Owner auf der Root-MG für die MG-Erstellung.",
        "Owner auf Management- und Connectivity-Subscription.",
        "OIDC: App-Registrierung + Federated Credentials + vier GitHub-Secrets (Runbook docs/OIDC-SETUP.md).",
        "Für Subscription-Neuanlage: EA/MCA-Billing-Rolle.",
        "Werkzeuge: Azure CLI ≥ 2.60, Bicep ≥ 0.29, PowerShell ≥ 7.4.",
    ]:
        bullet(doc, tx)

    # 12 Glossar
    doc.add_heading("12. Glossar", level=1)
    add_table(doc, ["Begriff", "Bedeutung"], [
        ["ALZ", "Azure Landing Zone – standardisiertes Cloud-Fundament"],
        ["AVM", "Azure Verified Modules – geprüfte Bicep-Module von Microsoft"],
        ["MG", "Management Group – hierarchische Gruppierung von Subscriptions"],
        ["Hub-and-Spoke", "Zentraler Hub (Shared Services) + angebundene Spokes (Workloads)"],
        ["OIDC", "OpenID Connect – passwortlose Pipeline-Anmeldung an Azure"],
        ["DCR", "Data Collection Rule – Regel zur Telemetrie-Erfassung"],
        ["Vending", "Automatisierte Bereitstellung/Platzierung von Subscriptions"],
        ["What-If", "Vorschau der Änderungen ohne Deployment"],
    ], widths=[1.8, 5.2])

    # Footer
    section = doc.sections[0]
    footer = section.footer.paragraphs[0]; footer.alignment = WD_ALIGN_PARAGRAPH.CENTER
    fr = footer.add_run("Azure Landing Zone – Technische Dokumentation · vertraulich"); fr.font.size = Pt(8); fr.font.color.rgb = GREY

    path = f"{OUT}/Azure-Landing-Zone-Dokumentation.docx"
    doc.save(path)
    return path

# =====================================================================
# POWERPOINT
# =====================================================================

def build_pptx():
    prs = Presentation()
    prs.slide_width = PInches(13.333); prs.slide_height = PInches(7.5)
    SW, SH = prs.slide_width, prs.slide_height
    blank = prs.slide_layouts[6]

    def add_rect(slide, x, y, w, h, color, line=False):
        from pptx.enum.shapes import MSO_SHAPE
        shp = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, x, y, w, h)
        shp.fill.solid(); shp.fill.fore_color.rgb = color
        if not line: shp.line.fill.background()
        shp.shadow.inherit = False
        return shp

    def txt(slide, x, y, w, h, text, size, color=PDARK, bold=False, align=PP_ALIGN.LEFT, font='Calibri'):
        tb = slide.shapes.add_textbox(x, y, w, h); tf = tb.text_frame; tf.word_wrap = True
        p = tf.paragraphs[0]; p.alignment = align
        r = p.add_run(); r.text = text; f = r.font
        f.size = size; f.bold = bold; f.color.rgb = color; f.name = font
        return tb

    def bullets(slide, x, y, w, h, items, size=PPt(16), color=PDARK):
        tb = slide.shapes.add_textbox(x, y, w, h); tf = tb.text_frame; tf.word_wrap = True
        first = True
        for it in items:
            lvl = 0; t = it
            if isinstance(it, tuple): t, lvl = it
            p = tf.paragraphs[0] if first else tf.add_paragraph(); first = False
            p.level = lvl
            r = p.add_run(); r.text = ("• " if lvl == 0 else "– ") + t
            r.font.size = size if lvl == 0 else PPt(13)
            r.font.color.rgb = color; r.font.name = 'Calibri'
            p.space_after = PPt(6)
        return tb

    def content_slide(title, subtitle=None):
        s = prs.slides.add_slide(blank)
        add_rect(s, 0, 0, SW, PInches(1.05), PBLUE)
        add_rect(s, 0, PInches(1.05), SW, Emu(45720), PDARK)  # thin accent line
        txt(s, PInches(0.5), PInches(0.18), PInches(12.3), PInches(0.7), title, PPt(26), PWHITE, True)
        if subtitle:
            txt(s, PInches(0.5), PInches(1.2), PInches(12.3), PInches(0.5), subtitle, PPt(14), PGREY, True)
        # footer
        txt(s, PInches(0.5), PInches(7.05), PInches(9), PInches(0.35), "Azure Landing Zone · Kickoff", PPt(9), PGREY)
        return s

    # --- Titel ---
    s = prs.slides.add_slide(blank)
    add_rect(s, 0, 0, SW, SH, PDARK)
    add_rect(s, 0, PInches(2.7), SW, PInches(0.08), PBLUE)
    txt(s, PInches(0.8), PInches(2.85), PInches(11.7), PInches(1.2), "Azure Landing Zone", PPt(48), PWHITE, True)
    txt(s, PInches(0.85), PInches(4.0), PInches(11.7), PInches(0.7), "Architektur, Umsetzungsstand & Beratung", PPt(22), PRGB(0x9F, 0xD3, 0xFF))
    txt(s, PInches(0.85), PInches(6.4), PInches(11.7), PInches(0.5), f"Kickoff · {DATE}", PPt(14), PRGB(0xB8,0xC4,0xD9))

    # --- Agenda ---
    s = content_slide("Agenda")
    bullets(s, PInches(0.7), PInches(1.5), PInches(12), PInches(5.4), [
        "Was ist eine Azure Landing Zone & Ziele",
        "Zielarchitektur und Management-Group-Hierarchie",
        "Domänen: Governance, Identity, Management, Security, Connectivity, Landing Zones",
        "Infrastructure as Code & CI/CD",
        "Umsetzungsstand & Roadmap",
        "Entscheidungs- und Beratungspunkte (gemeinsam)",
        "Nächste Schritte / Smoke Run",
    ], size=PPt(18))

    # --- Was ist ALZ ---
    s = content_slide("Was ist eine Azure Landing Zone?")
    bullets(s, PInches(0.7), PInches(1.5), PInches(12), PInches(5.4), [
        "Standardisiertes, richtliniengesteuertes Fundament für Workloads in Azure",
        "Liefert von Tag 1: Governance, Netzwerk, Identität, Security, Monitoring",
        ("Skalierungseinheit ist die Subscription – Workloads in dedizierten Landing Zones", 1),
        ("Leitplanken zentral per Azure Policy, nicht pro Ressource", 1),
        "Vollständig als Code (Bicep / Azure Verified Modules), per Pipeline reproduzierbar",
        "Ergebnis: schneller, sicherer, konsistenter Onboarding-Prozess für neue Workloads",
    ], size=PPt(17))

    # --- Prinzipien ---
    s = content_slide("Design-Prinzipien")
    bullets(s, PInches(0.7), PInches(1.5), PInches(12), PInches(5.4), [
        "Richtliniengesteuerte Governance (Guardrails auf MG-Ebene)",
        "Einheitliche Steuerungsebene & zentrales Logging",
        "Sicherheit von Grund auf (Defender, Segmentierung, Private DNS)",
        "Automatisierung & Wiederholbarkeit (IaC, What-If, CI/CD)",
        "Modulare Erweiterbarkeit je Domäne",
    ], size=PPt(18))

    # --- Architektur (Hierarchie) ---
    s = content_slide("Zielarchitektur – Management-Group-Hierarchie")
    tb = s.shapes.add_textbox(PInches(0.7), PInches(1.4), PInches(12), PInches(5.5))
    tf = tb.text_frame; tf.word_wrap = True
    tree = ("Tenant Root\n"
            "└─ alz (Intermediate Root)\n"
            "    ├─ alz-platform → connectivity · identity · management · security\n"
            "    ├─ alz-landingzones → corp · online · local\n"
            "    ├─ alz-sandbox (lockere Policies)\n"
            "    └─ alz-decommissioned (gesperrt)")
    p = tf.paragraphs[0]; r = p.add_run(); r.text = tree
    r.font.name = 'Consolas'; r.font.size = PPt(18); r.font.color.rgb = PDARK
    txt(s, PInches(0.7), PInches(6.2), PInches(12), PInches(0.6),
        "Primär: Germany West Central · Sekundär: North Europe", PPt(13), PGREY, True)

    # --- Domänen-Folien ---
    s = content_slide("Governance", "Management Groups · Policy · RBAC")
    bullets(s, PInches(0.7), PInches(1.7), PInches(12), PInches(5.0), [
        "MG-Hierarchie per Bicep auf Tenant-Ebene",
        "Guardrails: Allowed Locations · Require-RG-Tag · Storage-HTTPS (Deny)",
        "Corp: keine Public IPs an NICs · Decommissioned: Neuanlage gesperrt · Sandbox: Tag-Ausnahme",
        "RBAC-Modul: Owner/Contributor/Reader an Entra-Gruppen je MG (Object-IDs durch Kunde)",
        "Erweiterbar auf das vollständige ALZ-Policy-Set / Compliance-Frameworks",
    ], size=PPt(17))

    s = content_slide("Identity", "Plattform-Domäne (Roadmap)")
    bullets(s, PInches(0.7), PInches(1.7), PInches(12), PInches(5.0), [
        "Management Group alz-platform-identity & Identity-Subscription vorgesehen",
        "Geplant: Entra-ID-Diagnose → Log Analytics, rollenbasierte Zugriffe",
        "Optional: hybride Anbindung / Domänendienste je nach Anforderung",
        ("Ausprägung wird im Kickoff abgestimmt", 1),
    ], size=PPt(17))

    s = content_slide("Management & Monitoring", "Zentrale Protokollierung")
    bullets(s, PInches(0.7), PInches(1.7), PInches(12), PInches(5.0), [
        "Log Analytics Workspace (365 Tage Aufbewahrung)",
        "Data Collection Rules: VM Insights · Change Tracking · Defender-for-SQL",
        "User-Assigned Managed Identity",
        "Microsoft Sentinel & Automation Account per Schalter zuschaltbar",
    ], size=PPt(17))

    s = content_slide("Security", "Microsoft Defender for Cloud")
    bullets(s, PInches(0.7), PInches(1.7), PInches(12), PInches(5.0), [
        "Defender-Pläne: VMs · Storage · Key Vault · ARM · Container · App Service · SQL · DB",
        "Security Contacts mit Alarm-Benachrichtigung (Schweregrad-Schwelle)",
        "Activity-Log je Subscription → Log Analytics (Administrative, Security, Policy …)",
        "Tier Standard/Free konfigurierbar · Sentinel-Onboarding vorbereitet",
    ], size=PPt(17))

    s = content_slide("Connectivity", "Hub-and-Spoke")
    bullets(s, PInches(0.7), PInches(1.7), PInches(12), PInches(5.0), [
        "Hub-VNets: 10.0.0.0/22 (GWC) & 10.1.0.0/22 (NE), bidirektional gepeert",
        "Azure Firewall + Policy (DNS-Proxy, Azure-DNS, NTP, AzureCloud, Windows-Update; sonst Deny)",
        "Azure Bastion · 37 Private DNS Zones · DNS Private Resolver (optional)",
        "Spokes leiten ausgehenden Verkehr per Route Table über die Firewall",
        "VPN/ExpressRoute-Gateway & DDoS vorbereitet (standardmäßig aus)",
    ], size=PPt(16))

    s = content_slide("Landing Zones & Subscription Vending")
    bullets(s, PInches(0.7), PInches(1.7), PInches(12), PInches(5.0), [
        "Spoke-VNet je Workload: Route Table → Firewall, Hub-Peering, Private-DNS-Links",
        "Segmente: corp (intern) · online (internetseitig) · local (souverän)",
        "Subscription Vending (AVM): automatische Platzierung in die richtige MG",
        "Default Placement-Modus · Neuanlage optional (EA/MCA-Billing)",
    ], size=PPt(17))

    s = content_slide("Infrastructure as Code & CI/CD")
    bullets(s, PInches(0.7), PInches(1.7), PInches(12), PInches(5.0), [
        "Bicep + Azure Verified Modules (Microsoft-Registry)",
        "deploy.ps1: gestaffelte Schritte + optionale Schalter (Spoke, Vending, Security)",
        "GitHub Actions: validate · what-if · preflight · deploy (nach Scope gated)",
        "Passwortlose OIDC-Anmeldung (Federated Identity), Umgebung 'production'",
        "Alle Templates bauen fehlerfrei (0 Errors / 0 Warnings)",
    ], size=PPt(17))

    # --- Status ---
    s = content_slide("Umsetzungsstand")
    rows = [
        ("Management Groups, Governance, RBAC", "Umgesetzt"),
        ("Logging / Monitoring", "Umgesetzt"),
        ("Security-Baseline (Defender, Contacts, Activity-Log)", "Umgesetzt"),
        ("Hub-Networking, Firewall, Bastion, DNS, Peering", "Umgesetzt"),
        ("Spoke-Template & Subscription Vending", "Umgesetzt"),
        ("CI/CD + OIDC", "Umgesetzt"),
        ("Identity-Ressourcen / Sentinel-Connectors", "Roadmap"),
        ("VPN/ExpressRoute · DDoS · Virtual WAN", "Vorbereitet / optional"),
    ]
    tbl = s.shapes.add_table(len(rows)+1, 2, PInches(0.7), PInches(1.5), PInches(12), PInches(5.2)).table
    tbl.columns[0].width = PInches(8.6); tbl.columns[1].width = PInches(3.4)
    for j, htxt in enumerate(["Domäne", "Status"]):
        c = tbl.cell(0, j); c.text = htxt
        c.fill.solid(); c.fill.fore_color.rgb = PBLUE
        c.text_frame.paragraphs[0].runs[0].font.color.rgb = PWHITE
        c.text_frame.paragraphs[0].runs[0].font.bold = True
        c.text_frame.paragraphs[0].runs[0].font.size = PPt(14)
    for i, (a, b) in enumerate(rows, start=1):
        for j, val in enumerate((a, b)):
            c = tbl.cell(i, j); c.text = val
            r0 = c.text_frame.paragraphs[0].runs[0]; r0.font.size = PPt(12)
            r0.font.color.rgb = PDARK if j == 0 else (PBLUE if val == "Umgesetzt" else PGREY)
            if j == 1: r0.font.bold = True

    # --- Roadmap ---
    s = content_slide("Roadmap / nächste Schritte")
    bullets(s, PInches(0.7), PInches(1.6), PInches(12), PInches(5.2), [
        "Smoke Run im Kunden-Tenant (What-If → MGs → Logging → Networking)",
        "Identity-Domäne ausgestalten (Entra-Diagnose, hybride Anbindung)",
        "Sentinel-Onboarding (Data Connectors, Analyseregeln)",
        "On-Prem-Konnektivität aktivieren (VPN / ExpressRoute)",
        "Governance bei Bedarf auf volles ALZ-Policy-Set erweitern",
        "Härtung: Resource Locks, erweiterte Diagnostics, Cost Management",
    ], size=PPt(17))

    # --- Beratungspunkte ---
    s = content_slide("Entscheidungs- & Beratungspunkte", "Gemeinsam im Kickoff")
    bullets(s, PInches(0.7), PInches(1.7), PInches(6.0), PInches(5.0), [
        "Netzwerk-Topologie (Hub-Spoke vs. vWAN)",
        "IP-Adresskonzept / On-Prem-Overlap",
        "Regionen & Datenresidenz",
        "On-Prem-Anbindung: VPN vs. ExpressRoute",
        "DDoS Protection (Kostenfaktor)",
        "Identity: Entra-only / hybrid",
    ], size=PPt(15))
    bullets(s, PInches(6.9), PInches(1.7), PInches(5.8), PInches(5.0), [
        "RBAC-Modell & Entra-Gruppen (PIM)",
        "Policy-Tiefe / Compliance-Frameworks",
        "Defender-Tier (Standard vs. Free)",
        "Sentinel-Onboarding",
        "Subscription Vending: Placement vs. Neuanlage",
        "Log-Aufbewahrung & Kosten",
    ], size=PPt(15))

    # --- Abschluss ---
    s = prs.slides.add_slide(blank)
    add_rect(s, 0, 0, SW, SH, PDARK)
    add_rect(s, 0, PInches(3.0), SW, PInches(0.08), PBLUE)
    txt(s, PInches(0.8), PInches(3.15), PInches(11.7), PInches(1.0), "Vielen Dank – Fragen & Diskussion", PPt(34), PWHITE, True)
    txt(s, PInches(0.85), PInches(4.3), PInches(11.7), PInches(0.6), "Nächster Schritt: Smoke Run im Kunden-Tenant (risikofrei, beginnend mit What-If)", PPt(16), PRGB(0x9F,0xD3,0xFF))

    path = f"{OUT}/Azure-Landing-Zone-Kickoff.pptx"
    prs.save(path)
    return path

if __name__ == "__main__":
    d = build_docx()
    p = build_pptx()
    print("DOCX:", d)
    print("PPTX:", p)
