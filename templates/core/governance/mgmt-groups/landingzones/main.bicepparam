using './main.bicep'

// ===============================================================
// ANPASSEN: Ersetze alle Werte in <> mit deinen eigenen Werten
// Voraussetzung: int-root MG wurde bereits deployed
// ===============================================================

param parLocations = [
  'germanywestcentral'
  'northeurope'
]
param parEnableTelemetry = true

param landingZonesConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-landingzones'
  managementGroupDisplayName: 'Landing Zones'
  managementGroupParentId: 'alz'
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

param corpConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-landingzones-corp'
  managementGroupDisplayName: 'Corp'
  managementGroupParentId: 'alz-landingzones'
  managementGroupIntermediateRootName: 'alz'
  managementGroupDoNotEnforcePolicyAssignments: []
  managementGroupExcludedPolicyAssignments: []
  customerRbacRoleDefs: []
  customerRbacRoleAssignments: []
  customerPolicyDefs: []
  customerPolicySetDefs: []
  customerPolicyAssignments: []
  subscriptionsToPlaceInManagementGroup: []  // Füge Corp Subscription IDs hier ein
  waitForConsistencyCounterBeforeCustomPolicyDefinitions: 10
  waitForConsistencyCounterBeforeCustomPolicySetDefinitions: 10
  waitForConsistencyCounterBeforeCustomRoleDefinitions: 10
  waitForConsistencyCounterBeforePolicyAssignments: 40
  waitForConsistencyCounterBeforeRoleAssignments: 40
  waitForConsistencyCounterBeforeSubPlacement: 10
}

param onlineConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-landingzones-online'
  managementGroupDisplayName: 'Online'
  managementGroupParentId: 'alz-landingzones'
  managementGroupIntermediateRootName: 'alz'
  managementGroupDoNotEnforcePolicyAssignments: []
  managementGroupExcludedPolicyAssignments: []
  customerRbacRoleDefs: []
  customerRbacRoleAssignments: []
  customerPolicyDefs: []
  customerPolicySetDefs: []
  customerPolicyAssignments: []
  subscriptionsToPlaceInManagementGroup: []  // Füge Online Subscription IDs hier ein
  waitForConsistencyCounterBeforeCustomPolicyDefinitions: 10
  waitForConsistencyCounterBeforeCustomPolicySetDefinitions: 10
  waitForConsistencyCounterBeforeCustomRoleDefinitions: 10
  waitForConsistencyCounterBeforePolicyAssignments: 40
  waitForConsistencyCounterBeforeRoleAssignments: 40
  waitForConsistencyCounterBeforeSubPlacement: 10
}

param localConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-landingzones-local'
  managementGroupDisplayName: 'Local'
  managementGroupParentId: 'alz-landingzones'
  managementGroupIntermediateRootName: 'alz'
  managementGroupDoNotEnforcePolicyAssignments: []
  managementGroupExcludedPolicyAssignments: []
  customerRbacRoleDefs: []
  customerRbacRoleAssignments: []
  customerPolicyDefs: []
  customerPolicySetDefs: []
  customerPolicyAssignments: []
  subscriptionsToPlaceInManagementGroup: []  // Für Sovereign/Confidential Workloads
  waitForConsistencyCounterBeforeCustomPolicyDefinitions: 10
  waitForConsistencyCounterBeforeCustomPolicySetDefinitions: 10
  waitForConsistencyCounterBeforeCustomRoleDefinitions: 10
  waitForConsistencyCounterBeforePolicyAssignments: 40
  waitForConsistencyCounterBeforeRoleAssignments: 40
  waitForConsistencyCounterBeforeSubPlacement: 10
}

param parPolicyAssignmentParameterOverrides = {
  'Enforce-GR-KeyVault': {
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
  }
  'Deny-PublicPaaSEndpoints': {
    parameters: {
      effect: {
        value: 'Deny'
      }
    }
  }
  'Deploy-VM-ChangeTrack': {
    parameters: {
      dcrResourceId: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.Insights/dataCollectionRules/dcr-ct-alz-germanywestcentral'
      }
      userAssignedIdentityResourceId: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-alz-germanywestcentral'
      }
    }
  }
}
