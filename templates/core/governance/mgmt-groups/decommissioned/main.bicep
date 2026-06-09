// ================================================================ //
// ALZ Decommissioned Management Group
// Enthaelt stillzulegende Subscriptions - strikte Deny-Policies.
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

@description('ID (Name) der Decommissioned Management Group.')
param parDecommissionedMgId string = 'alz-decommissioned'

@description('Anzeigename der Decommissioned Management Group.')
param parDecommissionedMgDisplayName string = 'Decommissioned'

@description('ID der uebergeordneten Intermediate-Root Management Group.')
param parParentMgId string = 'alz'

resource decommissionedManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: parDecommissionedMgId
  properties: {
    displayName: parDecommissionedMgDisplayName
    details: {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/${parParentMgId}'
      }
    }
  }
}

@description('Resource ID der Decommissioned Management Group.')
output outDecommissionedManagementGroupId string = decommissionedManagementGroup.id
