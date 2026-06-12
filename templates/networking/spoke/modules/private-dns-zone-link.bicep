// ================================================================ //
// ALZ Private DNS Zone VNet-Link (native)
// Verlinkt ein (Spoke-)VNet mit einer bestehenden zentralen
// Private DNS Zone.
// Scope: Resource Group (RG der Private DNS Zone)
// ================================================================ //

targetScope = 'resourceGroup'

// ================ //
// Parameters
// ================ //

@description('Name der bestehenden Private DNS Zone.')
param parPrivateDnsZoneName string

@description('Name des VNet-Links.')
param parLinkName string

@description('Resource ID des zu verlinkenden VNet.')
param parVirtualNetworkResourceId string

@description('Auto-Registrierung von VM-Records aktivieren.')
param parRegistrationEnabled bool = false

// ================ //
// Resources
// ================ //

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: parPrivateDnsZoneName
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: parLinkName
  location: 'global'
  properties: {
    registrationEnabled: parRegistrationEnabled
    virtualNetwork: {
      id: parVirtualNetworkResourceId
    }
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID des VNet-Links.')
output outVirtualNetworkLinkId string = virtualNetworkLink.id
