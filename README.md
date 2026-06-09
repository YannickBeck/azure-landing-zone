# Azure Landing Zone – Bicep

Vollständiges Azure Landing Zone Deployment mit Bicep, basierend auf der offiziellen Microsoft-Dokumentation und dem [Azure/Azure-Landing-Zones](https://github.com/Azure/Azure-Landing-Zones) GitHub-Repository (AVM-basierter Ansatz, Stand 2026).

## Architektur

```
Tenant Root
└── alz  (Intermediate Root)
    ├── alz-platform
    │   ├── alz-platform-connectivity   ← Hub VNet, Firewall, Gateways
    │   ├── alz-platform-identity       ← AD DS, AAD Connect
    │   ├── alz-platform-management     ← Log Analytics, Sentinel
    │   └── alz-platform-security       ← Defender for Cloud
    ├── alz-landingzones
    │   ├── alz-landingzones-corp       ← Interne Workloads (privat)
    │   ├── alz-landingzones-online     ← Internet-facing Workloads
    │   └── alz-landingzones-local      ← Sovereign / Confidential
    ├── alz-sandbox                     ← Experimente, lockere Policies
    └── alz-decommissioned              ← Stilllegung
```

## Voraussetzungen

| Tool | Mindestversion | Installation |
|------|---------------|--------------|
| Azure CLI | 2.60 | `winget install Microsoft.AzureCLI` |
| Bicep | 0.29 | `az bicep upgrade` |
| PowerShell | 7.4 | `winget install Microsoft.PowerShell` |

**Azure-Berechtigungen:**
- Tenant: Global Administrator (für MG-Erstellung)
- Management Subscription: Owner
- Connectivity Subscription: Owner

## Schnellstart

### 1. Repository klonen

```powershell
git clone https://github.com/YannickBeck/azure-landing-zone.git
cd azure-landing-zone
```

### 2. Konfiguration anpassen

Öffne `config/platform-landing-zone.yaml` und ersetze alle `<PLATZHALTER>`:

```yaml
tenant:
  id: "<DEINE_TENANT_ID>"
subscriptions:
  management:
    id: "<MANAGEMENT_SUB_ID>"
  connectivity:
    id: "<CONNECTIVITY_SUB_ID>"
```

Danach die `.bicepparam`-Dateien aktualisieren (die Werte werden automatisch referenziert).

### 3. Deployment starten

```powershell
# Nur Management Groups deployen (empfohlen für ersten Test)
.\deploy.ps1 `
  -TenantId "<DEINE_TENANT_ID>" `
  -DeploymentScope ManagementGroups

# Vollständiges Deployment
.\deploy.ps1 `
  -TenantId "<DEINE_TENANT_ID>" `
  -ManagementSubscriptionId "<MANAGEMENT_SUB_ID>" `
  -ConnectivitySubscriptionId "<CONNECTIVITY_SUB_ID>" `
  -DeploymentScope All

# What-If (keine Änderungen, nur Preview)
.\deploy.ps1 `
  -TenantId "<DEINE_TENANT_ID>" `
  -DeploymentScope All `
  -WhatIf
```

### 4. Einzelne Module deployen

```powershell
# Int-Root Management Group
az deployment tenant create \
  --name "alz-introot" \
  --location germanywestcentral \
  --template-file templates/core/governance/mgmt-groups/int-root/main.bicep \
  --parameters templates/core/governance/mgmt-groups/int-root/main.bicepparam

# Logging (im Management-Subscription Kontext)
az account set --subscription "<MANAGEMENT_SUB_ID>"
az deployment sub create \
  --name "alz-logging" \
  --location germanywestcentral \
  --template-file templates/core/logging/main.bicep \
  --parameters templates/core/logging/main.bicepparam

# Hub Networking (im Connectivity-Subscription Kontext)
az account set --subscription "<CONNECTIVITY_SUB_ID>"
az deployment sub create \
  --name "alz-hubnetworking" \
  --location germanywestcentral \
  --template-file templates/networking/hubnetworking/main.bicep \
  --parameters templates/networking/hubnetworking/main.bicepparam
```

## Projektstruktur

```
├── .github/
│   └── workflows/
│       └── deploy-alz.yml          ← GitHub Actions CI/CD Pipeline
├── config/
│   └── platform-landing-zone.yaml  ← Zentrale Konfiguration
├── templates/
│   ├── core/
│   │   ├── alzCoreType.bicep        ← Shared Type-Definitionen
│   │   ├── governance/
│   │   │   └── mgmt-groups/
│   │   │       ├── int-root/        ← Intermediate Root MG + Policies
│   │   │       ├── platform/        ← Platform MG + Sub-MGs
│   │   │       ├── landingzones/    ← LZ MG + Corp/Online/Local
│   │   │       ├── sandbox/         ← Sandbox MG
│   │   │       └── decommissioned/  ← Decommissioned MG
│   │   └── logging/
│   │       ├── main.bicep           ← Log Analytics, DCRs, Managed Identity
│   │       └── main.bicepparam
│   └── networking/
│       ├── hubnetworking/
│       │   ├── main.bicep           ← Hub VNets, Firewall, Bastion, Gateways
│       │   └── main.bicepparam
│       └── virtualwan/
│           ├── main.bicep           ← Virtual WAN Alternative
│           └── main.bicepparam
├── bicepconfig.json                 ← Bicep Konfiguration + AVM-Registry
├── deploy.ps1                       ← Haupt-Deployment-Skript
└── .gitignore
```

## GitHub Actions CI/CD

Die Pipeline in `.github/workflows/deploy-alz.yml` erfordert folgende **GitHub Secrets**:

| Secret | Beschreibung |
|--------|-------------|
| `AZURE_CLIENT_ID` | Service Principal / Managed Identity Client ID |
| `AZURE_TENANT_ID` | Azure Tenant ID |
| `AZURE_MANAGEMENT_SUBSCRIPTION_ID` | Management Subscription ID |
| `AZURE_CONNECTIVITY_SUBSCRIPTION_ID` | Connectivity Subscription ID |

### OIDC Federated Identity einrichten

```bash
# Service Principal erstellen
az ad sp create-for-rbac --name "sp-alz-deployment" --role Owner \
  --scopes /providers/Microsoft.Management/managementGroups/<ROOT_MG>

# Federated Identity für GitHub Actions konfigurieren
az ad app federated-credential create \
  --id "<APP_ID>" \
  --parameters '{
    "name": "github-alz",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<OWNER>/<REPO>:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## Module (Azure Verified Modules)

Dieses Projekt nutzt [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/) über die öffentliche Bicep-Registry (`mcr.microsoft.com`):

| Modul | Version | Verwendung |
|-------|---------|-----------|
| `avm/res/management/management-group` | 0.1.2 | Alle Management Groups |
| `avm/res/resources/resource-group` | 0.4.1 | Resource Groups |
| `avm/res/operational-insights/workspace` | 0.9.0 | Log Analytics |
| `avm/res/automation/automation-account` | 0.10.0 | Automation Account |
| `avm/res/managed-identity/user-assigned-identity` | 0.4.1 | Managed Identity |
| `avm/res/insights/data-collection-rule` | 0.4.2 | DCRs (VM Insights, CT, SQL) |
| `avm/res/network/virtual-network` | 0.5.1 | Hub VNets |
| `avm/res/network/azure-firewall` | 0.5.1 | Azure Firewall |
| `avm/res/network/bastion-host` | 0.4.1 | Azure Bastion |
| `avm/res/network/virtual-network-gateway` | 0.5.0 | VPN/ER Gateways |
| `avm/res/network/private-dns-zone` | 0.6.0 | Private DNS Zones |
| `avm/res/network/ddos-protection-plan` | 0.3.0 | DDoS Protection |
| `avm/res/network/virtual-wan` | 0.3.0 | Virtual WAN |

## Referenzen

- [Azure Landing Zones Dokumentation](https://azure.github.io/Azure-Landing-Zones/)
- [ALZ Bicep Accelerator Repository](https://github.com/Azure/alz-bicep-accelerator)
- [Azure Verified Modules Registry](https://azure.github.io/Azure-Verified-Modules/)
- [Bicep Dokumentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
