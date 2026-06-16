using './main.bicep'

// ===============================================================
// Security Baseline - je Subscription deployen.
// Werte koennen ueber Umgebungsvariablen injiziert werden:
//   ALZ_SECURITY_EMAIL   - Security-Contact-E-Mail(s)
//   ALZ_LAW_RESOURCE_ID  - Resource ID des Log Analytics Workspace
// Deployment-Scope: Subscription
// ===============================================================

param parDefenderTier = 'Standard'

param parSecurityContactEmail = readEnvironmentVariable('ALZ_SECURITY_EMAIL', '')

param parLogAnalyticsWorkspaceResourceId = readEnvironmentVariable('ALZ_LAW_RESOURCE_ID', '')
