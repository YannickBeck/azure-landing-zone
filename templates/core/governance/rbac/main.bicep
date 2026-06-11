// ================================================================ //
// ALZ RBAC - Role Assignments auf Management Groups
// Weist Built-in-Rollen (Owner/Contributor/Reader) an
// Entra-ID-Principals (Gruppen empfohlen) auf MG-Ebene zu.
// Leeres parRoleAssignments-Array = No-Op.
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

// ================ //
// Type Definitions
// ================ //

type roleAssignmentType = {
  @description('ID der Ziel-Management-Group.')
  managementGroupId: string
  @description('Object ID des Entra-ID-Principals (Gruppe empfohlen).')
  principalId: string
  @description('Built-in-Rolle.')
  roleDefinition: 'Owner' | 'Contributor' | 'Reader'
  @description('Typ des Principals.')
  principalType: ('Group' | 'User' | 'ServicePrincipal')?
  @description('Beschreibung der Zuweisung.')
  description: string?
}

// ================ //
// Parameters
// ================ //

@description('Liste der Role Assignments. Leer = nichts deployen.')
param parRoleAssignments roleAssignmentType[] = []

// ================ //
// Modules
// ================ //

module roleAssignments 'modules/roleAssignment-mg.bicep' = [for (assignment, i) in parRoleAssignments: {
  name: 'alz-rbac-${i}-${uniqueString(assignment.managementGroupId, assignment.principalId, assignment.roleDefinition)}'
  scope: managementGroup(assignment.managementGroupId)
  params: {
    parPrincipalId: assignment.principalId
    parRoleDefinition: assignment.roleDefinition
    parPrincipalType: assignment.?principalType ?? 'Group'
    parDescription: assignment.?description ?? ''
  }
}]

// ================ //
// Outputs
// ================ //

@description('Resource IDs der erstellten Role Assignments.')
output outRoleAssignmentIds array = [for (assignment, i) in parRoleAssignments: roleAssignments[i].outputs.outRoleAssignmentId]
