using './main.bicep'

// Deployment-Scope: Tenant. Voraussetzung: int-root MG ('alz') existiert.

param parDecommissionedMgId = 'alz-decommissioned'
param parDecommissionedMgDisplayName = 'Decommissioned'
param parParentMgId = 'alz'
