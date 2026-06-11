// ================================================================ //
// ALZ Landing Zones Management Group + Sub-Management-Groups
// Erstellt: Landing Zones und darunter Corp, Online, Local.
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

// ================ //
// Parameters
// ================ //

@description('ID (Name) der Landing Zones Management Group.')
param parLandingZonesMgId string = 'alz-landingzones'

@description('Anzeigename der Landing Zones Management Group.')
param parLandingZonesMgDisplayName string = 'Landing Zones'

@description('ID der uebergeordneten Intermediate-Root Management Group.')
param parParentMgId string = 'alz'

@description('ID-Praefix fuer die Sub-Management-Groups.')
param parChildMgIdPrefix string = 'alz-landingzones-'

@description('Policy "Network interfaces should not have public IPs" auf der Corp-MG zuweisen (Deny).')
param parDenyNicPublicIpOnCorp bool = true

// ================ //
// Variables
// ================ //

var varChildren = [
  { suffix: 'corp', displayName: 'Corp' }
  { suffix: 'online', displayName: 'Online' }
  { suffix: 'local', displayName: 'Local' }
]

// ================ //
// Resources
// ================ //

resource landingZonesManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: parLandingZonesMgId
  properties: {
    displayName: parLandingZonesMgDisplayName
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
        id: landingZonesManagementGroup.id
      }
    }
  }
}]

// ================ //
// Modules
// ================ //

// Built-in: "Network interfaces should not have public IPs" (Corp = interne Workloads)
module denyNicPublicIpCorpPolicy '../modules/policyAssignment-builtin.bicep' = if (parDenyNicPublicIpOnCorp) {
  name: 'alz-lz-corp-denyNicPip-${uniqueString(parLandingZonesMgId)}'
  scope: managementGroup('${parChildMgIdPrefix}corp')
  dependsOn: [
    childManagementGroups
  ]
  params: {
    parPolicyAssignmentName: 'Deny-NIC-PublicIP'
    parPolicyAssignmentDisplayName: 'Corp: Keine Public IPs auf Network Interfaces'
    parPolicyAssignmentDescription: 'Verhindert Public IPs an NICs in der Corp Landing Zone (interne Workloads).'
    parPolicyDefinitionGuid: '83a86a26-fd1f-447c-b59d-e51f44264114'
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID der Landing Zones Management Group.')
output outLandingZonesManagementGroupId string = landingZonesManagementGroup.id

@description('Resource IDs der Landing-Zone Sub-Management-Groups.')
output outChildManagementGroupIds array = [for (child, i) in varChildren: childManagementGroups[i].id]
