// ================================================================ //
// ALZ Sandbox Management Group
// Sandbox fuer Experimente - lockere Policies, keine Corp-Anbindung.
// Scope: Tenant
// ================================================================ //

targetScope = 'tenant'

@description('ID (Name) der Sandbox Management Group.')
param parSandboxMgId string = 'alz-sandbox'

@description('Anzeigename der Sandbox Management Group.')
param parSandboxMgDisplayName string = 'Sandbox'

@description('ID der uebergeordneten Intermediate-Root Management Group.')
param parParentMgId string = 'alz'

@description('Sandbox von ausgewaehlten geerbten Guardrails ausnehmen (lockere Policies).')
param parDeploySandboxExemptions bool = true

@description('Name der Pflicht-Tag-Policy-Zuweisung auf der Int-Root-MG (wird in der Sandbox ausgenommen).')
param parRequireTagAssignmentName string = 'Require-RG-Tag'

resource sandboxManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: parSandboxMgId
  properties: {
    displayName: parSandboxMgDisplayName
    details: {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/${parParentMgId}'
      }
    }
  }
}

// Sandbox = lockere Policies: Pflicht-Tag (von der Int-Root geerbt) hier ausnehmen,
// damit Experimente nicht am fehlenden Tag scheitern. Region-Guardrail bleibt aktiv.
module requireTagExemption '../modules/policyExemption.bicep' = if (parDeploySandboxExemptions) {
  name: 'alz-sandbox-tagExempt-${uniqueString(parSandboxMgId)}'
  scope: managementGroup(parSandboxMgId)
  dependsOn: [
    sandboxManagementGroup
  ]
  params: {
    parExemptionName: 'Exempt-Require-RG-Tag'
    parPolicyAssignmentId: '/providers/Microsoft.Management/managementGroups/${parParentMgId}/providers/Microsoft.Authorization/policyAssignments/${parRequireTagAssignmentName}'
    parExemptionCategory: 'Waiver'
    parDisplayName: 'Sandbox: Pflicht-Tag-Guardrail ausgenommen'
    parDescription: 'Sandbox erlaubt Experimente ohne erzwungenes Resource-Group-Tag.'
  }
}

@description('Resource ID der Sandbox Management Group.')
output outSandboxManagementGroupId string = sandboxManagementGroup.id
