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

@description('ID der uebergeordneten Management Group. Leer = Tenant Root MG (= Tenant ID).')
param parParentMgId string = ''

@description('Liste der erlaubten Azure-Regionen fuer den Policy-Guardrail.')
param parAllowedLocations array = [
  'germanywestcentral'
  'northeurope'
]

@description('Zusaetzliche Guardrail-Policies (Require-Tag, Storage-HTTPS) zuweisen.')
param parDeployGuardrailPolicies bool = true

@description('Tag, das auf Resource Groups verpflichtend ist (leer = Zuweisung ueberspringen).')
param parRequiredTagName string = 'Environment'

@description('Effekt fuer "Secure transfer to storage accounts should be enabled".')
@allowed([ 'Audit', 'Deny', 'Disabled' ])
param parStorageSecureTransferEffect string = 'Deny'

// ================ //
// Variables
// ================ //

var varParentMgId = empty(parParentMgId) ? tenant().tenantId : parParentMgId

// ================ //
// Resources
// ================ //

resource intRootManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: parIntRootMgId
  properties: {
    displayName: parIntRootMgDisplayName
    details: {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/${varParentMgId}'
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

// Built-in: "Require a tag on resource groups"
module requireTagOnRgPolicy '../modules/policyAssignment-builtin.bicep' = if (parDeployGuardrailPolicies && !empty(parRequiredTagName)) {
  name: 'alz-introot-requireRgTag-${uniqueString(parIntRootMgId)}'
  scope: managementGroup(parIntRootMgId)
  dependsOn: [
    intRootManagementGroup
  ]
  params: {
    parPolicyAssignmentName: 'Require-RG-Tag'
    parPolicyAssignmentDisplayName: 'Pflicht-Tag auf Resource Groups (${parRequiredTagName})'
    parPolicyAssignmentDescription: 'Verweigert das Anlegen von Resource Groups ohne das Tag "${parRequiredTagName}".'
    parPolicyDefinitionGuid: '96670d01-0a4d-4649-9c89-2d3abc0a5025'
    parPolicyParameters: {
      tagName: {
        value: parRequiredTagName
      }
    }
  }
}

// Built-in: "Secure transfer to storage accounts should be enabled"
module storageSecureTransferPolicy '../modules/policyAssignment-builtin.bicep' = if (parDeployGuardrailPolicies) {
  name: 'alz-introot-storageHttps-${uniqueString(parIntRootMgId)}'
  scope: managementGroup(parIntRootMgId)
  dependsOn: [
    intRootManagementGroup
  ]
  params: {
    parPolicyAssignmentName: 'Deny-Storage-Http'
    parPolicyAssignmentDisplayName: 'Storage Accounts: Secure Transfer (HTTPS) erzwingen'
    parPolicyAssignmentDescription: 'Erzwingt HTTPS/Secure Transfer fuer alle Storage Accounts.'
    parPolicyDefinitionGuid: '404c3081-a854-4457-ae30-26a93ef643f9'
    parPolicyParameters: {
      effect: {
        value: parStorageSecureTransferEffect
      }
    }
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID der Intermediate-Root Management Group.')
output outIntRootManagementGroupId string = intRootManagementGroup.id

@description('Name der Intermediate-Root Management Group.')
output outIntRootManagementGroupName string = parIntRootMgId
