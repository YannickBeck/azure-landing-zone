using './main.bicep'

// ===============================================================
// Deployment-Scope: Management Subscription
// ===============================================================

param parLocations = [
  'germanywestcentral'
  'northeurope'
]

param parTags = {
  Environment: 'Production'
  ManagedBy: 'Platform Team'
  CostCenter: 'IT-Platform'
}

param parMgmtLoggingResourceGroup = 'rg-alz-logging-germanywestcentral'

param parLogAnalyticsWorkspaceName = 'law-alz-germanywestcentral'
param parLogAnalyticsWorkspaceSku = 'PerGB2018'
param parLogRetentionInDays = 365
param parSolutions = [
  'ChangeTracking'
]
param parEnableSentinel = false          // Auf true setzen fuer Microsoft Sentinel

param parUserAssignedIdentityName = 'mi-alz-germanywestcentral'
param parDataCollectionRuleVMInsightsName = 'dcr-vmi-alz-germanywestcentral'
param parDataCollectionRuleChangeTrackingName = 'dcr-ct-alz-germanywestcentral'
param parDataCollectionRuleMDFCSQLName = 'dcr-mdfcsql-alz-germanywestcentral'

param parDeployAutomationAccount = false  // Auf true setzen wenn benoetigt
param parAutomationAccountName = 'aa-alz-germanywestcentral'
