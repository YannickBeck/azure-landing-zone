# ALZ Bicep Accelerator – Bootstrap-Runbook

Dieses Runbook beschreibt, wie die Platform Landing Zone über die offizielle
`ALZ` PowerShell (`Deploy-Accelerator`) ausgerollt wird. Offizielle Referenz:
<https://aka.ms/alz/acc>.

> **Diese Schritte erzeugen echte Azure- und GitHub-Ressourcen.** Sie können nicht
> in einer isolierten CI-/Sandbox-Umgebung ohne Tenant-Zugang und GitHub-PAT
> ausgeführt werden – sie laufen interaktiv auf einer Maschine mit Azure-Login.

---

## 1. Voraussetzungen

| Anforderung | Detail |
|---|---|
| PowerShell | ≥ 7.4 |
| Azure CLI | ≥ 2.60, angemeldet (`az login`) |
| Berechtigungen | Owner auf den Subscriptions + erhöhter Zugriff am Tenant Root (Management-Group-Erstellung) |
| GitHub PAT | Classic Token mit `repo`, `workflow`, `admin:org`, `delete_repo` |
| Module | `Install-Module ALZ -Scope CurrentUser` |

**Erhöhter Zugriff am Tenant Root** (einmalig, danach wieder deaktivieren):
Entra ID → Properties → *Access management for Azure resources* → **Ein**.

---

## 2. Konfiguration befüllen

Die befüllten Vorlagen liegen in [`../config/`](../config/):

- `config/inputs-github.yaml` – Bootstrap (Tenant, Subscriptions, GitHub-Org, PAT)
- `config/platform-landing-zone.yaml` – Starter-Modul (Regionen, MG-IDs, `network_type`)

Mindestens zu setzen:
1. `subscription_ids.*` – die vier Platform-Subscriptions (siehe Single-Subscription unten)
2. `github_personal_access_token` (oder `TF_VAR_github_personal_access_token`)
3. `github_organization_name`, `apply_approvers`

### Single-Subscription-Setup

Steht (noch) nur **eine** Subscription bereit, alle vier Felder in
`subscription_ids` auf **dieselbe** ID setzen:

```yaml
subscription_ids:
  management:   "<SUBSCRIPTION_ID>"
  identity:     "<SUBSCRIPTION_ID>"
  connectivity: "<SUBSCRIPTION_ID>"
  security:     "<SUBSCRIPTION_ID>"
```

Die Trennung kann später erfolgen (Subscriptions in die jeweilige Management Group
verschieben). Die Management-Group-Hierarchie und Policies werden trotzdem vollständig
erstellt.

---

## 3. Kostenarme Variante (Smoke Run / kein Kostenrisiko)

Die Microsoft-Standardwerte aktivieren **alle** Netzwerk-Dienste in **beiden**
Regionen (≈ €5.800/Monat, inkl. DDoS + doppelter Firewalls/Gateways). Für einen
risikofreien Erst-Rollout zwei Wege:

**A) Netzwerk komplett überspringen** (kostenärmster Weg) – in
`config/platform-landing-zone.yaml`:

```yaml
network_type: "none"
```

→ deployt nur Management Groups + **volles Policy-Set** + Logging (≈ €0).

**B) Netzwerk minimal** – in `templates/networking/hubnetworking/main.bicepparam`
die Schalter reduzieren (Beispiel je Hub):

```bicep
azureFirewallSettings:        { deployAzureFirewall: false }
bastionHostSettings:          { deployBastion: false }
vpnGatewaySettings:           { deployVpnGateway: false }
expressRouteGatewaySettings:  { deployExpressRouteGateway: false }
ddosProtectionPlanSettings:   { deployDdosProtectionPlan: false }
privateDnsSettings:           { deployPrivateDnsZones: true, deployDnsPrivateResolver: false }
```

→ VNets + Private DNS Zones (≈ €15/Monat), keine teuren Dienste.

> **DDoS Protection (`deployDdosProtectionPlan`) ist im Microsoft-Default `true`** –
> das ist der teuerste Einzelposten (~€2.500/Monat). Bewusst entscheiden.

---

## 4. Bootstrap ausführen (Phase 0)

```powershell
az login
Install-Module ALZ -Scope CurrentUser

Deploy-Accelerator `
  -inputs ./config/inputs-github.yaml ./config/platform-landing-zone.yaml `
  -output ./output
```

Der Bootstrap (Terraform-basiert, auch bei `iac_type: bicep`) erstellt:

- Bootstrap-Resource-Group + Storage (State) + **Managed Identity mit Federated
  Credentials** (passwortloses OIDC für die Pipelines)
- ein **GitHub-Repository** mit dem Starter-Modul + generierten Deployment-Pipelines
- GitHub-Environments mit Approval-Gates (`apply_approvers`)

---

## 5. Deployment (Phase 1+)

Nach dem Bootstrap deployen die **generierten Pipelines** im neuen Repo die 18
geordneten Stufen aus `.config/ALZ-Powershell.config.json`:

1. Governance – Intermediate Root (volles Policy-Set)
2–5. Landing Zones (+ corp/online/local)
6–10. Platform (+ connectivity/identity/management/security)
11–12. Sandbox, Decommissioned
13–15. Cross-MG RBAC
16. Core Logging
17/18. Networking (Hub **oder** Virtual WAN, je `network_type`)

Empfehlung: erste Ausführung mit **What-If** prüfen (Pipeline-Eingang), dann Apply
über das Approval-Gate freigeben.

---

## 6. Lokale Validierung (ohne Azure)

Alle Templates bauen offline gegen die MCR:

```bash
bicep build templates/core/governance/mgmt-groups/int-root/main.bicep
```

> Die `.bicepparam` enthalten `{{platzhalter}}`, die der Accelerator beim Bootstrap
> ersetzt – `build-params` darauf schlägt daher absichtlich fehl, `build` der
> `.bicep` funktioniert.

---

## 7. Aufräumen

- Bootstrap rückbauen: im `./output`-Verzeichnis `terraform destroy` (bzw. der im
  Output dokumentierte Befehl).
- Erhöhten Zugriff am Tenant Root wieder **deaktivieren**.
- Management Groups bleiben kostenlos; Logging-RG löschen entfernt die LAW-Kosten.
