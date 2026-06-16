# Projekt-Status: Azure Landing Zone (ALZ Bicep Accelerator)

> **Zweck:** Dieses Dokument erhält den vollständigen Projektstatus für die Nutzung
> in Folge-Chat-Sessions. Immer zuerst lesen, bevor neue Arbeit gestartet wird.
>
> **Letzter Stand:** 2026-06-16 | Branch: `claude/peaceful-gates-d2fu7f` | Commit: `20b66f8`

---

## 1. Kontext & Ziel

Yannick Beck (yannickbeck1@web.de) baut eine **Azure Landing Zone** für einen Kunden
über den **offiziellen Microsoft ALZ Bicep Accelerator** auf. Der Kunde hat noch keinen
Kickoff gehabt und null Azure-Vorwissen → muss an die Hand genommen werden.

**Kickoff-Termin mit Technikern des Kunden steht bevor** (inkl. Netzwerker-Beteiligung).

---

## 2. Technische Basis

| Aspekt | Detail |
|---|---|
| IaC-Werkzeug | ALZ Bicep Accelerator (`Deploy-Accelerator` PS-Cmdlet) |
| IaC-Typ | `bicep` |
| Starter-Modul | `platform_landing_zone` |
| Bootstrap-Modul | `alz_github` (Terraform-Bootstrap, erstellt GitHub-Repo + OIDC) |
| Primäre Region | `germanywestcentral` |
| Sekundäre Region | `northeurope` |
| Netzwerk-Typ | `hubNetworking` (Hub-and-Spoke) |
| MG-Prefix/-Suffix | leer (Microsoft-Standard-IDs) |
| AVM-Kernmodul (Governance) | `avm/ptn/alz/empty:0.3.6` |
| AVM-Logging-Modul | `avm/ptn/alz/ama:0.2.0` |

**Policy-Set (über `avm/ptn/alz/empty:0.3.6`):**

- 149 Custom Policy Definitions
- 42 Policy Set Definitions (Initiativen)
- 123 Policy Assignments verteilt auf 9 MG-Ebenen:
  - `alz` (Int. Root): 17 Assignments
  - `landingzones`: 53 Assignments
  - `landingzones/corp`: 5 Assignments
  - `landingzones/local`: 1 Assignment
  - `platform`: 40 Assignments
  - `platform/connectivity`: 1 Assignment
  - `platform/identity`: 4 Assignments
  - `sandbox`: 1 Assignment
  - `decommissioned`: 1 Assignment
- 5 Custom RBAC-Rollen

**Achtung: Defender for Cloud wird automatisch aktiviert** durch Assignments wie
`Deploy-MDFC-Config-H224`, `Deploy-MDEndpoints` u.a. auf `alz`-Root-Ebene
→ kostet extra pro Ressource (Defender Standard-Plan).

---

## 3. Subscription-Setup

Der Kunde hat **eine Subscription**. Konfiguration als Single-Subscription-Setup:
alle vier Felder in `config/inputs-github.yaml` auf dieselbe Subscription-ID setzen.

```yaml
subscription_ids:
  management: "<SUBSCRIPTION_ID>"
  identity: "<SUBSCRIPTION_ID>"
  connectivity: "<SUBSCRIPTION_ID>"
  security: "<SUBSCRIPTION_ID>"
```

Die Trennung in 4 Subscriptions (empfohlen für Prod) kann später erfolgen.

**Subscription muss auf Enterprise Agreement, MCA oder Pay-as-you-go laufen** —
kein Free Tier. Alle benötigten Resource Providers werden automatisch registriert.

---

## 4. Kosten-Warnung

Microsoft-Default (alle Dienste in beiden Regionen aktiv): **~€5.800/Monat**

| Dienst | Kosten/Monat |
|---|---|
| 2× Azure Firewall Premium | ~€2.800 |
| 2× DDoS Protection Plan | ~€2.500 |
| 2× VPN Gateway | ~€540 |
| 2× Bastion | ~€270 |
| 2× ExpressRoute GW | ~€450 |
| 2× DNS Private Resolver | ~€120 |
| Log Analytics (minimal) | ~€50 |

**Für Erst-Rollout ohne Kostenrisiko:** `network_type: "none"` in
`config/platform-landing-zone.yaml` → deployt nur MGs + volles Policy-Set + Logging
(≈ €0 bis LAW-Daten anfallen).

---

## 5. Repo-Struktur

```
azure-landing-zone/
├── .config/
│   └── ALZ-Powershell.config.json        # 18 geordnete Deploy-Stufen
├── config/
│   ├── inputs-github.yaml                # Bootstrap-Konfiguration (BEFÜLLT, PAT/SubID leer)
│   └── platform-landing-zone.yaml        # Starter-Modul-Konfiguration (BEFÜLLT)
├── templates/
│   ├── core/
│   │   ├── alzCoreType.bicep             # Zentrale User-Defined-Types
│   │   ├── governance/
│   │   │   ├── lib/alz/                  # 319 Policy-JSON-Dateien (149 Def + 42 Init + 123 Assign)
│   │   │   └── mgmt-groups/
│   │   │       ├── int-root/             # avm/ptn/alz/empty:0.3.6 (475 Zeilen)
│   │   │       ├── platform/             # + subchecks connectivity/identity/management/security
│   │   │       ├── landingzones/         # + corp/local/online
│   │   │       ├── sandbox/
│   │   │       └── decommissioned/
│   │   └── logging/                      # avm/ptn/alz/ama:0.2.0
│   └── networking/
│       ├── hubnetworking/                # Hub-and-Spoke (alle Dienste Default ON)
│       └── virtualwan/                   # Alternative zu Hub (bei network_type: vwanConnectivity)
├── docs/
│   ├── ACCELERATOR-BOOTSTRAP.md         # Runbook für Deploy-Accelerator (Schritt-für-Schritt)
│   ├── TECHNICAL-REFERENCE.md           # 558-Zeilen-Granularreferenz (alle Ressourcen/Policies)
│   ├── PROJEKT-STATUS.md                # Diese Datei – Projektstatus für Folge-Chats
│   └── kickoff/
│       ├── Azure-Landing-Zone-Dokumentation.docx
│       ├── Azure-Landing-Zone-Kickoff.pptx
│       ├── Azure-Landing-Zone-QnA-Vorbereitung.docx
│       ├── Azure-Landing-Zone-Technische-Referenz.docx
│       ├── generate.py                   # Erzeugt Doku + PPTX
│       ├── generate-qna.py              # Erzeugt Q&A-Deck
│       └── generate-techref.py          # Erzeugt technische Referenz
├── legacy-custom/                        # Archiv: vorherige custom Implementierung (nicht löschen)
└── README.md
```

---

## 6. Deployment-Stufen (18 geordnete Stages aus `.config/ALZ-Powershell.config.json`)

| # | Name | Template |
|---|---|---|
| 1 | `mgmt_groups_int_root` | `templates/core/governance/mgmt-groups/int-root/` |
| 2 | `mgmt_groups_landing_zones` | `.../landingzones/` |
| 3 | `mgmt_groups_landing_zones_corp` | `.../landingzones/landingzones-corp/` |
| 4 | `mgmt_groups_landing_zones_local` | `.../landingzones/landingzones-local/` |
| 5 | `mgmt_groups_landing_zones_online` | `.../landingzones/landingzones-online/` |
| 6 | `mgmt_groups_platform` | `.../platform/` |
| 7 | `mgmt_groups_platform_connectivity` | `.../platform/platform-connectivity/` |
| 8 | `mgmt_groups_platform_identity` | `.../platform/platform-identity/` |
| 9 | `mgmt_groups_platform_management` | `.../platform/platform-management/` |
| 10 | `mgmt_groups_platform_security` | `.../platform/platform-security/` |
| 11 | `mgmt_groups_sandbox` | `.../sandbox/` |
| 12 | `mgmt_groups_decommissioned` | `.../decommissioned/` |
| 13 | `rbac_landingzones` | `.../landingzones/main-rbac.bicep` |
| 14 | `rbac_platform` | `.../platform/main-rbac.bicep` |
| 15 | `rbac_platform_connectivity` | `.../platform/platform-connectivity/main-rbac.bicep` |
| 16 | `logging` | `templates/core/logging/` |
| 17 | `hub_networking` | `templates/networking/hubnetworking/` |
| 18 | `virtual_wan` | `templates/networking/virtualwan/` |

Stufen 17 und 18 sind exklusiv durch `network_type` gesteuert.

---

## 7. Ressourcen, die erstellt werden

### Management Groups (12)
`alz` → `platform` (connectivity, identity, management, security), `landingzones`
(corp, local, online), `sandbox`, `decommissioned`

### Logging (Stufe 16, Region primary + secondary)
- Log Analytics Workspace: `law-alz-<region>` (PerGB2018, 365 Tage)
- User-Assigned Managed Identity: `mi-alz-<region>`
- DCR VM Insights: `dcr-vmi-alz-<region>`
- DCR Change Tracking: `dcr-ct-alz-<region>`
- DCR Defender SQL: `dcr-mdfcsql-alz-<region>`
- Solution: `ChangeTracking`
- Automation Account (optional): `aa-alz-<region>` (Default: `false`)
- Resource Group: `rg-alz-logging-<region>`

### Hub Networking (Stufe 17, je Region)
**Subnets je Hub-VNet (10.0.0.0/22 primary, 10.1.0.0/22 secondary):**
- AzureFirewallSubnet /26
- AzureFirewallManagementSubnet /26
- AzureBastionSubnet /26
- GatewaySubnet /27
- DNSPrivateResolverInboundSubnet /28
- DNSPrivateResolverOutboundSubnet /28

**Dienste (Default ON in beiden Hubs):**
Azure Firewall Premium, Bastion, VPN Gateway, ExpressRoute Gateway, DDoS Protection
Plan, Private DNS Zones (alle Azure-Standard-Zonen), DNS Private Resolver

---

## 8. Konfigurationsdateien (Platzhalter noch zu befüllen)

**`config/inputs-github.yaml`** — noch zu setzen:
- `subscription_ids.*` → alle vier auf dieselbe Subscription-ID
- `github_personal_access_token` → Classic PAT mit `repo`, `workflow`, `admin:org`, `delete_repo`
- `github_runners_personal_access_token` → dasselbe PAT (bei Microsoft-hosted Runnern)

**`config/platform-landing-zone.yaml`** — vollständig befüllt, keine Änderungen nötig.

---

## 9. Bootstrap-Voraussetzungen (für Deploy-Accelerator)

```powershell
az login
Install-Module ALZ -Scope CurrentUser

Deploy-Accelerator `
  -inputs ./config/inputs-github.yaml ./config/platform-landing-zone.yaml `
  -output ./output
```

**Voraussetzungen:**
- PowerShell ≥ 7.4
- Azure CLI ≥ 2.60, angemeldet (`az login`)
- Owner-Rechte auf den Subscriptions
- Erhöhter Zugriff am Tenant Root (Entra ID → Properties → Access management for Azure resources → Ein)
- GitHub PAT (Classic) mit: `repo`, `workflow`, `admin:org`, `delete_repo`

**Was Bootstrap erstellt:**
- Bootstrap-RG + Storage (Terraform State) + Managed Identity mit Federated Credentials (OIDC)
- Ein GitHub-Repository mit Starter-Modul + generierten Deployment-Pipelines
- GitHub-Environments mit Approval-Gates (`apply_approvers: yannickbeck1@web.de`)

Detailliertes Runbook: `docs/ACCELERATOR-BOOTSTRAP.md`

---

## 10. Lokale Verifikation (ohne Azure)

Alle Templates bauen offline gegen MCR:

```bash
/tmp/bicep build templates/core/governance/mgmt-groups/int-root/main.bicep
```

Alle 20 Templates wurden verifiziert: **20/20 OK, 0 Errors, 0 Warnings** (Bicep 0.44.1).

Bicep-CLI: `/tmp/bicep`
PowerShell: `/tmp/pwsh/pwsh`

---

## 11. Branch- & PR-Status

| Branch | Status |
|---|---|
| `master` | Enthält PR #1 (alte custom-Implementierung) — kein neuer Accelerator-PR erstellt |
| `claude/peaceful-gates-d2fu7f` | **Aktueller Arbeits-Branch** — Accelerator-Migration vollständig |

**Kein PR für Accelerator-Migration nach master erstellt** (nicht explizit angefragt).

---

## 12. Dokumentation (Kickoff-Unterlagen)

Alle Dateien in `docs/kickoff/`, aktuell auf Accelerator-Stand:

| Datei | Inhalt |
|---|---|
| `Azure-Landing-Zone-Dokumentation.docx` | 13 Kapitel: Übersicht, Architektur, MG-Hierarchie, Policies, Ressourcen, Netzwerk, Logging, Sicherheit, RBAC, Betrieb, Kosten, Migration, Nächste Schritte |
| `Azure-Landing-Zone-Kickoff.pptx` | Präsentation (15 Folien) für Kickoff |
| `Azure-Landing-Zone-QnA-Vorbereitung.docx` | 11 Themenblöcke A-K mit erwarteten Fragen + Antworten, inkl. Netzwerker-Fragen |
| `Azure-Landing-Zone-Technische-Referenz.docx` | Granular: alle 22 AVM-Module, 123 Assignments, 149 Policy-Defs, 42 Initiativen, 5 Rollen |
| `TECHNICAL-REFERENCE.md` | Markdown-Version der technischen Referenz |

---

## 13. Offene Punkte / Nächste Schritte

### Sofort machbar (kein Azure nötig):

**A1 – DNS Private Resolver**: Flag `deployDnsPrivateResolver` existiert in
`templates/networking/hubnetworking/main.bicep:56` und Subnets sind vorhanden,
aber kein `br/public:avm/res/network/dns-resolver`-Modul ist verdrahtet.
→ Modul ergänzen, gegated durch den Flag (Default `false` → kostenfrei).

**A2 – Decommissioned-MG Guardrail**: Header in
`templates/core/governance/mgmt-groups/decommissioned/main.bicep` verspricht
Deny-Policies, keine sind implementiert.
→ Built-in `Allowed resource types` mit leerer Liste zuweisen (blockt alles).

**A3 – Sandbox-MG Policy-Exemption**: Header verspricht lockere Policies, erbt aber
strikte `alz`-Set. → Policy-Exemption-Modul für `Require-RG-Tag` ergänzen.

**A4 – CI-Hygiene (`.github/workflows/`)**: Derzeit keine Workflows im Accelerator-Branch
(Workflows werden von Bootstrap generiert). CI-Validierung über MCR-Build weiterhin
über Legacy-Workflow möglich — prüfen ob relevant.

### Braucht Azure-Tenant:

**B – Smoke Run** (Details in `docs/ACCELERATOR-BOOTSTRAP.md`):
1. Subscription-ID + GitHub PAT in `config/inputs-github.yaml` eintragen
2. `Deploy-Accelerator` lokal ausführen (Bootstrap Phase 0)
3. Generierten GitHub-Repo-Pipelines mit What-If starten (bevor Apply)
4. First: `network_type: "none"` → €0 Kosten-Risiko

**C – Security-Baseline** (Template `templates/core/security/`):
Defender for Cloud Pricings explizit (nicht nur via Policy), Security Contacts,
Activity-Log-Diagnostics → LAW, Sentinel-Onboarding.

### Mittelfristig:
- PR für Accelerator-Migration → `master` erstellen (wenn bereit)
- Identity-Plattform: Ressourcen/Diagnostics in Identity-Subscription
- Online/Local Landing-Zone-Policies (Require-WAF, Require-CMK)

---

## 14. Kundensituation

- Kunde hat **0 Azure-Vorwissen**, noch kein Kickoff-Gespräch stattgefunden
- Kickoff mit Technikern + **Netzwerker** steht bevor
- Aktuell **1 Subscription** (Single-Subscription-Setup genügt zum Start)
- Empfehlung Subscriptions-Strategie: Start mit 1 Sub, später auf 4 trennen
  (Management, Connectivity, Identity, Security)
- **Subscription-Anforderungen**: EA / MCA / PAYG — kein Free Tier; alle Azure
  Resource Providers werden automatisch durch Accelerator registriert

---

## 15. Schlüssel-Fakten für Folgegespräche

- `avm/ptn/alz/empty:0.3.6` lädt das **gesamte ALZ-Policy-Set automatisch** via
  `lib/alz/` JSON-Dateien (nicht inline im Bicep)
- Policy Assignments werden über `loadJsonContent(...)` in Bicep geladen
- `DoNotEnforce`-Modus via `alzCoreType.bicep` → Policies greifen nicht, bis manuell
  auf `Enabled` gesetzt (gut für sanftes Onboarding)
- Bootstrap ist Terraform-basiert (auch bei `iac_type: bicep`)
- Echte Deployments / What-If brauchen den Azure-Tenant des Kunden
- Bicep offline baubar gegen MCR (kein Azure-Login nötig)
- Generator-Skripte: `docs/kickoff/generate*.py` erzeugen alle Office-Unterlagen neu
