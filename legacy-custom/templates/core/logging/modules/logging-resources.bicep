// ================================================================ //
// ALZ Logging Resources (native)
// Log Analytics Workspace, User Assigned Identity, Solutions,
// Data Collection Rules, optionale Automation Account.
// Scope: Resource Group
// ================================================================ //

targetScope = 'resourceGroup'

// ================ //
// Parameters
// ================ //

@description('Region fuer alle Logging-Ressourcen.')
param parLocation string

@description('Tags fuer alle Ressourcen.')
param parTags object = {}

@description('Name des Log Analytics Workspace.')
param parLogAnalyticsWorkspaceName string

@description('SKU des Log Analytics Workspace.')
param parLogAnalyticsWorkspaceSku string = 'PerGB2018'

@description('Aufbewahrung der Logs in Tagen (30-730).')
@minValue(30)
@maxValue(730)
param parLogRetentionInDays int = 365

@description('Liste der Log-Analytics-Solutions (z.B. ChangeTracking).')
param parSolutions array = [
  'ChangeTracking'
]

@description('Microsoft Sentinel (SecurityInsights) aktivieren.')
param parEnableSentinel bool = false

@description('Name der User Assigned Managed Identity.')
param parUserAssignedIdentityName string

@description('Name der VM-Insights Data Collection Rule.')
param parDataCollectionRuleVMInsightsName string

@description('Name der Change-Tracking Data Collection Rule.')
param parDataCollectionRuleChangeTrackingName string

@description('Name der MDFC-SQL Data Collection Rule.')
param parDataCollectionRuleMDFCSQLName string

@description('Automation Account deployen.')
param parDeployAutomationAccount bool = false

@description('Name der Automation Account.')
param parAutomationAccountName string = 'aa-alz'

@description('SKU der Automation Account.')
param parAutomationAccountSku string = 'Basic'

@description('System Assigned Identity fuer Automation Account.')
param parAutomationAccountUseManagedIdentity bool = true

@description('Public Network Access fuer Automation Account.')
param parAutomationAccountPublicNetworkAccess bool = true

// ================ //
// Variables
// ================ //

var varSolutions = union(parSolutions, parEnableSentinel ? [ 'SecurityInsights' ] : [])

// ================ //
// Resources
// ================ //

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: parLogAnalyticsWorkspaceName
  location: parLocation
  tags: parTags
  properties: {
    sku: {
      name: parLogAnalyticsWorkspaceSku
    }
    retentionInDays: parLogRetentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource solutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in varSolutions: {
  name: '${solution}(${logAnalyticsWorkspace.name})'
  location: parLocation
  tags: parTags
  plan: {
    name: '${solution}(${logAnalyticsWorkspace.name})'
    product: 'OMSGallery/${solution}'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
}]

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: parUserAssignedIdentityName
  location: parLocation
  tags: parTags
}

resource dataCollectionRuleVMInsights 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: parDataCollectionRuleVMInsightsName
  location: parLocation
  tags: parTags
  properties: {
    description: 'Data Collection Rule fuer VM Insights.'
    dataSources: {
      performanceCounters: [
        {
          name: 'VMInsightsPerfCounters'
          streams: [ 'Microsoft-InsightsMetrics' ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [ '\\VmInsights\\DetailedMetrics' ]
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
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.id
          name: 'VMInsightsDest'
        }
      ]
    }
    dataFlows: [
      {
        streams: [ 'Microsoft-InsightsMetrics' ]
        destinations: [ 'VMInsightsDest' ]
      }
      {
        streams: [ 'Microsoft-ServiceMap' ]
        destinations: [ 'VMInsightsDest' ]
      }
    ]
  }
}

resource dataCollectionRuleChangeTracking 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: parDataCollectionRuleChangeTrackingName
  location: parLocation
  tags: parTags
  properties: {
    description: 'Data Collection Rule fuer Change Tracking & Inventory.'
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
        {
          name: 'CTDataSource-Linux'
          streams: [
            'Microsoft-ConfigurationChange'
            'Microsoft-ConfigurationChangeV2'
            'Microsoft-ConfigurationData'
          ]
          extensionName: 'ChangeTracking-Linux'
          extensionSettings: {
            enableFiles: true
            enableSoftware: true
            enableServices: true
            enableInventory: true
          }
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.id
          name: 'ChangeTrackingDest'
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
        destinations: [ 'ChangeTrackingDest' ]
      }
    ]
  }
}

resource dataCollectionRuleMDFCSQL 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: parDataCollectionRuleMDFCSQLName
  location: parLocation
  tags: parTags
  properties: {
    description: 'Data Collection Rule fuer Microsoft Defender for SQL.'
    dataSources: {
      extensions: [
        {
          name: 'MicrosoftDefenderForSQL'
          streams: [
            'Microsoft-DefenderForSqlAlerts'
            'Microsoft-DefenderForSqlLogins'
            'Microsoft-DefenderForSqlTelemetry'
            'Microsoft-DefenderForSqlScanEvents'
            'Microsoft-DefenderForSqlScanResults'
          ]
          extensionName: 'MicrosoftDefenderForSQL'
          extensionSettings: {
            enableCollectionOfSqlQueriesForSecurityResearch: false
          }
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.id
          name: 'MDFCSQLDest'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-DefenderForSqlAlerts'
          'Microsoft-DefenderForSqlLogins'
          'Microsoft-DefenderForSqlTelemetry'
          'Microsoft-DefenderForSqlScanEvents'
          'Microsoft-DefenderForSqlScanResults'
        ]
        destinations: [ 'MDFCSQLDest' ]
      }
    ]
  }
}

resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = if (parDeployAutomationAccount) {
  name: parAutomationAccountName
  location: parLocation
  tags: parTags
  identity: parAutomationAccountUseManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    sku: {
      name: parAutomationAccountSku
    }
    publicNetworkAccess: parAutomationAccountPublicNetworkAccess
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID des Log Analytics Workspace.')
output outLogAnalyticsWorkspaceResourceId string = logAnalyticsWorkspace.id

@description('Resource ID der User Assigned Managed Identity.')
output outUserAssignedIdentityResourceId string = userAssignedIdentity.id

@description('Resource ID der VM-Insights DCR.')
output outDcrVMInsightsId string = dataCollectionRuleVMInsights.id

@description('Resource ID der Change-Tracking DCR.')
output outDcrChangeTrackingId string = dataCollectionRuleChangeTracking.id

@description('Resource ID der MDFC-SQL DCR.')
output outDcrMDFCSQLId string = dataCollectionRuleMDFCSQL.id
