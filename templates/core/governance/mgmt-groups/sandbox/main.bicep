// ================================================================ //
// ALZ Sandbox Management Group
// Sandbox fuer Experimente - lockere Policies, keine Corp-Anbindung.
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

@description('ID (Name) der Sandbox Management Group.')
param parSandboxMgId string = 'alz-sandbox'

@description('Anzeigename der Sandbox Management Group.')
param parSandboxMgDisplayName string = 'Sandbox'

@description('ID der uebergeordneten Intermediate-Root Management Group.')
param parParentMgId string = 'alz'

resource sandboxManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: parSandboxMgId
  properties: {
    displayName: parSandboxMgDisplayName
    details: {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/${parParentMgId}'
      }
    }
  }
}

@description('Resource ID der Sandbox Management Group.')
output outSandboxManagementGroupId string = sandboxManagementGroup.id
