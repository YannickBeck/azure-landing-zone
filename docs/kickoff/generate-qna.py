# -*- coding: utf-8 -*-
"""Generiert ein Q&A-Vorbereitungsdokument (erwartete Fragen + Antworten) fuer den ALZ-Kickoff."""
from docx import Document
from docx.shared import Pt, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

OUT = "/home/user/azure-landing-zone/docs/kickoff"
DATE = "15.06.2026"

BLUE = RGBColor(0x00, 0x78, 0xD4)
DARK = RGBColor(0x24, 0x3A, 0x5E)
GREY = RGBColor(0x60, 0x5E, 0x5C)
RED  = RGBColor(0xC0, 0x39, 0x2B)
GREEN= RGBColor(0x2E, 0x7D, 0x32)


def shade_cell(cell, hex_color):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear'); shd.set(qn('w:color'), 'auto'); shd.set(qn('w:fill'), hex_color)
    tcPr.append(shd)


def set_cell_text(cell, text, bold=False, color=None, size=9.5, white=False):
    cell.text = ""
    p = cell.paragraphs[0]; p.paragraph_format.space_after = Pt(2); p.paragraph_format.space_before = Pt(2)
    r = p.add_run(text); r.bold = bold; r.font.size = Pt(size)
    if white: r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
    elif color: r.font.color.rgb = color


def add_table(doc, headers, rows, widths=None):
    t = doc.add_table(rows=1, cols=len(headers)); t.style = 'Light Grid Accent 1'
    for i, h in enumerate(headers):
        set_cell_text(t.rows[0].cells[i], h, bold=True, white=True); shade_cell(t.rows[0].cells[i], '0078D4')
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


def body(doc, text, color=None, italic=False):
    p = doc.add_paragraph(); p.paragraph_format.space_after = Pt(6)
    r = p.add_run(text); r.italic = italic
    if color: r.font.color.rgb = color
    return p


def qa(doc, frage, antworten, heikel=False):
    """Eine Frage (fett, blau) + Antwort-Bullets. heikel=True markiert rot."""
    p = doc.add_paragraph(); p.paragraph_format.space_before = Pt(8); p.paragraph_format.space_after = Pt(2)
    if heikel:
        m = p.add_run("[heikel]  "); m.bold = True; m.font.color.rgb = RED; m.font.size = Pt(9)
    r = p.add_run("F:  " + frage); r.bold = True; r.font.color.rgb = BLUE; r.font.size = Pt(11)
    for a in antworten:
        bp = doc.add_paragraph(style='List Bullet'); bp.paragraph_format.space_after = Pt(2)
        run = bp.add_run(a); run.font.size = Pt(10.5); run.font.color.rgb = DARK


def section(doc, title):
    doc.add_heading(title, level=1)


def build():
    doc = Document()
    n = doc.styles['Normal']; n.font.name = 'Calibri'; n.font.size = Pt(10.5)
    for lvl, col, sz in [('Heading 1', DARK, 15), ('Heading 2', BLUE, 12.5)]:
        st = doc.styles[lvl]; st.font.color.rgb = col; st.font.name = 'Calibri'; st.font.size = Pt(sz)

    # Titel
    for _ in range(3): doc.add_paragraph()
    t = doc.add_paragraph(); t.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = t.add_run("Azure Landing Zone"); r.bold = True; r.font.size = Pt(28); r.font.color.rgb = BLUE
    s = doc.add_paragraph(); s.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = s.add_run("Q&A-Vorbereitung – Erwartete Fragen & Antworten"); r.font.size = Pt(15); r.font.color.rgb = DARK
    s2 = doc.add_paragraph(); s2.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = s2.add_run("Kickoff mit Technikern & Netzwerkern des Kunden"); r.font.size = Pt(11); r.font.color.rgb = GREY
    for _ in range(6): doc.add_paragraph()
    m = doc.add_paragraph(); m.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = m.add_run(f"Stand: {DATE} · internes Vorbereitungsdokument"); r.font.size = Pt(10); r.font.color.rgb = GREY
    doc.add_page_break()

    # Nutzung
    section(doc, "So nutzt du dieses Dokument")
    body(doc, "Dieses Deck sammelt Fragen, die dir die technischen Ansprechpartner und Netzwerker des Kunden "
              "voraussichtlich stellen – jeweils mit einer kompakten, fachlich belastbaren Antwort. Mit "
              "[heikel] markierte Fragen bergen ein Risiko (Kosten, Versprechen, Fallstrick): hier ehrlich "
              "bleiben und ggf. „klären wir im Detail-Design“ sagen, statt dich festzulegen.")
    body(doc, "Goldene Regel: Was umgesetzt ist, selbstbewusst zeigen. Was Roadmap ist, klar als Roadmap "
              "benennen. Bei IP-/DNS-/Identity-Themen erst ihren Bestand erfragen, dann zusagen.", color=GREY, italic=True)

    # A. Strategie
    section(doc, "A. Strategie & Architektur")
    qa(doc, "Folgt das der offiziellen Microsoft-ALZ-Referenz?",
       ["Ja. Management-Group-Hierarchie, Hub-and-Spoke, Subscription-Demokratisierung und Policy-Guardrails "
        "folgen dem Microsoft-ALZ-Referenzmodell. Umgesetzt mit Bicep auf Basis der Azure Verified Modules (AVM)."])
    qa(doc, "Warum Hub-and-Spoke und nicht Virtual WAN?",
       ["Hub-and-Spoke ist transparenter, günstiger im Einstieg und genügt für eine bis wenige Regionen.",
        "Virtual WAN ist als Skeleton vorbereitet – sinnvoll bei vielen Regionen/Standorten oder globalem Transit. "
        "Wechsel ist eine bewusste Architektur-Entscheidung, kein technisches Hindernis."], heikel=True)
    qa(doc, "Warum Bicep und nicht Terraform?",
       ["Bicep ist Azure-nativ, ohne State-Management, mit What-If und AVM-Modulen direkt aus der Microsoft-Registry.",
        "Terraform wäre möglich – Bicep reduziert hier Komplexität und Tooling-Abhängigkeiten."])
    qa(doc, "Was ist heute schon umgesetzt, was nicht?",
       ["Umgesetzt: Management Groups, Governance/Policy/RBAC, Logging, Security-Baseline, Hub-Networking "
        "(Firewall, Bastion, DNS, Peering), Spoke-Template, Subscription Vending, CI/CD mit OIDC.",
        "Roadmap: Identity-Ressourcen, Sentinel-Connectors, aktive VPN/ER-Gateways, WAF-Ingress, DDoS."])
    qa(doc, "Sind wir nach dem Aufbau an euch gebunden?",
       ["Nein. Alles ist als Code im Git-Repo, dokumentiert und reproduzierbar. Der Kunde kann es selbst "
        "betreiben oder weiterentwickeln."])

    # B. Governance
    section(doc, "B. Governance, Policy & RBAC")
    qa(doc, "Welche Policies greifen ab Tag 1?",
       ["Auf alz (Root): erlaubte Regionen (Deny), Pflicht-Tag auf Resource Groups (Deny), HTTPS-Pflicht für Storage (Deny).",
        "Auf landingzones-corp: keine Public IPs an NICs. Auf decommissioned: jede Neuanlage gesperrt. "
        "Auf sandbox: Tag-Pflicht gelockert (Exemption)."])
    qa(doc, "Was, wenn eine Policy ein legitimes Deployment blockiert?",
       ["Gezielte Policy Exemptions auf MG-/Subscription-/RG-Ebene – versioniert im Code, nicht als Klick im Portal. "
        "Das Sandbox-Beispiel zeigt das Muster bereits."])
    qa(doc, "Ist das schon das vollständige ALZ-Policy-Set?",
       ["Nein – bewusst ein schlankes, wirksames Custom-Set zum Start. Erweiterbar auf das volle ALZ-Set bzw. "
        "Compliance-Initiativen (ISO 27001, CIS, BSI C5), sobald Compliance-Pflichten feststehen."], heikel=True)
    qa(doc, "Wie funktioniert RBAC – wer bekommt was?",
       ["Wiederverwendbares Modul weist Built-in-Rollen (Owner/Contributor/Reader) an Entra-ID-Gruppen je "
        "Management Group zu. Object-IDs werden injiziert – keine Hardcodes. Leeres Set = gefahrloser No-Op.",
        "Konkrete Gruppen-Object-IDs braucht ihr vom Kunden."])
    qa(doc, "Nutzt ihr PIM / Just-in-Time-Zugriff?",
       ["PIM ist empfohlen und kompatibel (Eligible-Zuweisungen auf die Gruppen). Aktivierung ist eine "
        "Kundenentscheidung im RBAC-Modell."])

    # C. Netzwerk
    section(doc, "C. Netzwerk & Connectivity (Schwerpunkt Netzwerker)")
    qa(doc, "Warum /22 für den Hub – reicht das?",
       ["/22 (1024 Adressen) deckt AzureFirewallSubnet (/26), AzureBastionSubnet (/26), GatewaySubnet (/27) "
        "und Resolver-Subnetze mit Reserve ab.",
        "Bei sehr vielen Spokes/Diensten Adressplan früh größer wählen. Bestand on-prem entscheidet."], heikel=True)
    qa(doc, "Ist das VNet-Peering transitiv?",
       ["Nein. VNet-Peering ist nicht transitiv. Spoke-zu-Spoke läuft per UDR über die Hub-Firewall (Hairpin), "
        "nicht direkt zwischen Spokes."])
    qa(doc, "Standard- oder Premium-Firewall?",
       ["Aktuell Standard. Premium bietet IDPS, TLS-Inspection und URL-Filtering – ca. doppelte Kosten.",
        "Frage zurück: Erwartet ihr Layer-7-Inspection/TLS-Aufbruch? Dann planen wir Premium ein."], heikel=True)
    qa(doc, "Wie sieht das Egress-Regelwerk aus?",
       ["Default-Deny. Erlaubt sind nur DNS-Proxy, Azure-DNS, NTP, AzureCloud-HTTPS und Windows-Update.",
        "Alle Workload-spezifischen Freigaben kommen kontrolliert und versioniert in die Firewall Policy."])
    qa(doc, "Wie bindet ihr On-Prem an – VPN oder ExpressRoute?",
       ["Beides vorbereitet (Gateways deaktiviert). VPN für schnellen/günstigen Start, ExpressRoute für "
        "Bandbreite/SLA/dedizierte Leitung.",
        "Eure Entscheidung nach Bandbreite, SLA und Budget – plus GatewaySubnet ist reserviert."], heikel=True)
    qa(doc, "Unterstützt ihr BGP? Welches ASN nutzt Azure?",
       ["Ja, BGP wird unterstützt. Azure VPN Gateway nutzt standardmäßig ASN 65515 – euer On-Prem-ASN darf "
        "nicht kollidieren. ASN bitte vorab nennen."])
    qa(doc, "Wie verhindert ihr asymmetrisches Routing bei ExpressRoute + Firewall?",
       ["Über saubere UDR-/BGP-Propagation und ggf. Forced Tunneling. Das lösen wir im Netzwerk-Detail-Design "
        "sauber – ist ein bekannter Fallstrick, kein Showstopper."], heikel=True)
    qa(doc, "Ist Forced Tunneling (alles über On-Prem) möglich?",
       ["Ja – per UDR/BGP wird der Egress über das Gateway zurück nach on-prem gezwungen. Bewusst zu planen, "
        "da es die Firewall-Egress-Logik und ggf. Internetzugang verändert."])
    qa(doc, "Wie segmentiert ihr – NSG oder Firewall?",
       ["Beides komplementär: Azure Firewall für Nord-Süd und zentrale L3/L4(-L7)-Kontrolle, NSGs/ASGs für "
        "Ost-West auf Subnetz-/NIC-Ebene innerhalb der Spokes."])
    qa(doc, "Verfügbarkeitszonen / Hochverfügbarkeit?",
       ["Azure Firewall und Gateways können zonenredundant betrieben werden; zwei Hub-Regionen (GWC + NE) sind "
        "bidirektional gepeert. Konkrete Zonen-/HA-Stufe nach Verfügbarkeits-Anforderung."])
    qa(doc, "Wie funktioniert Internet-Ingress für öffentliche Workloads?",
       ["Für die Online-Landing-Zone ist Application Gateway/WAF vorgesehen – aktuell Roadmap, noch nicht gebaut.",
        "Egress läuft über die Firewall (SNAT); Ingress-Design je nach Workload (WAF, Front Door)."], heikel=True)
    qa(doc, "Wie hoch ist der Firewall-Durchsatz?",
       ["Azure Firewall skaliert automatisch in den zweistelligen Gbit/s-Bereich; SNAT-Ports sind die übliche "
        "Grenze und werden über mehrere Public IPs erweitert."])
    qa(doc, "DDoS-Schutz?",
       ["DDoS Network Protection ist vorbereitet, standardmäßig aus (~€2.500/Monat). Für internetseitige "
        "Workloads empfohlen, sonst pro öffentlicher IP der Basisschutz."], heikel=True)

    # D. DNS
    section(doc, "D. DNS & Namensauflösung")
    qa(doc, "Wie löst ihr Private Endpoints auf?",
       ["37 zentrale Private DNS Zones (privatelink.*) am Hub, mit den VNets verknüpft. Private Endpoints "
        "registrieren sich automatisch."])
    qa(doc, "Wie funktioniert hybride Namensauflösung zu On-Prem?",
       ["Über den DNS Private Resolver (Code vorhanden, per Default aus): Inbound-Endpoint für Azure→On-Prem-"
        "Anfragen, Outbound mit Forwarding-Regeln zu euren On-Prem-DNS-Servern.",
        "Wir brauchen: autoritative On-Prem-DNS-Server und die Domänen für Conditional Forwarding."], heikel=True)
    qa(doc, "DNS Private Resolver vs. eigene DNS-VMs?",
       ["Resolver ist PaaS, zonenredundant, kein VM-Betrieb – günstiger und wartungsärmer als ein DC/DNS-VM-Paar. "
        "Wir empfehlen den Resolver, sofern keine speziellen On-Prem-Abhängigkeiten dagegensprechen."])
    qa(doc, "Warum DNS-Proxy auf der Firewall?",
       ["Damit FQDN-basierte Firewall-Regeln konsistent auflösen und DNS zentral über die Firewall läuft – "
        "einheitlicher Auflösungspfad für alle Spokes."])

    # E. Security
    section(doc, "E. Security")
    qa(doc, "Welche Defender-Pläne, welcher Tier?",
       ["10 Pläne: VMs, Storage, Key Vault, ARM, Container, App Service, SQL, SQL-on-VM, Open-Source-DB, Cosmos DB.",
        "Tier je Plan konfigurierbar (Standard/Free). Standard für Produktion empfohlen – kostet pro Ressource."], heikel=True)
    qa(doc, "Habt ihr Sentinel / ein SIEM?",
       ["Sentinel-Onboarding ist über einen Schalter am Log Analytics Workspace vorbereitet. Data Connectors "
        "und Analyseregeln sind Roadmap und werden bei SIEM-Bedarf ausgestaltet."])
    qa(doc, "Wie werden Activity Logs zentralisiert?",
       ["Pro Subscription per Diagnostic Settings ins zentrale Log Analytics (Administrative, Security, Policy, "
        "ResourceHealth u. a.)."])
    qa(doc, "Wie lange werden Logs aufbewahrt?",
       ["Standard 365 Tage (PerGB2018). Anpassbar nach Compliance – längere Retention/Archiv treibt Kosten."])

    # F. Identity
    section(doc, "F. Identity")
    qa(doc, "Entra-only oder hybrid?",
       ["MG alz-platform-identity und eine Identity-Subscription sind vorgesehen. Ausprägung (Entra-only, "
        "hybrid, AD DS in Azure) ist Roadmap und richtet sich nach euren Anforderungen.",
        "Frage zurück: Habt ihr On-Prem-AD, das hybrid angebunden werden soll?"], heikel=True)
    qa(doc, "Diagnostiziert ihr Entra ID nach Log Analytics?",
       ["Geplant: Entra-Diagnose-Logs (Sign-ins, Audit) ins zentrale Log Analytics. Teil der Identity-Roadmap."])

    # G. Betrieb / IaC
    section(doc, "G. Betrieb, IaC & CI/CD")
    qa(doc, "Wie deployt ihr – manuell oder Pipeline?",
       ["GitHub Actions: Jobs validate (Build), what-if (Vorschau), preflight (Secret-Check), deploy (nach Scope "
        "gated). Lokal optional über deploy.ps1."])
    qa(doc, "Wie testet ihr Änderungen vorab?",
       ["Azure What-If zeigt vor jedem Deployment exakt, was sich ändert – ohne eine Ressource zu erstellen. "
        "Risikofrei und kostenlos."])
    qa(doc, "Wie läuft die Pipeline-Anmeldung an Azure?",
       ["Passwortlos über OIDC Federated Identity – keine gespeicherten Secrets/Zertifikate. Vier GitHub-Secrets, "
        "drei Federated Credentials, Umgebung 'production' mit Schutzregeln."])
    qa(doc, "Was, wenn ein Deployment fehlschlägt – Rollback?",
       ["Bicep ist deklarativ/idempotent: erneutes Deployment des letzten guten Stands stellt den Soll-Zustand "
        "wieder her. What-If vorab minimiert Fehldeployments."])
    qa(doc, "Wie verhindert ihr Configuration Drift?",
       ["Git ist die Quelle der Wahrheit; Re-Deployment korrigiert manuelle Änderungen. Policies (Deny) verhindern "
        "viele Drifts bereits an der Quelle."])

    # H. Kosten
    section(doc, "H. Kosten")
    body(doc, "Richtwerte (Region Germany West Central, ohne Workloads) – immer als „circa, abhängig von Nutzung“ kommunizieren:")
    add_table(doc, ["Komponente", "Grundkosten/Monat", "Status"], [
        ["Management Groups, Policy, RBAC", "kostenlos", "an"],
        ["Log Analytics (geringer Ingress)", "~0 (5 GB frei)", "an"],
        ["Private DNS Zones (37)", "~€15", "an"],
        ["Azure Firewall (Standard)", "~€1.100", "an"],
        ["Azure Bastion", "~€120", "an"],
        ["Public IPs", "~€6", "an"],
        ["VPN/ExpressRoute Gateway", "ab ~€140 / ~€280", "aus"],
        ["DDoS Network Protection", "~€2.500", "aus"],
        ["Defender Standard (je Ressource)", "ab ~€13/Server", "konfigurierbar"],
    ], widths=[3.2, 2.2, 1.6])
    qa(doc, "Was kostet die Plattform-Grundlast im Monat?",
       ["Mit Firewall + Bastion grob ~€1.250–1.300/Monat Grundlast.",
        "Ohne Firewall/Bastion (nur MGs + Logging + DNS) nur ~€15–30/Monat – gut für eine kostenarme Startphase."], heikel=True)
    qa(doc, "Was sind die größten Kostentreiber?",
       ["Azure Firewall, Bastion, optional DDoS und Defender-Standard. Alles bewusst schaltbar – nichts Teures "
        "läuft ungewollt mit (DDoS/Gateways sind aus)."])
    qa(doc, "Wie können wir Kosten optimieren?",
       ["Firewall-SKU nach Bedarf (Standard statt Premium), Bastion nur wo nötig, Defender selektiv pro Plan, "
        "Log-Retention nach Compliance, Reserved Instances/Savings Plans für Workloads."])

    # I. Migration
    section(doc, "I. Workloads & Migration")
    qa(doc, "Wie kommt unsere erste Workload in die Landing Zone?",
       ["Subscription in die passende MG platzieren (Vending), Spoke-VNet ausrollen (Route Table → Firewall, "
        "Hub-Peering, DNS-Links), dann Workload deployen. Policies greifen automatisch."])
    qa(doc, "Was bedeutet Subscription Vending konkret?",
       ["AVM-Pattern, das Subscriptions automatisiert in die richtige MG platziert. Standard: Placement bestehender "
        "Subscriptions (keine Billing-Rechte nötig). Optional: Neuanlage per EA/MCA."])
    qa(doc, "Können wir bestehende Subscriptions einbinden?",
       ["Ja – Placement-Modus verschiebt bestehende Subscriptions in die Hierarchie. Sie erben sofort Policies "
        "und RBAC der Ziel-MG."])
    qa(doc, "Wir haben aktuell nur eine Subscription – geht das?",
       ["Ja. Für Start/Smoke-Run zeigen alle Plattform-Rollen auf dieselbe Subscription; getrennte Resource "
        "Groups vermeiden Kollisionen. Multi-Subscription ist das Produktiv-Ziel, kein Muss zum Start."])

    # Gegenfragen
    section(doc, "J. Gegenfragen, die DU stellen solltest")
    for q in [
        "Welche IP-Bereiche sind on-prem belegt? (Überlappungsfreiheit für Hubs/Spokes)",
        "VPN oder ExpressRoute – Bandbreite, SLA, Provider, Redundanz?",
        "Euer On-Prem-ASN und ist BGP gewünscht?",
        "Wo liegen eure autoritativen DNS-Server und welche Domänen brauchen Forwarding?",
        "Erwartet ihr L7-Inspection/TLS-Aufbruch an der Firewall? (Standard vs. Premium)",
        "Habt ihr On-Prem-AD für hybride Identity?",
        "Welche Entra-Gruppen (Object-IDs) sollen welche Rollen je MG bekommen?",
        "Compliance-Pflichten (ISO/BSI/CIS), die die Policy-Tiefe bestimmen?",
        "EA/MCA vorhanden und wer hat Billing-Rechte? (Subscription-Neuanlage)",
        "Wer darf Elevated Access am Tenant Root aktivieren? (MG-Erstellung)",
    ]:
        bp = doc.add_paragraph(style='List Bullet'); bp.paragraph_format.space_after = Pt(3)
        run = bp.add_run(q); run.font.size = Pt(10.5); run.font.color.rgb = DARK

    # Top-Fallen
    section(doc, "K. Fünf Sätze, die du parat haben solltest")
    for q, col in [
        ("„What-If zeigt jede Änderung vorab – ohne Kosten, ohne Risiko.“", GREEN),
        ("„Was teuer ist (Firewall, DDoS), benennen wir transparent und schalten es bewusst.“", GREEN),
        ("„Peering ist nicht transitiv – Spoke-zu-Spoke läuft kontrolliert über die Firewall.“", GREEN),
        ("„Das lösen wir sauber im Netzwerk-Detail-Design.“ (bei tiefen Routing-/DNS-Fragen)", DARK),
        ("„Das ist Roadmap, nicht live.“ (bei Identity, Sentinel-Connectors, WAF, Gateways)", DARK),
    ]:
        p = doc.add_paragraph(); p.paragraph_format.space_after = Pt(4)
        r = p.add_run("•  " + q); r.font.size = Pt(11); r.bold = True; r.font.color.rgb = col

    # Footer
    sec = doc.sections[0]
    f = sec.footer.paragraphs[0]; f.alignment = WD_ALIGN_PARAGRAPH.CENTER
    fr = f.add_run("Azure Landing Zone – Q&A-Vorbereitung · intern · vertraulich"); fr.font.size = Pt(8); fr.font.color.rgb = GREY

    path = f"{OUT}/Azure-Landing-Zone-QnA-Vorbereitung.docx"
    doc.save(path)
    return path


if __name__ == "__main__":
    print("DOCX:", build())
