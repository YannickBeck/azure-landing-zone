// ================================================================ //
// ALZ Private DNS Zones (native)
// Erstellt Private DNS Zonen und verknuepft sie mit dem Hub-VNet.
// Scope: Resource Group
// ================================================================ //

targetScope = 'resourceGroup'

// ================ //
// Parameters
// ================ //

@description('Liste der Private DNS Zonen (FQDNs).')
param parPrivateDnsZones array

@description('Tags fuer alle Ressourcen.')
param parTags object = {}

@description('VNet-Links (Array aus {name, vnetId, registrationEnabled?}).')
param parVirtualNetworkLinks array = []

// ================ //
// Variables
// ================ //

// Kartesisches Produkt aus Zonen x VNet-Links (Bicep kennt keine verschachtelten Resource-Loops).
var varZoneLinks = flatten([for zone in parPrivateDnsZones: [for link in parVirtualNetworkLinks: {
  zoneName: zone
  linkName: link.name
  vnetId: link.vnetId
  registrationEnabled: link.?registrationEnabled ?? false
}]])

// ================ //
// Resources
// ================ //

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in parPrivateDnsZones: {
  name: zone
  location: 'global'
  tags: parTags
}]

resource virtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for link in varZoneLinks: {
  name: '${link.zoneName}/${link.linkName}'
  location: 'global'
  tags: parTags
  properties: {
    registrationEnabled: link.registrationEnabled
    virtualNetwork: {
      id: link.vnetId
    }
  }
  dependsOn: [
    privateDnsZones
  ]
}]

// ================ //
// Outputs
// ================ //

@description('Anzahl der erstellten Private DNS Zonen.')
output outPrivateDnsZoneCount int = length(parPrivateDnsZones)
