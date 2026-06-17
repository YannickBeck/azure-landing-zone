using '../../templates/core/logging/main.bicep'

// Smoke Run – vereinfachtes Logging
// Unterschiede zu Produktion:
//   - Nur eine Region (germanywestcentral)
//   - Retention 30 Tage statt 365 (Kostenersparnis)
//   - Kein Automation Account
//   - Präfix 'poc' kennzeichnet Demo-Ressourcen im Tenant

param parLocations = [
  'germanywestcentral'
]

param parTags = {
  Environment: 'PoC'
  ManagedBy: 'Platform Team'
  CostCenter: 'IT-Demo'
}

param parMgmtLoggingResourceGroup = 'rg-alz-poc-logging-gwe'

param parLogAnalyticsWorkspaceName = 'law-alz-poc-gwe'
param parLogAnalyticsWorkspaceSku = 'PerGB2018'
param parLogRetentionInDays = 30
param parSolutions = []

param parEnableSentinel = false

param parUserAssignedIdentityName = 'mi-alz-poc-gwe'
param parDataCollectionRuleVMInsightsName = 'dcr-vmi-alz-poc-gwe'
param parDataCollectionRuleChangeTrackingName = 'dcr-ct-alz-poc-gwe'
param parDataCollectionRuleMDFCSQLName = 'dcr-mdfcsql-alz-poc-gwe'

param parDeployAutomationAccount = false
param parAutomationAccountName = 'aa-alz-poc-gwe'
