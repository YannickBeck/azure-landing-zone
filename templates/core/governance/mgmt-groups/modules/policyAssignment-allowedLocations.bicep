// ================================================================ //
// Policy Assignment: Allowed Locations (Built-in)
// Beispiel-Governance-Guardrail auf Management-Group-Ebene.
// Scope: Management Group
// ================================================================ //

targetScope = 'managementGroup'

@description('Name der Policy-Zuweisung.')
param parPolicyAssignmentName string = 'Deny-Location'

@description('Liste der erlaubten Azure-Regionen.')
param parAllowedLocations array

// Built-in Policy "Allowed locations"
var varPolicyDefinitionId = '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: parPolicyAssignmentName
  properties: {
    displayName: 'Erlaubte Regionen (Allowed locations)'
    description: 'Schraenkt die Regionen ein, in denen Ressourcen deployed werden duerfen.'
    policyDefinitionId: varPolicyDefinitionId
    enforcementMode: 'Default'
    parameters: {
      listOfAllowedLocations: {
        value: parAllowedLocations
      }
    }
  }
}

@description('Resource ID der Policy-Zuweisung.')
output outPolicyAssignmentId string = policyAssignment.id
