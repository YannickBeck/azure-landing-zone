using './main.bicep'

// ===============================================================
// ANPASSEN: Ersetze alle Werte in <> mit deinen eigenen Werten
// ===============================================================

// General Parameters
param parLocations = [
  'germanywestcentral'      // Primäre Region - z.B. 'germanywestcentral', 'westeurope'
  'northeurope'             // Sekundäre Region - z.B. 'northeurope', 'eastus2'
]

param parEnableTelemetry = true

// Intermediate Root Management Group Configuration
param intRootConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz'                  // ID des Root-MG (z.B. 'alz', 'corp-alz')
  managementGroupDisplayName: 'Azure Landing Zones'
  managementGroupParentId: '<TENANT_ID>'      // Deine Azure Tenant ID (GUID)
  managementGroupIntermediateRootName: 'alz'

  managementGroupDoNotEnforcePolicyAssignments: []
  managementGroupExcludedPolicyAssignments: []

  customerRbacRoleDefs: []
  customerRbacRoleAssignments: []
  customerPolicyDefs: []
  customerPolicySetDefs: []
  customerPolicyAssignments: []

  subscriptionsToPlaceInManagementGroup: []

  waitForConsistencyCounterBeforeCustomPolicyDefinitions: 10
  waitForConsistencyCounterBeforeCustomPolicySetDefinitions: 10
  waitForConsistencyCounterBeforeCustomRoleDefinitions: 10
  waitForConsistencyCounterBeforePolicyAssignments: 40
  waitForConsistencyCounterBeforeRoleAssignments: 40
  waitForConsistencyCounterBeforeSubPlacement: 10
}

// Policy Assignment Parameter Overrides
param parPolicyAssignmentParameterOverrides = {
  'Deploy-MDFC-Config': {
    parameters: {
      logAnalyticsWorkspaceResourceId: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.OperationalInsights/workspaces/law-alz-germanywestcentral'
      }
      emailSecurityContact: {
        value: 'security@<YOUR_DOMAIN>'        // Deine Security-Kontakt E-Mail
      }
    }
  }
  'Deploy-AzActivity-Log': {
    parameters: {
      logAnalytics: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.OperationalInsights/workspaces/law-alz-germanywestcentral'
      }
      logsEnabled: {
        value: 'True'
      }
    }
  }
  'Deploy-Diag-Logs': {
    parameters: {
      logAnalytics: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.OperationalInsights/workspaces/law-alz-germanywestcentral'
      }
    }
  }
  'Deploy-ServiceHealth': {
    parameters: {
      emailAddress: {
        value: 'ops@<YOUR_DOMAIN>'             // Operations Team E-Mail
      }
      effect: {
        value: 'DeployIfNotExists'
      }
    }
  }
  'Deploy-SQL-DB-Auditing': {
    parameters: {
      logAnalyticsWorkspaceId: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.OperationalInsights/workspaces/law-alz-germanywestcentral'
      }
    }
  }
}
