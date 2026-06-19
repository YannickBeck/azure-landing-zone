// ================================================================ //
// ALZ RBAC – Role Assignments auf Management Groups
//
// Unterstützt Built-in-Rollen UND die 5 ALZ-Custom-Rollen:
//   Built-in:   'Owner' | 'Contributor' | 'Reader'
//   ALZ-Custom: 'Subscription-Owner' | 'Security-Operations' |
//               'Network-Management' | 'Application-Owners' |
//               'Network-Subnet-Contributor'
//   Direkt:     '/providers/Microsoft.Authorization/roleDefinitions/<guid>'
//
// Leeres parRoleAssignments-Array = No-Op (kein Fehler).
// Scope: Tenant
// Voraussetzung: Stufe 1 muss gelaufen sein (ALZ-Custom-Rollen müssen existieren).
// ================================================================ //

targetScope = 'tenant'

// ================ //
// Type Definitions
// ================ //

type roleAssignmentType = {
  @description('ID der Ziel-Management-Group (z. B. "alz-platform").')
  managementGroupId: string

  @description('Object ID der Entra-ID-Gruppe (oder User/ServicePrincipal).')
  principalId: string

  @description('''
    Rollenname oder direkte roleDefinitionId.
    Built-in:   Owner | Contributor | Reader
    ALZ-Custom: Subscription-Owner | Security-Operations |
                Network-Management | Application-Owners |
                Network-Subnet-Contributor
    Direkt:     /providers/Microsoft.Authorization/roleDefinitions/<guid>
  ''')
  roleDefinition: string

  @description('Typ des Principals. Standard: Group.')
  principalType: ('Group' | 'User' | 'ServicePrincipal')?

  @description('Kurzbeschreibung der Zuweisung (für Azure-Portal).')
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
    parPrincipalId:     assignment.principalId
    parRoleDefinition:  assignment.roleDefinition
    parPrincipalType:   assignment.?principalType ?? 'Group'
    parDescription:     assignment.?description   ?? ''
  }
}]

// ================ //
// Outputs
// ================ //

@description('Resource IDs der erstellten Role Assignments.')
output outRoleAssignmentIds array = [for (assignment, i) in parRoleAssignments: roleAssignments[i].outputs.outRoleAssignmentId]
