// ================================================================ //
// Policy Exemption (generisch)
// Nimmt eine (ggf. von einer uebergeordneten MG geerbte) Policy-
// Zuweisung auf der Ziel-MG-Ebene von der Durchsetzung aus.
// Scope: Management Group
// ================================================================ //

targetScope = 'managementGroup'

@description('Name der Exemption.')
param parExemptionName string

@description('Resource ID der auszunehmenden Policy-Zuweisung.')
param parPolicyAssignmentId string

@description('Kategorie der Exemption.')
@allowed([ 'Waiver', 'Mitigated' ])
param parExemptionCategory string = 'Waiver'

@description('Anzeigename der Exemption.')
param parDisplayName string = ''

@description('Begruendung/Beschreibung der Exemption.')
param parDescription string = ''

resource policyExemption 'Microsoft.Authorization/policyExemptions@2022-07-01-preview' = {
  name: parExemptionName
  properties: {
    policyAssignmentId: parPolicyAssignmentId
    exemptionCategory: parExemptionCategory
    displayName: empty(parDisplayName) ? null : parDisplayName
    description: empty(parDescription) ? null : parDescription
  }
}

@description('Resource ID der Policy Exemption.')
output outPolicyExemptionId string = policyExemption.id
