using './main.bicep'

// Deployment-Scope: Tenant. Voraussetzung: int-root MG ('alz') existiert.

param parSandboxMgId = 'alz-sandbox'
param parSandboxMgDisplayName = 'Sandbox'
param parParentMgId = 'alz'
