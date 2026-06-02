// ================================================================ //
// ALZ Sandbox Management Group
// Sandbox for experimentation - relaxed policies, no Corp connectivity
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

import { alzCoreType } from '../../../../alzCoreType.bicep'

// ================ //
// Parameters
// ================ //

@description('Configuration for the Sandbox management group.')
param sandboxConfig alzCoreType

@description('Array of Azure regions.')
param parLocations array = [
  deployment().location
]

@description('Enable or disable telemetry.')
param parEnableTelemetry bool = true

// ================ //
// Variables
// ================ //

var varSandboxMgName = sandboxConfig.managementGroupName ?? 'alz-sandbox'
var varSandboxMgDisplayName = sandboxConfig.managementGroupDisplayName ?? 'Sandbox'
var varSandboxMgParentId = sandboxConfig.managementGroupParentId ?? 'alz'

// ================ //
// Modules
// ================ //

module sandboxManagementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (sandboxConfig.createOrUpdateManagementGroup) {
  name: 'alz-sandbox-MG-${uniqueString(deployment().name)}'
  params: {
    name: varSandboxMgName
    displayName: varSandboxMgDisplayName
    parentId: '/providers/Microsoft.Management/managementGroups/${varSandboxMgParentId}'
    enableTelemetry: parEnableTelemetry
  }
}

// ================ //
// Outputs
// ================ //

@description('The resource ID of the Sandbox management group.')
output outSandboxManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${varSandboxMgName}'
