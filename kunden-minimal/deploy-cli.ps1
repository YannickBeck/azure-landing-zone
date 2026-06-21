#!/usr/bin/env pwsh
# =============================================================================
# Azure Landing Zone – Kunden-Minimal CLI Deployment
# Verwendung:
#   .\deploy-cli.ps1 -TenantId "<ID>" -ConnectivitySubscriptionId "<ID>"
#   .\deploy-cli.ps1 -TenantId "<ID>" -ConnectivitySubscriptionId "<ID>" -WhatIf
# =============================================================================
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$ConnectivitySubscriptionId = "",

    [Parameter(Mandatory = $false)]
    [string]$ProduktionSubscriptionId = "",

    [Parameter(Mandatory = $false)]
    [string]$SandboxSubscriptionId = "",

    [Parameter(Mandatory = $false)]
    [ValidateSet("All", "ManagementGroups", "Logging", "Networking")]
    [string]$DeploymentScope = "All",

    [Parameter(Mandatory = $false)]
    [string]$PrimaryLocation = "germanywestcentral",

    [Parameter(Mandatory = $false)]
    [string]$IntRootMgId = "alz",

    [Parameter(Mandatory = $false)]
    [switch]$DeploySpoke,

    [Parameter(Mandatory = $false)]
    [switch]$DeploySubscriptionVending,

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
$TemplatesRoot = Join-Path $PSScriptRoot ".." "templates"

function Write-Header { param($msg)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " $msg" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}
function Write-Step { param($msg) Write-Host "[STEP] $msg" -ForegroundColor Yellow }
function Write-OK   { param($msg) Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "[FAIL] $msg" -ForegroundColor Red; exit 1 }

function Invoke-AzDeploy {
    param($Name, $Scope, $Extra, [switch]$Silent)
    $baseArgs = @("--name", $Name, "--location", $PrimaryLocation, "--output", "json")
    if ($WhatIf) { $baseArgs += "--what-if" }
    $allArgs = $Extra + $baseArgs
    $result = az @allArgs 2>&1
    if ($LASTEXITCODE -ne 0 -and -not $Silent) {
        Write-Fail "$Name fehlgeschlagen: $result"
    }
    return $result
}

# ── Pre-flight ──────────────────────────────────────────
Write-Header "Azure Landing Zone – Kunden-Minimal (~€765/Monat)"
if ($WhatIf) { Write-Host "  MODUS: What-If Simulation – kein echtes Deployment`n" -ForegroundColor Magenta }

try {
    $v = az version --query '"azure-cli"' -o tsv 2>$null
    Write-OK "Azure CLI $v"
} catch { Write-Fail "Azure CLI nicht gefunden: https://aka.ms/installazurecli" }

az bicep upgrade --only-show-errors 2>$null
Write-OK "Bicep aktualisiert"

$account = az account show --query "user.name" -o tsv 2>$null
if (-not $account) { az login --tenant $TenantId }
Write-OK "Angemeldet als: $account"
az account set --tenant $TenantId
Write-OK "Tenant: $TenantId"

$ts = Get-Date -Format "yyyyMMdd-HHmmss"

# ── Step 1: Management Groups ───────────────────────────
if ($DeploymentScope -in @("All", "ManagementGroups")) {
    Write-Header "Step 1 – Management Groups (8 MGs)"

    Write-Step "1a) Int-Root (alz) + volles Policy-Set (149 Definitionen, 118 Assignments)..."
    Invoke-AzDeploy "alz-introot-$ts" "tenant" @(
        "deployment", "tenant", "create",
        "--template-file", "$TemplatesRoot\core\governance\mgmt-groups\int-root\main.bicep",
        "--parameters",   "$TemplatesRoot\core\governance\mgmt-groups\int-root\main.bicepparam"
    )
    Write-OK "Int-Root + Policy-Set deployed"

    Write-Step "1b) Platform MG (alz-platform-connectivity)..."
    Invoke-AzDeploy "alz-platform-$ts" "tenant" @(
        "deployment", "tenant", "create",
        "--template-file", "$TemplatesRoot\core\governance\mgmt-groups\platform\main.bicep",
        "--parameters",   "$TemplatesRoot\core\governance\mgmt-groups\platform\main.bicepparam"
    )
    Write-OK "alz-platform-connectivity deployed"

    Write-Step "1c) Landing Zones MG (alz-landingzones-corp)..."
    Invoke-AzDeploy "alz-lz-$ts" "tenant" @(
        "deployment", "tenant", "create",
        "--template-file", "$TemplatesRoot\core\governance\mgmt-groups\landingzones\main.bicep",
        "--parameters",   "$TemplatesRoot\core\governance\mgmt-groups\landingzones\main.bicepparam"
    )
    Write-OK "alz-landingzones-corp deployed"

    Write-Step "1d) Sandbox MG..."
    Invoke-AzDeploy "alz-sandbox-$ts" "tenant" @(
        "deployment", "tenant", "create",
        "--template-file", "$TemplatesRoot\core\governance\mgmt-groups\sandbox\main.bicep",
        "--parameters",   "$TemplatesRoot\core\governance\mgmt-groups\sandbox\main.bicepparam"
    ) -Silent
    Write-OK "alz-sandbox deployed"

    Write-Step "1e) RBAC Role Assignments..."
    Invoke-AzDeploy "alz-rbac-$ts" "tenant" @(
        "deployment", "tenant", "create",
        "--template-file", "$TemplatesRoot\core\governance\rbac\main.bicep",
        "--parameters",   "$TemplatesRoot\core\governance\rbac\main.bicepparam"
    )
    Write-OK "RBAC deployed"
}

# ── Step 2: Logging ─────────────────────────────────────
if ($DeploymentScope -in @("All", "Logging") -and $ConnectivitySubscriptionId) {
    Write-Header "Step 2 – Logging (Connectivity Sub)"
    az account set --subscription $ConnectivitySubscriptionId

    Invoke-AzDeploy "alz-logging-$ts" "sub" @(
        "deployment", "sub", "create",
        "--template-file", "$TemplatesRoot\core\logging\main.bicep",
        "--parameters",   "$TemplatesRoot\core\logging\main.bicepparam"
    )
    Write-OK "Log Analytics Workspace + DCRs + Managed Identity deployed"
}

# ── Step 3: Hub Networking ──────────────────────────────
if ($DeploymentScope -in @("All", "Networking") -and $ConnectivitySubscriptionId) {
    Write-Header "Step 3 – Hub Networking (Firewall Standard, ~€700/Mon)"
    Write-Host "  Zurückgestellt: Bastion, VPN Gateway, DNS Resolver`n" -ForegroundColor DarkYellow
    az account set --subscription $ConnectivitySubscriptionId

    Invoke-AzDeploy "alz-hub-$ts" "sub" @(
        "deployment", "sub", "create",
        "--template-file", "$TemplatesRoot\networking\hubnetworking\main.bicep",
        "--parameters",   "$PSScriptRoot\hubnetworking.bicepparam"
    )
    Write-OK "Hub VNet + Azure Firewall + Private DNS Zones deployed"
}

# ── Step 4 (optional): Spoke ────────────────────────────
if ($DeploySpoke -and $ProduktionSubscriptionId) {
    Write-Header "Step 4 – Spoke Networking (Produktion Sub)"
    az account set --subscription $ProduktionSubscriptionId

    Invoke-AzDeploy "alz-spoke-$ts" "sub" @(
        "deployment", "sub", "create",
        "--template-file", "$TemplatesRoot\networking\spoke\main.bicep",
        "--parameters",   "$TemplatesRoot\networking\spoke\main.bicepparam"
    )
    Write-OK "Spoke VNet + Route Table + Hub-Peering deployed"
}

# ── Step 5 (optional): Subscription Vending ─────────────
if ($DeploySubscriptionVending) {
    Write-Header "Step 5 – Subscription Vending"

    Invoke-AzDeploy "alz-vending-$ts" "mg" @(
        "deployment", "mg", "create",
        "--management-group-id", $IntRootMgId,
        "--template-file", "$TemplatesRoot\core\subscription-vending\main.bicep",
        "--parameters",   "$TemplatesRoot\core\subscription-vending\main.bicepparam"
    )
    Write-OK "Subscription in Ziel-MG platziert"
}

# ── Zusammenfassung ─────────────────────────────────────
Write-Header "Deployment abgeschlossen"
Write-Host @"
  Kosten-Uebersicht (Kunden-Minimal):
    Azure Firewall Standard  ~€700/Monat  [aktiv]
    Log Analytics Workspace   ~€50/Monat  [aktiv]
    Private DNS Zones         ~€15/Monat  [aktiv]
    Azure Bastion              €0/Monat  [zurueckgestellt]
    VPN Gateway                €0/Monat  [zurueckgestellt]
  ─────────────────────────────────────
    Gesamt                   ~€765/Monat

  Skalierung (hubnetworking.bicepparam):
    + VPN    → deployVpnGateway: true   (+€140/Mon)
    + Bastion → deployBastion: true     (+€120/Mon)

  Portal:
    Management Groups  → https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups
    Policy Compliance  → https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyMenuBlade/~/Compliance
"@ -ForegroundColor Cyan
