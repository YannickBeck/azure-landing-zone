using './main.bicep'

// ===============================================================
// ANPASSEN: Subscription Vending Konfiguration.
// Default: Placement-only (bestehende Subscription -> Ziel-MG).
// Deployment-Scope: Management Group (z.B. alz)
// ===============================================================

param parCreateSubscription = false
param parExistingSubscriptionId = '<WORKLOAD_SUBSCRIPTION_ID>'
param parTargetManagementGroupId = 'alz-landingzones-corp'

param parSubscriptionTags = {
  Environment: 'Production'
  ManagedBy: 'Platform Team'
}

// Nur bei parCreateSubscription = true (erfordert EA/MCA-Billing-Rolle):
// param parSubscriptionBillingScope = '/providers/Microsoft.Billing/billingAccounts/<BILLING_ACCOUNT>/enrollmentAccounts/<ENROLLMENT_ACCOUNT>'
// param parSubscriptionName = 'sub-alz-corp-workload01'
// param parSubscriptionWorkload = 'Production'

// Optional: Spoke-Netz direkt mit ausrollen
param parDeploySpokeNetwork = false
// param parSpokeVnetName = 'vnet-corp-workload01-germanywestcentral'
// param parSpokeResourceGroupName = 'rg-alz-spoke-corp-workload01'
// param parSpokeAddressSpace = [ '10.2.0.0/24' ]
// param parHubVirtualNetworkResourceId = '/subscriptions/<CONNECTIVITY_SUBSCRIPTION_ID>/resourceGroups/rg-alz-conn-germanywestcentral/providers/Microsoft.Network/virtualNetworks/vnet-alz-germanywestcentral'
