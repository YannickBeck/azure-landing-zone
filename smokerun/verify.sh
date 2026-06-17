#!/usr/bin/env bash
# Verifikation nach dem Smoke Run
# Kann separat ausgeführt werden: bash smokerun/verify.sh
set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()   { echo -e "${GREEN}[OK]${RESET}  $1"; }
warn() { echo -e "${YELLOW}[??]${RESET}  $1"; }
fail() { echo -e "${RED}[!!]${RESET}  $1"; }
hdr()  { echo -e "\n${CYAN}${BOLD}─── $1 ───${RESET}"; }

PASS=0; FAIL=0

check() {
  local label="$1"; shift
  if eval "$@" &>/dev/null; then
    ok "$label"; ((PASS++)) || true
  else
    fail "$label"; ((FAIL++)) || true
  fi
}

# ─── Management Groups ────────────────────────────────────────────────────
hdr "Management Groups"
for mg in alz alz-platform alz-platform-connectivity alz-platform-identity \
          alz-platform-management alz-platform-security \
          alz-landingzones alz-landingzones-corp alz-landingzones-online \
          alz-landingzones-local alz-sandbox alz-decommissioned; do
  check "MG vorhanden: $mg" \
    "az account management-group show --name '$mg'"
done

# ─── Policy Assignments ───────────────────────────────────────────────────
hdr "Policy Assignments"
check "Mindestens 3 Assignments auf alz" \
  "[ \$(az policy assignment list --scope /providers/Microsoft.Management/managementGroups/alz --query 'length(@)' -o tsv) -ge 3 ]"

check "Corp-Policies vorhanden (Deny-Public-IP)" \
  "az policy assignment list --scope /providers/Microsoft.Management/managementGroups/alz-landingzones-corp --query '[?contains(name,\`Deny\`)].name' -o tsv | grep -q ."

# ─── Logging ─────────────────────────────────────────────────────────────
hdr "Logging"
check "Resource Group vorhanden: rg-alz-poc-logging-gwe" \
  "az group show -n rg-alz-poc-logging-gwe"

check "Log Analytics Workspace: law-alz-poc-gwe" \
  "az monitor log-analytics workspace show -g rg-alz-poc-logging-gwe -n law-alz-poc-gwe"

check "Managed Identity: mi-alz-poc-gwe" \
  "az identity show -g rg-alz-poc-logging-gwe -n mi-alz-poc-gwe"

check "DCR VM Insights vorhanden" \
  "az monitor data-collection rule show -g rg-alz-poc-logging-gwe -n dcr-vmi-alz-poc-gwe"

check "DCR Change Tracking vorhanden" \
  "az monitor data-collection rule show -g rg-alz-poc-logging-gwe -n dcr-ct-alz-poc-gwe"

# ─── Netzwerk ─────────────────────────────────────────────────────────────
hdr "Netzwerk"
check "Resource Group vorhanden: rg-alz-poc-conn-germanywestcentral" \
  "az group show -n rg-alz-poc-conn-germanywestcentral"

check "Hub VNet vorhanden: vnet-alz-poc-gwe" \
  "az network vnet show -g rg-alz-poc-conn-germanywestcentral -n vnet-alz-poc-gwe"

check "AzureFirewallSubnet vorhanden" \
  "az network vnet subnet show -g rg-alz-poc-conn-germanywestcentral --vnet-name vnet-alz-poc-gwe -n AzureFirewallSubnet"

check "DNS Resource Group vorhanden: rg-alz-poc-dns-germanywestcentral" \
  "az group show -n rg-alz-poc-dns-germanywestcentral"

DNS_COUNT=$(az network private-dns zone list -g rg-alz-poc-dns-germanywestcentral --query 'length(@)' -o tsv 2>/dev/null || echo 0)
if [ "${DNS_COUNT:-0}" -ge 10 ]; then
  ok "Private DNS Zones: $DNS_COUNT Zonen deployed"
  ((PASS++)) || true
else
  warn "Private DNS Zones: nur $DNS_COUNT Zonen (erwartet ≥ 10)"
fi

# ─── Zusammenfassung ──────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Ergebnis: ${GREEN}$PASS bestanden${RESET}  ${RED}$FAIL fehlgeschlagen${RESET}"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "${YELLOW}Tipp:${RESET} Fehlgeschlagene Checks → Deployment noch nicht abgeschlossen oder Fehler aufgetreten."
  echo -e "      Logs prüfen: az deployment tenant list --query '[?starts_with(name,\`alz-poc\`)]' -o table"
  exit 1
fi
