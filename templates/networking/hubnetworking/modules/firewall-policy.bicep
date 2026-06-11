// ================================================================ //
// ALZ Azure Firewall Policy (native)
// Firewall Policy mit Basis-Regelwerk:
// - DNS-Proxy (ab Standard-Tier)
// - Network-Rules: Azure DNS, NTP, AzureCloud (HTTPS)
// - Application-Rules: Windows Update FQDN-Tags
// Nicht gematchter Traffic wird implizit verweigert (Default Deny).
// Scope: Resource Group
// ================================================================ //

targetScope = 'resourceGroup'

// ================ //
// Parameters
// ================ //

@description('Name der Firewall Policy.')
param parFirewallPolicyName string

@description('Region der Firewall Policy.')
param parLocation string

@description('Tags fuer alle Ressourcen.')
param parTags object = {}

@description('SKU-Tier; muss zum Tier der zugehoerigen Azure Firewall passen.')
@allowed([ 'Basic', 'Standard', 'Premium' ])
param parSkuTier string = 'Standard'

@description('Interne Quell-Adressbereiche fuer die Basis-Regeln.')
param parInternalAddressSpaces array = [
  '10.0.0.0/8'
]

@description('Basis-Regelwerk (DNS, NTP, AzureCloud, Windows Update) deployen.')
param parDeployBaseRules bool = true

// ================ //
// Variables
// ================ //

// DNS-Proxy wird vom Basic-Tier nicht unterstuetzt
var varDnsSettings = parSkuTier == 'Basic' ? null : {
  enableProxy: true
  servers: []
}

// ================ //
// Resources
// ================ //

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-05-01' = {
  name: parFirewallPolicyName
  location: parLocation
  tags: parTags
  properties: {
    sku: {
      tier: parSkuTier
    }
    threatIntelMode: 'Alert'
    dnsSettings: varDnsSettings
  }
}

resource baseRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = if (parDeployBaseRules) {
  parent: firewallPolicy
  name: 'alz-base-rules'
  properties: {
    priority: 1000
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'alz-network-allow'
        priority: 1000
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Allow-Azure-DNS'
            ipProtocols: [ 'TCP', 'UDP' ]
            sourceAddresses: parInternalAddressSpaces
            destinationAddresses: [ '168.63.129.16' ]
            destinationPorts: [ '53' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-NTP'
            ipProtocols: [ 'UDP' ]
            sourceAddresses: parInternalAddressSpaces
            destinationAddresses: [ '*' ]
            destinationPorts: [ '123' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-AzureCloud-Https'
            ipProtocols: [ 'TCP' ]
            sourceAddresses: parInternalAddressSpaces
            destinationAddresses: [ 'AzureCloud' ]
            destinationPorts: [ '443' ]
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'alz-application-allow'
        priority: 1100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Allow-Windows-Update'
            sourceAddresses: parInternalAddressSpaces
            fqdnTags: [
              'WindowsUpdate'
              'WindowsDiagnostics'
            ]
            protocols: [
              { protocolType: 'Https', port: 443 }
              { protocolType: 'Http', port: 80 }
            ]
          }
        ]
      }
    ]
  }
}

// ================ //
// Outputs
// ================ //

@description('Resource ID der Firewall Policy.')
output outFirewallPolicyId string = firewallPolicy.id
