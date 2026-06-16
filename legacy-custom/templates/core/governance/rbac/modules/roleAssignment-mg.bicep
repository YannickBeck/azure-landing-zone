// ================================================================ //
// ALZ Role Assignment (native)
// Weist eine Built-in-Rolle (Owner/Contributor/Reader) einem
// Entra-ID-Principal auf Management-Group-Ebene zu.
// Scope: Management Group
// ================================================================ //

targetScope = 'managementGroup'

// ================ //
// Parameters
// ================ //

@description('Object ID des Entra-ID-Principals (Gruppe empfohlen).')
param parPrincipalId string

@description('Built-in-Rolle.')
@allowed([ 'Owner', 'Contributor', 'Reader' ])
param parRoleDefinition string

@description('Typ des Principals.')
@allowed([ 'Group', 'User', 'ServicePrincipal' ])
param parPrincipalType string = 'Group'

@description('Beschreibung der Zuweisung.')
param parDescription string = ''

// ================ //
// Variables
// ================ //

// Built-in Role Definition GUIDs
var varRoleDefinitionIds = {
  Owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

// ================ //
// Resources
// ================ //

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(managementGroup().id, parPrincipalId, varRoleDefinitionIds[parRoleDefinition])
  properties: {
    principalId: parPrincipalId
    roleDefinitionId: tenantResourceId('Microsoft.Authorization/roleDefinitions', varRoleDefinitionIds[parRoleDefinition])
    principalType: parPrincipalType
    description: empty(parDescription) ? null : parDescription
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID des Role Assignment.')
output outRoleAssignmentId string = roleAssignment.id
