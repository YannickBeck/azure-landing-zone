// ================================================================ //
// ALZ Logging & Management Module
// Erstellt die Logging-Resource-Group und ruft das Resource-Group-
// scoped Modul auf (LAW, UAMI, DCRs, optionale Automation Account).
// Scope: Subscription (Management Subscription)
// ================================================================ //

targetScope = 'subscription'

// ================ //
// Parameters
// ================ //

@description('Array der Azure-Regionen. Erstes Element ist die primaere Region.')
param parLocations array = [
  deployment().location
]

@description('Tags fuer alle Ressourcen.')
param parTags object = {}

@description('Name der Resource Group fuer Management & Logging.')
param parMgmtLoggingResourceGroup string = 'rg-alz-logging-${parLocations[0]}'

@description('Name des Log Analytics Workspace.')
param parLogAnalyticsWorkspaceName string = 'law-alz-${parLocations[0]}'

@description('SKU des Log Analytics Workspace.')
param parLogAnalyticsWorkspaceSku string = 'PerGB2018'

@description('Aufbewahrung der Logs in Tagen.')
param parLogRetentionInDays int = 365

@description('Log-Analytics-Solutions.')
param parSolutions array = [
  'ChangeTracking'
]

@description('Microsoft Sentinel aktivieren.')
param parEnableSentinel bool = false

@description('Name der User Assigned Managed Identity.')
param parUserAssignedIdentityName string = 'mi-alz-${parLocations[0]}'

@description('Name der VM-Insights DCR.')
param parDataCollectionRuleVMInsightsName string = 'dcr-vmi-alz-${parLocations[0]}'

@description('Name der Change-Tracking DCR.')
param parDataCollectionRuleChangeTrackingName string = 'dcr-ct-alz-${parLocations[0]}'

@description('Name der MDFC-SQL DCR.')
param parDataCollectionRuleMDFCSQLName string = 'dcr-mdfcsql-alz-${parLocations[0]}'

@description('Automation Account deployen.')
param parDeployAutomationAccount bool = false

@description('Name der Automation Account.')
param parAutomationAccountName string = 'aa-alz-${parLocations[0]}'

// ================ //
// Resources
// ================ //

resource managementLoggingResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: parMgmtLoggingResourceGroup
  location: parLocations[0]
  tags: parTags
}

// ================ //
// Modules
// ================ //

module loggingResources 'modules/logging-resources.bicep' = {
  name: 'alz-logging-resources-${uniqueString(parMgmtLoggingResourceGroup)}'
  scope: managementLoggingResourceGroup
  params: {
    parLocation: parLocations[0]
    parTags: parTags
    parLogAnalyticsWorkspaceName: parLogAnalyticsWorkspaceName
    parLogAnalyticsWorkspaceSku: parLogAnalyticsWorkspaceSku
    parLogRetentionInDays: parLogRetentionInDays
    parSolutions: parSolutions
    parEnableSentinel: parEnableSentinel
    parUserAssignedIdentityName: parUserAssignedIdentityName
    parDataCollectionRuleVMInsightsName: parDataCollectionRuleVMInsightsName
    parDataCollectionRuleChangeTrackingName: parDataCollectionRuleChangeTrackingName
    parDataCollectionRuleMDFCSQLName: parDataCollectionRuleMDFCSQLName
    parDeployAutomationAccount: parDeployAutomationAccount
    parAutomationAccountName: parAutomationAccountName
  }
}

// ================ //
// Outputs
// ================ //

@description('Name der Logging Resource Group.')
output outMgmtLoggingResourceGroupName string = managementLoggingResourceGroup.name

@description('Resource ID des Log Analytics Workspace.')
output outLogAnalyticsWorkspaceResourceId string = loggingResources.outputs.outLogAnalyticsWorkspaceResourceId

@description('Resource ID der User Assigned Managed Identity.')
output outUserAssignedIdentityResourceId string = loggingResources.outputs.outUserAssignedIdentityResourceId
