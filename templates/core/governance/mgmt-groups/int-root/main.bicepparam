using './main.bicep'

// ===============================================================
// ANPASSEN: Ersetze <TENANT_ID> mit deiner Azure Tenant ID (GUID)
// Deployment-Scope: Tenant
// ===============================================================

param parIntRootMgId = 'alz'
param parIntRootMgDisplayName = 'Azure Landing Zones'
param parParentMgId = '<TENANT_ID>'        // Deine Azure Tenant ID (GUID)

param parAllowedLocations = [
  'germanywestcentral'
  'northeurope'
]
