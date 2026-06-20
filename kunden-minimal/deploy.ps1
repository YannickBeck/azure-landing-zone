#!/usr/bin/env pwsh
# =============================================================================
# Azure Landing Zone - Kunden-Minimal Deployment (3 Subscriptions)
# Basiert auf: https://github.com/Azure/Azure-Landing-Zones (ALZ Bicep AVM)
#
# SETUP: 3 Subscriptions
#   - Connectivity  → Hub-Netzwerk, Azure Firewall, Logging
#   - Produktion    → Erste Workload-Spoke-VNets
#   - Sandbox       → Entwicklung, Tests, Experimente
#
# VORAUSSETZUNGEN:
#   - Azure CLI >= 2.60 installiert (az version)
#   - Bicep CLI >= 0.29 (az bicep upgrade)
#   - Global Admin / Owner-Rechte auf Tenant-Ebene
#   - 3 Azure Subscriptions bereitgestellt
#
# VERWENDUNG:
#   .\deploy.ps1 -TenantId "<YOUR_TENANT_ID>" `
#                -ConnectivitySubscriptionId "<CONN_SUB_ID>"
#
# REIHENFOLGE der Deployments:
#   1. Int-Root Management Group inkl. Policy-Guardrails (Tenant-Scope)
#   2. Platform Management Group: Connectivity (Tenant-Scope)
#   3. Landing Zones Management Group: Corp (Tenant-Scope)
#   4. Sandbox + Decommissioned Management Groups (Tenant-Scope)
#   5. RBAC Role Assignments auf Management Groups (Tenant-Scope)
#   6. Logging (Connectivity Subscription-Scope)
#   7. Hub Networking: Firewall Standard, kein Bastion/VPN (Connectivity Subscription-Scope)
#   8. Optional: Spoke Networking (-DeploySpoke, Produktion Subscription-Scope)
#   9. Optional: Subscription Vending (-DeploySubscriptionVending, MG-Scope)
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$ConnectivitySubscriptionId = "",

    [Parameter(Mandatory = $false)]
    [ValidateSet("All", "ManagementGroups", "Logging", "Networking")]
    [string]$DeploymentScope = "All",

    [Parameter(Mandatory = $false)]
    [string]$PrimaryLocation = "germanywestcentral",

    [Parameter(Mandatory = $false)]
    [string]$IntRootMgId = "alz",

    # Optional: Spoke-Netzwerk in Produktion Subscription deployen
    [Parameter(Mandatory = $false)]
    [switch]$DeploySpoke,

    [Parameter(Mandatory = $false)]
    [string]$ProduktionSubscriptionId = "",

    # Optional: Subscription Vending (siehe templates/core/subscription-vending)
    [Parameter(Mandatory = $false)]
    [switch]$DeploySubscriptionVending,

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
$TemplatesRoot = Join-Path $PSScriptRoot ".." "templates"

function Write-Header { param($msg) Write-Host "`n========================================" -ForegroundColor Cyan; Write-Host " $msg" -ForegroundColor Cyan; Write-Host "========================================`n" -ForegroundColor Cyan }
function Write-Step   { param($msg) Write-Host "[STEP] $msg" -ForegroundColor Yellow }
function Write-OK     { param($msg) Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Fail   { param($msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }

# ============================================================
# Pre-flight checks
# ============================================================
Write-Header "Azure Landing Zone – Kunden-Minimal Deployment (~€765/Monat)"

try {
    $azVersion = az version --query '"azure-cli"' -o tsv 2>$null
    Write-OK "Azure CLI $azVersion gefunden"
} catch {
    Write-Fail "Azure CLI nicht gefunden. Bitte installieren: https://aka.ms/installazurecli"
    exit 1
}

try {
    az bicep upgrade --only-show-errors 2>$null
    $bicepVersion = az bicep version --only-show-errors 2>$null
    Write-OK "Bicep $bicepVersion aktualisiert"
} catch {
    Write-Fail "Bicep konnte nicht aktualisiert werden"
}

$account = az account show --query "user.name" -o tsv 2>$null
if (-not $account) {
    Write-Step "Bitte bei Azure anmelden..."
    az login --tenant $TenantId
}
Write-OK "Angemeldet als: $account"

az account set --tenant $TenantId
Write-OK "Tenant gesetzt: $TenantId"

$DeployArgs = if ($WhatIf) { @("--what-if") } else { @() }
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ============================================================
# Step 1: Management Groups (Tenant-Scope) – 8 MGs
# ============================================================
if ($DeploymentScope -in @("All", "ManagementGroups")) {

    Write-Header "Step 1: Management Groups deployen (8 MGs)"

    # 1a) Intermediate Root (alz) + vollständiges Policy-Set
    Write-Step "1a) Int-Root Management Group + Policy-Guardrails..."
    $result = az deployment tenant create `
        --name "alz-introot-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$TemplatesRoot\core\governance\mgmt-groups\int-root\main.bicep" `
        --parameters "$TemplatesRoot\core\governance\mgmt-groups\int-root\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Int-Root MG Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Int-Root MG + Policy-Set deployed"

    # 1b) Platform MG: nur Connectivity (kein Identity/Management/Security im Minimal-Setup)
    Write-Step "1b) Platform Management Group (Connectivity)..."
    $result = az deployment tenant create `
        --name "alz-platform-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$TemplatesRoot\core\governance\mgmt-groups\platform\main.bicep" `
        --parameters "$TemplatesRoot\core\governance\mgmt-groups\platform\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Platform MG Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Platform MG deployed (alz-platform-connectivity)"

    # 1c) Landing Zones MG: nur Corp (kein Online/Local im Minimal-Setup)
    Write-Step "1c) Landing Zones Management Group (Corp)..."
    $result = az deployment tenant create `
        --name "alz-landingzones-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$TemplatesRoot\core\governance\mgmt-groups\landingzones\main.bicep" `
        --parameters "$TemplatesRoot\core\governance\mgmt-groups\landingzones\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "LZ MG Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Landing Zone MG deployed (alz-landingzones-corp)"

    # 1d) Sandbox
    Write-Step "1d) Sandbox Management Group..."
    az deployment tenant create `
        --name "alz-sandbox-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$TemplatesRoot\core\governance\mgmt-groups\sandbox\main.bicep" `
        --parameters "$TemplatesRoot\core\governance\mgmt-groups\sandbox\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1 | Out-Null
    Write-OK "Sandbox MG deployed"

    # 1e) Decommissioned
    Write-Step "1e) Decommissioned Management Group..."
    az deployment tenant create `
        --name "alz-decommissioned-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$TemplatesRoot\core\governance\mgmt-groups\decommissioned\main.bicep" `
        --parameters "$TemplatesRoot\core\governance\mgmt-groups\decommissioned\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1 | Out-Null
    Write-OK "Decommissioned MG deployed"

    # 1f) RBAC Role Assignments
    Write-Step "1f) RBAC Role Assignments auf Management Groups..."
    $result = az deployment tenant create `
        --name "alz-rbac-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$TemplatesRoot\core\governance\rbac\main.bicep" `
        --parameters "$TemplatesRoot\core\governance\rbac\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "RBAC Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "RBAC Role Assignments deployed"
}

# ============================================================
# Step 2: Logging (Connectivity Subscription)
# Hinweis: Im 3-Sub-Minimalmodell läuft Logging in der Connectivity Sub,
#          nicht in einer eigenen Management Sub.
# ============================================================
if ($DeploymentScope -in @("All", "Logging") -and $ConnectivitySubscriptionId) {

    Write-Header "Step 2: Logging deployen (Connectivity Subscription)"
    Write-Step "Log Analytics Workspace in Connectivity Sub: $ConnectivitySubscriptionId"

    az account set --subscription $ConnectivitySubscriptionId

    $result = az deployment sub create `
        --name "alz-logging-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$TemplatesRoot\core\logging\main.bicep" `
        --parameters "$TemplatesRoot\core\logging\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Logging Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Log Analytics Workspace, DCRs und Managed Identity deployed"
}

# ============================================================
# Step 3: Hub Networking (Connectivity Subscription)
# Kunden-Minimal: Firewall Standard aktiv, Bastion/VPN/DNS-Resolver zurückgestellt
# Verwendet: kunden-minimal/hubnetworking.bicepparam
# ============================================================
if ($DeploymentScope -in @("All", "Networking") -and $ConnectivitySubscriptionId) {

    Write-Header "Step 3: Hub Networking deployen (~€700/Monat – Firewall Standard)"
    Write-Step "Hub in Connectivity Sub: $ConnectivitySubscriptionId"
    Write-Step "Konfiguration: deployBastion=false, deployVpnGateway=false, 1 Region (GWC)"

    az account set --subscription $ConnectivitySubscriptionId

    $result = az deployment sub create `
        --name "alz-hubnetworking-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$TemplatesRoot\networking\hubnetworking\main.bicep" `
        --parameters "$ScriptRoot\hubnetworking.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Hub Networking Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Hub VNet, Azure Firewall Standard und Private DNS Zones deployed"
    Write-OK "Zurückgestellt: Bastion (deployBastion: true wenn VPN-Tunnel nicht vorhanden)"
    Write-OK "Zurückgestellt: VPN Gateway (deployVpnGateway: true wenn On-Prem konkret geplant)"
}

# ============================================================
# Step 4 (optional): Spoke Networking (Produktion Subscription)
# ============================================================
if ($DeploySpoke) {

    if (-not $ProduktionSubscriptionId) {
        Write-Fail "-DeploySpoke erfordert -ProduktionSubscriptionId"
        exit 1
    }

    Write-Header "Step 4: Spoke Networking deployen (Produktion Subscription)"
    Write-Step "Spoke in Produktion Sub: $ProduktionSubscriptionId"
    Write-Step "Hinweis: templates\networking\spoke\main.bicepparam anpassen (Hub-VNet-ID, Firewall-IP)"

    az account set --subscription $ProduktionSubscriptionId

    $result = az deployment sub create `
        --name "alz-spoke-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$TemplatesRoot\networking\spoke\main.bicep" `
        --parameters "$TemplatesRoot\networking\spoke\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Spoke Networking Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Spoke VNet, Route Table und Hub-Peering deployed"
}

# ============================================================
# Step 5 (optional): Subscription Vending (MG-Scope)
# ============================================================
if ($DeploySubscriptionVending) {

    Write-Header "Step 5: Subscription Vending (optional)"
    Write-Step "Ziel-MG: alz-landingzones-corp (Produktion) oder alz-sandbox"
    Write-Step "Hinweis: templates\core\subscription-vending\main.bicepparam anpassen"

    $result = az deployment mg create `
        --name "alz-sub-vending-$Timestamp" `
        --management-group-id $IntRootMgId `
        --location $PrimaryLocation `
        --template-file "$TemplatesRoot\core\subscription-vending\main.bicep" `
        --parameters "$TemplatesRoot\core\subscription-vending\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Subscription Vending Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Subscription erstellt und in Ziel-MG platziert"
}

Write-Header "Deployment abgeschlossen! (~€765/Monat)"
Write-Host @"

Kosten-Uebersicht (Kunden-Minimal):
  Azure Firewall Standard   ~€700/Monat  [aktiv]
  Log Analytics Workspace   ~€50/Monat   [aktiv]
  Private DNS Zones         ~€15/Monat   [aktiv]
  Azure Bastion             €0/Monat     [zurueckgestellt – Kunde nutzt eigenen Gateway]
  VPN Gateway               €0/Monat     [zurueckgestellt – aktivieren wenn On-Prem geplant]
  ─────────────────────────────────────────────
  Gesamt                    ~€765/Monat

Skalierung (Schalter in hubnetworking.bicepparam):
  + VPN Gateway  → deployVpnGateway: true   (+€140/Monat, bei On-Prem-Anbindung)
  + Bastion      → deployBastion: true      (+€120/Monat, wenn kein VPN-Tunnel vorhanden)
  + DNS Resolver → deployDnsPrivateResolver: true (+€25/Monat)

Naechste Schritte:
  1. Management Groups pruefen:
     https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups

  2. Policy-Compliance pruefen:
     https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyMenuBlade/~/Compliance

  3. Connectivity Sub: Subscriptions zuweisen
     alz-platform-connectivity → Connectivity Sub
     alz-landingzones-corp     → Produktion Sub
     alz-sandbox               → Sandbox Sub

  4. Erste Workload: .\deploy.ps1 ... -DeploySpoke -ProduktionSubscriptionId <SUB_ID>

"@ -ForegroundColor Cyan
