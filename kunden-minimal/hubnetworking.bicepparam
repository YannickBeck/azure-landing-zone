using '../templates/networking/hubnetworking/main.bicep'

// ===============================================================
// Kunden-Minimal Hub Networking – Germany West Central
// Kosten: ~€715/Monat (Firewall Standard + Private DNS Zones)
//
// Aktiv:          Azure Firewall Standard, Private DNS Zones
// Zurückgestellt: Bastion, VPN Gateway, DNS Private Resolver
//
// Skalierung (Schalter):
//   + Bastion      → deployBastion: true      (+€120/Mon, wenn kein VPN-Tunnel)
//   + VPN Gateway  → deployVpnGateway: true   (+€140/Mon, bei On-Prem-Anbindung)
//   + DNS Resolver → deployDnsPrivateResolver: true (+€25/Mon)
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
  // ======== Einziger Hub: Germany West Central ========
  {
    name: 'vnet-alz-germanywestcentral'
    location: 'germanywestcentral'
    addressPrefixes: [
      '10.0.0.0/22'
    ]
    deployPeering: false             // Kein zweiter Hub → kein Hub-zu-Hub Peering
    dnsServers: []
    peeringSettings: []
    subnets: [
      // Alle Subnetze reserviert – Dienste nur deployen wenn Schalter aktiv
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.0.0/26'
      }
      {
        name: 'AzureFirewallManagementSubnet'
        addressPrefix: '10.0.0.192/26'
      }
      {
        name: 'AzureBastionSubnet'
        addressPrefix: '10.0.0.64/26'  // Reserviert, Bastion zurückgestellt
      }
      {
        name: 'GatewaySubnet'
        addressPrefix: '10.0.0.128/27' // Reserviert, VPN Gateway zurückgestellt
      }
      {
        name: 'DNSPrivateResolverInboundSubnet'
        addressPrefix: '10.0.0.160/28' // Reserviert, DNS Resolver zurückgestellt
        delegation: 'Microsoft.Network/dnsResolvers'
      }
      {
        name: 'DNSPrivateResolverOutboundSubnet'
        addressPrefix: '10.0.0.176/28' // Reserviert, DNS Resolver zurückgestellt
        delegation: 'Microsoft.Network/dnsResolvers'
      }
    ]
    azureFirewallSettings: {
      deployAzureFirewall: true
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
      deployBastion: false            // Zurückgestellt: Kunde hat eigenen On-Prem Gateway
                                      // → true setzen wenn kein VPN-Tunnel vorhanden ist
      bastionHostSettingsName: 'bas-alz-germanywestcentral'
      skuName: 'Standard'
    }
    vpnGatewaySettings: {
      deployVpnGateway: false         // Zurückgestellt: aktivieren wenn On-Prem-Anbindung geplant
                                      // → true setzen, dann auch Local Network Gateway + Connection anlegen
      name: 'vgw-alz-germanywestcentral'
      skuName: 'VpnGw1AZ'
      vpnMode: 'activeActiveBgp'
      vpnType: 'RouteBased'
      asn: 65515
    }
    expressRouteGatewaySettings: {
      deployExpressRouteGateway: false
      name: 'ergw-alz-germanywestcentral'
    }
    privateDnsSettings: {
      deployPrivateDnsZones: true
      deployDnsPrivateResolver: false // Zurückgestellt
      privateDnsResolverName: 'dnspr-alz-germanywestcentral'
      privateDnsZones: []
    }
    ddosProtectionPlanSettings: {
      deployDdosProtectionPlan: false // ACHTUNG: ~€2.500/Monat Fixkosten
      name: 'ddos-alz-germanywestcentral'
    }
  }
]
