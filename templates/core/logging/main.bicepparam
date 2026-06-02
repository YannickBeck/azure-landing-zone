using './main.bicep'

// ===============================================================
// ANPASSEN: Ersetze alle Werte in <> mit deinen eigenen Werten
// Deployment-Scope: Management Subscription
// ===============================================================

param parLocations = [
  'germanywestcentral'
  'northeurope'
]

param parGlobalResourceLock = {
  name: 'GlobalResourceLock'
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Accelerator.'
}

param parTags = {
  Environment: 'Production'
  ManagedBy: 'Platform Team'
  CostCenter: 'IT-Platform'
}

param parEnableTelemetry = true

// Resource Group
param parMgmtLoggingResourceGroup = 'rg-alz-logging-germanywestcentral'

// Automation Account (optional - auf false setzen um Kosten zu sparen)
param parDeployAutomationAccount = false
param parAutomationAccountName = 'aa-alz-germanywestcentral'
param parAutomationAccountLocation = 'germanywestcentral'
param parAutomationAccountUseManagedIdentity = true
param parAutomationAccountPublicNetworkAccess = true
param parAutomationAccountSku = 'Basic'

// Log Analytics Workspace
param parLogAnalyticsWorkspaceName = 'law-alz-germanywestcentral'
param parLogAnalyticsWorkspaceLocation = 'germanywestcentral'
param parLogAnalyticsWorkspaceSku = 'PerGB2018'
param parLogAnalyticsWorkspaceLogRetentionInDays = 365
param parLogAnalyticsWorkspaceSolutions = [
  'ChangeTracking'
]
param parLogAnalyticsWorkspaceEnableSentinel = false  // Auf true setzen um Sentinel zu aktivieren

// Data Collection Rules
param parUserAssignedIdentityName = 'mi-alz-germanywestcentral'
param parDataCollectionRuleVMInsightsName = 'dcr-vmi-alz-germanywestcentral'
param parDataCollectionRuleChangeTrackingName = 'dcr-ct-alz-germanywestcentral'
param parDataCollectionRuleMDFCSQLName = 'dcr-mdfcsql-alz-germanywestcentral'
