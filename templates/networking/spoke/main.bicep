// ================================================================ //
// ALZ Spoke Networking
// Spoke-VNet fuer Workload Landing Zones:
// - VNet + Subnets, optional mit Route Table (Default -> Firewall)
// - VNet-Peering Spoke <-> Hub (beide Richtungen)
// - Optionale Links auf die zentralen Private DNS Zonen
// Scope: Subscription (Workload Subscription)
// ================================================================ //

targetScope = 'subscription'

// ================ //
// Type Definitions
// ================ //

type spokeSubnetType = {
  name: string
  addressPrefix: string
  delegation: string?
  associateRouteTable: bool?
}

// ================ //
// Parameters
// ================ //

@description('Name des Workloads (Bestandteil der Namenskonvention).')
param parWorkloadName string

@description('Region des Spoke.')
param parLocation string

@description('Tags fuer alle Ressourcen.')
param parTags object = {}

@description('Enable or disable telemetry.')
param parEnableTelemetry bool = true

@description('Name der Spoke Resource Group.')
param parSpokeResourceGroupName string = 'rg-alz-spoke-${parWorkloadName}-${parLocation}'

@description('Name des Spoke VNet.')
param parSpokeVnetName string = 'vnet-${parWorkloadName}-${parLocation}'

@description('Adress-Praefixe des Spoke VNet.')
param parAddressPrefixes array

@description('Subnetze des Spoke VNet.')
param parSubnets spokeSubnetType[]

@description('Resource ID des Hub VNet (fuer Peering und DNS).')
param parHubVirtualNetworkResourceId string

@description('Hub-seitiges Peering (Hub -> Spoke) mit anlegen. Erfordert Netzwerk-Rechte auf der Connectivity Subscription.')
param parCreateHubToSpokePeering bool = true

@description('Private IP der Hub-Firewall. Leer = keine Route Table / kein erzwungener Firewall-Transit.')
param parFirewallPrivateIp string = ''

@description('Remote-Gateways des Hubs nutzen (erfordert VPN/ER-Gateway im Hub).')
param parUseRemoteGateways bool = false

@description('Resource IDs der zentralen Private DNS Zonen, die mit dem Spoke verlinkt werden sollen.')
param parPrivateDnsZoneResourceIds array = []

// ================ //
// Variables
// ================ //

var varHubVnetSubscriptionId = split(parHubVirtualNetworkResourceId, '/')[2]
var varHubVnetResourceGroupName = split(parHubVirtualNetworkResourceId, '/')[4]
var varHubVnetName = last(split(parHubVirtualNetworkResourceId, '/'))
var varDeployRouteTable = !empty(parFirewallPrivateIp)

// ================ //
// Modules
// ================ //

module spokeResourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'alz-spoke-rg-${uniqueString(deployment().name)}'
  params: {
    name: parSpokeResourceGroupName
    location: parLocation
    tags: parTags
    enableTelemetry: parEnableTelemetry
  }
}

// Default-Route ueber die Hub-Firewall (nur wenn Firewall-IP angegeben)
module spokeRouteTable 'modules/route-table.bicep' = if (varDeployRouteTable) {
  name: 'alz-spoke-rt-${uniqueString(deployment().name)}'
  scope: resourceGroup(parSpokeResourceGroupName)
  dependsOn: [ spokeResourceGroup ]
  params: {
    parRouteTableName: 'rt-${parSpokeVnetName}'
    parLocation: parLocation
    parTags: parTags
    parNextHopIpAddress: parFirewallPrivateIp
  }
}

module spokeVirtualNetwork 'br/public:avm/res/network/virtual-network:0.5.1' = {
  name: 'alz-spoke-vnet-${uniqueString(deployment().name)}'
  scope: resourceGroup(parSpokeResourceGroupName)
  dependsOn: [ spokeResourceGroup ]
  params: {
    name: parSpokeVnetName
    location: parLocation
    tags: parTags
    addressPrefixes: parAddressPrefixes
    enableTelemetry: parEnableTelemetry
    subnets: [for subnet in parSubnets: {
      name: subnet.name
      addressPrefix: subnet.addressPrefix
      delegation: subnet.?delegation
      routeTableResourceId: (varDeployRouteTable && (subnet.?associateRouteTable ?? true)) ? spokeRouteTable.outputs.outRouteTableId : null
    }]
  }
}

// Peering Spoke -> Hub
module spokeToHubPeering '../hubnetworking/modules/vnet-peering.bicep' = {
  name: 'alz-spoke-peer-${uniqueString(deployment().name)}'
  scope: resourceGroup(parSpokeResourceGroupName)
  dependsOn: [ spokeVirtualNetwork ]
  params: {
    parLocalVnetName: parSpokeVnetName
    parPeeringName: 'peer-${parSpokeVnetName}-to-${varHubVnetName}'
    parRemoteVnetId: parHubVirtualNetworkResourceId
    parAllowForwardedTraffic: true
    parAllowGatewayTransit: false
    parAllowVirtualNetworkAccess: true
    parUseRemoteGateways: parUseRemoteGateways
  }
}

// Peering Hub -> Spoke (Cross-Subscription in die Connectivity Subscription)
module hubToSpokePeering '../hubnetworking/modules/vnet-peering.bicep' = if (parCreateHubToSpokePeering) {
  name: 'alz-hub-spoke-peer-${uniqueString(deployment().name)}'
  scope: resourceGroup(varHubVnetSubscriptionId, varHubVnetResourceGroupName)
  params: {
    parLocalVnetName: varHubVnetName
    parPeeringName: 'peer-${varHubVnetName}-to-${parSpokeVnetName}'
    parRemoteVnetId: spokeVirtualNetwork.outputs.resourceId
    parAllowForwardedTraffic: true
    // Hub bietet Gateway-Transit an, wenn der Spoke Remote-Gateways nutzt
    parAllowGatewayTransit: parUseRemoteGateways
    parAllowVirtualNetworkAccess: true
    parUseRemoteGateways: false
  }
}

// Links auf die zentralen Private DNS Zonen (RG der Zone, Cross-Subscription)
module privateDnsZoneLinks 'modules/private-dns-zone-link.bicep' = [for (zoneId, i) in parPrivateDnsZoneResourceIds: {
  name: 'alz-spoke-dnslink-${i}-${uniqueString(deployment().name)}'
  scope: resourceGroup(split(zoneId, '/')[2], split(zoneId, '/')[4])
  params: {
    parPrivateDnsZoneName: last(split(zoneId, '/'))
    parLinkName: 'vnetlink-${parSpokeVnetName}'
    parVirtualNetworkResourceId: spokeVirtualNetwork.outputs.resourceId
  }
}]

// ================ //
// Outputs
// ================ //

@description('Resource ID des Spoke VNet.')
output outSpokeVirtualNetworkId string = spokeVirtualNetwork.outputs.resourceId

@description('Name der Spoke Resource Group.')
output outSpokeResourceGroupName string = parSpokeResourceGroupName

@description('Resource ID der Spoke Route Table (leer, wenn keine Firewall-IP angegeben).')
output outSpokeRouteTableId string = varDeployRouteTable ? spokeRouteTable.outputs.outRouteTableId : ''
