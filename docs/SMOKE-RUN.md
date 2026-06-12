# Smoke-Run-Runbook – Azure Landing Zone

Dieses Runbook beschreibt einen **gestaffelten Smoke Run**: eine minimal-invasive
End-to-End-Prüfung, dass die Landing Zone real in Azure deployt. Stufen sind nach
**Risiko/Kosten** geordnet – jede Stufe ist ein eigener Gate. Bei Fehlern stoppen,
Ursache beheben, Stufe wiederholen.

> **Status:** Stufe 0 (statische Validierung) läuft bereits grün in der CI
> (`Validate Bicep Templates`). Die Stufen 1–4 führst du gemäß diesem Runbook aus.

---

## 0. Voraussetzungen

| Tool | Version | Prüfen |
|------|---------|--------|
| Azure CLI | ≥ 2.60 | `az version` |
| Bicep | ≥ 0.29 | `az bicep version` |
| PowerShell | ≥ 7.4 | `pwsh --version` (nur für `deploy.ps1`) |

**Berechtigungen:**
- Tenant Root: *Owner* bzw. *Management Group Contributor* auf der Tenant-Root-MG
  (für MG-Erstellung). Für MG-Erstellung muss der User einmalig unter
  *Microsoft Entra ID → Eigenschaften → Zugriffsverwaltung für Azure-Ressourcen* erhöht
  sein **oder** „Management Group Contributor“ auf Root besitzen.
- *Owner* auf der Management- und der Connectivity-Subscription.

**Variablen setzen** (einmal pro Shell):

```bash
TENANT_ID="<DEINE_TENANT_ID>"
MGMT_SUB="<MANAGEMENT_SUBSCRIPTION_ID>"
CONN_SUB="<CONNECTIVITY_SUBSCRIPTION_ID>"
LOCATION="germanywestcentral"
```

**Anmelden & Tenant prüfen:**

```bash
az login --tenant "$TENANT_ID"
az account show --query "{tenant:tenantId, sub:name}" -o table
```

> Die Parent-MG der Int-Root-MG fällt automatisch auf `tenant().tenantId` zurück
> (Tenant Root). Ein Override ist via `export ALZ_PARENT_MG_ID=<mg-id>` möglich –
> für den Smoke Run **nicht** nötig.

---

## Stufe 0 – Statische Validierung (kostenlos, keine Azure-Wirkung)

Bereits grün in CI. Lokal optional:

```bash
# Bicep-CLI (falls nicht via az): https://github.com/Azure/bicep/releases
for f in $(find templates -name 'main.bicep'); do
  echo "== $f =="; az bicep build --file "$f" || break
done
```

**Erwartung:** 0 Errors, 0 Warnings für alle 11 Templates.

---

## Stufe 1 – What-If (keine Änderungen in Azure)

Preview gegen die echte ARM-API – es wird **nichts** angelegt. Einfachster Weg über
das Skript (deckt alle Scopes ab):

```bash
pwsh ./deploy.ps1 -TenantId "$TENANT_ID" \
  -ManagementSubscriptionId "$MGMT_SUB" \
  -ConnectivitySubscriptionId "$CONN_SUB" \
  -DeploymentScope All -WhatIf
```

Oder granular nur mit der Azure CLI:

```bash
# Management Groups (Tenant-Scope)
az deployment tenant create --name alz-smoke-mg-whatif --location "$LOCATION" \
  --template-file templates/core/governance/mgmt-groups/int-root/main.bicep \
  --parameters templates/core/governance/mgmt-groups/int-root/main.bicepparam --what-if

# Logging (Management-Subscription)
az account set --subscription "$MGMT_SUB"
az deployment sub create --name alz-smoke-log-whatif --location "$LOCATION" \
  --template-file templates/core/logging/main.bicep \
  --parameters templates/core/logging/main.bicepparam --what-if

# Hub Networking (Connectivity-Subscription)
az account set --subscription "$CONN_SUB"
az deployment sub create --name alz-smoke-net-whatif --location "$LOCATION" \
  --template-file templates/networking/hubnetworking/main.bicep \
  --parameters templates/networking/hubnetworking/main.bicepparam --what-if
```

**Erwartung:** `What-if` listet zu erstellende Ressourcen (`+ Create`), **keine Fehler**.
**Gate:** Treten Template-/Parameterfehler auf → hier stoppen und beheben.

---

## Stufe 2 – Management Groups deployen (kostenlos, reversibel)

Erzeugt die MG-Hierarchie, die Policy-Assignments (Deny-Location, Require-RG-Tag,
Deny-Storage-Http, Deny-NIC-PublicIP@corp) und RBAC (nur falls in
`templates/core/governance/rbac/main.bicepparam` Gruppen eingetragen sind).

```bash
pwsh ./deploy.ps1 -TenantId "$TENANT_ID" -DeploymentScope ManagementGroups
```

**Verifizieren:**

```bash
az account management-group list -o table          # alz, alz-platform*, alz-landingzones*, alz-sandbox, alz-decommissioned
az policy assignment list \
  --scope /providers/Microsoft.Management/managementGroups/alz -o table
```

**Erwartung:** 10 Management Groups vorhanden; ≥ 3 Policy-Assignments auf `alz`,
1 auf `alz-landingzones-corp`.

---

## Stufe 3 – Logging deployen (geringe Kosten)

```bash
pwsh ./deploy.ps1 -TenantId "$TENANT_ID" \
  -ManagementSubscriptionId "$MGMT_SUB" -DeploymentScope Logging
```

**Verifizieren:**

```bash
az account set --subscription "$MGMT_SUB"
az monitor log-analytics workspace show \
  -g rg-alz-logging-germanywestcentral -n law-alz-germanywestcentral \
  --query "{name:name, retention:retentionInDays, sku:sku.name}" -o table
az monitor data-collection rule list -g rg-alz-logging-germanywestcentral -o table
```

**Erwartung:** Workspace `law-alz-germanywestcentral` (Retention 365), 3 Data Collection Rules, 1 User-Assigned Identity.

---

## Stufe 4 – Hub Networking deployen (laufende Kosten!)

> **Kostenhinweis:** Azure Firewall ≈ 1,25 €/h, Bastion ≈ 0,19 €/h. Für einen
> günstigen Netzwerk-Smoke in `templates/networking/hubnetworking/main.bicepparam`
> beim **primären Hub** setzen:
> `azureFirewallSettings.deployAzureFirewall: false` (Zeile 67) und
> `bastionHostSettings.deployBastion: false` (Zeile 78).
> Dann entstehen nur VNets + Peering + Private DNS Zones (praktisch kostenlos),
> der Datenpfad-Teil (Firewall Policy/Regeln) wird allerdings nicht mitgetestet.

```bash
pwsh ./deploy.ps1 -TenantId "$TENANT_ID" \
  -ConnectivitySubscriptionId "$CONN_SUB" -DeploymentScope Networking
```

**Verifizieren:**

```bash
az account set --subscription "$CONN_SUB"
# VNets in beiden Regionen
az network vnet list -o table
# Peering-Status (muss "Connected" sein)
az network vnet peering list \
  -g rg-alz-conn-germanywestcentral --vnet-name vnet-alz-germanywestcentral \
  --query "[].{name:name, state:peeringState}" -o table
# Firewall + gebundene Policy (nur falls deployAzureFirewall=true)
az network firewall list -g rg-alz-conn-germanywestcentral \
  --query "[].{name:name, policy:firewallPolicy.id}" -o table
# Private DNS Zones
az network private-dns zone list -g rg-alz-dns-germanywestcentral -o table
```

**Erwartung:** 2 Hub-VNets; Peering-Status `Connected`; (falls aktiviert) Firewall
mit gebundener `afwp-alz-…`-Policy; 37 Private DNS Zones am primären Hub verlinkt.

---

## Gesamt-Checkliste

- [ ] Stufe 1 What-If aller Scopes ohne Fehler
- [ ] 10 Management Groups + Policy-Assignments vorhanden
- [ ] Log Analytics Workspace + 3 DCRs + UAMI
- [ ] 2 Hub-VNets, Peering `Connected`
- [ ] (falls aktiv) Firewall mit Policy gebunden, Bastion vorhanden, Private DNS verlinkt

---

## Rückbau / Teardown (Reihenfolge umgekehrt)

```bash
# Stufe 4 + 3: Resource Groups löschen
az account set --subscription "$CONN_SUB"
az group delete -n rg-alz-conn-germanywestcentral --yes
az group delete -n rg-alz-dns-germanywestcentral  --yes
az account set --subscription "$MGMT_SUB"
az group delete -n rg-alz-logging-germanywestcentral --yes

# Stufe 2: Management Groups (erst Subscriptions zurück nach Tenant-Root verschieben,
# dann Kinder vor Eltern löschen)
for mg in alz-platform-connectivity alz-platform-identity alz-platform-management \
          alz-platform-security alz-landingzones-corp alz-landingzones-online \
          alz-landingzones-local alz-platform alz-landingzones alz-sandbox \
          alz-decommissioned alz; do
  az account management-group delete --name "$mg" 2>/dev/null || true
done
```

> Eine MG lässt sich nur löschen, wenn sie **keine** Subscriptions oder Kind-MGs mehr
> enthält. Die obige Reihenfolge berücksichtigt das (Kinder zuerst).

---

## Kostenübersicht (Smoke, wenige Stunden)

| Stufe | Ressourcen | Kosten |
|-------|-----------|--------|
| 1 What-If | – | 0 |
| 2 Management Groups | MGs, Policies | 0 |
| 3 Logging | LAW + DCRs + UAMI | gering (Ingestion) |
| 4 Networking ohne Firewall/Bastion | VNets, Peering, DNS | praktisch 0 |
| 4 Networking voll | + Firewall + Bastion | ~1,5 €/h |

---

## Troubleshooting

| Symptom | Ursache / Fix |
|---------|---------------|
| `AuthorizationFailed` auf Tenant-Scope | User braucht „Management Group Contributor“ auf Root-MG bzw. erhöhten Zugriff. |
| `RequestDisallowedByPolicy` (Region) | Die `Deny-Location`-Policy auf `alz` erlaubt nur `germanywestcentral`/`northeurope`. Andere Regionen werden geblockt – Location anpassen. |
| `InvalidPolicyAssignmentName` | Assignment-Namen sind auf MG-Scope auf 24 Zeichen begrenzt (im Repo eingehalten). |
| AVM-Restore schlägt fehl | Netzwerkzugriff auf `mcr.microsoft.com` nötig; `az bicep upgrade` ausführen. |
| Peering bleibt `Disconnected` | Beide Hub-VNets müssen deployt sein; Deployment erneut laufen lassen (idempotent). |

---

## Alternative: Smoke über CI (sobald OIDC eingerichtet)

Aktuell sind die OIDC-Secrets **nicht** gesetzt (der `whatif`-Job überspringt daher
sauber). Nach Einrichtung von Service Principal + Federated Credential + den 4
Secrets (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_MANAGEMENT_SUBSCRIPTION_ID`,
`AZURE_CONNECTIVITY_SUBSCRIPTION_ID`, siehe README) lässt sich der Smoke per
*Actions → Deploy Azure Landing Zone → Run workflow* mit `What-If only = true`
auslösen.
