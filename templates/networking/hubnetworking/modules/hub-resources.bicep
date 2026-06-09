// ================================================================ //
// ALZ Hub Resources (native)
// Hub-VNet, Subnets, optionale Azure Firewall, Bastion,
// VPN-/ExpressRoute-Gateway, DDoS Protection Plan.
// Scope: Resource Group
// ================================================================ //

targetScope = 'resourceGroup'

// ================ //
// Parameters
// ================ //

@description('Name des Hub Virtual Network.')
param parHubName string

@description('Region des Hubs.')
param parLocation string

@description('Tags fuer alle Ressourcen.')
param parTags object = {}

@description('Adress-Praefixe des Hub VNet.')
param parAddressPrefixes array

@description('Subnetze (Array aus {name, addressPrefix, delegation?}).')
param parSubnets array

@description('Custom DNS Server (leer = Azure DNS).')
param parDnsServers array = []

// --- Azure Firewall ---
@description('Azure Firewall deployen.')
param parDeployFirewall bool = false
param parFirewallName string = 'afw-alz-${parLocation}'
@allowed([ 'Basic', 'Standard', 'Premium' ])
param parFirewallTier string = 'Standard'
param parFirewallPipName string = 'pip-afw-alz-${parLocation}'
param parFirewallMgmtPipName string = 'pip-afw-mgmt-alz-${parLocation}'

// --- Bastion ---
@description('Azure Bastion deployen.')
param parDeployBastion bool = false
param parBastionName string = 'bas-alz-${parLocation}'
@allowed([ 'Basic', 'Standard' ])
param parBastionSku string = 'Standard'
param parBastionPipName string = 'pip-bas-alz-${parLocation}'

// --- VPN Gateway ---
@description('VPN Gateway deployen.')
param parDeployVpnGateway bool = false
param parVpnGatewayName string = 'vgw-alz-${parLocation}'
param parVpnGatewaySku string = 'VpnGw1AZ'
param parVpnEnableBgp bool = true
param parVpnAsn int = 65515
param parVpnPipName string = 'pip-vgw-alz-${parLocation}'

// --- ExpressRoute Gateway ---
@description('ExpressRoute Gateway deployen.')
param parDeployErGateway bool = false
param parErGatewayName string = 'ergw-alz-${parLocation}'
param parErGatewaySku string = 'ErGw1AZ'
param parErPipName string = 'pip-ergw-alz-${parLocation}'

// --- DDoS ---
@description('DDoS Protection Plan deployen (ACHTUNG: hohe Kosten).')
param parDeployDdos bool = false
param parDdosName string = 'ddos-alz-${parLocation}'

// ================ //
// Variables
// ================ //

var varSubnets = [for subnet in parSubnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.addressPrefix
    delegations: (subnet.?delegation != null) ? [
      {
        name: 'delegation'
        properties: {
          serviceName: subnet.delegation
        }
      }
    ] : []
  }
}]

// ================ //
// Resources
// ================ //

resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2024-05-01' = if (parDeployDdos) {
  name: parDdosName
  location: parLocation
  tags: parTags
}

resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: parHubName
  location: parLocation
  tags: parTags
  properties: {
    addressSpace: {
      addressPrefixes: parAddressPrefixes
    }
    dhcpOptions: !empty(parDnsServers) ? {
      dnsServers: parDnsServers
    } : null
    subnets: varSubnets
    enableDdosProtection: parDeployDdos
    ddosProtectionPlan: parDeployDdos ? {
      id: ddosProtectionPlan.id
    } : null
  }
}

// --- Public IPs ---
resource publicIpFirewall 'Microsoft.Network/publicIPAddresses@2024-05-01' = if (parDeployFirewall) {
  name: parFirewallPipName
  location: parLocation
  tags: parTags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource publicIpFirewallMgmt 'Microsoft.Network/publicIPAddresses@2024-05-01' = if (parDeployFirewall && parFirewallTier == 'Basic') {
  name: parFirewallMgmtPipName
  location: parLocation
  tags: parTags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource publicIpBastion 'Microsoft.Network/publicIPAddresses@2024-05-01' = if (parDeployBastion) {
  name: parBastionPipName
  location: parLocation
  tags: parTags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource publicIpVpn 'Microsoft.Network/publicIPAddresses@2024-05-01' = if (parDeployVpnGateway) {
  name: parVpnPipName
  location: parLocation
  tags: parTags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource publicIpEr 'Microsoft.Network/publicIPAddresses@2024-05-01' = if (parDeployErGateway) {
  name: parErPipName
  location: parLocation
  tags: parTags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// --- Azure Firewall ---
resource azureFirewall 'Microsoft.Network/azureFirewalls@2024-05-01' = if (parDeployFirewall) {
  name: parFirewallName
  location: parLocation
  tags: parTags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: parFirewallTier
    }
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          subnet: {
            id: '${hubVirtualNetwork.id}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: publicIpFirewall.id
          }
        }
      }
    ]
    managementIpConfiguration: (parFirewallTier == 'Basic') ? {
      name: 'mgmtIpConfig'
      properties: {
        subnet: {
          id: '${hubVirtualNetwork.id}/subnets/AzureFirewallManagementSubnet'
        }
        publicIPAddress: {
          id: publicIpFirewallMgmt.id
        }
      }
    } : null
  }
}

// --- Bastion ---
resource bastionHost 'Microsoft.Network/bastionHosts@2024-05-01' = if (parDeployBastion) {
  name: parBastionName
  location: parLocation
  tags: parTags
  sku: {
    name: parBastionSku
  }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${hubVirtualNetwork.id}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: publicIpBastion.id
          }
        }
      }
    ]
  }
}

// --- VPN Gateway ---
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = if (parDeployVpnGateway) {
  name: parVpnGatewayName
  location: parLocation
  tags: parTags
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: parVpnEnableBgp
    bgpSettings: parVpnEnableBgp ? {
      asn: parVpnAsn
    } : null
    sku: {
      name: parVpnGatewaySku
      tier: parVpnGatewaySku
    }
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${hubVirtualNetwork.id}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: publicIpVpn.id
          }
        }
      }
    ]
  }
}

// --- ExpressRoute Gateway ---
resource erGateway 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = if (parDeployErGateway) {
  name: parErGatewayName
  location: parLocation
  tags: parTags
  properties: {
    gatewayType: 'ExpressRoute'
    sku: {
      name: parErGatewaySku
      tier: parErGatewaySku
    }
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${hubVirtualNetwork.id}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: publicIpEr.id
          }
        }
      }
    ]
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID des Hub VNet.')
output outHubVirtualNetworkId string = hubVirtualNetwork.id

@description('Name des Hub VNet.')
output outHubVirtualNetworkName string = hubVirtualNetwork.name

@description('Private IP der Azure Firewall (falls deployed).')
output outFirewallPrivateIp string = parDeployFirewall ? azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress : ''
