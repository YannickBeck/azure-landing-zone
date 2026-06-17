#!/usr/bin/env bash
# Smoke Run Teardown – entfernt alle smoke-spezifischen Ressourcen
# Management Groups werden zuletzt gelöscht (Kinder vor Eltern)
#
# VERWENDUNG:
#   export SUB_ID="<subscription-id>"
#   bash smokerun/teardown.sh
#
# ACHTUNG: Löscht Resource Groups und Management Groups unwiderruflich.
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()   { echo -e "${GREEN}[OK]${RESET}  $1"; }
step() { echo -e "${YELLOW}[>>]${RESET}  $1"; }
hdr()  { echo -e "\n${CYAN}${BOLD}═══ $1 ═══${RESET}\n"; }

[ -z "${SUB_ID:-}" ] && { echo -e "${RED}SUB_ID nicht gesetzt.${RESET}"; exit 1; }

hdr "Smoke Run Teardown"
echo -e "${RED}${BOLD}ACHTUNG: Alle Smoke-Ressourcen werden gelöscht!${RESET}"
echo "Subscription: $SUB_ID"
echo ""
read -rp "Fortfahren? [j/N] " confirm
[[ "$confirm" =~ ^[jJyY]$ ]] || { echo "Abgebrochen."; exit 0; }

az account set --subscription "$SUB_ID"

# ─── Resource Groups ──────────────────────────────────────────────────────
hdr "Resource Groups löschen"
for rg in \
  rg-alz-poc-logging-gwe \
  rg-alz-poc-conn-germanywestcentral \
  rg-alz-poc-dns-germanywestcentral; do
  if az group show -n "$rg" &>/dev/null; then
    step "Lösche: $rg"
    az group delete -n "$rg" --yes --no-wait
    ok "Löschauftrag gesendet: $rg"
  else
    ok "Nicht vorhanden (übersprungen): $rg"
  fi
done

echo ""
step "Warte auf Löschung der Resource Groups (max. 3 Minuten)..."
for rg in \
  rg-alz-poc-logging-gwe \
  rg-alz-poc-conn-germanywestcentral \
  rg-alz-poc-dns-germanywestcentral; do
  timeout 180 bash -c "until ! az group show -n '$rg' &>/dev/null; do sleep 10; done" \
    && ok "Gelöscht: $rg" \
    || echo -e "${YELLOW}Timeout: $rg evtl. noch aktiv – manuell prüfen${RESET}"
done

# ─── Management Groups ────────────────────────────────────────────────────
hdr "Management Groups löschen (Kinder vor Eltern)"
# Subscriptions zuerst zurück zur Tenant Root verschieben
step "Subscription aus MGs entfernen..."
az account management-group subscription remove \
  --name alz-landingzones-corp --subscription "$SUB_ID" 2>/dev/null || true
az account management-group subscription remove \
  --name alz-landingzones-online --subscription "$SUB_ID" 2>/dev/null || true
az account management-group subscription remove \
  --name alz-sandbox --subscription "$SUB_ID" 2>/dev/null || true
az account management-group subscription remove \
  --name alz --subscription "$SUB_ID" 2>/dev/null || true

for mg in \
  alz-platform-connectivity \
  alz-platform-identity \
  alz-platform-management \
  alz-platform-security \
  alz-landingzones-corp \
  alz-landingzones-online \
  alz-landingzones-local \
  alz-platform \
  alz-landingzones \
  alz-sandbox \
  alz-decommissioned \
  alz; do
  if az account management-group show --name "$mg" &>/dev/null; then
    step "Lösche MG: $mg"
    az account management-group delete --name "$mg" 2>/dev/null \
      && ok "Gelöscht: $mg" \
      || echo -e "${YELLOW}Warnung: $mg konnte nicht gelöscht werden (ggf. noch Kinder vorhanden)${RESET}"
  else
    ok "Nicht vorhanden: $mg"
  fi
done

hdr "Teardown abgeschlossen"
ok "Smoke Run vollständig bereinigt."
echo -e "Policy-Assignments werden automatisch mit den MGs entfernt.\n"
