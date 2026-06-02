// ================================================================ //
// ALZ Decommissioned Management Group
// Holds subscriptions being retired - strict deny policies
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

import { alzCoreType } from '../../../../alzCoreType.bicep'

// ================ //
// Parameters
// ================ //

@description('Configuration for the Decommissioned management group.')
param decommissionedConfig alzCoreType

@description('Array of Azure regions.')
param parLocations array = [
  deployment().location
]

@description('Enable or disable telemetry.')
param parEnableTelemetry bool = true

// ================ //
// Variables
// ================ //

var varDecommMgName = decommissionedConfig.managementGroupName ?? 'alz-decommissioned'
var varDecommMgDisplayName = decommissionedConfig.managementGroupDisplayName ?? 'Decommissioned'
var varDecommMgParentId = decommissionedConfig.managementGroupParentId ?? 'alz'

// ================ //
// Modules
// ================ //

module decommissionedManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (decommissionedConfig.createOrUpdateManagementGroup) {
  name: 'alz-decommissioned-MG-${uniqueString(deployment().name)}'
  params: {
    name: varDecommMgName
    displayName: varDecommMgDisplayName
    parentId: '/providers/Microsoft.Management/managementGroups/${varDecommMgParentId}'
    enableTelemetry: parEnableTelemetry
  }
}

// ================ //
// Outputs
// ================ //

@description('The resource ID of the Decommissioned management group.')
output outDecommissionedManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${varDecommMgName}'
