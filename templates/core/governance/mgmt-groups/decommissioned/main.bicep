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

@description('Sperr-Guardrail (Deny jeglicher neuer Ressourcen) auf der Decommissioned-MG zuweisen.')
param parDeployDecommissionedGuardrail bool = true

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

// Built-in "Allowed resource types" mit LEERER Allow-Liste => blockt jede Neuanlage.
// Stillzulegende Subscriptions koennen so nichts Neues mehr erzeugen (Loeschen bleibt moeglich).
module denyAllResourcesPolicy '../modules/policyAssignment-builtin.bicep' = if (parDeployDecommissionedGuardrail) {
  name: 'alz-decomm-denyAll-${uniqueString(parDecommissionedMgId)}'
  scope: managementGroup(parDecommissionedMgId)
  dependsOn: [
    decommissionedManagementGroup
  ]
  params: {
    parPolicyAssignmentName: 'Deny-Decomm-Resources'
    parPolicyAssignmentDisplayName: 'Decommissioned: Keine neuen Ressourcen zulassen'
    parPolicyAssignmentDescription: 'Verweigert das Anlegen jeglicher Ressourcentypen in stillzulegenden Subscriptions (leere Allow-Liste).'
    parPolicyDefinitionGuid: 'a08ec900-254a-4555-9bf5-e42af04b5c5c'
    parPolicyParameters: {
      listOfResourceTypesAllowed: {
        value: []
      }
    }
  }
}

@description('Resource ID der Decommissioned Management Group.')
output outDecommissionedManagementGroupId string = decommissionedManagementGroup.id
