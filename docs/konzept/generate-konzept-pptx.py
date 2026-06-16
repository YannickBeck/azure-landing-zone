# -*- coding: utf-8 -*-
"""
Generiert das Bechtle-Kundenkonzept "Azure Landing Zone" als PowerPoint-Präsentation.

Basis-Vorlage : bechtle-brand/Powerpoint/Bechtle_Designvorlage_Grün_Teil1.pptx
Output        : Powerpoint/Azure-Landing-Zone-Konzept.pptx

Nutzung:
    python3 docs/konzept/generate-konzept-pptx.py

Abhängigkeit  : python-pptx  (pip install python-pptx)
"""

import os
from pptx import Presentation
from pptx.util import Pt

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATE  = os.path.join(BASE_DIR, "bechtle-brand", "Powerpoint",
                         "VORLAGE_Bechtle_Praesentation.pptx")
OUTPUT    = os.path.join(BASE_DIR, "Powerpoint", "Azure-Landing-Zone-Konzept.pptx")

KUNDE = "<KUNDE>"
DATE  = "16.06.2026"

# Layout-Indices im Slide-Master
L_TITLE   = 0   # Title Slide with Picture
L_AGENDA  = 4   # Agenda
L_DIVIDER = 6   # Divider Number / Icon
L_CONTENT = 14  # Titel und Inhalt

# Beziehungs-Namespace für r:id-Attribut
_NS_R = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}"


# ─────────────────────────────────────────────────────────────────────────────
# Hilfsfunktionen
# ─────────────────────────────────────────────────────────────────────────────

def clear_slides(prs):
    """Alle bestehenden Folien aus der Vorlage entfernen."""
    sld_id_lst = prs.slides._sldIdLst
    for sld_id in list(sld_id_lst):
        r_id = sld_id.get(_NS_R + "id")
        if r_id:
            try:
                prs.part.drop_rel(r_id)
            except Exception:
                pass
        sld_id_lst.remove(sld_id)


def sl(prs, idx):
    """Slide-Layout per Index aus dem ersten Master."""
    return prs.slide_masters[0].slide_layouts[idx]


def ph(slide, idx):
    """Platzhalter per Format-Index suchen."""
    for p in slide.placeholders:
        if p.placeholder_format.idx == idx:
            return p
    return None


def set_text(slide, ph_idx, text, size=None, bold=False):
    """Einfachen Text in einen Platzhalter schreiben."""
    p = ph(slide, ph_idx)
    if p is None:
        return
    tf = p.text_frame
    tf.clear()
    para = tf.paragraphs[0]
    run = para.add_run()
    run.text = text
    if size:
        run.font.size = Pt(size)
    if bold:
        run.font.bold = True


def set_bullets(slide, ph_idx, items, size=13):
    """
    Bullet-Punkte in einen Platzhalter schreiben.
    items: Liste von str oder (str, level)-Tupeln (level 0=Haupt, 1=Unter-Bullet).
    """
    p = ph(slide, ph_idx)
    if p is None:
        return
    tf = p.text_frame
    tf.clear()
    tf.word_wrap = True
    for i, item in enumerate(items):
        text, level = (item, 0) if isinstance(item, str) else item
        para = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        para.level = level
        run = para.add_run()
        run.text = text
        if size:
            run.font.size = Pt(size)


# ─────────────────────────────────────────────────────────────────────────────
# Folien-Bausteine
# ─────────────────────────────────────────────────────────────────────────────

def title_slide(prs):
    slide = prs.slides.add_slide(sl(prs, L_TITLE))
    set_text(slide, 0, "Azure Landing Zone")
    set_text(slide, 1, "Konzept und Umsetzungsfahrplan")
    set_text(slide, 15,
             f"{KUNDE}  ·  Bechtle GmbH & Co. KG  ·  {DATE}", size=10)
    return slide


def agenda_slide(prs):
    slide = prs.slides.add_slide(sl(prs, L_AGENDA))
    set_text(slide, 0, "Agenda")
    set_bullets(slide, 13, [
        "Management Summary",
        "1  ·  Ausgangslage und Zielbild",
        "2  ·  Methodik und Vorgehen",
        "3  ·  Zielarchitektur",
        "4  ·  Governance und Policies",
        "5  ·  Netzwerk-Architektur",
        "6  ·  Sicherheit",
        "7  ·  Monitoring und Logging",
        "8  ·  Identity und RBAC",
        "9  ·  Automatisierung und CI/CD",
        "10  ·  Kosten und Kostensteuerung",
        "11  ·  Roadmap und Phasen",
        "12  ·  Risiken und Entscheidungen",
        "13  ·  Ergänzende Randthemen",
        "14  ·  Nächste Schritte",
    ], size=13)
    return slide


def divider(prs, title, subtitle, facts=None):
    """Kapitel-Trenner-Folie (Divider Number / Icon)."""
    slide = prs.slides.add_slide(sl(prs, L_DIVIDER))
    set_text(slide, 0, title)
    set_text(slide, 1, subtitle)
    if facts:
        set_bullets(slide, 13, facts, size=12)
    return slide


def content(prs, breadcrumb, title, bullets, size=13):
    """Standard-Inhalts-Folie (Titel und Inhalt)."""
    slide = prs.slides.add_slide(sl(prs, L_CONTENT))
    set_text(slide, 1, breadcrumb)
    set_text(slide, 0, title)
    set_bullets(slide, 13, bullets, size=size)
    return slide


# ─────────────────────────────────────────────────────────────────────────────
# Hauptfunktion
# ─────────────────────────────────────────────────────────────────────────────

def build():
    prs = Presentation(TEMPLATE)
    clear_slides(prs)

    # ── 1. Titelfolie ────────────────────────────────────────────────────────
    title_slide(prs)

    # ── 2. Agenda ────────────────────────────────────────────────────────────
    agenda_slide(prs)

    # ── Management Summary ───────────────────────────────────────────────────
    divider(prs,
        "Management Summary",
        "Governance · Netzwerk · Sicherheit · Automatisierung – als IaC-Fundament",
        [
            "12 Management Groups",
            "149 Policy-Definitionen",
            "42 Initiativen  ·  123 Assignments",
            "22 AVM-Module",
            "18 Deploy-Stufen",
            "~€5.800/Monat (vollständig steuerbar)",
        ]
    )
    content(prs, "Management Summary", "Die vier Kernnutzen der Azure Landing Zone", [
        ("Governance & Policies: 149 Policy-Defs, 42 Initiativen, 123 Assignments – "
         "automatische Guardrails auf allen MG-Ebenen", 0),
        ("Netzwerk-Hub (Hub-and-Spoke): Azure Firewall, Bastion, Private DNS – "
         "sichere Konnektivität für alle Workloads", 0),
        ("Sicherheit & Defender: Microsoft Defender for Cloud automatisch via Policy aktiviert – "
         "keine manuelle Konfiguration", 0),
        ("IaC & Automatisierung: 18 Deploy-Stufen, OIDC (passwortlos), "
         "What-If vor Apply, Approval-Gate", 0),
        ("Kosten: Microsoft-Default ~€5.800/Monat  ↔  Pilot mit network_type: none ≈ €0", 0),
        ("Empfehlung: Pilot mit 1 Subscription, network_type: none, "
         "Policies im DoNotEnforce-Modus – Governance vom ersten Tag an", 0),
    ])

    # ── 1. Ausgangslage & Zielbild ───────────────────────────────────────────
    divider(prs,
        "1  ·  Ausgangslage und Zielbild",
        "Von der ersten Subscription zur skalierbaren Cloud-Grundstruktur"
    )
    content(prs, "Ausgangslage und Zielbild", "Warum eine Azure Landing Zone?", [
        ("Ausgangssituation: Azure-Einstieg ohne Governance-Modell – "
         "Ressourcen entstehen ad hoc, ohne einheitliche Leitplanken", 0),
        ("Chance: Von Anfang an auf industrieerprobter Basis aufbauen – "
         "statt technische Schulden durch spätere Nachrüstung", 0),
        ("Zielbild: Standardisierte, mandantenweite Grundstruktur als stabiles Fundament "
         "für alle künftigen Workloads", 0),
        ("12 MGs als strukturierter Verwaltungsrahmen für alle Subscriptions", 1),
        ("Vollständiges ALZ-Policy-Set für automatische Governance ohne manuelle Eingriffe", 1),
        ("Reproduzierbares IaC-Modell: audit-fähig, rückrollbar, nachvollziehbar", 1),
        ("Abgrenzung: ALZ = Fundament – Migration, Anwendungsentwicklung und "
         "Applikationsbetrieb sind eigenständige Folgeprojekte", 0),
    ])

    # ── 2. Methodik & Vorgehen ────────────────────────────────────────────────
    divider(prs,
        "2  ·  Methodik und Vorgehen",
        "Microsoft ALZ Bicep Accelerator – kein Eigenbau, sondern Microsoft-Standard"
    )
    content(prs, "Methodik und Vorgehen",
            "ALZ Bicep Accelerator + 18 Deployment-Stufen", [
        ("Microsoft-Standard: derselbe Accelerator, den Microsoft für tausende "
         "Enterprise-Kunden empfiehlt und pflegt", 0),
        ("Policy-Set komplett: 149 Definitionen, 42 Initiativen, 123 Assignments – "
         "automatisch aus MCR (Microsoft Container Registry)", 0),
        ("22 Azure Verified Modules (AVM): Microsoft-zertifizierte Bicep-Module, "
         "kein Eigenbau-IaC", 0),
        ("18 geordnete Deploy-Stufen: Governance (1–12) → RBAC (13–15) → "
         "Logging (16) → Netzwerk (17/18)", 0),
        ("OIDC Federated Identity: passwortlose Pipelines – keine Secrets oder "
         "Zertifikate", 0),
        ("What-If vor Apply: Pipeline zeigt geplante Änderungen zur Freigabe, "
         "bevor etwas ausgeführt wird", 0),
        ("Qualitätssicherung: bicep build aller 20 Templates offline; "
         "20/20 grün (Bicep 0.44.1)", 0),
    ])

    # ── 3. Zielarchitektur ────────────────────────────────────────────────────
    divider(prs,
        "3  ·  Zielarchitektur",
        "12 Management Groups + Hub-and-Spoke-Netzwerk in zwei Regionen"
    )
    content(prs, "Zielarchitektur", "Management Group Hierarchie (12 MGs)", [
        ("Tenant Root", 0),
        ("alz (Intermediate Root) – alle ALZ-Policies erben von hier", 1),
        ("alz-platform: connectivity · identity · management · security", 1),
        ("alz-platform-connectivity  → Hub-Netzwerk, Firewall, DNS", 1),
        ("alz-platform-identity      → Identity-Dienste (Entra, AD DS)", 1),
        ("alz-platform-management    → Logging, Monitoring, Operations", 1),
        ("alz-platform-security      → Security-Tooling, Defender", 1),
        ("alz-landingzones: corp · online · local", 1),
        ("alz-sandbox  ·  alz-decommissioned", 1),
        ("Region: Germany West Central (primär 10.0.0.0/22) + "
         "North Europe (sekundär 10.1.0.0/22)", 0),
        ("Subscription-Strategie: Single-Sub für Pilot → "
         "4 dedizierte Platform-Subs für Produktion", 0),
    ])

    # ── 4. Governance & Policies ──────────────────────────────────────────────
    divider(prs,
        "4  ·  Governance und Policies",
        "149 Policy-Definitionen · 42 Initiativen · 123 Assignments",
        [
            "9 MG-Ebenen mit Assignments",
            "5 Custom RBAC-Rollen",
            "DoNotEnforce → sanftes Onboarding",
        ]
    )
    content(prs, "Governance und Policies", "Das vollständige ALZ-Policy-Set", [
        ("Policy-Definitionen (Custom): 149 – Monitoring (55), Netzwerk (20), "
         "Storage (16), SQL (13), Guardrails je Dienst", 0),
        ("Policy-Set-Definitionen (Initiativen): 42 – Deploy-MDFC-Config, "
         "Deploy-Private-DNS-Zones, Enforce-Guardrails-* je Dienst", 0),
        ("Policy-Assignments: 123 – verteilt auf 9 MG-Ebenen; "
         "Kind-MGs erben zusätzlich", 0),
        ("alz-Root: 17  ·  alz-landingzones: 53  ·  alz-platform: 40  ·  "
         "alz-corp: 5  ·  weitere: 8", 1),
        ("5 Custom RBAC-Rollen: Subscription-Owner · Security-Ops · "
         "Network-Mgmt · App-Owners · Subnet-Contributor", 0),
        ("DoNotEnforce-Modus: Policies greifen (Compliance-Dashboard), "
         "blockieren aber nichts → sanftes Onboarding", 0),
        ("Stufenplan: Audit → selektiv Enabled → "
         "vollständiges Enforcement nach Remediation", 0),
    ])

    # ── 5. Netzwerk-Architektur ───────────────────────────────────────────────
    divider(prs,
        "5  ·  Netzwerk-Architektur",
        "Hub-and-Spoke · Bechtle-Empfehlung: 1 Region · Firewall Standard · ~€1.050/Monat"
    )
    content(prs, "Netzwerk-Architektur", "Hub-and-Spoke: Bechtle-Empfehlung vs. Microsoft-Default", [
        ("Bechtle-Empfehlung: 1× Hub-VNet GWC 10.0.0.0/22 – alle Kernfunktionen, "
         "eine Region, ~€1.050/Monat", 0),
        ("Microsoft-Default: 2× Hub-VNets (GWC + NE) – alle Dienste, beide Regionen, "
         "~€5.800/Monat", 0),
        ("Azure Firewall Standard (1×): ~€700/Monat  [Default: Premium 2× = ~€2.200]", 0),
        ("Azure Bastion Standard (1×): ~€120/Monat  [Default: 2× = €240]", 0),
        ("VPN Gateway VpnGw1AZ (1×): ~€140/Monat  [Default: 2× = €280]", 0),
        ("ExpressRoute Gateway: deaktiviert – bei ER-Leitung aktivieren [Default: 2× = €560]", 0),
        ("DDoS Protection: deaktiviert – bei internet-facing Workloads aktivieren [Default: €2.500]", 0),
        ("Private DNS Zones + DNS Resolver: aktiv – unveraendert  ~€40/Monat", 0),
    ])

    # ── 6. Sicherheit ─────────────────────────────────────────────────────────
    divider(prs,
        "6  ·  Sicherheit",
        "Defender for Cloud · Netzwerksegmentierung · Automatische Remediation"
    )
    content(prs, "Sicherheit", "Mehrschichtige Sicherheitsarchitektur", [
        ("Präventiv (Policies): Deny-Subnet-Without-Nsg, Deny-MgmtPorts-Internet, "
         "Deny-Public-IP, Deny-Public-Endpoints (Corp)", 0),
        ("Defender for Cloud: auto-aktiviert via Deploy-MDFC-Config-H224 auf "
         "alz-Root (DeployIfNotExists)", 0),
        ("Defender for Endpoint: Deploy-MDEndpoints auf allen VMs – "
         "im Defender Server-Plan enthalten", 0),
        ("MDFC Benchmarks: Microsoft Cloud Security Benchmark v1 + v2 "
         "(kostenlos, Audit)", 0),
        ("Activity Logs + Diagnose: alle Subscriptions und Ressourcen "
         "→ Log Analytics (via DINE-Policies)", 0),
        ("Backup: Deploy-VM-Backup sichert VMs ohne Backup-Tag automatisch "
         "in Recovery Vault", 0),
        ("Roadmap: Microsoft Sentinel als SIEM-Folgestufe "
         "(nicht Bestandteil der Landing Zone)", 0),
    ])

    # ── 7. Monitoring & Logging ───────────────────────────────────────────────
    divider(prs,
        "7  ·  Monitoring und Logging",
        "Zentraler Log Analytics Workspace + 3 Data Collection Rules"
    )
    content(prs, "Monitoring und Logging",
            "Zentrales Logging (AVM-Pattern avm/ptn/alz/ama:0.2.0)", [
        ("Log Analytics Workspace: law-alz-<region>, PerGB2018, "
         "365 Tage Retention", 0),
        ("3 Data Collection Rules: VM Insights · Change Tracking · "
         "Defender for SQL", 0),
        ("User-Assigned Managed Identity: mi-alz-<region> für passwortlose "
         "Policy-Remediation (DeployIfNotExists)", 0),
        ("DINE-Policies: jede neue VM verbindet sich automatisch mit LAW + DCRs – "
         "keine manuelle Konfiguration", 0),
        ("Deploy-Diag-LogsCat: leitet alle Diagnose-Kategorien aller Ressourcen "
         "in Log Analytics", 0),
        ("Kosten: 5 GB/Monat kostenlos; danach ~€2/GB; "
         "Automation Account optional (default: aus)", 0),
    ])

    # ── 8. Identity & RBAC ────────────────────────────────────────────────────
    divider(prs,
        "8  ·  Identity und RBAC",
        "5 Custom-Rollen + Entra-ID-Gruppen-basierte Zuweisungen"
    )
    content(prs, "Identity und RBAC", "5 Custom RBAC-Rollen", [
        ("Subscription-Owner (alz): delegierter Owner, eingeschränkt ohne volle "
         "Owner-Rechte (1 Action)  → Plattform-Admins", 0),
        ("Security-Operations (alz): horizontale Sicherheitssicht über alle "
         "Subscriptions (12 Actions)  → Security-Team", 0),
        ("Network-Management (alz): VNets, UDRs, NSGs, NVAs plattformweit "
         "(4 Actions)  → Netzwerk-Team", 0),
        ("Application-Owners (alz): Contributor auf Resource-Group-Ebene "
         "(1 Action)  → App-/Ops-Teams", 0),
        ("Network-Subnet-Contributor (alz): vollständiger Subnetz-Zugriff "
         "(8 Actions)  → Netzwerk-Ops", 0),
        ("Zuweisung: Entra-ID-Gruppen-Object-IDs in Bicep-Params; "
         "leeres Array = No-Op (gefahrlos)", 0),
        ("Roadmap: PIM, Conditional Access, hybride Identitäten als "
         "Folge-Baustein (Identity-Baseline)", 0),
    ])

    # ── 9. Automatisierung & CI/CD ────────────────────────────────────────────
    divider(prs,
        "9  ·  Automatisierung und CI/CD",
        "Bootstrap → 18 Deploy-Stufen → GitOps-Betrieb"
    )
    content(prs, "Automatisierung und CI/CD",
            "Pipeline-Workflow (GitHub Actions)", [
        ("Bootstrap (Phase 0, Terraform): Resource Group + Storage (State) + "
         "Managed Identity (OIDC Federated Credentials)", 0),
        ("GitHub-Repo + Environments + Approval-Gates automatisch generiert", 0),
        ("5 Pipeline-Schritte: Trigger → Validation (bicep build) → "
         "What-If → Approval → Apply", 0),
        ("18 Stufen sequenziell: Governance-MGs (1–12) → RBAC (13–15) → "
         "Logging (16) → Hub-Netzwerk (17) oder vWAN (18)", 0),
        ("OIDC Federated Identity: keine Passwörter, keine Zertifikate, "
         "keine Secrets in Pipelines", 0),
        ("GitOps: PR → Review → Approval → Deploy; "
         "jede Änderung mit Autor + Timestamp in Git-History", 0),
        ("Rückrollbarkeit: neuer Commit → Rollback-Pipeline; "
         "vollständiges Audit-Trail in Azure Activity Log", 0),
    ])

    # ── 10. Kosten & Sizing ───────────────────────────────────────────────────
    divider(prs,
        "10  ·  Kosten und Kostensteuerung",
        "Bechtle-Empfehlung: ~€1.050/Monat – voller Funktionsumfang, eine Region"
    )
    content(prs, "Kosten und Kostensteuerung",
            "Gestufter Ausbau: €0 → €1.050 → €5.800", [
        ("Stufe 1 – Governance-Pilot: network_type: none → "
         "MGs + volles Policy-Set + Logging  ca. €50/Monat (nur LAW)", 0),
        ("Stufe 2 – Bechtle-Empfehlung: Firewall Standard, 1 Region, "
         "kein DDoS/ER  →  ~€1.050/Monat", 0),
        ("  Firewall Standard 1×: ~€700  |  Bastion 1×: ~€120  |  VPN GW 1×: ~€140  "
         "|  DNS: ~€40  |  LAW: ~€50", 1),
        ("Stufe 3 – Geo-Redundanz: + Sekundar-Hub NE  →  ~€1.800/Monat", 0),
        ("Stufe 4 – Firewall Premium: IDPS / TLS / URL-Filterung  →  ~€2.400/Monat", 0),
        ("Stufe 5 – DDoS Protection: bei internet-facing Workloads  →  ~€4.900/Monat", 0),
        ("Stufe 6 – Microsoft-Default: alle Dienste, beide Regionen  →  ~€5.800/Monat", 0),
        ("Alle Stufen sind additive Aenderungen – kein Rueckbau erforderlich", 0),
    ])

    content(prs, "Kosten und Kostensteuerung",
            "Konfigurationsvergleich: Vorteile und Nachteile (1/2)", [
        ("Pilot  ~€50/Monat  (network_type: none)", 0),
        ("+ Nullrisiko; volles Governance-Set (MGs, Policies, Logging)", 1),
        ("– Keine Netzwerkkonnektivität; Workloads nicht deploybar", 1),
        ("  Empfehlung: Einstieg, PoC, Compliance-Audit ohne Netzwerkbedarf", 1),
        ("Bechtle-Empfehlung  ~€1.050/Monat  (Standard FW, 1 Region)", 0),
        ("+ Voller Funktionsumfang; 4× günstiger als Microsoft-Default", 1),
        ("+ Firewall, Bastion, VPN, DNS aktiv; In-Place-Upgrade auf Premium möglich", 1),
        ("– Keine zweite Region; kein IDPS/TLS; kein DDoS-Schutz", 1),
        ("  Empfehlung: Standard-Produktionsumgebungen, erste Workloads", 1),
        ("Geo-Redundanz  ~€1.800/Monat  (+ Hub North Europe)", 0),
        ("+ Regionale Ausfallsicherheit; zwei unabhängige Netzwerkhubs", 1),
        ("– Doppelte Netzwerkkosten; erhöhte Betriebskomplexität", 1),
        ("  Empfehlung: SLA-kritische Systeme, Multi-Region-Anforderungen", 1),
    ], size=11)

    content(prs, "Kosten und Kostensteuerung",
            "Konfigurationsvergleich: Vorteile und Nachteile (2/2)", [
        ("Firewall Premium  ~€2.400/Monat  (+ IDPS / TLS-Inspektion)", 0),
        ("+ IDPS, TLS-Inspektion, URL-Filterung; In-Place-Upgrade ohne Rebuild", 1),
        ("– +€1.350 ggü. Bechtle-Empfehlung; Zertifikat-Rollout erforderlich", 1),
        ("  Empfehlung: Hohe Sicherheitsanforderungen, regulierte Branchen", 1),
        ("DDoS Protection  ~€4.900/Monat  (+ Network Protection Plan)", 0),
        ("+ Vollständiger DDoS-Schutz für alle öffentlichen IPs; SLA-Garantie", 1),
        ("– ~€2.500/Monat Fixkosten (Plan Fee), unabhängig von Angriffen", 1),
        ("  Empfehlung: Nur bei internet-facing Workloads mit realem DDoS-Risiko", 1),
        ("Microsoft-Default  ~€5.800/Monat  (alle Dienste, 2 Regionen)", 0),
        ("+ Maximale Redundanz; Enterprise-Standard; Herstellerempfehlung", 1),
        ("– Höchste Kosten; viele Komponenten initial ungenutzt; Overkill für Start", 1),
        ("  Empfehlung: Unternehmenskritische Systeme mit strengster Compliance", 1),
    ], size=11)

    content(prs, "Kosten und Kostensteuerung",
            "Bechtle-Varianten: Vier Konfigurationen im Vergleich", [
        ("Option A – Bechtle-Standard  ~€1.050/Monat  (Baseline)", 0),
        ("FW Standard 1× ~€700 | VPN GW 1× ~€140 | Bastion ~€120 | DNS ~€25 | LAW ~€50", 1),
        ("ALZ-konform: Ja  |  Differenz: Referenz", 1),
        ("Option B – Bechtle-Optimiert  ~€770/Monat  (ALZ-konform)", 0),
        ("FW Standard reserved ~€560 | VPN Gateway deferred (€0) | Bastion ~€120 | DNS ~€25 | LAW ~€50", 1),
        ("ALZ-konform: Ja  |  Differenz: −€280/Mon. (26 % günstiger)", 1),
        ("Option C – Bechtle-Budget  ~€500/Monat  (⚠ ALZ-Bruch)", 0),
        ("FW Basic ~€300 | VPN Gateway deferred (€0) | Bastion ~€120 | DNS ~€25 | LAW ~€50", 1),
        ("ALZ-konform: NEIN  |  Differenz: −€550/Mon. (52 % günstiger)", 1),
        ("Bruch: Firewall Basic = keine App-Rules, kein Threat Intel, kein Autoscaling", 1),
        ("Option D – Microsoft-Default  ~€5.800/Monat  (maximaler Standard)", 0),
        ("FW Premium 2× ~€2.200 | DDoS Plan ~€2.500 | ER GW 2× ~€560 | VPN 2× | Bastion 2× | 2 Regionen", 1),
        ("ALZ-konform: Ja (vollständig)  |  Differenz: +€4.750/Mon. (452 % teurer als A)", 1),
    ], size=11)

    # ── 11. Roadmap & Phasen ──────────────────────────────────────────────────
    divider(prs,
        "11  ·  Roadmap und Phasen",
        "6 Phasen – von Kickoff bis laufendem Betrieb"
    )
    content(prs, "Roadmap und Phasen", "6 Projektphasen im Überblick", [
        ("Phase 1 – Beratung & Kickoff: Discovery-Workshop; "
         "Entscheidungsprotokoll (Region, Netzwerk, DDoS, Enforcement)", 0),
        ("Phase 2 – Bootstrap & Grundgerüst: Deploy-Accelerator; "
         "MGs + Policies (DoNotEnforce); Logging aktiv  ≈ €0", 0),
        ("Phase 3 – Netzwerk-Pilot: Hub-VNets + DNS; erste Spoke-VNets; "
         "ggf. minimale Firewall  €15–€1.300/Monat", 0),
        ("Phase 4 – Sicherheit & Enforcement: Defender aktivieren; "
         "Guardrails einschalten; Remediation  + Defender-Kosten", 0),
        ("Phase 5 – Workload-Onboarding: erste Applikation in ALZ; "
         "Spoke-Netzwerke; RBAC-Gruppen befüllen", 0),
        ("Phase 6 – Betrieb & Optimierung: Cost Management; Tagging; "
         "Monitoring-Dashboards; Policy-Weiterentwicklung", 0),
    ])

    # ── 12. Risiken & Entscheidungen ──────────────────────────────────────────
    divider(prs,
        "12  ·  Risiken und Entscheidungen",
        "Klare Entscheidungen für einen sicheren Start"
    )
    content(prs, "Risiken und Entscheidungen",
            "Top-Risiken und Entscheidungsbedarf", [
        ("DDoS im Default AN → ~€2.500/Monat unerwartet; "
         "deployDdosProtectionPlan: false für Start", 0),
        ("Subscription-Typ: kein Free Tier → "
         "EA/MCA/PAYG vor Bootstrap sicherstellen", 0),
        ("IP-Adresskonflikt On-Prem mit Hub-VNets → "
         "IP-Plan vor Netzwerk-Deploy abstimmen", 0),
        ("Defender-Pläne auto. per Policy aktiviert → "
         "Tier-Konfiguration vor Apply reviewen", 0),
        ("Entscheidung: network_type: none (€0) vs. hubNetworking (~€5.800) "
         "für Pilot", 0),
        ("Entscheidung: Enforcement-Zeitpunkt – wann von DoNotEnforce auf "
         "Enabled (Empfehlung: 4–8 Wochen Audit-Phase)", 0),
        ("Entscheidung: On-Prem-Anbindung – "
         "VPN vs. ExpressRoute vs. keins (je nach SLA und Bandbreite)", 0),
    ])

    # ── 13. Ergänzende Randthemen ─────────────────────────────────────────────
    divider(prs,
        "13  ·  Ergänzende Randthemen",
        "Außerhalb des ALZ-Scopes – aber eng verknüpft"
    )
    content(prs, "Ergänzende Randthemen",
            "Abhängigkeiten und Folge-Bausteine", [
        ("Entra ID & Identity: PIM, Conditional Access, hybride Identitäten → "
         "Identity-Baseline als Folgestufe", 0),
        ("On-Prem-Anbindung: VPN-Gateway (deployt, aktiv) oder ExpressRoute → "
         "Leitungsbestellung + BGP-Konfiguration außerhalb Scope", 0),
        ("Backup & DR: Deploy-VM-Backup aktiv via Policy; "
         "Recovery Vault-Konfiguration und DR-Tests als Folgestufe", 0),
        ("Kostenmanagement: Azure Cost Management Dashboards, "
         "Budget-Alerts je MG/Sub, FinOps-Prozesse", 0),
        ("Compliance & Regulatorik: BSI, ISO 27001, DSGVO → "
         "Defender for Cloud Regulatory Compliance Dashboard", 0),
        ("Workload-Migration: Azure Migrate Assessment → "
         "ALZ ist das Ziel, nicht der Migrations-Prozess selbst", 0),
    ])

    # ── 14. Nächste Schritte ──────────────────────────────────────────────────
    divider(prs,
        "14  ·  Nächste Schritte",
        "Empfohlener Pilot-Pfad in 6 Schritten – ohne Kostenrisiko"
    )
    content(prs, "Nächste Schritte",
            "Sofortmaßnahmen und empfohlener Pilot-Pfad", [
        ("1.  Subscription-ID + GitHub PAT in "
         "config/inputs-github.yaml eintragen", 0),
        ("2.  Bootstrap: Deploy-Accelerator -inputs config/inputs-github.yaml "
         "config/platform-landing-zone.yaml", 0),
        ("3.  Pipeline mit What-If prüfen → "
         "welche Ressourcen werden erstellt?", 0),
        ("4.  Apply genehmigen – network_type: none (≈€0) für "
         "risikofreien Pilot-Start", 0),
        ("5.  Policy-Compliance-Dashboard reviewen → "
         "welche Guardrails greifen, welche nicht?", 0),
        ("6.  Schrittweise Enforcement und Netzwerk-Dienste aktivieren "
         "nach Audit-Phase", 0),
        ("Bechtle begleitet: Kickoff-Workshop → Bootstrap-Begleitung → "
         "Pilot → Workload-Onboarding", 0),
    ])

    # ── Abschluss-Folie ───────────────────────────────────────────────────────
    divider(prs,
        "Vielen Dank",
        "Nächster Schritt: Kickoff-Workshop vereinbaren",
        [
            KUNDE,
            " ",
            "Bechtle GmbH & Co. KG",
            "Gottlieb-Daimler-Straße 2 · 68165 Mannheim",
            "T +49 621 87503-0 · www.bechtle.com",
        ]
    )

    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    prs.save(OUTPUT)
    slide_count = len(prs.slides)
    print(f"Gespeichert: {OUTPUT}")
    print(f"Folien: {slide_count}")


if __name__ == "__main__":
    build()
