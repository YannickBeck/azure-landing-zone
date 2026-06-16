// ================================================================ //
// ALZ Platform Management Group + Sub-Management-Groups
// Erstellt: Platform und darunter Connectivity, Identity,
//           Management, Security.
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

// ================ //
// Parameters
// ================ //

@description('ID (Name) der Platform Management Group.')
param parPlatformMgId string = 'alz-platform'

@description('Anzeigename der Platform Management Group.')
param parPlatformMgDisplayName string = 'Platform'

@description('ID der uebergeordneten Intermediate-Root Management Group.')
param parParentMgId string = 'alz'

@description('ID-Praefix fuer die Sub-Management-Groups.')
param parChildMgIdPrefix string = 'alz-platform-'

// ================ //
// Variables
// ================ //

var varChildren = [
  { suffix: 'connectivity', displayName: 'Connectivity' }
  { suffix: 'identity', displayName: 'Identity' }
  { suffix: 'management', displayName: 'Management' }
  { suffix: 'security', displayName: 'Security' }
]

// ================ //
// Resources
// ================ //

resource platformManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: parPlatformMgId
  properties: {
    displayName: parPlatformMgDisplayName
    details: {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/${parParentMgId}'
      }
    }
  }
}

resource childManagementGroups 'Microsoft.Management/managementGroups@2023-04-01' = [for child in varChildren: {
  name: '${parChildMgIdPrefix}${child.suffix}'
  properties: {
    displayName: child.displayName
    details: {
      parent: {
        id: platformManagementGroup.id
      }
    }
  }
}]

// ================ //
// Outputs
// ================ //

@description('Resource ID der Platform Management Group.')
output outPlatformManagementGroupId string = platformManagementGroup.id

@description('Resource IDs der Platform Sub-Management-Groups.')
output outChildManagementGroupIds array = [for (child, i) in varChildren: childManagementGroups[i].id]
