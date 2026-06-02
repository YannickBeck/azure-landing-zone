using './main.bicep'

// ===============================================================
// ANPASSEN: Ersetze alle Werte in <> mit deinen eigenen Werten
// Deployment-Scope: Connectivity Subscription
// ===============================================================

param parLocations = [
  'germanywestcentral'
  'northeurope'
]

param parGlobalResourceLock = {
  name: 'GlobalResourceLock'
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Accelerator.'
}

param parTags = {
  Environment: 'Production'
  ManagedBy: 'Platform Team'
  CostCenter: 'IT-Connectivity'
}

param parEnableTelemetry = true

param parHubNetworkingResourceGroupNamePrefix = 'rg-alz-conn'
param parDnsResourceGroupNamePrefix = 'rg-alz-dns'
param parDnsPrivateResolverResourceGroupNamePrefix = 'rg-alz-dnspr'

param hubNetworks = [
  // ======== Primärer Hub: Germany West Central ========
  {
    name: 'vnet-alz-germanywestcentral'
    location: 'germanywestcentral'
    addressPrefixes: [
      '10.0.0.0/22'          // Anpassen an dein IP-Schema
    ]
    deployPeering: true
    dnsServers: []
    peeringSettings: [
      {
        remoteVirtualNetworkName: 'vnet-alz-northeurope'
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        useRemoteGateways: false
      }
    ]
    subnets: [
      {
        name: 'AzureBastionSubnet'
        addressPrefix: '10.0.0.64/26'
      }
      {
        name: 'GatewaySubnet'
        addressPrefix: '10.0.0.128/27'
      }
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.0.0/26'
      }
      {
        name: 'AzureFirewallManagementSubnet'
        addressPrefix: '10.0.0.192/26'
      }
      {
        name: 'DNSPrivateResolverInboundSubnet'
        addressPrefix: '10.0.0.160/28'
        delegation: 'Microsoft.Network/dnsResolvers'
      }
      {
        name: 'DNSPrivateResolverOutboundSubnet'
        addressPrefix: '10.0.0.176/28'
        delegation: 'Microsoft.Network/dnsResolvers'
      }
    ]
    azureFirewallSettings: {
      deployAzureFirewall: true             // Auf false setzen um Kosten zu sparen
      azureFirewallName: 'afw-alz-germanywestcentral'
      azureSkuTier: 'Standard'
      publicIPAddressObject: {
        name: 'pip-afw-alz-germanywestcentral'
      }
      managementIPAddressObject: {
        name: 'pip-afw-mgmt-alz-germanywestcentral'
      }
    }
    bastionHostSettings: {
      deployBastion: true                   // Auf false setzen um Kosten zu sparen
      bastionHostSettingsName: 'bas-alz-germanywestcentral'
      skuName: 'Standard'
    }
    vpnGatewaySettings: {
      deployVpnGateway: false               // Auf true setzen wenn VPN benötigt
      name: 'vgw-alz-germanywestcentral'
      skuName: 'VpnGw1AZ'
      vpnMode: 'activeActiveBgp'
      vpnType: 'RouteBased'
      asn: 65515
    }
    expressRouteGatewaySettings: {
      deployExpressRouteGateway: false      // Auf true setzen wenn ExpressRoute benötigt
      name: 'ergw-alz-germanywestcentral'
    }
    privateDnsSettings: {
      deployPrivateDnsZones: true
      deployDnsPrivateResolver: false
      privateDnsResolverName: 'dnspr-alz-germanywestcentral'
      privateDnsZones: []
    }
    ddosProtectionPlanSettings: {
      deployDdosProtectionPlan: false       // Auf true setzen - ACHTUNG: ~$2500/Monat
      name: 'ddos-alz-germanywestcentral'
    }
  }
  // ======== Sekundärer Hub: North Europe ========
  {
    name: 'vnet-alz-northeurope'
    location: 'northeurope'
    addressPrefixes: [
      '10.1.0.0/22'
    ]
    deployPeering: true
    dnsServers: []
    peeringSettings: [
      {
        remoteVirtualNetworkName: 'vnet-alz-germanywestcentral'
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        useRemoteGateways: false
      }
    ]
    subnets: [
      {
        name: 'AzureBastionSubnet'
        addressPrefix: '10.1.0.64/26'
      }
      {
        name: 'GatewaySubnet'
        addressPrefix: '10.1.0.128/27'
      }
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.1.0.0/26'
      }
      {
        name: 'AzureFirewallManagementSubnet'
        addressPrefix: '10.1.0.192/26'
      }
      {
        name: 'DNSPrivateResolverInboundSubnet'
        addressPrefix: '10.1.0.160/28'
        delegation: 'Microsoft.Network/dnsResolvers'
      }
      {
        name: 'DNSPrivateResolverOutboundSubnet'
        addressPrefix: '10.1.0.176/28'
        delegation: 'Microsoft.Network/dnsResolvers'
      }
    ]
    azureFirewallSettings: {
      deployAzureFirewall: false            // Sekundäre Region optional
      azureFirewallName: 'afw-alz-northeurope'
      azureSkuTier: 'Standard'
      publicIPAddressObject: {
        name: 'pip-afw-alz-northeurope'
      }
    }
    bastionHostSettings: {
      deployBastion: false
      bastionHostSettingsName: 'bas-alz-northeurope'
      skuName: 'Standard'
    }
    vpnGatewaySettings: {
      deployVpnGateway: false
      name: 'vgw-alz-northeurope'
    }
    expressRouteGatewaySettings: {
      deployExpressRouteGateway: false
      name: 'ergw-alz-northeurope'
    }
    privateDnsSettings: {
      deployPrivateDnsZones: false
      deployDnsPrivateResolver: false
      privateDnsResolverName: 'dnspr-alz-northeurope'
      privateDnsZones: []
    }
    ddosProtectionPlanSettings: {
      deployDdosProtectionPlan: false
    }
  }
]
