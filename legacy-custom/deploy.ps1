#!/usr/bin/env pwsh
# =============================================================================
# Azure Landing Zone - Vollständiges Deployment-Skript
# Basiert auf: https://github.com/Azure/Azure-Landing-Zones (ALZ Bicep AVM)
#
# VORAUSSETZUNGEN:
#   - Azure CLI >= 2.60 installiert (az version)
#   - Bicep CLI >= 0.29 (az bicep upgrade)
#   - Global Admin / Owner-Rechte auf Tenant-Ebene
#   - Mindestens 4 Azure Subscriptions (Management, Connectivity, Identity, ggf. Corp)
#
# VERWENDUNG:
#   .\deploy.ps1 -TenantId "<YOUR_TENANT_ID>"
#
# REIHENFOLGE der Deployments:
#   1. Int-Root Management Group inkl. Policy-Guardrails (Tenant-Scope)
#   2. Platform Management Groups (Tenant-Scope)
#   3. Landing Zones Management Groups inkl. Corp-Policies (Tenant-Scope)
#   4. Sandbox + Decommissioned Management Groups (Tenant-Scope)
#   5. RBAC Role Assignments auf Management Groups (Tenant-Scope)
#   6. Logging (Management Subscription-Scope)
#   7. Hub Networking inkl. Firewall Policy + Peering (Connectivity Subscription-Scope)
#   8. Optional: Spoke Networking (-DeploySpoke, Workload Subscription-Scope)
#   9. Optional: Subscription Vending (-DeploySubscriptionVending, MG-Scope)
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$ManagementSubscriptionId = "",

    [Parameter(Mandatory = $false)]
    [string]$ConnectivitySubscriptionId = "",

    [Parameter(Mandatory = $false)]
    [ValidateSet("All", "ManagementGroups", "Logging", "Networking")]
    [string]$DeploymentScope = "All",

    [Parameter(Mandatory = $false)]
    [string]$PrimaryLocation = "germanywestcentral",

    [Parameter(Mandatory = $false)]
    [string]$IntRootMgId = "alz",

    # Optional: Spoke-Netzwerk in einer Workload Subscription deployen
    [Parameter(Mandatory = $false)]
    [switch]$DeploySpoke,

    [Parameter(Mandatory = $false)]
    [string]$WorkloadSubscriptionId = "",

    # Optional: Subscription Vending (siehe templates/core/subscription-vending)
    [Parameter(Mandatory = $false)]
    [switch]$DeploySubscriptionVending,

    # Optional: Security Baseline (Defender for Cloud, Security Contacts, Activity-Log -> LAW)
    [Parameter(Mandatory = $false)]
    [switch]$DeploySecurity,

    [Parameter(Mandatory = $false)]
    [string]$SecurityContactEmail = "",

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

# Colours for output
function Write-Header { param($msg) Write-Host "`n========================================" -ForegroundColor Cyan; Write-Host " $msg" -ForegroundColor Cyan; Write-Host "========================================`n" -ForegroundColor Cyan }
function Write-Step   { param($msg) Write-Host "[STEP] $msg" -ForegroundColor Yellow }
function Write-OK     { param($msg) Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Fail   { param($msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }

# ============================================================
# Pre-flight checks
# ============================================================
Write-Header "Azure Landing Zone Deployment"

# Check Azure CLI
try {
    $azVersion = az version --query '"azure-cli"' -o tsv 2>$null
    Write-OK "Azure CLI $azVersion gefunden"
} catch {
    Write-Fail "Azure CLI nicht gefunden. Bitte installieren: https://aka.ms/installazurecli"
    exit 1
}

# Check Bicep
try {
    az bicep upgrade --only-show-errors 2>$null
    $bicepVersion = az bicep version --only-show-errors 2>$null
    Write-OK "Bicep $bicepVersion aktualisiert"
} catch {
    Write-Fail "Bicep konnte nicht aktualisiert werden"
}

# Login check
$account = az account show --query "user.name" -o tsv 2>$null
if (-not $account) {
    Write-Step "Bitte bei Azure anmelden..."
    az login --tenant $TenantId
}
Write-OK "Angemeldet als: $account"

# Set tenant
az account set --tenant $TenantId
Write-OK "Tenant gesetzt: $TenantId"

$DeployArgs = if ($WhatIf) { @("--what-if") } else { @() }
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ============================================================
# Step 1: Management Groups (Tenant-Scope)
# ============================================================
if ($DeploymentScope -in @("All", "ManagementGroups")) {

    Write-Header "Step 1: Management Groups deployen"

    # 1a) Intermediate Root
    Write-Step "1a) Int-Root Management Group..."
    $result = az deployment tenant create `
        --name "alz-introot-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$ScriptRoot\templates\core\governance\mgmt-groups\int-root\main.bicep" `
        --parameters "$ScriptRoot\templates\core\governance\mgmt-groups\int-root\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Int-Root MG Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Int-Root MG deployed"

    # 1b) Platform Management Groups
    Write-Step "1b) Platform Management Groups..."
    $result = az deployment tenant create `
        --name "alz-platform-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$ScriptRoot\templates\core\governance\mgmt-groups\platform\main.bicep" `
        --parameters "$ScriptRoot\templates\core\governance\mgmt-groups\platform\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Platform MG Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Platform MGs deployed (Connectivity, Identity, Management, Security)"

    # 1c) Landing Zones Management Groups
    Write-Step "1c) Landing Zones Management Groups..."
    $result = az deployment tenant create `
        --name "alz-landingzones-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$ScriptRoot\templates\core\governance\mgmt-groups\landingzones\main.bicep" `
        --parameters "$ScriptRoot\templates\core\governance\mgmt-groups\landingzones\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "LZ MG Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Landing Zone MGs deployed (Corp, Online, Local)"

    # 1d) Sandbox
    Write-Step "1d) Sandbox Management Group..."
    az deployment tenant create `
        --name "alz-sandbox-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$ScriptRoot\templates\core\governance\mgmt-groups\sandbox\main.bicep" `
        --parameters "$ScriptRoot\templates\core\governance\mgmt-groups\sandbox\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1 | Out-Null
    Write-OK "Sandbox MG deployed"

    # 1e) Decommissioned
    Write-Step "1e) Decommissioned Management Group..."
    az deployment tenant create `
        --name "alz-decommissioned-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$ScriptRoot\templates\core\governance\mgmt-groups\decommissioned\main.bicep" `
        --parameters "$ScriptRoot\templates\core\governance\mgmt-groups\decommissioned\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1 | Out-Null
    Write-OK "Decommissioned MG deployed"

    # 1f) RBAC Role Assignments (leeres Array in main.bicepparam = No-Op)
    Write-Step "1f) RBAC Role Assignments auf Management Groups..."
    $result = az deployment tenant create `
        --name "alz-rbac-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$ScriptRoot\templates\core\governance\rbac\main.bicep" `
        --parameters "$ScriptRoot\templates\core\governance\rbac\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "RBAC Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "RBAC Role Assignments deployed"
}

# ============================================================
# Step 2: Logging (Management Subscription)
# ============================================================
if ($DeploymentScope -in @("All", "Logging") -and $ManagementSubscriptionId) {

    Write-Header "Step 2: Logging & Management deployen"
    Write-Step "Logging in Management Subscription: $ManagementSubscriptionId"

    az account set --subscription $ManagementSubscriptionId

    $result = az deployment sub create `
        --name "alz-logging-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$ScriptRoot\templates\core\logging\main.bicep" `
        --parameters "$ScriptRoot\templates\core\logging\main.bicepparam" `
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
# ============================================================
if ($DeploymentScope -in @("All", "Networking") -and $ConnectivitySubscriptionId) {

    Write-Header "Step 3: Hub Networking deployen"
    Write-Step "Networking in Connectivity Subscription: $ConnectivitySubscriptionId"

    az account set --subscription $ConnectivitySubscriptionId

    $result = az deployment sub create `
        --name "alz-hubnetworking-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$ScriptRoot\templates\networking\hubnetworking\main.bicep" `
        --parameters "$ScriptRoot\templates\networking\hubnetworking\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Hub Networking Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Hub VNets, Firewall Policy, Azure Firewall, Bastion, Peering, Private DNS Zones deployed"
}

# ============================================================
# Step 4 (optional): Spoke Networking (Workload Subscription)
# ============================================================
if ($DeploySpoke) {

    if (-not $WorkloadSubscriptionId) {
        Write-Fail "-DeploySpoke erfordert -WorkloadSubscriptionId"
        exit 1
    }

    Write-Header "Step 4: Spoke Networking deployen (optional)"
    Write-Step "Spoke in Workload Subscription: $WorkloadSubscriptionId"
    Write-Step "Hinweis: templates\networking\spoke\main.bicepparam vorher anpassen (Hub-VNet-ID, Firewall-IP)"

    az account set --subscription $WorkloadSubscriptionId

    $result = az deployment sub create `
        --name "alz-spoke-$Timestamp" `
        --location $PrimaryLocation `
        --template-file "$ScriptRoot\templates\networking\spoke\main.bicep" `
        --parameters "$ScriptRoot\templates\networking\spoke\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Spoke Networking Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Spoke VNet, Route Table und Hub-Peering deployed"
}

# ============================================================
# Step 5 (optional): Subscription Vending (Management-Group-Scope)
# ============================================================
if ($DeploySubscriptionVending) {

    Write-Header "Step 5: Subscription Vending (optional)"
    Write-Step "Hinweis: templates\core\subscription-vending\main.bicepparam vorher anpassen (Subscription-ID/Billing-Scope, Ziel-MG)"

    $result = az deployment mg create `
        --name "alz-sub-vending-$Timestamp" `
        --management-group-id $IntRootMgId `
        --location $PrimaryLocation `
        --template-file "$ScriptRoot\templates\core\subscription-vending\main.bicep" `
        --parameters "$ScriptRoot\templates\core\subscription-vending\main.bicepparam" `
        @DeployArgs `
        --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Subscription Vending Deployment fehlgeschlagen: $result"
        exit 1
    }
    Write-OK "Subscription erstellt/platziert"
}

# ============================================================
# Step 6 (optional): Security Baseline (je Subscription)
# Defender for Cloud + Security Contacts + Activity-Log -> LAW
# ============================================================
if ($DeploySecurity) {

    Write-Header "Step 6: Security Baseline (optional)"

    # LAW Resource ID fuer Activity-Log-Diagnostics (aus Management-Subscription)
    if ($ManagementSubscriptionId) {
        $env:ALZ_LAW_RESOURCE_ID = "/subscriptions/$ManagementSubscriptionId/resourceGroups/rg-alz-logging-$PrimaryLocation/providers/Microsoft.OperationalInsights/workspaces/law-alz-$PrimaryLocation"
    }
    $env:ALZ_SECURITY_EMAIL = $SecurityContactEmail

    # Auf alle angegebenen Subscriptions anwenden
    $securitySubs = @($ManagementSubscriptionId, $ConnectivitySubscriptionId, $WorkloadSubscriptionId) | Where-Object { $_ }
    foreach ($sub in ($securitySubs | Select-Object -Unique)) {
        Write-Step "Security Baseline in Subscription: $sub"
        az account set --subscription $sub
        $result = az deployment sub create `
            --name "alz-security-$Timestamp" `
            --location $PrimaryLocation `
            --template-file "$ScriptRoot\templates\core\security\main.bicep" `
            --parameters "$ScriptRoot\templates\core\security\main.bicepparam" `
            @DeployArgs `
            --output json 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Security Deployment fehlgeschlagen ($sub): $result"
            exit 1
        }
        Write-OK "Defender-Plaene, Security Contacts und Activity-Log-Diagnostics deployed ($sub)"
    }
}

Write-Header "Deployment abgeschlossen!"
Write-Host @"

Naechste Schritte:
  1. Azure Portal: Management Groups ueberpruefen
     https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups

  2. Policy-Compliance pruefen (Deny-Location, Require-RG-Tag, Deny-Storage-Http, Deny-NIC-PublicIP):
     https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyMenuBlade/~/Compliance

  3. Workload-Subscriptions platzieren: .\deploy.ps1 ... -DeploySubscriptionVending

  4. Spoke VNets deployen: .\deploy.ps1 ... -DeploySpoke -WorkloadSubscriptionId <SUB_ID>

  5. GitHub Repository: https://github.com/Azure/Azure-Landing-Zones

"@ -ForegroundColor Cyan
