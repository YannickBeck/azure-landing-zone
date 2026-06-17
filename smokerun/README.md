# ALZ Smoke Run – Single Subscription

Vollständiger End-to-End-Test der Azure Landing Zone auf **einer einzigen Subscription**.
Ideal für Demo-Umgebungen, Kundenpräsentationen und initiale Validierung.

## Was wird deployed

| Ressource | Smoke Run | Produktion |
|-----------|-----------|-----------|
| 12 Management Groups | ✅ identisch | ✅ |
| 149 Policies / 123 Assignments | ✅ identisch | ✅ |
| Log Analytics Workspace | ✅ (30 Tage) | ✅ (365 Tage) |
| 3 Data Collection Rules | ✅ | ✅ |
| Hub VNet + Subnetze | ✅ (1 Region) | ✅ (2 Regionen) |
| Private DNS Zones | ✅ | ✅ |
| Azure Firewall | ❌ (~€1.100/Monat sparen) | ✅ |
| Azure Bastion | ❌ (~€120/Monat sparen) | ✅ |
| VPN / ExpressRoute Gateway | ❌ | optional |
| DDoS Protection Plan | ❌ | optional |

**Geschätzte Kosten:** < €5 für einen mehrstündigen Smoke Run.

## Voraussetzungen

- Azure CLI ≥ 2.60: `az version`
- Bicep: `az bicep upgrade`
- Owner-Berechtigung auf der Subscription
- Einmalig erhöhter Zugriff auf Tenant Root (für MG-Erstellung):
  Entra ID → Eigenschaften → *Zugriffsverwaltung für Azure-Ressourcen* → Ja

## Schnellstart

```bash
# 1. Variablen setzen
export TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export SUB_ID="yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"

# 2. What-If (kein echtes Deploy – empfohlen zum Start)
bash smokerun/run.sh

# 3. Echtes Deploy
bash smokerun/run.sh --deploy

# 4. Ergebnis prüfen (auch separat ausführbar)
bash smokerun/verify.sh

# 5. Teardown nach dem Test
bash smokerun/teardown.sh
```

## Dateistruktur

```
smokerun/
├── run.sh          Hauptskript (What-If + Deploy)
├── verify.sh       Prüft alle erwarteten Ressourcen
├── teardown.sh     Bereinigt alle Smoke-Ressourcen
└── params/
    ├── mgmt-groups.bicepparam    MG-Hierarchie (identisch Produktion)
    ├── logging.bicepparam        LAW, DCRs (vereinfacht, 30 Tage)
    └── hubnetworking.bicepparam  Hub VNet + DNS (ohne Firewall/Bastion)
```

## Parameter-Unterschiede zu Produktion

| Parameter | Smoke Run | Produktion |
|-----------|-----------|-----------|
| Regionen | 1 (germanywestcentral) | 2 (GWC + NE) |
| Log-Retention | 30 Tage | 365 Tage |
| Ressource-Präfix | `alz-poc-*` | `alz-*` |
| Hub-Peering | nein | ja (bidirektional) |
| `deployAzureFirewall` | false | true |
| `deployBastion` | false | true |

## Troubleshooting

| Fehler | Ursache | Fix |
|--------|---------|-----|
| `AuthorizationFailed` (Tenant-Scope) | Erhöhter Zugriff fehlt | Entra ID → Eigenschaften → Zugriffsverwaltung aktivieren |
| `RequestDisallowedByPolicy` | Deny-Location greift für andere Region | Region in params auf `germanywestcentral` prüfen |
| `already exists` bei MGs | MGs von vorherigem Run vorhanden | Idempotent – einfach nochmal laufen lassen |
| Teardown hängt bei MG-Löschen | Subscription noch in MG | `subscription remove` im Teardown-Skript erledigt das automatisch |

## Von Smoke auf Produktion hochstufen

Die Smoke-Sub kann direkt als Produktions-Subscription weiterverwendet werden:

```bash
# Sub in korrekte MG verschieben (z.B. platform-management für LAW)
az account management-group subscription add \
  --name alz-platform-management \
  --subscription "$SUB_ID"
```

Alle Ressourcen bleiben unverändert. Danach die produktiven Param-Files
aus `templates/` für Firewall, Bastion und die zweite Region deployen.
