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

param platformConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-platform'
  managementGroupDisplayName: 'Platform'
  managementGroupParentId: 'alz'            // ID des Int-Root MG (muss übereinstimmen)
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

param connectivityConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-platform-connectivity'
  managementGroupDisplayName: 'Connectivity'
  managementGroupParentId: 'alz-platform'
  managementGroupIntermediateRootName: 'alz'
  managementGroupDoNotEnforcePolicyAssignments: []
  managementGroupExcludedPolicyAssignments: []
  customerRbacRoleDefs: []
  customerRbacRoleAssignments: []
  customerPolicyDefs: []
  customerPolicySetDefs: []
  customerPolicyAssignments: []
  subscriptionsToPlaceInManagementGroup: [
    '<CONNECTIVITY_SUBSCRIPTION_ID>'        // Deine Connectivity Subscription ID
  ]
  waitForConsistencyCounterBeforeCustomPolicyDefinitions: 10
  waitForConsistencyCounterBeforeCustomPolicySetDefinitions: 10
  waitForConsistencyCounterBeforeCustomRoleDefinitions: 10
  waitForConsistencyCounterBeforePolicyAssignments: 40
  waitForConsistencyCounterBeforeRoleAssignments: 40
  waitForConsistencyCounterBeforeSubPlacement: 10
}

param identityConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-platform-identity'
  managementGroupDisplayName: 'Identity'
  managementGroupParentId: 'alz-platform'
  managementGroupIntermediateRootName: 'alz'
  managementGroupDoNotEnforcePolicyAssignments: []
  managementGroupExcludedPolicyAssignments: []
  customerRbacRoleDefs: []
  customerRbacRoleAssignments: []
  customerPolicyDefs: []
  customerPolicySetDefs: []
  customerPolicyAssignments: []
  subscriptionsToPlaceInManagementGroup: [
    '<IDENTITY_SUBSCRIPTION_ID>'            // Deine Identity Subscription ID
  ]
  waitForConsistencyCounterBeforeCustomPolicyDefinitions: 10
  waitForConsistencyCounterBeforeCustomPolicySetDefinitions: 10
  waitForConsistencyCounterBeforeCustomRoleDefinitions: 10
  waitForConsistencyCounterBeforePolicyAssignments: 40
  waitForConsistencyCounterBeforeRoleAssignments: 40
  waitForConsistencyCounterBeforeSubPlacement: 10
}

param managementMgConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-platform-management'
  managementGroupDisplayName: 'Management'
  managementGroupParentId: 'alz-platform'
  managementGroupIntermediateRootName: 'alz'
  managementGroupDoNotEnforcePolicyAssignments: []
  managementGroupExcludedPolicyAssignments: []
  customerRbacRoleDefs: []
  customerRbacRoleAssignments: []
  customerPolicyDefs: []
  customerPolicySetDefs: []
  customerPolicyAssignments: []
  subscriptionsToPlaceInManagementGroup: [
    '<MANAGEMENT_SUBSCRIPTION_ID>'          // Deine Management Subscription ID
  ]
  waitForConsistencyCounterBeforeCustomPolicyDefinitions: 10
  waitForConsistencyCounterBeforeCustomPolicySetDefinitions: 10
  waitForConsistencyCounterBeforeCustomRoleDefinitions: 10
  waitForConsistencyCounterBeforePolicyAssignments: 40
  waitForConsistencyCounterBeforeRoleAssignments: 40
  waitForConsistencyCounterBeforeSubPlacement: 10
}

param securityConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-platform-security'
  managementGroupDisplayName: 'Security'
  managementGroupParentId: 'alz-platform'
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

param parPolicyAssignmentParameterOverrides = {
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
  'Deploy-VM-Monitoring': {
    parameters: {
      dcrResourceId: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.Insights/dataCollectionRules/dcr-vmi-alz-germanywestcentral'
      }
      userAssignedIdentityResourceId: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-alz-germanywestcentral'
      }
    }
  }
  'Deploy-MDFC-DefSQL-AMA': {
    parameters: {
      userWorkspaceResourceId: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.OperationalInsights/workspaces/law-alz-germanywestcentral'
      }
      dcrResourceId: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.Insights/dataCollectionRules/dcr-mdfcsql-alz-germanywestcentral'
      }
      userAssignedIdentityResourceId: {
        value: '/subscriptions/<MANAGEMENT_SUBSCRIPTION_ID>/resourceGroups/rg-alz-logging-germanywestcentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-alz-germanywestcentral'
      }
    }
  }
}
