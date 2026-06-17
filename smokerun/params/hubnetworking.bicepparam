using '../../templates/networking/hubnetworking/main.bicep'

// Smoke Run – minimaler Hub ohne kostenpflichtige Dienste
// Unterschiede zu Produktion:
//   - Nur ein Hub (germanywestcentral, kein North Europe)
//   - Kein Azure Firewall  (spart ~€1.100/Monat)
//   - Kein Bastion         (spart ~€120/Monat)
//   - Kein VPN Gateway     (spart ~€140/Monat)
//   - Kein ExpressRoute    (spart ~€280/Monat)
//   - Kein DDoS Plan       (spart ~€2.500/Monat)
//   - Private DNS Zones deployen (kostenlos, wichtig für den Test)
//   - Präfix 'smoke' zur Unterscheidung

param parTags = {
  Environment: 'Smoke'
  ManagedBy: 'Platform Team'
  CostCenter: 'IT-Demo'
}

param parEnableTelemetry = false

param parHubNetworkingResourceGroupNamePrefix = 'rg-alz-smoke-conn'
param parDnsResourceGroupNamePrefix = 'rg-alz-smoke-dns'

param hubNetworks = [
  {
    name: 'vnet-alz-smoke-gwe'
    location: 'germanywestcentral'
    addressPrefixes: [
      '10.0.0.0/24'
    ]
    deployPeering: false    // Kein zweiter Hub zum Peeren
    dnsServers: []
    peeringSettings: []

    subnets: [
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
        addressPrefix: '10.0.0.64/26'
      }
      {
        name: 'GatewaySubnet'
        addressPrefix: '10.0.0.128/27'
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
      deployAzureFirewall: false
      azureFirewallName: 'afw-alz-smoke-gwe'
      azureSkuTier: 'Standard'
      publicIPAddressObject: { name: 'pip-afw-alz-smoke-gwe' }
      managementIPAddressObject: { name: 'pip-afw-mgmt-alz-smoke-gwe' }
    }

    bastionHostSettings: {
      deployBastion: false
      bastionHostSettingsName: 'bas-alz-smoke-gwe'
      skuName: 'Standard'
    }

    vpnGatewaySettings: {
      deployVpnGateway: false
      name: 'vgw-alz-smoke-gwe'
      skuName: 'VpnGw1AZ'
      vpnMode: 'activeActiveBgp'
      vpnType: 'RouteBased'
      asn: 65515
    }

    expressRouteGatewaySettings: {
      deployExpressRouteGateway: false
      name: 'ergw-alz-smoke-gwe'
    }

    privateDnsSettings: {
      deployPrivateDnsZones: true     // Testen, dass DNS-Zonen korrekt deployen
      deployDnsPrivateResolver: false
      privateDnsResolverName: 'dnspr-alz-smoke-gwe'
      privateDnsZones: []
    }

    ddosProtectionPlanSettings: {
      deployDdosProtectionPlan: false
      name: 'ddos-alz-smoke'
    }
  }
]
