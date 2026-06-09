// ================================================================ //
// ALZ Int-Root Management Group (Intermediate Root)
// Erstellt die oberste ALZ-Management-Group unterhalb des
// Tenant Root und weist einen Beispiel-Policy-Guardrail zu.
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

// ================ //
// Parameters
// ================ //

@description('ID (Name) der Intermediate-Root Management Group.')
param parIntRootMgId string = 'alz'

@description('Anzeigename der Intermediate-Root Management Group.')
param parIntRootMgDisplayName string = 'Azure Landing Zones'

@description('ID der uebergeordneten Management Group. Standard: Tenant Root MG (= Tenant ID).')
param parParentMgId string = tenant().tenantId

@description('Liste der erlaubten Azure-Regionen fuer den Policy-Guardrail.')
param parAllowedLocations array = [
  'germanywestcentral'
  'northeurope'
]

// ================ //
// Resources
// ================ //

resource intRootManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: parIntRootMgId
  properties: {
    displayName: parIntRootMgDisplayName
    details: {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/${parParentMgId}'
      }
    }
  }
}

// ================ //
// Modules
// ================ //

module allowedLocationsPolicy '../modules/policyAssignment-allowedLocations.bicep' = {
  name: 'alz-introot-allowedLocations-${uniqueString(parIntRootMgId)}'
  scope: managementGroup(parIntRootMgId)
  dependsOn: [
    intRootManagementGroup
  ]
  params: {
    parPolicyAssignmentName: 'Deny-Location'
    parAllowedLocations: parAllowedLocations
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID der Intermediate-Root Management Group.')
output outIntRootManagementGroupId string = intRootManagementGroup.id

@description('Name der Intermediate-Root Management Group.')
output outIntRootManagementGroupName string = parIntRootMgId
