# -*- coding: utf-8 -*-
"""
Bechtle-Design-konformes PowerPoint für Azure Landing Zone.

Layouts nach BECHTLE-DESIGN-PPTX.md:
  L0  Title Slide       L6  Divider          L9  Highlight (hell)
  L10 Highlight Dark    L14 Titel+Inhalt     L16 2x Text (Vergleich)
  L19 Text+Bild rechts  L20 Text+Bild groß   L27 3x Säulen

Regel: max. 40 % der Folien dürfen L14 sein.
"""

import os
from pptx import Presentation
from pptx.util import Pt, Inches, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

BASE_DIR  = os.path.dirname(os.path.abspath(__file__))
IMAGES    = os.path.join(BASE_DIR, "images")
TEMPLATE  = os.path.join(BASE_DIR, "bechtle-brand", "Powerpoint",
                         "VORLAGE_Bechtle_Praesentation.pptx")
OUTPUT    = os.path.join(BASE_DIR, "Powerpoint", "Azure-Landing-Zone-Konzept.pptx")

KUNDE = "<KUNDE>"
DATE  = "17.06.2026"

# ── Farben ────────────────────────────────────────────────────────────────────
C_DARK  = RGBColor(0x07, 0x50, 0x33)   # accent1 Dunkelgrün
C_MID   = RGBColor(0x23, 0xA9, 0x6A)   # accent2 Grün
C_LIME  = RGBColor(0xAA, 0xDE, 0x0C)   # accent3 Limette
C_GREY  = RGBColor(0x59, 0x59, 0x59)
C_WHITE = RGBColor(0xFF, 0xFF, 0xFF)
C_BG    = RGBColor(0xF2, 0xF9, 0xF5)   # sehr helles Grün

_NS_R = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}"


# ── Basis-Helfer ──────────────────────────────────────────────────────────────

def clear_slides(prs):
    lst = prs.slides._sldIdLst
    for sid in list(lst):
        rid = sid.get(_NS_R + "id")
        if rid:
            try: prs.part.drop_rel(rid)
            except Exception: pass
        lst.remove(sid)


def sl(prs, idx):
    return prs.slide_masters[0].slide_layouts[idx]


def ph(slide, idx):
    for p in slide.placeholders:
        if p.placeholder_format.idx == idx:
            return p
    return None


def set_text(slide, idx, text, size=None, bold=False, color=None):
    p = ph(slide, idx)
    if p is None:
        return
    tf = p.text_frame
    tf.clear()
    para = tf.paragraphs[0]
    run  = para.add_run()
    run.text = text
    if size:  run.font.size  = Pt(size)
    if bold:  run.font.bold  = True
    if color: run.font.color.rgb = color


def set_bullets(slide, idx, items, size=12):
    """items: str  oder  (str, level)  – level 0=Haupt, 1=Unter"""
    p = ph(slide, idx)
    if p is None:
        return
    tf = p.text_frame
    tf.clear()
    tf.word_wrap = True
    for i, item in enumerate(items):
        text, lvl = (item, 0) if isinstance(item, str) else item
        para = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        para.level = lvl
        run = para.add_run()
        run.text = text
        if size: run.font.size = Pt(size)


def add_img(slide, img_file, ph_idx=14):
    """Bild in PICTURE-Placeholder einfügen."""
    p = ph(slide, ph_idx)
    if p is None:
        return
    path = os.path.join(IMAGES, img_file)
    if os.path.exists(path):
        p.insert_picture(path)


def colored_box(slide, left, top, w, h, fill=C_DARK, text=None,
                txt_size=20, txt_bold=True, txt_color=C_WHITE, align=PP_ALIGN.CENTER):
    """Farbiges Rechteck mit optionalem Text."""
    shape = slide.shapes.add_shape(1, left, top, w, h)
    shape.fill.solid()
    shape.fill.fore_color.rgb = fill
    shape.line.fill.background()
    if text:
        tf = shape.text_frame
        tf.word_wrap = True
        para = tf.paragraphs[0]
        para.alignment = align
        run = para.add_run()
        run.text = text
        run.font.size  = Pt(txt_size)
        run.font.bold  = txt_bold
        run.font.color.rgb = txt_color
    return shape


# ── Folienbaustein-Funktionen ─────────────────────────────────────────────────

def title_slide(prs):
    slide = prs.slides.add_slide(sl(prs, 0))
    set_text(slide, 0,  "Azure Landing Zone",             size=36, bold=True)
    set_text(slide, 1,  "Konzept und Umsetzungsfahrplan", size=18)
    set_text(slide, 15, f"{KUNDE}  ·  Bechtle GmbH & Co. KG  ·  {DATE}", size=10)
    return slide


def agenda_4col(prs):
    """L5 – Agenda mit 4 Themenspalten."""
    slide = prs.slides.add_slide(sl(prs, 5))
    set_text(slide, 0, "Agenda")
    set_bullets(slide, 20, [
        "Management Summary",
        " ",
        "Ausgangslage",
        "Methodik",
        "Zielarchitektur",
    ], size=13)
    set_bullets(slide, 21, [
        "Governance",
        " ",
        "§ 4  Policies & Assignments",
        "§ 5  Netzwerk-Architektur",
        "§ 6  Sicherheit",
    ], size=13)
    set_bullets(slide, 22, [
        "Betrieb",
        " ",
        "§ 7  Monitoring & Logging",
        "§ 8  Identity & RBAC",
        "§ 9  Automatisierung",
    ], size=13)
    set_bullets(slide, 23, [
        "Wirtschaftlichkeit",
        " ",
        "§ 10  Kosten & Varianten",
        "§ 11  Roadmap & Phasen",
        "§ 12–14  Risiken & Next Steps",
    ], size=13)
    return slide


def divider(prs, title, subtitle, facts=None):
    slide = prs.slides.add_slide(sl(prs, 6))
    set_text(slide, 0, title,    size=28, bold=True)
    set_text(slide, 1, subtitle, size=14)
    if facts:
        set_bullets(slide, 13, facts, size=13)
    return slide


def highlight_dark(prs, breadcrumb, statement, body=None):
    """L10 – Key-Statement auf dunklem Hintergrund. Max 2–3× verwenden."""
    slide = prs.slides.add_slide(sl(prs, 10))
    set_text(slide, 1, breadcrumb, size=11)
    set_text(slide, 0, statement,  size=24, bold=True)
    if body:
        set_text(slide, 13, body, size=12)
    return slide


def kpi_slide(prs, breadcrumb, kpi, subtitle=None):
    """L9 – Highlight hell: einzelne große Zahl / Kernaussage."""
    slide = prs.slides.add_slide(sl(prs, 9))
    set_text(slide, 1, breadcrumb, size=12)
    set_text(slide, 0, kpi,        size=40, bold=True)
    if subtitle:
        # L9 hat keinen PH13 – Ergänzungstext als Textbox
        tb = slide.shapes.add_textbox(Inches(0.37), Inches(5.2), Inches(5.5), Inches(1.0))
        tf = tb.text_frame
        tf.word_wrap = True
        r  = tf.paragraphs[0].add_run()
        r.text = subtitle
        r.font.size = Pt(13)
        r.font.color.rgb = C_GREY
    return slide


def content(prs, breadcrumb, title, bullets, size=12):
    """L14 – Standard-Bulletliste. Sparsam einsetzen (< 40 % aller Folien)."""
    slide = prs.slides.add_slide(sl(prs, 14))
    set_text(slide, 1, breadcrumb)
    set_text(slide, 0, title)
    set_bullets(slide, 13, bullets, size=size)
    return slide


def compare(prs, breadcrumb, title, left_hd, left_items, right_hd, right_items, size=12):
    """L16 – Zwei-Spalten-Vergleich."""
    slide = prs.slides.add_slide(sl(prs, 16))
    set_text(slide, 1, breadcrumb)
    set_text(slide, 0, title)
    set_bullets(slide, 13, [(left_hd,  0)] + [(t, 1) for t in left_items],  size=size)
    set_bullets(slide, 14, [(right_hd, 0)] + [(t, 1) for t in right_items], size=size)
    return slide


def diagram_slide(prs, breadcrumb, title, img_file, bullets, big=False):
    """L19 (big=False) / L20 (big=True) – Text links, Bild rechts."""
    slide = prs.slides.add_slide(sl(prs, 20 if big else 19))
    set_text(slide, 1, breadcrumb)
    set_text(slide, 0, title)
    if bullets:
        set_bullets(slide, 13, bullets, size=11)
    add_img(slide, img_file)
    return slide


def three_col(prs, breadcrumb, title, cols):
    """
    L27 – 3 Säulen mit farbigen Header-Boxen und Bullet-Text darunter.
    cols: [(header, color, [bullet, ...]), ...]  – genau 3 Einträge.

    PH-Positionen aus Design-Guide:
      Bilder:  PH18(0,37"/2,37")  PH19(4,70"/2,37")  PH20(9,03"/2,37")  je 3,94"×2,76"
      Texte:   PH13(0,37"/5,52")  PH14(4,70"/5,52")  PH21(9,03"/5,52")  je 3,94"×1,58"
    """
    slide = prs.slides.add_slide(sl(prs, 27))
    set_text(slide, 1, breadcrumb)
    set_text(slide, 0, title)

    # Positionen der Bild-Slots
    box_positions = [
        (Inches(0.37),  Inches(2.37), Inches(3.94), Inches(2.76)),
        (Inches(4.70),  Inches(2.37), Inches(3.94), Inches(2.76)),
        (Inches(9.03),  Inches(2.37), Inches(3.94), Inches(2.76)),
    ]
    text_ph_idx = [13, 14, 21]

    for i, (hdr, color, bullets) in enumerate(cols):
        l, t, w, h = box_positions[i]
        # Farbige Hintergrundbox (ersetzt Bild-Placeholder)
        colored_box(slide, l, t, w, h, fill=color,
                    text=hdr, txt_size=18, txt_bold=True, txt_color=C_WHITE)
        # Bullet-Text in den Text-Placeholder schreiben
        set_bullets(slide, text_ph_idx[i], bullets, size=11)

    return slide


# ── Präsentation bauen ────────────────────────────────────────────────────────

def build():
    prs = Presentation(TEMPLATE)
    clear_slides(prs)

    # ── Titelfolie ─────────────────────────────────────────────────────────────
    title_slide(prs)                                                            # L0

    # ── Agenda ─────────────────────────────────────────────────────────────────
    agenda_4col(prs)                                                             # L5

    # ── Management Summary ─────────────────────────────────────────────────────
    highlight_dark(prs,                                                          # L10
        "Management Summary",
        "Governance · Netzwerk · Sicherheit\nals Code – reproduzierbar und auditfähig.",
        "Microsoft ALZ Bicep Accelerator  ·  149 Policies  ·  12 MGs  ·  ~€1.050/Monat"
    )

    three_col(prs,                                                               # L27
        "Management Summary",
        "Drei Kernnutzen der Azure Landing Zone",
        [
            ("Governance",  C_DARK, [
                "149 Policy-Definitionen",
                "42 Initiativen",
                "123 Assignments auf 9 MG-Ebenen",
                "Automatisch – kein manueller Eingriff",
            ]),
            ("Netzwerk",    C_MID, [
                "Hub-and-Spoke in GWC",
                "Azure Firewall · Bastion · VPN",
                "59 Private DNS Zonen",
                "Spoke-VNets per Vending-Template",
            ]),
            ("Sicherheit",  RGBColor(0x05, 0x3B, 0x25), [
                "Defender for Cloud auto-aktiviert",
                "CrowdStrike SIEM via Event Hub",
                "Break-Glass-Logging",
                "OIDC – keine Passwörter in Pipelines",
            ]),
        ]
    )

    kpi_slide(prs,                                                               # L9
        "Management Summary · Bechtle-Empfehlung",
        "~€1.050 / Monat",
        "Voller ALZ-Funktionsumfang · eine Region · 4× günstiger als Microsoft-Default (~€5.800)"
    )

    # ── §1 Ausgangslage ────────────────────────────────────────────────────────
    divider(prs,
        "1  ·  Ausgangslage und Zielbild",
        "Von der ersten Subscription zur skalierbaren Cloud-Grundstruktur"
    )                                                                            # L6

    compare(prs,                                                                 # L16
        "Ausgangslage und Zielbild",
        "Ohne Azure Landing Zone vs. Mit Azure Landing Zone",
        "Ohne ALZ",
        [
            "Ressourcen entstehen ad hoc",
            "Keine einheitlichen Guardrails",
            "Sicherheitsbaselines manuell",
            "Keine Netzwerksegmentierung",
            "Compliance mühsam nachzuweisen",
            "Technische Schulden ab Tag 1",
        ],
        "Mit ALZ (Bechtle)",
        [
            "Standardisierter Verwaltungsrahmen",
            "149 Policies – automatische Guardrails",
            "Defender for Cloud via Policy",
            "Hub-and-Spoke – zentrale Firewall",
            "Audit-Trail in Git + Activity Log",
            "Skalierbar ohne Rearchitektur",
        ]
    )

    # ── §2 Methodik ────────────────────────────────────────────────────────────
    divider(prs,
        "2  ·  Methodik und Vorgehen",
        "Microsoft ALZ Bicep Accelerator – kein Eigenbau, kein Vendor-Lock-in"
    )                                                                            # L6

    content(prs,                                                                 # L14
        "Methodik und Vorgehen",
        "ALZ Bicep Accelerator + 18 Deploy-Stufen",
        [
            ("Microsoft-Standard – tausendfach erprobt, Microsoft-gepflegt", 0),
            ("20 Azure Verified Modules (AVM) – zertifiziertes IaC, kein Eigenbau", 0),
            ("18 geordnete Stufen:  Governance (1–12)  →  RBAC (13–15)  →  Logging (16)  →  Netzwerk (17/18)", 0),
            ("OIDC Federated Identity – keine Secrets oder Zertifikate in Pipelines", 0),
            ("What-If vor Apply – Änderungsvorschau und Approval-Gate vor jedem Deploy", 0),
            ("Bicep Build: alle 20 Templates grün (Bicep 0.44.1) · CI läuft auf jedem PR", 0),
        ],
        size=13
    )

    # ── §3 Zielarchitektur ─────────────────────────────────────────────────────
    divider(prs,
        "3  ·  Zielarchitektur",
        "12 Management Groups  ·  Hub-and-Spoke  ·  Germany West Central",
        ["12 MGs", "Hub-VNet 10.0.0.0/22", "Private DNS 59 Zonen"]
    )                                                                            # L6

    diagram_slide(prs,                                                           # L20
        "Zielarchitektur",
        "Hub-and-Spoke-Topologie",
        "alz-hub-spoke.png",
        [
            "Connectivity Sub: Firewall · Bastion · VPN · DNS",
            "alz-corp: interne Workloads, Private Endpoints",
            "alz-online: internet-facing Dienste",
            "On-Prem: VPN aktiv · ExpressRoute deferred",
            "SIEM: CrowdStrike via Event Hub",
        ],
        big=True
    )

    diagram_slide(prs,                                                           # L19
        "Zielarchitektur",
        "Management Group Hierarchie (12 MGs)",
        "alz-mg-hierarchy.png",
        [
            "alz → alz-platform → connectivity / identity / management / security",
            "alz → alz-landingzones → corp / online / local",
            "alz → alz-sandbox  ·  alz-decommissioned",
            "DoNotEnforce: Audit-Modus schützt Bestand",
            "Exemptions für Legacy-Ressourcen möglich",
        ],
        big=False
    )

    compare(prs,                                                                 # L16
        "Zielarchitektur · Subscription-Strategie",
        "Einstieg (Single-Sub) vs. Produktionsbetrieb (Multi-Sub)",
        "Phase 1 – Single Subscription",
        [
            "Alle Platform-Rollen auf 1 Sub",
            "MG-Hierarchie identisch zu Prod",
            "Sofortiger Pilot ohne PoC-Overhead",
            "Smoke Run: bash smokerun/run.sh",
            "Kosten: Ressourcen wie Prod",
        ],
        "Phase 2 – Dedizierte Platform-Subs",
        [
            "sub-alz-connectivity (Hub/FW)",
            "sub-alz-management  (LAW/DCR)",
            "sub-alz-identity     (AD DS)",
            "sub-alz-security     (Defender)",
            "Blast-Radius-Isolation je Rolle",
        ]
    )

    # ── §4 Governance ─────────────────────────────────────────────────────────
    divider(prs,
        "4  ·  Governance und Policies",
        "149 Definitionen · 42 Initiativen · 123 Assignments",
        ["9 MG-Ebenen", "5 Custom RBAC-Rollen", "DoNotEnforce → kein Produktionsrisiko"]
    )                                                                            # L6

    three_col(prs,                                                               # L27
        "Governance und Policies",
        "Das vollständige ALZ-Policy-Set",
        [
            ("149 Definitionen", C_DARK, [
                "Monitoring / Diagnose: 67",
                "Netzwerk: 20",
                "Storage: 16",
                "SQL & Datenbanken: 13",
                "Security & Defender: 12",
                "Compute & Backup: 11",
                "Governance & Tagging: 10",
            ]),
            ("42 Initiativen", C_MID, [
                "Deploy-MDFC-Config",
                "Deploy-Private-DNS-Zones (59)",
                "Enforce-Guardrails-* (26 Dienste)",
                "Deploy-VM/VMSS-Monitoring",
                "Deploy-MDEndpoints",
                "Enforce-ACSB",
                "Deploy-VM-Backup",
            ]),
            ("123 Assignments", RGBColor(0x05, 0x3B, 0x25), [
                "alz-Root:             17",
                "alz-landingzones:     53",
                "alz-platform:         40",
                "alz-corp:              5",
                "alz-identity:          4",
                "alz-connectivity:      1",
                "Sandbox + Decomm:      2",
            ]),
        ]
    )

    compare(prs,                                                                 # L16
        "Governance und Policies · Onboarding",
        "DoNotEnforce-Modus: sicheres Onboarding bestehender Ressourcen",
        "Ohne DoNotEnforce",
        [
            "Policies blockieren sofort",
            "Bestehende Ressourcen brechen",
            "Produktion kann unterbrochen werden",
            "Kein Audit vor Enforcement",
            "Rollback-Risiko bei Fehlkonfiguration",
        ],
        "Mit DoNotEnforce (Bechtle-Standard)",
        [
            "Policies werden ausgewertet, nicht erzwungen",
            "Compliance-Dashboard zeigt Handlungsbedarf",
            "Bestehende Ressourcen laufen ungestört",
            "Audit-Phase 4–8 Wochen",
            "Selektives Enforcing nach Remediation",
        ]
    )

    # ── §5 Netzwerk ───────────────────────────────────────────────────────────
    divider(prs,
        "5  ·  Netzwerk-Architektur",
        "Hub-and-Spoke · Germany West Central  ·  Firewall Standard · ~€1.050/Monat"
    )                                                                            # L6

    diagram_slide(prs,                                                           # L20
        "Netzwerk-Architektur",
        "Connectivity Subscription im Detail",
        "alz-hub-spoke.png",
        [
            "Azure Firewall Standard:  ~€700/Mon.",
            "Azure Bastion Standard:   ~€120/Mon.",
            "VPN Gateway VpnGw1AZ:     ~€140/Mon.",
            "DNS Private Resolver + 59 Zonen: ~€25",
            "Key Vault · Event Hub · UDR → FW",
        ],
        big=True
    )

    compare(prs,                                                                 # L16
        "Netzwerk-Architektur · Kostenvergleich",
        "Microsoft-Default vs. Bechtle-Empfehlung",
        "Microsoft-Default  ~€5.800/Mon.",
        [
            "Azure Firewall Premium 2×   ~€2.200",
            "DDoS Network Protection      ~€2.500",
            "ExpressRoute Gateway 2×        ~€560",
            "VPN Gateway 2×                  ~€280",
            "Azure Bastion 2×                ~€240",
            "2 Regionen: GWC + North Europe",
            "Alle Dienste von Beginn an aktiv",
        ],
        "Bechtle-Empfehlung  ~€1.050/Mon.",
        [
            "Azure Firewall Standard 1×     ~€700",
            "DDoS: deferred (aktivierbar)",
            "ExpressRoute GW: deferred",
            "VPN Gateway 1×                  ~€140",
            "Azure Bastion 1×                ~€120",
            "1 Region: Germany West Central",
            "In-Place-Upgrade ohne Rebuild",
        ]
    )

    # ── §6 Sicherheit ─────────────────────────────────────────────────────────
    divider(prs,
        "6  ·  Sicherheit",
        "Defender for Cloud · CrowdStrike SIEM · Automatische Remediation"
    )                                                                            # L6

    three_col(prs,                                                               # L27
        "Sicherheit",
        "Drei Sicherheitsebenen",
        [
            ("Präventiv",   C_DARK, [
                "Deny-Subnet-Without-Nsg",
                "Deny-MgmtPorts-Internet",
                "Deny-Public-IP (corp)",
                "Deny-Public-Endpoints (59 PaaS)",
                "HTTPS-only (Storage, SQL, AppGW)",
            ]),
            ("Detektiv",    C_MID, [
                "Defender for Cloud (via Policy)",
                "Activity Logs → Log Analytics",
                "Diagnose-Policies (67 Ressourcentypen)",
                "CrowdStrike SIEM via Event Hub",
                "Break-Glass-Account-Logging",
            ]),
            ("Reaktiv",     RGBColor(0x05, 0x3B, 0x25), [
                "Deploy-MDFC-Config-H224 (auto)",
                "Deploy-MDEndpoints auf alle VMs",
                "Defender for SQL (ATP)",
                "VM Backup Policy (auto-Sicherung)",
                "Logic Apps → On-Prem-Monitoring",
            ]),
        ]
    )

    # ── §7 Monitoring & Logging ────────────────────────────────────────────────
    divider(prs,
        "7  ·  Monitoring und Logging",
        "Zentraler Log Analytics Workspace  ·  3 Data Collection Rules"
    )                                                                            # L6

    compare(prs,                                                                 # L16
        "Monitoring und Logging",
        "Zentrale Logging-Plattform (AVM avm/ptn/alz/ama:0.2.0)",
        "Infrastruktur (deployed)",
        [
            "law-alz-gwe  (365 Tage, PerGB2018)",
            "mi-alz-gwe   (Managed Identity)",
            "dcr-vmi-alz-gwe  (VM Insights)",
            "dcr-ct-alz-gwe   (Change Tracking)",
            "dcr-mdfcsql-alz-gwe (Defender SQL)",
            "Kosten: 5 GB/Mon. kostenlos, ~€2/GB",
        ],
        "Automatik (via DINE-Policies)",
        [
            "Jede neue VM → AMA + DCR (auto)",
            "Activity Logs aller Subs → LAW",
            "Diagnose aller Ressourcentypen → LAW",
            "Defender for Cloud → Security-Events",
            "CrowdStrike: Event Hub Export → SIEM",
            "Roadmap: Microsoft Sentinel optional",
        ]
    )

    # ── §8 Identity & RBAC ────────────────────────────────────────────────────
    divider(prs,
        "8  ·  Identity und RBAC",
        "5 Custom-Rollen  ·  Entra-ID-Gruppen  ·  Least Privilege"
    )                                                                            # L6

    content(prs,                                                                 # L14
        "Identity und RBAC",
        "5 Custom RBAC-Rollen auf Management-Group-Ebene",
        [
            ("Subscription-Owner (alz)", 0),
            ("Delegierter Owner für Subscriptions – ohne volle Tenant-Rechte  →  Plattform-Admins", 1),
            ("Security-Operations (alz)", 0),
            ("Horizontale Sicherheitssicht: Defender, MDFC, Sentinel  →  SOC-Team", 1),
            ("Network-Management (alz-platform-connectivity)", 0),
            ("VNets · UDRs · NSGs · Firewall  →  Netzwerk-Team", 1),
            ("Application-Owners (alz-landingzones)", 0),
            ("Contributor auf eigene Resource Groups  →  Workload-Teams", 1),
            ("Network-Subnet-Contributor (alz-landingzones)", 0),
            ("Nur Subnetze in bestehenden VNets  →  delegierter Netzwerkzugriff", 1),
        ],
        size=12
    )

    # ── §9 Automatisierung & CI/CD ────────────────────────────────────────────
    divider(prs,
        "9  ·  Automatisierung und CI/CD",
        "Bootstrap → 18 Deploy-Stufen → GitOps-Betrieb"
    )                                                                            # L6

    content(prs,                                                                 # L14
        "Automatisierung und CI/CD",
        "Pipeline-Workflow: Trigger → Validate → What-If → Approve → Deploy",
        [
            ("OIDC Federated Identity: keine Secrets, keine Zertifikate, keine Passwörter", 0),
            ("Bicep Build auf jedem PR – statische Validierung ohne Azure-Verbindung", 0),
            ("What-If Preview: ARM-API zeigt geplante Änderungen vor dem Apply", 0),
            ("Approval-Gate (GitHub Environment 'production'): explizite Freigabe erforderlich", 0),
            ("18 Stufen sequenziell:  1–12 Governance  ·  13–15 RBAC  ·  16 Logging  ·  17/18 Netzwerk", 0),
            ("GitOps: jede Änderung = Commit → vollständiges Audit-Trail in Git-History", 0),
            ("Smoke Run in einer einzigen Sub: bash smokerun/run.sh --deploy", 0),
        ],
        size=13
    )

    # ── §10 Kosten ────────────────────────────────────────────────────────────
    divider(prs,
        "10  ·  Kosten und Kostensteuerung",
        "Gestufter Ausbau: €50 → €1.050 → €5.800 – volle Kostenkontrolle"
    )                                                                            # L6

    kpi_slide(prs,                                                               # L9
        "Kosten und Kostensteuerung · Bechtle-Empfehlung",
        "~€1.050 / Monat",
        "Option A – Bechtle-Standard: Firewall Standard 1×  ·  Bastion  ·  VPN Gateway  ·  ALZ-konform"
    )

    content(prs,                                                                 # L14
        "Kosten und Kostensteuerung",
        "Gestufter Ausbau: 6 Kostenstufen",
        [
            ("Stufe 1 – Governance-Pilot     ~€50/Mon.", 0),
            ("network_type: none · MGs + Policies (DoNotEnforce) + Logging · kein Netzwerk", 1),
            ("Stufe 2 – Bechtle-Standard     ~€1.050/Mon.  ✅ Empfohlen", 0),
            ("FW Standard ~€700 · Bastion ~€120 · VPN GW ~€140 · DNS ~€25 · LAW ~€50", 1),
            ("Stufe 3 – Geo-Redundanz        ~€1.800/Mon.", 0),
            ("+ Sekundärer Hub North Europe · bidirektionales Peering", 1),
            ("Stufe 4 – Firewall Premium     ~€2.400/Mon.", 0),
            ("+ IDPS · TLS-Inspektion · URL-Filterung · Zertifikat-Rollout", 1),
            ("Stufe 5 – DDoS Protection      ~€4.900/Mon.", 0),
            ("+ DDoS Network Protection Plan (~€2.500 Fix) · nur bei internet-facing Workloads", 1),
            ("Stufe 6 – Microsoft-Default    ~€5.800/Mon.", 0),
            ("Alle Dienste · beide Regionen · maximale Redundanz", 1),
        ],
        size=11
    )

    compare(prs,                                                                 # L16
        "Kosten und Kostensteuerung · Vier Varianten",
        "Bechtle-Varianten: ALZ-konform vs. Budget",
        "Option A  ~€1.050 / B  ~€770  (ALZ-konform)",
        [
            "A: Firewall Standard 1×  ~€700",
            "A: Bastion ~€120  ·  VPN GW ~€140",
            "A: DNS ~€25  ·  LAW ~€50  →  €1.050",
            "─────────────────────────────",
            "B: FW Standard reserved  ~€560",
            "B: VPN GW deferred (€0) · Bastion ~€120",
            "B: DNS ~€25  ·  LAW ~€50  →  ~€770",
            "B: 26 % günstiger als A · ALZ-konform ✅",
        ],
        "Option C  ~€500  (ALZ-Bruch)  /  D  ~€5.800",
        [
            "C: Firewall Basic  ~€300  ⚠ ALZ-Bruch",
            "C: Kein App-Rules · kein Threat Intel",
            "C: Bastion ~€120  ·  DNS ~€25 · LAW ~€50",
            "C: 52 % günstiger – aber eingeschränkt",
            "─────────────────────────────",
            "D: Microsoft-Default  ~€5.800/Mon.",
            "D: FW Premium 2× · DDoS Plan · ER GW 2×",
            "D: Maximale Redundanz · 452 % vs. A",
        ]
    )

    # ── §11–14 kompakt ────────────────────────────────────────────────────────
    divider(prs,
        "11  ·  Roadmap und Phasen",
        "6 Phasen – von Kickoff bis laufendem Betrieb"
    )                                                                            # L6

    content(prs,                                                                 # L14
        "Roadmap und Phasen",
        "6 Projektphasen",
        [
            ("Phase 1 – Kickoff & Discovery: Workshop · Region · Netzwerk · DDoS · Enforcement", 0),
            ("Phase 2 – Bootstrap:  Deploy-Accelerator · MGs + Policies (DoNotEnforce) · Logging  ≈ €0", 0),
            ("Phase 3 – Netzwerk-Pilot:  Hub-VNets · DNS · erste Spokes  →  ~€1.050/Mon.", 0),
            ("Phase 4 – Sicherheit:  Defender aktivieren · Guardrails einschalten · Remediation", 0),
            ("Phase 5 – Workload-Onboarding:  erste Applikation in ALZ · RBAC-Gruppen befüllen", 0),
            ("Phase 6 – Betrieb:  Cost Management · Tagging · Monitoring-Dashboards", 0),
        ],
        size=13
    )

    divider(prs,
        "12–14  ·  Risiken · Randthemen · Nächste Schritte",
        "Entscheidungen vor Projektstart – klären, bevor der Bootstrap läuft"
    )                                                                            # L6

    compare(prs,                                                                 # L16
        "Risiken und Entscheidungen",
        "Klärungsbedarf vor Bootstrap",
        "Offene Entscheidungen",
        [
            "network_type: none (€0) vs. hubNetworking (~€1.050)?",
            "Enforcement-Zeitpunkt: wann von DoNotEnforce auf Enabled?",
            "On-Prem-Anbindung: VPN vs. ExpressRoute vs. keins?",
            "Subscription-Typ: EA / MCA / PAYG?",
            "DDoS: deployDdosProtectionPlan: false für Start",
            "Defender-Tier: welche Pläne aktivieren?",
        ],
        "Sofortmaßnahmen vom Kunden",
        [
            "Azure Tenant ID + Owner-Zugriff Tenant Root",
            "Subscription ID(s) bereitstellen",
            "Bestehende IP-Ranges mitteilen (Konfliktcheck)",
            "5 Entra-Gruppen anlegen + Object IDs",
            "Security-Contact-E-Mail benennen",
            "CrowdStrike-Ansprechpartner benennen",
        ]
    )

    # ── Abschluss-Statement ────────────────────────────────────────────────────
    highlight_dark(prs,                                                          # L10
        "Nächste Schritte",
        "Tenant ID + Subscription ID → Smoke Run → Live in einer Woche.",
        "bash smokerun/run.sh --deploy  ·  verify.sh prüft 24 Checks automatisch  ·  teardown.sh für Cleanup"
    )

    divider(prs,                                                                 # L6
        "Vielen Dank",
        "Nächster Schritt: Kickoff-Workshop vereinbaren",
        [
            KUNDE,
            " ",
            "Bechtle GmbH & Co. KG",
            "Gottlieb-Daimler-Straße 2  ·  74172 Neckarsulm",
            "www.bechtle.com",
        ]
    )

    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    prs.save(OUTPUT)

    # Layout-Statistik
    from collections import Counter
    layout_counts = Counter()
    for s in prs.slides:
        try:
            name = s.slide_layout.name
        except Exception:
            name = "unknown"
        layout_counts[name] += 1
    total = len(prs.slides)
    print(f"Gespeichert: {OUTPUT}")
    print(f"Folien gesamt: {total}")
    print("Layout-Verteilung:")
    for name, cnt in sorted(layout_counts.items(), key=lambda x: -x[1]):
        pct = cnt / total * 100
        flag = "  ⚠ >40%" if "Inhalt" in name and pct > 40 else ""
        print(f"  {name:40s} {cnt:3d}  ({pct:.0f}%){flag}")


if __name__ == "__main__":
    build()
