using '../../templates/core/logging/main.bicep'

// Smoke Run – vereinfachtes Logging
// Unterschiede zu Produktion:
//   - Nur eine Region (germanywestcentral)
//   - Retention 30 Tage statt 365 (Kostenersparnis)
//   - Kein Automation Account
//   - Präfix 'smoke' zur Unterscheidung

param parLocations = [
  'germanywestcentral'
]

param parTags = {
  Environment: 'Smoke'
  ManagedBy: 'Platform Team'
  CostCenter: 'IT-Demo'
}

param parMgmtLoggingResourceGroup = 'rg-alz-smoke-logging-gwe'

param parLogAnalyticsWorkspaceName = 'law-alz-smoke-gwe'
param parLogAnalyticsWorkspaceSku = 'PerGB2018'
param parLogRetentionInDays = 30
param parSolutions = []

param parEnableSentinel = false

param parUserAssignedIdentityName = 'mi-alz-smoke-gwe'
param parDataCollectionRuleVMInsightsName = 'dcr-vmi-alz-smoke-gwe'
param parDataCollectionRuleChangeTrackingName = 'dcr-ct-alz-smoke-gwe'
param parDataCollectionRuleMDFCSQLName = 'dcr-mdfcsql-alz-smoke-gwe'

param parDeployAutomationAccount = false
param parAutomationAccountName = 'aa-alz-smoke-gwe'
