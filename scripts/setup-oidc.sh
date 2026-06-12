#!/usr/bin/env bash
# =============================================================================
# OIDC-Setup fuer GitHub Actions (Federated Identity) - Azure Landing Zone
#
# Legt App-Registrierung + Service Principal an, erstellt die drei Federated
# Credentials (pull_request, environment:production, ref:master), weist RBAC zu
# und setzt die vier GitHub-Secrets.
#
# Voraussetzungen: az (angemeldet, mit Rechten lt. docs/OIDC-SETUP.md),
#                  gh (angemeldet) - optional, sonst Secrets manuell setzen.
#
# Verwendung:
#   ORG=YannickBeck REPO=azure-landing-zone \
#   TENANT_ID=... MGMT_SUB=... CONN_SUB=... \
#   ./scripts/setup-oidc.sh
#
# Optional: ROOT_MG (Default: $TENANT_ID = Tenant Root MG), APP_NAME, SKIP_SECRETS=1
# =============================================================================
set -euo pipefail

ORG="${ORG:?ORG (GitHub-Owner) erforderlich}"
REPO="${REPO:?REPO (Repository-Name) erforderlich}"
TENANT_ID="${TENANT_ID:?TENANT_ID erforderlich}"
MGMT_SUB="${MGMT_SUB:?MGMT_SUB (Management Subscription Id) erforderlich}"
CONN_SUB="${CONN_SUB:?CONN_SUB (Connectivity Subscription Id) erforderlich}"
ROOT_MG="${ROOT_MG:-$TENANT_ID}"
APP_NAME="${APP_NAME:-sp-alz-github-oidc}"

echo "==> App-Registrierung '$APP_NAME'"
APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)
if [ -z "$APP_ID" ]; then
  APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
fi
az ad sp show --id "$APP_ID" >/dev/null 2>&1 || az ad sp create --id "$APP_ID" >/dev/null
SP_OID=$(az ad sp show --id "$APP_ID" --query id -o tsv)
echo "    AppId (AZURE_CLIENT_ID) = $APP_ID"

echo "==> Federated Credentials"
for SUBJECT in \
  "repo:$ORG/$REPO:ref:refs/heads/master" \
  "repo:$ORG/$REPO:pull_request" \
  "repo:$ORG/$REPO:environment:production"; do
  NAME="alz-$(echo "$SUBJECT" | tr ':/' '--')"
  if az ad app federated-credential list --id "$APP_ID" --query "[?subject=='$SUBJECT']" -o tsv | grep -q .; then
    echo "    vorhanden: $SUBJECT"
  else
    az ad app federated-credential create --id "$APP_ID" --parameters "{
      \"name\": \"$NAME\",
      \"issuer\": \"https://token.actions.githubusercontent.com\",
      \"subject\": \"$SUBJECT\",
      \"audiences\": [\"api://AzureADTokenExchange\"]
    }" >/dev/null
    echo "    erstellt:  $SUBJECT"
  fi
done

echo "==> RBAC (Owner)"
for SCOPE in \
  "/providers/Microsoft.Management/managementGroups/$ROOT_MG" \
  "/subscriptions/$MGMT_SUB" \
  "/subscriptions/$CONN_SUB"; do
  az role assignment create --assignee-object-id "$SP_OID" \
    --assignee-principal-type ServicePrincipal --role Owner \
    --scope "$SCOPE" >/dev/null 2>&1 && echo "    zugewiesen: $SCOPE" \
    || echo "    bereits vorhanden/uebersprungen: $SCOPE"
done

if [ "${SKIP_SECRETS:-0}" = "1" ]; then
  echo "==> Secrets uebersprungen (SKIP_SECRETS=1). Setze manuell:"
  echo "    AZURE_CLIENT_ID=$APP_ID"
  echo "    AZURE_TENANT_ID=$TENANT_ID"
  echo "    AZURE_MANAGEMENT_SUBSCRIPTION_ID=$MGMT_SUB"
  echo "    AZURE_CONNECTIVITY_SUBSCRIPTION_ID=$CONN_SUB"
else
  echo "==> GitHub-Secrets + Environment 'production'"
  gh secret set AZURE_CLIENT_ID                    --repo "$ORG/$REPO" --body "$APP_ID"
  gh secret set AZURE_TENANT_ID                    --repo "$ORG/$REPO" --body "$TENANT_ID"
  gh secret set AZURE_MANAGEMENT_SUBSCRIPTION_ID   --repo "$ORG/$REPO" --body "$MGMT_SUB"
  gh secret set AZURE_CONNECTIVITY_SUBSCRIPTION_ID --repo "$ORG/$REPO" --body "$CONN_SUB"
  gh api -X PUT "repos/$ORG/$REPO/environments/production" >/dev/null && echo "    Environment 'production' ok"
fi

echo "==> Fertig. Verifikation: az ad app federated-credential list --id $APP_ID -o table"
