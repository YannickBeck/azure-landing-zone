# OIDC-Setup für GitHub Actions

Damit die Pipeline (`.github/workflows/deploy-alz.yml`) sich passwortlos per
**OpenID Connect (Federated Identity)** an Azure anmelden kann, brauchst du eine
App-Registrierung mit Federated Credentials und vier GitHub-Secrets. Dieses Runbook
beschreibt das einmalige Setup – manuell per CLI oder automatisiert über
[`scripts/setup-oidc.sh`](../scripts/setup-oidc.sh).

> **Warum drei Federated Credentials?** Die Jobs laufen in unterschiedlichen
> GitHub-Kontexten, und das OIDC-Token-`subject` unterscheidet sich je Kontext:
>
> | Job | Auslöser | Token-`subject` |
> |-----|----------|-----------------|
> | `whatif` | `pull_request` | `repo:<ORG>/<REPO>:pull_request` |
> | `deploy-*` | `push` auf `master`, Environment `production` | `repo:<ORG>/<REPO>:environment:production` |
> | (Reserve) | Push auf `master` ohne Environment | `repo:<ORG>/<REPO>:ref:refs/heads/master` |
>
> Der `validate`-Job meldet sich **nicht** an (reines `bicep build`) und braucht kein Credential.

---

## Voraussetzungen

- `az` (Azure CLI) ≥ 2.60, angemeldet als Benutzer mit:
  - **User Access Administrator**/**Owner** auf der Ziel-Management-Group (für die
    Rollenzuweisung an den Service Principal) und auf den beiden Subscriptions.
  - Rechten zum Erstellen von App-Registrierungen (Standard für die meisten Tenants;
    sonst „Application Developer“-Rolle in Entra ID).
- `gh` (GitHub CLI), authentifiziert (`gh auth login`) – optional, nur zum Setzen der
  Secrets. Alternativ setzt du die Secrets im Repo unter
  *Settings → Secrets and variables → Actions* manuell.

---

## Variablen

```bash
ORG="YannickBeck"
REPO="azure-landing-zone"
APP_NAME="sp-alz-github-oidc"

TENANT_ID="<DEINE_TENANT_ID>"
ROOT_MG="$TENANT_ID"                 # Tenant Root MG = Tenant ID; oder 'alz' wenn bereits vorhanden
MGMT_SUB="<MANAGEMENT_SUBSCRIPTION_ID>"
CONN_SUB="<CONNECTIVITY_SUBSCRIPTION_ID>"
```

> **Scope-Hinweis:** Für das **erste** Deployment muss der Service Principal die
> Int-Root-MG `alz` unterhalb der Tenant Root MG anlegen – dafür braucht er Rechte
> auf der **Tenant Root MG** (`ROOT_MG="$TENANT_ID"`). Danach kann der Scope auf `alz`
> verengt werden.

---

## Schritt 1 – App-Registrierung + Service Principal

```bash
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
az ad sp create --id "$APP_ID"
SP_OID=$(az ad sp show --id "$APP_ID" --query id -o tsv)
echo "AppId (= AZURE_CLIENT_ID): $APP_ID"
```

## Schritt 2 – Federated Credentials (3 Subjects)

```bash
for SUBJECT in \
  "repo:$ORG/$REPO:ref:refs/heads/master" \
  "repo:$ORG/$REPO:pull_request" \
  "repo:$ORG/$REPO:environment:production"; do
  NAME="alz-$(echo "$SUBJECT" | tr ':/' '--')"
  az ad app federated-credential create --id "$APP_ID" --parameters "{
    \"name\": \"$NAME\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"$SUBJECT\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"
done
```

## Schritt 3 – RBAC für den Service Principal

```bash
# Management-Group-Ebene: Owner deckt MG-Erstellung, Policy- und Rollenzuweisungen ab
az role assignment create --assignee-object-id "$SP_OID" \
  --assignee-principal-type ServicePrincipal --role Owner \
  --scope "/providers/Microsoft.Management/managementGroups/$ROOT_MG"

# Subscriptions: Owner (Ressourcen + Rollenzuweisungen)
az role assignment create --assignee-object-id "$SP_OID" \
  --assignee-principal-type ServicePrincipal --role Owner \
  --scope "/subscriptions/$MGMT_SUB"
az role assignment create --assignee-object-id "$SP_OID" \
  --assignee-principal-type ServicePrincipal --role Owner \
  --scope "/subscriptions/$CONN_SUB"
```

> **Least-Privilege-Alternative** statt `Owner` auf den Subscriptions:
> `Contributor` **+** `User Access Administrator` (Letzteres wird für die
> RBAC-/Vending-Rollenzuweisungen benötigt). `Owner` ist die einfachere Variante.

## Schritt 4 – GitHub-Secrets setzen

```bash
gh secret set AZURE_CLIENT_ID                 --repo "$ORG/$REPO" --body "$APP_ID"
gh secret set AZURE_TENANT_ID                 --repo "$ORG/$REPO" --body "$TENANT_ID"
gh secret set AZURE_MANAGEMENT_SUBSCRIPTION_ID   --repo "$ORG/$REPO" --body "$MGMT_SUB"
gh secret set AZURE_CONNECTIVITY_SUBSCRIPTION_ID --repo "$ORG/$REPO" --body "$CONN_SUB"
```

## Schritt 5 – GitHub-Environment `production`

Die Deploy-Jobs laufen im Environment `production`. Lege es an (einmalig) und
hinterlege optional Schutzregeln (Required reviewers):

```bash
gh api -X PUT "repos/$ORG/$REPO/environments/production" >/dev/null && echo "Environment 'production' ok"
```

---

## Verifikation

```bash
# Federated Credentials vorhanden?
az ad app federated-credential list --id "$APP_ID" \
  --query "[].{name:name, subject:subject}" -o table
# Rollen vorhanden?
az role assignment list --assignee "$APP_ID" --all \
  --query "[].{role:roleDefinitionName, scope:scope}" -o table
# Secrets gesetzt?
gh secret list --repo "$ORG/$REPO"
```

**Smoke über CI auslösen:** *Actions → Deploy Azure Landing Zone → Run workflow*
mit `What-If only = true` (Stufe 1) oder `false` für ein echtes Deployment des
gewählten Scopes. Siehe [`docs/SMOKE-RUN.md`](SMOKE-RUN.md).

---

## Troubleshooting

| Symptom | Ursache / Fix |
|---------|---------------|
| `AADSTS70021: No matching federated identity record` | `subject` passt nicht zum Job-Kontext. Prüfe die 3 Subjects (PR vs. environment:production vs. ref). |
| `Insufficient privileges to complete the operation` (App-Erstellung) | Benutzer braucht „Application Developer“ in Entra ID. |
| `AuthorizationFailed` beim Deploy | Rollenzuweisung fehlt/zu eng – Owner auf MG + beiden Subs prüfen (Schritt 3). |
| Deploy-Job „waiting“ | Environment `production` hat Required Reviewers – Freigabe erteilen. |
