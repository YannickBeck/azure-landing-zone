using './main.bicep'

// ===============================================================
// Voraussetzung: int-root MG ('alz') wurde bereits deployed
// Deployment-Scope: Tenant
// ===============================================================

param parPlatformMgId = 'alz-platform'
param parPlatformMgDisplayName = 'Platform'
param parParentMgId = 'alz'              // muss mit int-root parIntRootMgId uebereinstimmen
param parChildMgIdPrefix = 'alz-platform-'
