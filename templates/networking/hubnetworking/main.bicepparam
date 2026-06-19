using './main.bicep'

// ===============================================================
// ANPASSEN: Ersetze alle Werte in <> mit deinen eigenen Werten
// Deployment-Scope: Connectivity Subscription
// ===============================================================

param parTags = {
  Environment: 'Production'
  ManagedBy: 'Platform Team'
  CostCenter: 'IT-Connectivity'
}

param parEnableTelemetry = true

param parHubNetworkingResourceGroupNamePrefix = 'rg-alz-conn'
param parDnsResourceGroupNamePrefix = 'rg-alz-dns'

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
  // Sekundärer Hub (z. B. westeurope für Geo-Redundanz) nur für Variante D (Microsoft Default ~€5.800/Monat).
  // Bechtle-Empfehlung (Variante A/B, ~€1.050/Monat): kein zweiter Hub – nur GWC aktiv.
  // Bei Bedarf neues Objekt hier einfügen: { name: 'vnet-alz-westeurope', location: 'westeurope', ... }
]
