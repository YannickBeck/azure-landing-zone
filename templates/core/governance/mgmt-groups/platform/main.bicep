// ================================================================ //
// ALZ Platform Management Group
// Deploys Platform MG with sub-groups: Connectivity, Identity,
// Management, Security
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

import { alzCoreType } from '../../../../alzCoreType.bicep'

// ================ //
// Parameters
// ================ //

@description('Configuration for the Platform management group.')
param platformConfig alzCoreType

@description('Array of Azure regions. First element is primary region.')
param parLocations array = [
  deployment().location
]

@description('Enable or disable telemetry.')
param parEnableTelemetry bool = true

@description('Override specific policy assignment parameters.')
param parPolicyAssignmentParameterOverrides object = {}

// Sub-management group configurations
@description('Configuration for the Platform Connectivity sub-management group.')
param connectivityConfig alzCoreType = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-platform-connectivity'
  managementGroupDisplayName: 'Connectivity'
  managementGroupParentId: platformConfig.managementGroupName ?? 'alz-platform'
  managementGroupIntermediateRootName: platformConfig.managementGroupIntermediateRootName ?? 'alz'
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

@description('Configuration for the Platform Identity sub-management group.')
param identityConfig alzCoreType = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-platform-identity'
  managementGroupDisplayName: 'Identity'
  managementGroupParentId: platformConfig.managementGroupName ?? 'alz-platform'
  managementGroupIntermediateRootName: platformConfig.managementGroupIntermediateRootName ?? 'alz'
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

@description('Configuration for the Platform Management sub-management group.')
param managementMgConfig alzCoreType = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-platform-management'
  managementGroupDisplayName: 'Management'
  managementGroupParentId: platformConfig.managementGroupName ?? 'alz-platform'
  managementGroupIntermediateRootName: platformConfig.managementGroupIntermediateRootName ?? 'alz'
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

@description('Configuration for the Platform Security sub-management group.')
param securityConfig alzCoreType = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-platform-security'
  managementGroupDisplayName: 'Security'
  managementGroupParentId: platformConfig.managementGroupName ?? 'alz-platform'
  managementGroupIntermediateRootName: platformConfig.managementGroupIntermediateRootName ?? 'alz'
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

// ================ //
// Variables
// ================ //

var varPlatformMgName = platformConfig.managementGroupName ?? 'alz-platform'
var varPlatformMgDisplayName = platformConfig.managementGroupDisplayName ?? 'Platform'
var varPlatformMgParentId = platformConfig.managementGroupParentId ?? 'alz'

// ================ //
// Modules
// ================ //

module platformManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (platformConfig.createOrUpdateManagementGroup) {
  name: 'alz-platform-MG-${uniqueString(deployment().name)}'
  params: {
    name: varPlatformMgName
    displayName: varPlatformMgDisplayName
    parentId: '/providers/Microsoft.Management/managementGroups/${varPlatformMgParentId}'
    enableTelemetry: parEnableTelemetry
  }
}

module connectivityManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (connectivityConfig.createOrUpdateManagementGroup) {
  name: 'alz-connectivity-MG-${uniqueString(deployment().name)}'
  dependsOn: [ platformManagementGroup ]
  params: {
    name: connectivityConfig.managementGroupName ?? 'alz-platform-connectivity'
    displayName: connectivityConfig.managementGroupDisplayName ?? 'Connectivity'
    parentId: '/providers/Microsoft.Management/managementGroups/${varPlatformMgName}'
    enableTelemetry: parEnableTelemetry
  }
}

module identityManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (identityConfig.createOrUpdateManagementGroup) {
  name: 'alz-identity-MG-${uniqueString(deployment().name)}'
  dependsOn: [ platformManagementGroup ]
  params: {
    name: identityConfig.managementGroupName ?? 'alz-platform-identity'
    displayName: identityConfig.managementGroupDisplayName ?? 'Identity'
    parentId: '/providers/Microsoft.Management/managementGroups/${varPlatformMgName}'
    enableTelemetry: parEnableTelemetry
  }
}

module managementManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (managementMgConfig.createOrUpdateManagementGroup) {
  name: 'alz-mgmt-MG-${uniqueString(deployment().name)}'
  dependsOn: [ platformManagementGroup ]
  params: {
    name: managementMgConfig.managementGroupName ?? 'alz-platform-management'
    displayName: managementMgConfig.managementGroupDisplayName ?? 'Management'
    parentId: '/providers/Microsoft.Management/managementGroups/${varPlatformMgName}'
    enableTelemetry: parEnableTelemetry
  }
}

module securityManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (securityConfig.createOrUpdateManagementGroup) {
  name: 'alz-security-MG-${uniqueString(deployment().name)}'
  dependsOn: [ platformManagementGroup ]
  params: {
    name: securityConfig.managementGroupName ?? 'alz-platform-security'
    displayName: securityConfig.managementGroupDisplayName ?? 'Security'
    parentId: '/providers/Microsoft.Management/managementGroups/${varPlatformMgName}'
    enableTelemetry: parEnableTelemetry
  }
}

// ================ //
// Outputs
// ================ //

@description('The resource ID of the Platform management group.')
output outPlatformManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${varPlatformMgName}'

@description('The resource ID of the Connectivity management group.')
output outConnectivityManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${connectivityConfig.managementGroupName ?? 'alz-platform-connectivity'}'

@description('The resource ID of the Identity management group.')
output outIdentityManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${identityConfig.managementGroupName ?? 'alz-platform-identity'}'

@description('The resource ID of the Management management group.')
output outManagementManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${managementMgConfig.managementGroupName ?? 'alz-platform-management'}'

@description('The resource ID of the Security management group.')
output outSecurityManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${securityConfig.managementGroupName ?? 'alz-platform-security'}'
