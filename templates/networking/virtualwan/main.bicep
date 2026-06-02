// ================================================================ //
// ALZ Virtual WAN Networking Module
// Alternative to Hub-Spoke - Global enterprise connectivity
// Deploys: Virtual WAN, vHubs, Azure Firewall (Secured Hub),
//          ExpressRoute/VPN Gateways, Private DNS Zones
// Scope: Subscription (Connectivity Subscription)
// ================================================================ //

targetScope = 'subscription'

// ================ //
// Parameters
// ================ //

@description('Array of Azure regions.')
param parLocations array = [
  deployment().location
]

@description('Tags to apply to all resources.')
param parTags object = {}

@description('Enable or disable telemetry.')
param parEnableTelemetry bool = true

@description('Resource group name for Virtual WAN resources.')
param parVwanResourceGroupName string = 'rg-alz-vwan-${parLocations[0]}'

@description('Name of the Virtual WAN resource.')
param parVirtualWanName string = 'vwan-alz'

@description('Type of Virtual WAN.')
@allowed(['Basic', 'Standard'])
param parVirtualWanType string = 'Standard'

@description('Enable branch-to-branch traffic in Virtual WAN.')
param parVirtualWanEnableBranchToBranchTraffic bool = true

@description('Virtual Hub configurations array.')
param vHubs array = []

// ================ //
// Modules
// ================ //

module vwanResourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'alz-vwan-rg-${uniqueString(deployment().name)}'
  params: {
    name: parVwanResourceGroupName
    location: parLocations[0]
    tags: parTags
    enableTelemetry: parEnableTelemetry
  }
}

module virtualWan 'br/public:avm/res/network/virtual-wan:0.3.0' = {
  name: 'alz-vwan-${uniqueString(deployment().name)}'
  scope: resourceGroup(parVwanResourceGroupName)
  dependsOn: [ vwanResourceGroup ]
  params: {
    name: parVirtualWanName
    location: parLocations[0]
    tags: parTags
    enableTelemetry: parEnableTelemetry
    type: parVirtualWanType
    allowBranchToBranchTraffic: parVirtualWanEnableBranchToBranchTraffic
  }
}

// ================ //
// Outputs
// ================ //

@description('The resource ID of the Virtual WAN.')
output outVirtualWanId string = virtualWan.outputs.resourceId

@description('The Virtual WAN resource group name.')
output outVwanResourceGroupName string = parVwanResourceGroupName
