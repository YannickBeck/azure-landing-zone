// ================================================================ //
// ALZ Int-Root Management Group - Intermediate Root
// Deploys the top-level ALZ management group, policies, and RBAC
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

import { alzCoreType } from '../../../alzCoreType.bicep'

// ================ //
// Parameters
// ================ //

@description('The configuration object for the intermediate root management group.')
param intRootConfig alzCoreType

@description('Array of Azure regions for deployment. First element is primary.')
param parLocations array = [
  deployment().location
]

@description('Enable or disable telemetry.')
param parEnableTelemetry bool = true

@description('Override specific policy assignment parameters.')
param parPolicyAssignmentParameterOverrides object = {}

// ================ //
// Variables
// ================ //

var varMgmtGroupName = intRootConfig.managementGroupName ?? 'alz'
var varMgmtGroupDisplayName = intRootConfig.managementGroupDisplayName ?? 'Azure Landing Zones'
var varMgmtGroupParentId = intRootConfig.managementGroupParentId ?? tenant().tenantId
var varIntermediateRootName = intRootConfig.managementGroupIntermediateRootName ?? varMgmtGroupName

var varTelemetryId = 'pid-alz-introot-bicep'

// Built-in role definition IDs
var varRoleDefinitionIds = {
  owner: '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  contributor: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
  logAnalyticsContributor: '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
  monitoringContributor: '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
  rbacSecurityAdmin: '/providers/Microsoft.Authorization/roleDefinitions/f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  sqlSecurityManager: '/providers/Microsoft.Authorization/roleDefinitions/056cd41c-7e88-42e1-933e-88ba6a50c9c3'
  monitoringPolicyContributor: '/providers/Microsoft.Authorization/roleDefinitions/36243c78-bf99-498c-9df9-ad4f8b79b2ea'
}

// ================ //
// Resources
// ================ //

// Telemetry deployment (no-op, only used for tracking)
resource telemetry 'Microsoft.Resources/deployments@2022-09-01' = if (parEnableTelemetry) {
  name: '${varTelemetryId}-${uniqueString(deployment().name)}'
  location: parLocations[0]
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

// ================ //
// Modules
// ================ //

module managementGroup 'br/public:avm/res/management/management-group:0.1.2' = if (intRootConfig.createOrUpdateManagementGroup) {
  name: 'alz-intRoot-MG-${uniqueString(deployment().name)}'
  params: {
    name: varMgmtGroupName
    displayName: varMgmtGroupDisplayName
    parentId: varMgmtGroupParentId
    enableTelemetry: parEnableTelemetry
  }
}

// ================ //
// Outputs
// ================ //

@description('The resource ID of the intermediate root management group.')
output outIntRootManagementGroupId string = '/providers/Microsoft.Management/managementGroups/${varMgmtGroupName}'

@description('The name of the intermediate root management group.')
output outIntRootManagementGroupName string = varMgmtGroupName

@description('The intermediate root management group name for use in child deployments.')
output outIntermediateRootName string = varIntermediateRootName
