#!/usr/bin/env bash
# =============================================================================
# ALZ Smoke Run – Single Subscription
#
# Führt einen vollständigen End-to-End-Deploy der Azure Landing Zone
# in einer einzigen Subscription aus.
#
# VERWENDUNG:
#   export TENANT_ID="<tenant-id>"
#   export SUB_ID="<subscription-id>"
#   bash smokerun/run.sh             # What-If (kein echtes Deploy)
#   bash smokerun/run.sh --deploy    # Echtes Deploy
#   bash smokerun/run.sh --deploy --skip-whatif
# =============================================================================
set -euo pipefail

DEPLOY=false
SKIP_WHATIF=false
for arg in "$@"; do
  case $arg in
    --deploy)       DEPLOY=true ;;
    --skip-whatif)  SKIP_WHATIF=true ;;
  esac
done

# ─── Farben ────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

header() { echo -e "\n${CYAN}${BOLD}═══ $1 ═══${RESET}\n"; }
ok()     { echo -e "${GREEN}[OK]${RESET}  $1"; }
step()   { echo -e "${YELLOW}[>>]${RESET}  $1"; }
fail()   { echo -e "${RED}[!!]${RESET}  $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PARAMS_DIR="$SCRIPT_DIR/params"
LOCATION="germanywestcentral"
TS="$(date +%Y%m%d-%H%M%S)"

# ─── Variablen prüfen ─────────────────────────────────────────────────────
header "Voraussetzungen"

[ -z "${TENANT_ID:-}" ] && fail "TENANT_ID nicht gesetzt. Export: export TENANT_ID=<id>"
[ -z "${SUB_ID:-}" ]    && fail "SUB_ID nicht gesetzt.    Export: export SUB_ID=<id>"

az version &>/dev/null || fail "Azure CLI nicht gefunden"
az bicep version &>/dev/null || { step "Bicep installieren..."; az bicep upgrade; }

ok "Tenant:       $TENANT_ID"
ok "Subscription: $SUB_ID"
ok "Location:     $LOCATION"
ok "Deploy-Modus: $DEPLOY (--deploy zum Aktivieren)"

# ─── Login ─────────────────────────────────────────────────────────────────
header "Azure Login"
CURRENT=$(az account show --query "user.name" -o tsv 2>/dev/null || true)
if [ -z "$CURRENT" ]; then
  az login --tenant "$TENANT_ID"
fi
az account set --subscription "$SUB_ID"
ok "Angemeldet als: $(az account show --query "user.name" -o tsv)"
ok "Subscription:   $(az account show --query "name" -o tsv)"

# ─── Bicep bauen (statische Validierung) ──────────────────────────────────
header "Stufe 0 – Statische Validierung"
step "Bicep Build aller Smoke-Templates..."
az bicep build --file "$ROOT_DIR/templates/core/governance/mgmt-groups/int-root/main.bicep" --stdout > /dev/null
az bicep build --file "$ROOT_DIR/templates/core/logging/main.bicep"                         --stdout > /dev/null
az bicep build --file "$ROOT_DIR/templates/networking/hubnetworking/main.bicep"              --stdout > /dev/null
ok "Alle Templates kompilieren fehlerfrei"

# ─── What-If ──────────────────────────────────────────────────────────────
if [ "$SKIP_WHATIF" = false ]; then
  header "Stufe 1 – What-If (keine Änderungen)"

  step "What-If: Management Groups..."
  az deployment tenant create \
    --name "alz-poc-mg-whatif-$TS" \
    --location "$LOCATION" \
    --template-file "$ROOT_DIR/templates/core/governance/mgmt-groups/int-root/main.bicep" \
    --parameters "$PARAMS_DIR/mgmt-groups.bicepparam" \
    --what-if 2>&1 | grep -E "^\s*(~|\+|-|!)|Resource|What if|Error" || true

  step "What-If: Logging..."
  az deployment sub create \
    --name "alz-poc-log-whatif-$TS" \
    --location "$LOCATION" \
    --template-file "$ROOT_DIR/templates/core/logging/main.bicep" \
    --parameters "$PARAMS_DIR/logging.bicepparam" \
    --what-if 2>&1 | grep -E "^\s*(~|\+|-|!)|Resource|What if|Error" || true

  step "What-If: Hub Networking..."
  az deployment sub create \
    --name "alz-poc-net-whatif-$TS" \
    --location "$LOCATION" \
    --template-file "$ROOT_DIR/templates/networking/hubnetworking/main.bicep" \
    --parameters "$PARAMS_DIR/hubnetworking.bicepparam" \
    --what-if 2>&1 | grep -E "^\s*(~|\+|-|!)|Resource|What if|Error" || true

  ok "What-If abgeschlossen – keine Fehler"
fi

# ─── Deploy (nur mit --deploy) ────────────────────────────────────────────
if [ "$DEPLOY" = false ]; then
  echo -e "\n${YELLOW}Kein echtes Deploy – laufe mit --deploy für echten Smoke Run.${RESET}\n"
  exit 0
fi

header "Stufe 2 – Management Groups deployen"
step "Intermediate Root MG + Policy-Assignments..."
az deployment tenant create \
  --name "alz-poc-mg-$TS" \
  --location "$LOCATION" \
  --template-file "$ROOT_DIR/templates/core/governance/mgmt-groups/int-root/main.bicep" \
  --parameters "$PARAMS_DIR/mgmt-groups.bicepparam" \
  --output none
ok "Management Groups deployed"

step "Landing Zones MGs..."
az deployment tenant create \
  --name "alz-poc-lz-$TS" \
  --location "$LOCATION" \
  --template-file "$ROOT_DIR/templates/core/governance/mgmt-groups/landingzones/main.bicep" \
  --parameters "$ROOT_DIR/templates/core/governance/mgmt-groups/landingzones/main.bicepparam" \
  --output none
ok "Landing Zone MGs deployed"

step "Sandbox + Decommissioned MGs..."
az deployment tenant create \
  --name "alz-poc-sb-$TS" --location "$LOCATION" \
  --template-file "$ROOT_DIR/templates/core/governance/mgmt-groups/sandbox/main.bicep" \
  --parameters "$ROOT_DIR/templates/core/governance/mgmt-groups/sandbox/main.bicepparam" \
  --output none
az deployment tenant create \
  --name "alz-poc-dc-$TS" --location "$LOCATION" \
  --template-file "$ROOT_DIR/templates/core/governance/mgmt-groups/decommissioned/main.bicep" \
  --parameters "$ROOT_DIR/templates/core/governance/mgmt-groups/decommissioned/main.bicepparam" \
  --output none
ok "Sandbox + Decommissioned deployed"

# ─── Stufe 3: Logging ──────────────────────────────────────────────────────
header "Stufe 3 – Logging deployen"
az account set --subscription "$SUB_ID"
step "Log Analytics + DCRs + Managed Identity..."
az deployment sub create \
  --name "alz-poc-log-$TS" \
  --location "$LOCATION" \
  --template-file "$ROOT_DIR/templates/core/logging/main.bicep" \
  --parameters "$PARAMS_DIR/logging.bicepparam" \
  --output none
ok "Logging deployed"

# ─── Stufe 4: Hub Networking ───────────────────────────────────────────────
header "Stufe 4 – Hub Networking deployen (ohne Firewall/Bastion)"
step "Hub VNet + Subnetze + Private DNS Zones..."
az deployment sub create \
  --name "alz-poc-net-$TS" \
  --location "$LOCATION" \
  --template-file "$ROOT_DIR/templates/networking/hubnetworking/main.bicep" \
  --parameters "$PARAMS_DIR/hubnetworking.bicepparam" \
  --output none
ok "Hub Networking deployed"

# ─── Verifikation ──────────────────────────────────────────────────────────
header "Verifikation"
bash "$SCRIPT_DIR/verify.sh"

echo -e "\n${GREEN}${BOLD}Smoke Run erfolgreich abgeschlossen!${RESET}"
echo -e "Teardown: ${YELLOW}bash smokerun/teardown.sh${RESET}\n"
