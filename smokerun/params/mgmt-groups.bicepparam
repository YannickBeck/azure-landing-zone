using '../../templates/core/governance/mgmt-groups/int-root/main.bicep'

// Smoke Run – identische MG-Hierarchie wie Produktion
// Keine Änderungen nötig: MGs sind kostenlos und idempotent

param parIntRootMgId = 'alz'
param parIntRootMgDisplayName = 'Azure Landing Zones'
param parParentMgId = readEnvironmentVariable('ALZ_PARENT_MG_ID', '')

param parAllowedLocations = [
  'germanywestcentral'
  'northeurope'
]

param parDeployGuardrailPolicies = true
param parRequiredTagName = 'Environment'
param parStorageSecureTransferEffect = 'Deny'
