// ================================================================ //
// ALZ Security Baseline (je Subscription)
// - Microsoft Defender for Cloud: Pricing/Plans
// - Security Contacts (E-Mail-Benachrichtigungen)
// - Activity-Log Diagnostic Settings -> Log Analytics Workspace
// Scope: Subscription
// ================================================================ //

targetScope = 'subscription'

// ================ //
// Parameters
// ================ //

@description('Defender-for-Cloud Tier fuer die ausgewaehlten Plaene.')
@allowed([ 'Free', 'Standard' ])
param parDefenderTier string = 'Standard'

@description('Defender-for-Cloud Plaene, die auf den gewaehlten Tier gesetzt werden.')
param parDefenderPlans array = [
  'VirtualMachines'
  'StorageAccounts'
  'KeyVaults'
  'Arm'
  'Containers'
  'AppServices'
  'SqlServers'
  'SqlServerVirtualMachines'
  'OpenSourceRelationalDatabases'
  'CosmosDbs'
]

@description('E-Mail(s) fuer Security Contacts (Semikolon-getrennt). Leer = ueberspringen.')
param parSecurityContactEmail string = ''

@description('Minimale Schweregrad-Stufe fuer Alert-Benachrichtigungen.')
@allowed([ 'High', 'Medium', 'Low' ])
param parMinimalAlertSeverity string = 'High'

@description('Resource ID des Log Analytics Workspace fuer Activity-Log-Diagnostics. Leer = ueberspringen.')
param parLogAnalyticsWorkspaceResourceId string = ''

@description('Name der Subscription-Activity-Log Diagnostic Settings.')
param parDiagnosticSettingsName string = 'alz-activitylog-to-law'

// ================ //
// Variables
// ================ //

var varActivityLogCategories = [
  'Administrative'
  'Security'
  'ServiceHealth'
  'Alert'
  'Recommendation'
  'Policy'
  'Autoscale'
  'ResourceHealth'
]

// ================ //
// Resources
// ================ //

// Microsoft Defender for Cloud - Plaene
resource defenderPlans 'Microsoft.Security/pricings@2024-01-01' = [for plan in parDefenderPlans: {
  name: plan
  properties: {
    pricingTier: parDefenderTier
  }
}]

// Security Contacts (nur wenn E-Mail gesetzt)
resource securityContact 'Microsoft.Security/securityContacts@2020-01-01-preview' = if (!empty(parSecurityContactEmail)) {
  name: 'default'
  properties: {
    emails: parSecurityContactEmail
    alertNotifications: {
      state: 'On'
      minimalSeverity: parMinimalAlertSeverity
    }
    notificationsByRole: {
      state: 'On'
      roles: [ 'Owner' ]
    }
  }
}

// Activity-Log -> Log Analytics (nur wenn Workspace gesetzt)
resource activityLogToLaw 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(parLogAnalyticsWorkspaceResourceId)) {
  name: parDiagnosticSettingsName
  properties: {
    workspaceId: parLogAnalyticsWorkspaceResourceId
    logs: [for category in varActivityLogCategories: {
      category: category
      enabled: true
    }]
  }
}

// ================ //
// Outputs
// ================ //

@description('Anzahl der konfigurierten Defender-Plaene.')
output outConfiguredDefenderPlanCount int = length(parDefenderPlans)

@description('Wurde ein Security Contact gesetzt?')
output outSecurityContactConfigured bool = !empty(parSecurityContactEmail)

@description('Wurde Activity-Log-Diagnostics an Log Analytics angebunden?')
output outActivityLogDiagnosticsConfigured bool = !empty(parLogAnalyticsWorkspaceResourceId)
