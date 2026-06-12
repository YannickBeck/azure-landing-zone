// ================================================================ //
// ALZ Route Table (native)
// Default-Route 0.0.0.0/0 -> Azure Firewall (erzwungener Transit).
// Muss in derselben Subscription/Region wie das zugehoerige VNet
// liegen.
// Scope: Resource Group
// ================================================================ //

targetScope = 'resourceGroup'

// ================ //
// Parameters
// ================ //

@description('Name der Route Table.')
param parRouteTableName string

@description('Region der Route Table.')
param parLocation string

@description('Tags fuer alle Ressourcen.')
param parTags object = {}

@description('Private IP der Azure Firewall (Next Hop).')
param parNextHopIpAddress string

@description('BGP-Routen-Propagation deaktivieren (empfohlen fuer Spoke-Subnets hinter der Firewall).')
param parDisableBgpRoutePropagation bool = true

// ================ //
// Resources
// ================ //

resource routeTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: parRouteTableName
  location: parLocation
  tags: parTags
  properties: {
    disableBgpRoutePropagation: parDisableBgpRoutePropagation
    routes: [
      {
        name: 'default-to-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: parNextHopIpAddress
        }
      }
    ]
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID der Route Table.')
output outRouteTableId string = routeTable.id
