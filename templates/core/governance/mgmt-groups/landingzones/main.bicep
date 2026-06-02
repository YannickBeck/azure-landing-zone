// ================================================================ //
// ALZ Landing Zones Management Group
// Deploys Landing Zones MG with sub-groups: Corp, Online, Local
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

import { alzCoreType } from '../../../../alzCoreType.bicep'

// ================ //
// Parameters
// ================ //

@description('Configuration for the Landing Zones management group.')
param landingZonesConfig alzCoreType

@description('Array of Azure regions. First element is primary region.')
param parLocations array = [
  deployment().location
]

@description('Enable or disable telemetry.')
param parEnableTelemetry bool = true

@description('Override specific policy assignment parameters.')
param parPolicyAssignmentParameterOverrides object = {}

// Sub-management group configurations
@description('Configuration for the Corp sub-management group (internal-facing workloads).')
param corpConfig alzCoreType = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-landingzones-corp'
  managementGroupDisplayName: 'Corp'
  managementGroupParentId: landingZonesConfig.managementGroupName ?? 'alz-landingzones'
  managementGroupIntermediateRootName: landingZonesConfig.managementGroupIntermediateRootName ?? 'alz'
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

@description('Configuration for the Online sub-management group (internet-facing workloads).')
param onlineConfig alzCoreType = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-landingzones-online'
  managementGroupDisplayName: 'Online'
  managementGroupParentId: landingZonesConfig.managementGroupName ?? 'alz-landingzones'
  managementGroupIntermediateRootName: landingZonesConfig.managementGroupIntermediateRootName ?? 'alz'
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

@description('Configuration for the Local sub-management group (confidential/sovereign workloads).')
param localConfig alzCoreType = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'alz-landingzones-local'
  managementGroupDisplayName: 'Local'
  managementGroupParentId: landingZonesConfig.managementGroupName ?? 'alz-landingzones'
  managementGroupIntermediateRootName: landingZonesConfig.managementGroupIntermediateRootName ?? 'alz'
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

var varLzMgName = landingZonesConfig.managementGroupName ?? 'alz-landingzones'
var varLzMgDisplayName = landingZonesConfig.managementGroupDisplayName ?? 'Landing Zones'
var varLzMgParentId = landingZonesConfig.managementGroupParentId ?? 'alz'

// ================ //
// Modules
// ================ //

module landingZonesManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (landingZonesConfig.createOrUpdateManagementGroup) {
  name: 'alz-lz-MG-${uniqueString(deployment().name)}'
  params: {
    name: varLzMgName
    displayName: varLzMgDisplayName
    parentId: '/providers/Microsoft.Management/managementGroups/${varLzMgParentId}'
    enableTelemetry: parEnableTelemetry
  }
}

module corpManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (corpConfig.createOrUpdateManagementGroup) {
  name: 'alz-corp-MG-${uniqueString(deployment().name)}'
  dependsOn: [ landingZonesManagementGroup ]
  params: {
    name: corpConfig.managementGroupName ?? 'alz-landingzones-corp'
    displayName: corpConfig.managementGroupDisplayName ?? 'Corp'
    parentId: '/providers/Microsoft.Management/managementGroups/${varLzMgName}'
    enableTelemetry: parEnableTelemetry
  }
}

module onlineManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (onlineConfig.createOrUpdateManagementGroup) {
  name: 'alz-online-MG-${uniqueString(deployment().name)}'
  dependsOn: [ landingZonesManagementGroup ]
  params: {
    name: onlineConfig.managementGroupName ?? 'alz-landingzones-online'
    displayName: onlineConfig.managementGroupDisplayName ?? 'Online'
    parentId: '/providers/Microsoft.Management/managementGroups/${varLzMgName}'
    enableTelemetry: parEnableTelemetry
  }
}

module localManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (localConfig.createOrUpdateManagementGroup) {
  name: 'alz-local-MG-${uniqueString(deployment().name)}'
  dependsOn: [ landingZonesManagementGroup ]
  params: {
    name: localConfig.managementGroupName ?? 'alz-landingzones-local'
    displayName: localConfig.managementGroupDisplayName ?? 'Local'
    parentId: '/providers/Microsoft.Management/managementGroups/${varLzMgName}'
    enableTelemetry: parEnableTelemetry
  }
}

// ================ //
// Outputs
// ================ //

@description('The resource ID of the Landing Zones management group.')
output outLandingZonesManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${varLzMgName}'

@description('The resource ID of the Corp management group.')
output outCorpManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${corpConfig.managementGroupName ?? 'alz-landingzones-corp'}'

@description('The resource ID of the Online management group.')
output outOnlineManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${onlineConfig.managementGroupName ?? 'alz-landingzones-online'}'

@description('The resource ID of the Local management group.')
output outLocalManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${localConfig.managementGroupName ?? 'alz-landingzones-local'}'
