// ================================================================ //
// ALZ Subscription Vending
// Erstellt bzw. platziert eine Landing-Zone-Subscription in der
// Ziel-Management-Group, optional inkl. Spoke-VNet + Hub-Peering.
// Nutzt das AVM-Pattern-Modul avm/ptn/lz/sub-vending.
//
// Modi:
//  - Placement-only (Default): bestehende Subscription -> Ziel-MG
//  - Create: neue Subscription via Billing Scope (erfordert
//    EA/MCA-Billing-Rolle des Deployers)
// Scope: Management Group (z.B. alz)
// ================================================================ //

targetScope = 'managementGroup'

// ================ //
// Parameters
// ================ //

@description('Neue Subscription erstellen (true) oder bestehende platzieren (false).')
param parCreateSubscription bool = false

@description('Resource ID des Billing Scope (nur bei parCreateSubscription = true).')
param parSubscriptionBillingScope string = ''

@description('Alias-/Anzeigename der Subscription (nur bei parCreateSubscription = true).')
param parSubscriptionName string = ''

@description('Workload-Typ der neuen Subscription.')
@allowed([ 'Production', 'DevTest' ])
param parSubscriptionWorkload string = 'Production'

@description('ID einer bestehenden Subscription (nur bei parCreateSubscription = false).')
param parExistingSubscriptionId string = ''

@description('Ziel-Management-Group fuer die Subscription.')
param parTargetManagementGroupId string = 'alz-landingzones-corp'

@description('Tags fuer die Subscription.')
param parSubscriptionTags object = {}

@description('Spoke-VNet inkl. Hub-Peering direkt mit deployen.')
param parDeploySpokeNetwork bool = false

@description('Name des Spoke-VNet.')
param parSpokeVnetName string = ''

@description('Region des Spoke-VNet.')
param parSpokeLocation string = 'germanywestcentral'

@description('Name der Spoke Resource Group.')
param parSpokeResourceGroupName string = ''

@description('Adressraum des Spoke-VNet.')
param parSpokeAddressSpace array = []

@description('Resource ID des Hub-VNet fuer das Peering.')
param parHubVirtualNetworkResourceId string = ''

@description('Remote-Gateways des Hubs nutzen (erfordert VPN/ER-Gateway im Hub).')
param parUseRemoteGateways bool = false

@description('Enable or disable telemetry.')
param parEnableTelemetry bool = true

// ================ //
// Modules
// ================ //

module subscriptionVending 'br/public:avm/ptn/lz/sub-vending:0.8.0' = {
  name: 'alz-sub-vending-${uniqueString(deployment().name)}'
  params: {
    enableTelemetry: parEnableTelemetry
    subscriptionAliasEnabled: parCreateSubscription
    subscriptionBillingScope: parSubscriptionBillingScope
    subscriptionAliasName: parSubscriptionName
    subscriptionDisplayName: parSubscriptionName
    subscriptionWorkload: parSubscriptionWorkload
    existingSubscriptionId: parExistingSubscriptionId
    subscriptionManagementGroupAssociationEnabled: true
    subscriptionManagementGroupId: parTargetManagementGroupId
    subscriptionTags: parSubscriptionTags
    // Resource-Provider-Registrierung deaktiviert; der Default des Moduls
    // wuerde Deployment Scripts (Managed Identity + Storage) erfordern.
    resourceProviders: {}
    virtualNetworkEnabled: parDeploySpokeNetwork
    virtualNetworkName: parSpokeVnetName
    virtualNetworkLocation: parSpokeLocation
    virtualNetworkResourceGroupName: parSpokeResourceGroupName
    virtualNetworkAddressSpace: parSpokeAddressSpace
    virtualNetworkPeeringEnabled: parDeploySpokeNetwork && !empty(parHubVirtualNetworkResourceId)
    hubNetworkResourceId: parHubVirtualNetworkResourceId
    virtualNetworkUseRemoteGateways: parUseRemoteGateways
  }
}

// ================ //
// Outputs
// ================ //

@description('Subscription ID der erstellten bzw. platzierten Subscription.')
output outSubscriptionId string = subscriptionVending.outputs.subscriptionId

@description('Resource ID der erstellten bzw. platzierten Subscription.')
output outSubscriptionResourceId string = subscriptionVending.outputs.subscriptionResourceId
