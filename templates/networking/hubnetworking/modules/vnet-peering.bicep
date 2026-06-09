// ================================================================ //
// ALZ VNet Peering (native)
// Erstellt ein VNet-Peering vom lokalen Hub zu einem Remote-VNet.
// Scope: Resource Group (RG des lokalen VNet)
// ================================================================ //

targetScope = 'resourceGroup'

// ================ //
// Parameters
// ================ //

@description('Name des lokalen (Quell-)VNet.')
param parLocalVnetName string

@description('Name des Peerings.')
param parPeeringName string

@description('Resource ID des Remote-VNet.')
param parRemoteVnetId string

@description('Weitergeleiteten Traffic erlauben.')
param parAllowForwardedTraffic bool = true

@description('Gateway Transit erlauben.')
param parAllowGatewayTransit bool = false

@description('Zugriff zwischen VNets erlauben.')
param parAllowVirtualNetworkAccess bool = true

@description('Remote-Gateways verwenden.')
param parUseRemoteGateways bool = false

// ================ //
// Resources
// ================ //

resource localVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: parLocalVnetName
}

resource virtualNetworkPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  parent: localVirtualNetwork
  name: parPeeringName
  properties: {
    allowForwardedTraffic: parAllowForwardedTraffic
    allowGatewayTransit: parAllowGatewayTransit
    allowVirtualNetworkAccess: parAllowVirtualNetworkAccess
    useRemoteGateways: parUseRemoteGateways
    remoteVirtualNetwork: {
      id: parRemoteVnetId
    }
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID des Peerings.')
output outPeeringId string = virtualNetworkPeering.id
