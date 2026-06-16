using './main.bicep'

// ===============================================================
// ANPASSEN: Beispiel-Spoke fuer einen Corp-Workload.
// Ersetze alle Werte in <> mit deinen eigenen Werten.
// Deployment-Scope: Workload Subscription
// ===============================================================

param parWorkloadName = 'corp-app01'
param parLocation = 'germanywestcentral'

param parTags = {
  Environment: 'Production'
  ManagedBy: 'Platform Team'
  CostCenter: 'IT-Workload'
}

param parAddressPrefixes = [
  '10.2.0.0/24'          // Anpassen an dein IP-Schema (kein Overlap mit Hubs!)
]

param parSubnets = [
  {
    name: 'snet-app'
    addressPrefix: '10.2.0.0/26'
  }
  {
    name: 'snet-data'
    addressPrefix: '10.2.0.64/26'
  }
]

param parHubVirtualNetworkResourceId = '/subscriptions/<CONNECTIVITY_SUBSCRIPTION_ID>/resourceGroups/rg-alz-conn-germanywestcentral/providers/Microsoft.Network/virtualNetworks/vnet-alz-germanywestcentral'

// Private IP der Hub-Firewall (Output outAzureFirewallPrivateIps des
// Hub-Networking-Deployments, z.B. '10.0.0.4'). Leer = keine Default-Route.
param parFirewallPrivateIp = ''

// Resource IDs der zentralen Private DNS Zonen (optional), z.B.:
// '/subscriptions/<CONNECTIVITY_SUBSCRIPTION_ID>/resourceGroups/rg-alz-dns-germanywestcentral/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
param parPrivateDnsZoneResourceIds = []
