using './main.bicep'

// ===============================================================
// Deployment-Scope: Tenant
// parParentMgId leer lassen => Tenant Root MG (tenant().tenantId).
// Override optional ueber die Umgebungsvariable ALZ_PARENT_MG_ID.
// ===============================================================

param parIntRootMgId = 'alz'
param parIntRootMgDisplayName = 'Azure Landing Zones'
param parParentMgId = readEnvironmentVariable('ALZ_PARENT_MG_ID', '')

param parAllowedLocations = [
  'germanywestcentral'
  'northeurope'
]

// Schlankes Guardrail-Set (siehe ../modules/policyAssignment-builtin.bicep)
param parDeployGuardrailPolicies = true
param parRequiredTagName = 'Environment'
param parStorageSecureTransferEffect = 'Deny'
