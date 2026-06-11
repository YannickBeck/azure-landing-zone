// ================================================================ //
// ALZ Hub Networking Module
// Deploys Hub-Spoke network topology with:
// - Hub VNet, Azure Firewall, Bastion, VPN/ExpressRoute Gateways
// - Private DNS Zones, DNS Private Resolver
// - DDoS Protection Plan
// - VNet Peering between primary and secondary hubs
// Scope: Subscription (Connectivity Subscription)
// ================================================================ //

targetScope = 'subscription'

// ================ //
// Type Definitions
// ================ //

type lockType = {
  name: string
  kind: 'CanNotDelete' | 'ReadOnly' | 'None'
  notes: string?
}

type subnetType = {
  name: string
  addressPrefix: string
  delegation: string?
}

type azureFirewallSettingsType = {
  deployAzureFirewall: bool
  azureFirewallName: string?
  azureSkuTier: ('Basic' | 'Standard' | 'Premium')?
  publicIPAddressObject: { name: string }?
  managementIPAddressObject: { name: string }?
  firewallPolicyName: string?
  deployBaseFirewallRules: bool?
}

type bastionSettingsType = {
  deployBastion: bool
  bastionHostSettingsName: string?
  skuName: ('Basic' | 'Standard')?
}

type vpnGatewaySettingsType = {
  deployVpnGateway: bool
  name: string?
  skuName: ('Basic' | 'VpnGw1' | 'VpnGw1AZ' | 'VpnGw2' | 'VpnGw2AZ' | 'VpnGw3' | 'VpnGw3AZ' | 'VpnGw4' | 'VpnGw4AZ' | 'VpnGw5' | 'VpnGw5AZ')?
  vpnMode: ('activeActiveBgp' | 'activeActiveNoBgp' | 'activePassiveBgp' | 'activePassiveNoBgp')?
  vpnType: ('RouteBased' | 'PolicyBased')?
  asn: int?
}

type erGatewaySettingsType = {
  deployExpressRouteGateway: bool
  name: string?
  skuName: ('Standard' | 'HighPerformance' | 'UltraPerformance' | 'ErGw1AZ' | 'ErGw2AZ' | 'ErGw3AZ')?
}

type privateDnsSettingsType = {
  deployPrivateDnsZones: bool
  deployDnsPrivateResolver: bool?
  privateDnsResolverName: string?
  privateDnsZones: array?
}

type ddosSettingsType = {
  deployDdosProtectionPlan: bool
  name: string?
}

type peeringSettingsType = {
  remoteVirtualNetworkName: string
  allowForwardedTraffic: bool?
  allowGatewayTransit: bool?
  allowVirtualNetworkAccess: bool?
  useRemoteGateways: bool?
}

type hubNetworkType = {
  name: string
  location: string
  addressPrefixes: string[]
  deployPeering: bool?
  dnsServers: string[]?
  peeringSettings: peeringSettingsType[]?
  subnets: subnetType[]
  azureFirewallSettings: azureFirewallSettingsType?
  bastionHostSettings: bastionSettingsType?
  vpnGatewaySettings: vpnGatewaySettingsType?
  expressRouteGatewaySettings: erGatewaySettingsType?
  privateDnsSettings: privateDnsSettingsType?
  ddosProtectionPlanSettings: ddosSettingsType?
}

// ================ //
// Parameters
// ================ //

@description('Array of Azure regions.')
param parLocations array = [
  deployment().location
]

@description('Global resource lock settings.')
param parGlobalResourceLock lockType = {
  name: 'GlobalResourceLock'
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Accelerator.'
}

@description('Tags to apply to all resources.')
param parTags object = {}

@description('Enable or disable telemetry.')
param parEnableTelemetry bool = true

@description('Resource group name prefix for hub networking.')
param parHubNetworkingResourceGroupNamePrefix string = 'rg-alz-conn'

@description('Resource group name prefix for private DNS zones.')
param parDnsResourceGroupNamePrefix string = 'rg-alz-dns'

@description('Resource group name prefix for DNS Private Resolver.')
param parDnsPrivateResolverResourceGroupNamePrefix string = 'rg-alz-dnspr'

@description('Array of hub network configurations.')
param hubNetworks hubNetworkType[] = []

@description('Interne Quell-Adressbereiche fuer die Basis-Firewall-Regeln.')
param parInternalAddressSpaces array = [
  '10.0.0.0/8'
]

// ================ //
// Variables
// ================ //

var varDefaultPrivateDnsZones = [
  'privatelink.azure-automation.net'
  'privatelink.database.windows.net'
  'privatelink.sql.azuresynapse.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.azuresynapse.net'
  'privatelink.blob.core.windows.net'
  'privatelink.table.core.windows.net'
  'privatelink.queue.core.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.web.core.windows.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.documents.azure.com'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.gremlin.cosmos.azure.com'
  'privatelink.table.cosmos.azure.com'
  'privatelink.postgres.database.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.mariadb.database.azure.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.managedhsm.azure.net'
  'privatelink.azurewebsites.net'
  'privatelink.api.azureml.ms'
  'privatelink.notebooks.azure.net'
  'privatelink.servicebus.windows.net'
  'privatelink.azure-devices.net'
  'privatelink.eventgrid.azure.net'
  'privatelink.azurehealthcareapis.com'
  'privatelink.workeronline.microsoft.com'
  'privatelink.azure-devices-provisioning.net'
  'privatelink.digitaltwins.azure.net'
  'privatelink.azurecontainerapps.io'
  'privatelink.search.windows.net'
  'privatelink.azurecr.io'
  'privatelink.redis.cache.windows.net'
  'privatelink.openai.azure.com'
]

// Lookup: VNet-Name -> Location (zur Aufloesung der Remote-Resource-Group beim Peering)
var varHubLocationByVnetName = toObject(hubNetworks, hub => hub.name, hub => hub.location)

// Alle Hub-Peerings flach: ein Eintrag je (Hub, peeringSetting).
// map/flatten statt verschachtelter For-Expressions (BCP138).
var varHubPeerings = flatten(map(hubNetworks, hub => map(hub.?peeringSettings ?? [], peering => {
  enabled: hub.?deployPeering ?? false
  localVnetName: hub.name
  localLocation: hub.location
  remoteVnetName: peering.remoteVirtualNetworkName
  allowForwardedTraffic: peering.?allowForwardedTraffic ?? true
  allowGatewayTransit: peering.?allowGatewayTransit ?? false
  allowVirtualNetworkAccess: peering.?allowVirtualNetworkAccess ?? true
  useRemoteGateways: peering.?useRemoteGateways ?? false
})))

// ================ //
// Modules
// ================ //

// Resource Groups for each hub location
module hubNetworkingResourceGroups 'br/public:avm/res/resources/resource-group:0.4.1' = [for (hub, i) in hubNetworks: {
  name: 'alz-hub-rg-${i}-${uniqueString(deployment().name)}'
  params: {
    name: '${parHubNetworkingResourceGroupNamePrefix}-${hub.location}'
    location: hub.location
    tags: parTags
    enableTelemetry: parEnableTelemetry
  }
}]

module dnsResourceGroups 'br/public:avm/res/resources/resource-group:0.4.1' = [for (hub, i) in hubNetworks: {
  name: 'alz-dns-rg-${i}-${uniqueString(deployment().name)}'
  params: {
    name: '${parDnsResourceGroupNamePrefix}-${hub.location}'
    location: hub.location
    tags: parTags
    enableTelemetry: parEnableTelemetry
  }
}]

// DDoS Protection Plans
module ddosProtectionPlans 'br/public:avm/res/network/ddos-protection-plan:0.3.0' = [for (hub, i) in hubNetworks: if (hub.ddosProtectionPlanSettings.?deployDdosProtectionPlan ?? false) {
  name: 'alz-ddos-${i}-${uniqueString(deployment().name)}'
  scope: resourceGroup('${parHubNetworkingResourceGroupNamePrefix}-${hub.location}')
  dependsOn: [ hubNetworkingResourceGroups ]
  params: {
    name: hub.ddosProtectionPlanSettings.?name ?? 'ddos-alz-${hub.location}'
    location: hub.location
    tags: parTags
    enableTelemetry: parEnableTelemetry
  }
}]

// Hub Virtual Networks
module hubVirtualNetworks 'br/public:avm/res/network/virtual-network:0.5.1' = [for (hub, i) in hubNetworks: {
  name: 'alz-hub-vnet-${i}-${uniqueString(deployment().name)}'
  scope: resourceGroup('${parHubNetworkingResourceGroupNamePrefix}-${hub.location}')
  dependsOn: [ hubNetworkingResourceGroups ]
  params: {
    name: hub.name
    location: hub.location
    tags: parTags
    addressPrefixes: hub.addressPrefixes
    dnsServers: hub.dnsServers ?? []
    enableTelemetry: parEnableTelemetry
    subnets: [for subnet in hub.subnets: {
      name: subnet.name
      addressPrefix: subnet.addressPrefix
      delegation: subnet.?delegation
    }]
  }
}]

// VNet Peering zwischen den Hubs (beide Richtungen, je nach peeringSettings)
@batchSize(1)
module hubVnetPeerings 'modules/vnet-peering.bicep' = [for (peering, i) in varHubPeerings: if (peering.enabled) {
  name: 'alz-hub-peer-${i}-${uniqueString(deployment().name)}'
  scope: resourceGroup('${parHubNetworkingResourceGroupNamePrefix}-${peering.localLocation}')
  dependsOn: [ hubVirtualNetworks ]
  params: {
    parLocalVnetName: peering.localVnetName
    parPeeringName: 'peer-${peering.localVnetName}-to-${peering.remoteVnetName}'
    parRemoteVnetId: resourceId('${parHubNetworkingResourceGroupNamePrefix}-${varHubLocationByVnetName[peering.remoteVnetName]}', 'Microsoft.Network/virtualNetworks', peering.remoteVnetName)
    parAllowForwardedTraffic: peering.allowForwardedTraffic
    parAllowGatewayTransit: peering.allowGatewayTransit
    parAllowVirtualNetworkAccess: peering.allowVirtualNetworkAccess
    parUseRemoteGateways: peering.useRemoteGateways
  }
}]

// Firewall Policies (mit Basis-Regelwerk) fuer alle Hubs mit Azure Firewall
module firewallPolicies 'modules/firewall-policy.bicep' = [for (hub, i) in hubNetworks: if (hub.azureFirewallSettings.?deployAzureFirewall ?? false) {
  name: 'alz-afwp-${i}-${uniqueString(deployment().name)}'
  scope: resourceGroup('${parHubNetworkingResourceGroupNamePrefix}-${hub.location}')
  dependsOn: [ hubNetworkingResourceGroups ]
  params: {
    parFirewallPolicyName: hub.azureFirewallSettings.?firewallPolicyName ?? 'afwp-alz-${hub.location}'
    parLocation: hub.location
    parTags: parTags
    parSkuTier: hub.azureFirewallSettings.?azureSkuTier ?? 'Standard'
    parInternalAddressSpaces: parInternalAddressSpaces
    parDeployBaseRules: hub.azureFirewallSettings.?deployBaseFirewallRules ?? true
  }
}]

// Azure Firewalls
module azureFirewalls 'br/public:avm/res/network/azure-firewall:0.5.1' = [for (hub, i) in hubNetworks: if (hub.azureFirewallSettings.?deployAzureFirewall ?? false) {
  name: 'alz-afw-${i}-${uniqueString(deployment().name)}'
  scope: resourceGroup('${parHubNetworkingResourceGroupNamePrefix}-${hub.location}')
  dependsOn: [ hubVirtualNetworks ]
  params: {
    name: hub.azureFirewallSettings.?azureFirewallName ?? 'afw-alz-${hub.location}'
    location: hub.location
    tags: parTags
    enableTelemetry: parEnableTelemetry
    virtualNetworkResourceId: hubVirtualNetworks[i].outputs.resourceId
    azureSkuTier: hub.azureFirewallSettings.?azureSkuTier ?? 'Standard'
    firewallPolicyId: firewallPolicies[i].outputs.outFirewallPolicyId
    publicIPAddressObject: {
      name: hub.azureFirewallSettings.?publicIPAddressObject.?name ?? 'pip-afw-alz-${hub.location}'
    }
    managementIPAddressObject: hub.azureFirewallSettings.?azureSkuTier == 'Basic' ? {
      name: hub.azureFirewallSettings.?managementIPAddressObject.?name ?? 'pip-afw-mgmt-alz-${hub.location}'
    } : null
  }
}]

// Bastion Hosts
module bastionHosts 'br/public:avm/res/network/bastion-host:0.8.2' = [for (hub, i) in hubNetworks: if (hub.bastionHostSettings.?deployBastion ?? false) {
  name: 'alz-bas-${i}-${uniqueString(deployment().name)}'
  scope: resourceGroup('${parHubNetworkingResourceGroupNamePrefix}-${hub.location}')
  dependsOn: [ hubVirtualNetworks ]
  params: {
    name: hub.bastionHostSettings.?bastionHostSettingsName ?? 'bas-alz-${hub.location}'
    location: hub.location
    tags: parTags
    enableTelemetry: parEnableTelemetry
    virtualNetworkResourceId: hubVirtualNetworks[i].outputs.resourceId
    skuName: hub.bastionHostSettings.?skuName ?? 'Standard'
  }
}]

// VPN Gateways
module vpnGateways 'br/public:avm/res/network/virtual-network-gateway:0.5.0' = [for (hub, i) in hubNetworks: if (hub.vpnGatewaySettings.?deployVpnGateway ?? false) {
  name: 'alz-vpngw-${i}-${uniqueString(deployment().name)}'
  scope: resourceGroup('${parHubNetworkingResourceGroupNamePrefix}-${hub.location}')
  dependsOn: [ hubVirtualNetworks ]
  params: {
    name: hub.vpnGatewaySettings.?name ?? 'vgw-alz-${hub.location}'
    location: hub.location
    tags: parTags
    enableTelemetry: parEnableTelemetry
    vNetResourceId: hubVirtualNetworks[i].outputs.resourceId
    gatewayType: 'Vpn'
    skuName: hub.vpnGatewaySettings.?skuName ?? 'VpnGw1AZ'
    vpnType: hub.vpnGatewaySettings.?vpnType ?? 'RouteBased'
    // vpnMode -> clusterSettings (discriminated union des AVM-Moduls)
    clusterSettings: (hub.vpnGatewaySettings.?vpnMode ?? 'activeActiveBgp') == 'activeActiveBgp' ? {
      clusterMode: 'activeActiveBgp'
      asn: hub.vpnGatewaySettings.?asn ?? 65515
    } : (hub.vpnGatewaySettings.?vpnMode ?? 'activeActiveBgp') == 'activeActiveNoBgp' ? {
      clusterMode: 'activeActiveNoBgp'
    } : (hub.vpnGatewaySettings.?vpnMode ?? 'activeActiveBgp') == 'activePassiveBgp' ? {
      clusterMode: 'activePassiveBgp'
      asn: hub.vpnGatewaySettings.?asn ?? 65515
    } : {
      clusterMode: 'activePassiveNoBgp'
    }
  }
}]

// ExpressRoute Gateways
module expressRouteGateways 'br/public:avm/res/network/virtual-network-gateway:0.5.0' = [for (hub, i) in hubNetworks: if (hub.expressRouteGatewaySettings.?deployExpressRouteGateway ?? false) {
  name: 'alz-ergw-${i}-${uniqueString(deployment().name)}'
  scope: resourceGroup('${parHubNetworkingResourceGroupNamePrefix}-${hub.location}')
  dependsOn: [ hubVirtualNetworks ]
  params: {
    name: hub.expressRouteGatewaySettings.?name ?? 'ergw-alz-${hub.location}'
    location: hub.location
    tags: parTags
    enableTelemetry: parEnableTelemetry
    vNetResourceId: hubVirtualNetworks[i].outputs.resourceId
    gatewayType: 'ExpressRoute'
    skuName: hub.expressRouteGatewaySettings.?skuName ?? 'ErGw1AZ'
    clusterSettings: {
      clusterMode: 'activePassiveNoBgp'
    }
  }
}]

// Private DNS Zones (primary hub only)
module privateDnsZones 'br/public:avm/res/network/private-dns-zone:0.6.0' = [for (zone, i) in varDefaultPrivateDnsZones: if (length(hubNetworks) > 0 && (hubNetworks[0].privateDnsSettings.?deployPrivateDnsZones ?? false)) {
  name: 'alz-pdns-${i}-${uniqueString(deployment().name)}'
  scope: resourceGroup('${parDnsResourceGroupNamePrefix}-${hubNetworks[0].location}')
  dependsOn: [ dnsResourceGroups ]
  params: {
    name: zone
    location: 'global'
    tags: parTags
    enableTelemetry: parEnableTelemetry
    virtualNetworkLinks: [
      {
        name: 'vnetlink-${hubNetworks[0].name}'
        virtualNetworkResourceId: hubVirtualNetworks[0].outputs.resourceId
        registrationEnabled: false
      }
    ]
  }
}]

// ================ //
// Outputs
// ================ //

@description('Array of hub virtual network resource IDs.')
output outHubVirtualNetworkIds array = [for (hub, i) in hubNetworks: hubVirtualNetworks[i].outputs.resourceId]

@description('Array of hub networking resource group names.')
output outHubNetworkingResourceGroupNames array = [for hub in hubNetworks: '${parHubNetworkingResourceGroupNamePrefix}-${hub.location}']

@description('Private IPs der Azure Firewalls je Hub (leerer String, wenn keine Firewall deployed). Wird von Spoke-Templates als Next Hop benoetigt.')
output outAzureFirewallPrivateIps array = [for (hub, i) in hubNetworks: (hub.azureFirewallSettings.?deployAzureFirewall ?? false) ? azureFirewalls[i].outputs.privateIp : '']

@description('Resource IDs der Firewall Policies je Hub (leerer String, wenn keine Firewall deployed).')
output outFirewallPolicyIds array = [for (hub, i) in hubNetworks: (hub.azureFirewallSettings.?deployAzureFirewall ?? false) ? firewallPolicies[i].outputs.outFirewallPolicyId : '']
