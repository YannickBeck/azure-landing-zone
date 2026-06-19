// ================================================================ //
// ALZ Role Assignment
// Unterstützt Built-in-Rollen, ALZ-Custom-Rollen und direkte IDs.
//
// roleDefinition akzeptiert:
//   'Owner' | 'Contributor' | 'Reader'          → Built-in (GUID-Lookup)
//   'Subscription-Owner'                         → ALZ Custom Role
//   'Security-Operations'                        → ALZ Custom Role
//   'Network-Management'                         → ALZ Custom Role
//   'Application-Owners'                         → ALZ Custom Role
//   'Network-Subnet-Contributor'                 → ALZ Custom Role
//   '/providers/Microsoft.Authorization/...'     → direkte Resource-ID
// ================================================================ //

targetScope = 'managementGroup'

// ================ //
// Parameters
// ================ //

@description('Object ID des Entra-ID-Principals (Gruppe empfohlen).')
param parPrincipalId string

@description('Rollenname (Built-in oder ALZ-Custom) oder vollständige roleDefinitionId (/providers/...).')
param parRoleDefinition string

@description('Typ des Principals.')
@allowed([ 'Group', 'User', 'ServicePrincipal' ])
param parPrincipalType string = 'Group'

@description('Beschreibung der Zuweisung.')
param parDescription string = ''

// ================ //
// Variables
// ================ //

// Built-in Role GUIDs (Microsoft-Standard)
var varBuiltInRoles = {
  Owner:       '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader:      'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

// ALZ Custom Role GUIDs – deployt von avm/ptn/alz/empty:0.3.6 auf der alz-Root-MG
var varAlzCustomRoles = {
  'Subscription-Owner':          '3036fbd3-d48f-4f34-b21d-ae70e34ac0a3'
  'Security-Operations':         '06b7e0d3-4e96-4ece-8012-52de11ad79c3'
  'Network-Management':          '91a24c40-3e9a-4c19-9ef7-31aec2a27c5e'
  'Application-Owners':          '71e12741-03da-4a97-9d4c-5d78db6e84e3'
  'Network-Subnet-Contributor':  '4fd05993-e02e-4f6b-9f66-48dab5aee3b7'
}

// Auflösung: direkte Resource-ID → unverändert; bekannter Name → GUID-Lookup; sonst Fehler
var varIsResourceId  = startsWith(parRoleDefinition, '/')
var varIsBuiltIn     = contains(varBuiltInRoles, parRoleDefinition)
var varIsAlzCustom   = contains(varAlzCustomRoles, parRoleDefinition)

var varResolvedGuid = varIsBuiltIn   ? varBuiltInRoles[parRoleDefinition]
                    : varIsAlzCustom ? varAlzCustomRoles[parRoleDefinition]
                    : ''

var varRoleDefinitionId = varIsResourceId
  ? parRoleDefinition
  : tenantResourceId('Microsoft.Authorization/roleDefinitions', varResolvedGuid)

// ================ //
// Resources
// ================ //

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(managementGroup().id, parPrincipalId, parRoleDefinition)
  properties: {
    principalId:       parPrincipalId
    roleDefinitionId:  varRoleDefinitionId
    principalType:     parPrincipalType
    description:       empty(parDescription) ? null : parDescription
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID des Role Assignment.')
output outRoleAssignmentId string = roleAssignment.id
