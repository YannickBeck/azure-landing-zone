using './main.bicep'

// ===============================================================
// Voraussetzung: int-root MG ('alz') wurde bereits deployed
// Deployment-Scope: Tenant
// ===============================================================

param parLandingZonesMgId = 'alz-landingzones'
param parLandingZonesMgDisplayName = 'Landing Zones'
param parParentMgId = 'alz'
param parChildMgIdPrefix = 'alz-landingzones-'
