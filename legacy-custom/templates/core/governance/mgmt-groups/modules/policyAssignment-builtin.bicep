// ================================================================ //
// Policy Assignment: Built-in (generisch)
// Weist eine beliebige Built-in Policy-Definition auf
// Management-Group-Ebene zu.
// Scope: Management Group
// ================================================================ //

targetScope = 'managementGroup'

@description('Name der Policy-Zuweisung (max. 24 Zeichen auf MG-Scope).')
@maxLength(24)
param parPolicyAssignmentName string

@description('Anzeigename der Policy-Zuweisung.')
param parPolicyAssignmentDisplayName string

@description('Beschreibung der Policy-Zuweisung.')
param parPolicyAssignmentDescription string = ''

@description('GUID der Built-in Policy-Definition.')
param parPolicyDefinitionGuid string

@description('Parameter der Policy im Format { name: { value: ... } }.')
param parPolicyParameters object = {}

@description('Enforcement Mode der Zuweisung.')
@allowed([ 'Default', 'DoNotEnforce' ])
param parEnforcementMode string = 'Default'

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: parPolicyAssignmentName
  properties: {
    displayName: parPolicyAssignmentDisplayName
    description: parPolicyAssignmentDescription
    policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', parPolicyDefinitionGuid)
    enforcementMode: parEnforcementMode
    parameters: parPolicyParameters
  }
}

@description('Resource ID der Policy-Zuweisung.')
output outPolicyAssignmentId string = policyAssignment.id
