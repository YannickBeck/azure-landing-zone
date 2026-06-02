// ================================================================ //
// ALZ Logging & Management Module
// Deploys: Log Analytics Workspace, Automation Account,
//          Data Collection Rules, User Assigned Identity
// Scope: Subscription (Management Subscription)
// ================================================================ //

targetScope = 'subscription'

// ================ //
// Type Definitions
// ================ //

type lockType = {
  @description('The name of the lock.')
  name: string
  @description('The type of lock: CanNotDelete, ReadOnly, or None.')
  kind: 'CanNotDelete' | 'ReadOnly' | 'None'
  @description('Optional notes about the lock.')
  notes: string?
}

// ================ //
// Parameters
// ================ //

@description('Array of Azure regions. First element is primary region.')
param parLocations array = [
  deployment().location
]

@description('Global resource lock settings.')
param parGlobalResourceLock lockType = {
  name: 'GlobalResourceLock'
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Accelerator.'
}

@description('Tags to apply to all resources.')
param parTags object = {}

@description('Enable or disable telemetry.')
param parEnableTelemetry bool = true

@description('Name of the resource group for management and logging resources.')
param parMgmtLoggingResourceGroup string = 'rg-alz-logging-${parLocations[0]}'

// Automation Account
@description('Deploy automation account.')
param parDeployAutomationAccount bool = false

@description('Name of the Automation Account.')
param parAutomationAccountName string = 'aa-alz-${parLocations[0]}'

@description('Location for the Automation Account.')
param parAutomationAccountLocation string = parLocations[0]

@description('Use managed identity for Automation Account.')
param parAutomationAccountUseManagedIdentity bool = true

@description('Allow public network access to Automation Account.')
param parAutomationAccountPublicNetworkAccess bool = true

@description('SKU for Automation Account.')
param parAutomationAccountSku string = 'Basic'

// Log Analytics Workspace
@description('Name of the Log Analytics Workspace.')
param parLogAnalyticsWorkspaceName string = 'law-alz-${parLocations[0]}'

@description('Location for the Log Analytics Workspace.')
param parLogAnalyticsWorkspaceLocation string = parLocations[0]

@description('SKU for Log Analytics Workspace.')
@allowed([
  'PerGB2018'
  'CapacityReservation'
  'Free'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param parLogAnalyticsWorkspaceSku string = 'PerGB2018'

@description('Log retention in days (30-730).')
@minValue(30)
@maxValue(730)
param parLogAnalyticsWorkspaceLogRetentionInDays int = 365

@description('Solutions to add to Log Analytics Workspace.')
param parLogAnalyticsWorkspaceSolutions array = [
  'ChangeTracking'
]

@description('Enable Microsoft Sentinel.')
param parLogAnalyticsWorkspaceEnableSentinel bool = false

// Data Collection Rules
@description('Name for the User Assigned Managed Identity.')
param parUserAssignedIdentityName string = 'mi-alz-${parLocations[0]}'

@description('Name for the VM Insights Data Collection Rule.')
param parDataCollectionRuleVMInsightsName string = 'dcr-vmi-alz-${parLocations[0]}'

@description('Name for the Change Tracking Data Collection Rule.')
param parDataCollectionRuleChangeTrackingName string = 'dcr-ct-alz-${parLocations[0]}'

@description('Name for the MDFC SQL Data Collection Rule.')
param parDataCollectionRuleMDFCSQLName string = 'dcr-mdfcsql-alz-${parLocations[0]}'

// ================ //
// Variables
// ================ //

var varLawSolutions = union(
  parLogAnalyticsWorkspaceSolutions,
  parLogAnalyticsWorkspaceEnableSentinel ? ['SecurityInsights'] : []
)

// ================ //
// Modules
// ================ //

module managementResourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'alz-mgmt-rg-${uniqueString(deployment().name)}'
  params: {
    name: parMgmtLoggingResourceGroup
    location: parLocations[0]
    tags: parTags
    enableTelemetry: parEnableTelemetry
    lock: parGlobalResourceLock.kind != 'None' ? {
      kind: parGlobalResourceLock.kind
      name: parGlobalResourceLock.name
    } : null
  }
}

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.9.0' = {
  name: 'alz-law-${uniqueString(deployment().name)}'
  scope: resourceGroup(parMgmtLoggingResourceGroup)
  dependsOn: [ managementResourceGroup ]
  params: {
    name: parLogAnalyticsWorkspaceName
    location: parLogAnalyticsWorkspaceLocation
    tags: parTags
    skuName: parLogAnalyticsWorkspaceSku
    dataRetention: parLogAnalyticsWorkspaceLogRetentionInDays
    enableTelemetry: parEnableTelemetry
    gallerySolutions: [for solution in varLawSolutions: {
      name: solution
      product: 'OMSGallery/${solution}'
      publisher: 'Microsoft'
    }]
  }
}

module automationAccount 'br/public:avm/res/automation/automation-account:0.10.0' = if (parDeployAutomationAccount) {
  name: 'alz-aa-${uniqueString(deployment().name)}'
  scope: resourceGroup(parMgmtLoggingResourceGroup)
  dependsOn: [ managementResourceGroup ]
  params: {
    name: parAutomationAccountName
    location: parAutomationAccountLocation
    tags: parTags
    skuName: parAutomationAccountSku
    enableTelemetry: parEnableTelemetry
    managedIdentities: parAutomationAccountUseManagedIdentity ? {
      systemAssigned: true
    } : null
    publicNetworkAccess: parAutomationAccountPublicNetworkAccess ? 'Enabled' : 'Disabled'
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        logCategoriesAndGroups: [
          { category: 'JobLogs' }
          { category: 'JobStreams' }
          { category: 'DSCNodeStatus' }
        ]
      }
    ]
  }
}

module userAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  name: 'alz-umi-${uniqueString(deployment().name)}'
  scope: resourceGroup(parMgmtLoggingResourceGroup)
  dependsOn: [ managementResourceGroup ]
  params: {
    name: parUserAssignedIdentityName
    location: parLocations[0]
    tags: parTags
    enableTelemetry: parEnableTelemetry
  }
}

module dataCollectionRuleVMInsights 'br/public:avm/res/insights/data-collection-rule:0.4.2' = {
  name: 'alz-dcr-vmi-${uniqueString(deployment().name)}'
  scope: resourceGroup(parMgmtLoggingResourceGroup)
  dependsOn: [ managementResourceGroup, logAnalyticsWorkspace ]
  params: {
    name: parDataCollectionRuleVMInsightsName
    location: parLocations[0]
    tags: parTags
    enableTelemetry: parEnableTelemetry
    kind: 'Windows'
    dataSources: {
      performanceCounters: [
        {
          name: 'VMInsightsPerfCounters'
          streams: [ 'Microsoft-InsightsMetrics' ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\VmInsights\\DetailedMetrics'
          ]
        }
      ]
      extensions: [
        {
          name: 'DependencyAgentDataSource'
          streams: [ 'Microsoft-ServiceMap' ]
          extensionName: 'DependencyAgent'
          extensionSettings: {}
        }
      ]
    }
    dataFlows: [
      {
        streams: [ 'Microsoft-InsightsMetrics', 'Microsoft-ServiceMap' ]
        destinations: [ parLogAnalyticsWorkspaceName ]
      }
    ]
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
          name: parLogAnalyticsWorkspaceName
        }
      ]
    }
  }
}

module dataCollectionRuleChangeTracking 'br/public:avm/res/insights/data-collection-rule:0.4.2' = {
  name: 'alz-dcr-ct-${uniqueString(deployment().name)}'
  scope: resourceGroup(parMgmtLoggingResourceGroup)
  dependsOn: [ managementResourceGroup, logAnalyticsWorkspace ]
  params: {
    name: parDataCollectionRuleChangeTrackingName
    location: parLocations[0]
    tags: parTags
    enableTelemetry: parEnableTelemetry
    kind: 'Windows'
    dataSources: {
      extensions: [
        {
          name: 'CTDataSource-Windows'
          streams: [
            'Microsoft-ConfigurationChange'
            'Microsoft-ConfigurationChangeV2'
            'Microsoft-ConfigurationData'
          ]
          extensionName: 'ChangeTracking-Windows'
          extensionSettings: {
            enableFiles: true
            enableSoftware: true
            enableRegistry: true
            enableServices: true
            enableInventory: true
          }
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-ConfigurationChange'
          'Microsoft-ConfigurationChangeV2'
          'Microsoft-ConfigurationData'
        ]
        destinations: [ parLogAnalyticsWorkspaceName ]
      }
    ]
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
          name: parLogAnalyticsWorkspaceName
        }
      ]
    }
  }
}

module dataCollectionRuleMDFCSQL 'br/public:avm/res/insights/data-collection-rule:0.4.2' = {
  name: 'alz-dcr-mdfcsql-${uniqueString(deployment().name)}'
  scope: resourceGroup(parMgmtLoggingResourceGroup)
  dependsOn: [ managementResourceGroup, logAnalyticsWorkspace ]
  params: {
    name: parDataCollectionRuleMDFCSQLName
    location: parLocations[0]
    tags: parTags
    enableTelemetry: parEnableTelemetry
    kind: 'Windows'
    dataSources: {
      extensions: [
        {
          name: 'MicrosoftDefenderForSQL'
          streams: [ 'Microsoft-DefenderForSqlScanEvents', 'Microsoft-DefenderForSqlScanResults' ]
          extensionName: 'MicrosoftDefenderForSQL'
          extensionSettings: {}
        }
      ]
    }
    dataFlows: [
      {
        streams: [ 'Microsoft-DefenderForSqlScanEvents', 'Microsoft-DefenderForSqlScanResults' ]
        destinations: [ parLogAnalyticsWorkspaceName ]
      }
    ]
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
          name: parLogAnalyticsWorkspaceName
        }
      ]
    }
  }
}

// ================ //
// Outputs
// ================ //

@description('The resource ID of the Log Analytics Workspace.')
output outLogAnalyticsWorkspaceResourceId string = logAnalyticsWorkspace.outputs.resourceId

@description('The name of the Log Analytics Workspace.')
output outLogAnalyticsWorkspaceName string = parLogAnalyticsWorkspaceName

@description('The resource group for management and logging.')
output outMgmtLoggingResourceGroupName string = parMgmtLoggingResourceGroup

@description('The resource ID of the VM Insights Data Collection Rule.')
output outDataCollectionRuleVMInsightsId string = dataCollectionRuleVMInsights.outputs.resourceId

@description('The resource ID of the Change Tracking Data Collection Rule.')
output outDataCollectionRuleChangeTrackingId string = dataCollectionRuleChangeTracking.outputs.resourceId

@description('The resource ID of the MDFC SQL Data Collection Rule.')
output outDataCollectionRuleMDFCSQLId string = dataCollectionRuleMDFCSQL.outputs.resourceId

@description('The resource ID of the User Assigned Managed Identity.')
output outUserAssignedIdentityResourceId string = userAssignedIdentity.outputs.resourceId
