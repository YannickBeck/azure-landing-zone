using './main.bicep'

// ===============================================================
// Virtual WAN Konfiguration (Alternative zu Hub-Networking)
// Nur eins von beiden deployen: hubnetworking ODER virtualwan
// ===============================================================

param parLocations = [
  'germanywestcentral'
  'northeurope'
]

param parTags = {
  Environment: 'Production'
  ManagedBy: 'Platform Team'
}

param parEnableTelemetry = true

param parVwanResourceGroupName = 'rg-alz-vwan-germanywestcentral'
param parVirtualWanName = 'vwan-alz'
param parVirtualWanType = 'Standard'
param parVirtualWanEnableBranchToBranchTraffic = true

param vHubs = [
  {
    name: 'vhub-alz-germanywestcentral'
    location: 'germanywestcentral'
    addressPrefix: '10.100.0.0/23'
    deployVpnGateway: false
    deployExpressRouteGateway: false
    deployAzureFirewall: false
  }
]
