# Azure Landing Zone – Technische Referenz

> Granulare, datengetriebene Dokumentation aller deployten Ressourcen, Policies, Management Groups und Module. **Automatisch generiert** aus dem Repository-Stand `942dd4f` am 16.06.2026 via `docs/kickoff/generate-techref.py`.

Basis: offizielles **Azure ALZ Bicep Accelerator** Starter-Modul (`avm/ptn/alz/empty`, volles ALZ-Policy-Set).

## 1. Deployment-Topologie & Reihenfolge

Die Plattform wird in dieser festen Reihenfolge deployt (`.config/ALZ-Powershell.config.json`):

| # | Stufe | Scope | Template |
|---|---|---|---|
| 1 | Governance-Intermediate Root | managementGroup | core/governance/mgmt-groups/int-root/main.bicep |
| 2 | Governance-Landing Zones | managementGroup | core/governance/mgmt-groups/landingzones/main.bicep |
| 3 | Governance-Landing Zones Corp | managementGroup | core/governance/mgmt-groups/landingzones/landingzones-corp/main.bicep |
| 4 | Governance-Landing Zones Online | managementGroup | core/governance/mgmt-groups/landingzones/landingzones-online/main.bicep |
| 5 | Governance-Landing Zones Local | managementGroup | core/governance/mgmt-groups/landingzones/landingzones-local/main.bicep |
| 6 | Governance-Platform | managementGroup | core/governance/mgmt-groups/platform/main.bicep |
| 7 | Governance-Platform Connectivity | managementGroup | core/governance/mgmt-groups/platform/platform-connectivity/main.bicep |
| 8 | Governance-Platform Identity | managementGroup | core/governance/mgmt-groups/platform/platform-identity/main.bicep |
| 9 | Governance-Platform Management | managementGroup | core/governance/mgmt-groups/platform/platform-management/main.bicep |
| 10 | Governance-Platform Security | managementGroup | core/governance/mgmt-groups/platform/platform-security/main.bicep |
| 11 | Governance-Sandbox | managementGroup | core/governance/mgmt-groups/sandbox/main.bicep |
| 12 | Governance-Decommissioned | managementGroup | core/governance/mgmt-groups/decommissioned/main.bicep |
| 13 | Governance-Platform RBAC | managementGroup | core/governance/mgmt-groups/platform/main-rbac.bicep |
| 14 | Governance-Platform Connectivity RBAC | managementGroup | core/governance/mgmt-groups/platform/platform-connectivity/main-rbac.bicep |
| 15 | Governance-Landing Zones RBAC | managementGroup | core/governance/mgmt-groups/landingzones/main-rbac.bicep |
| 16 | Core-Logging | subscription | core/logging/main.bicep |
| 17 | Networking-Hub Networking | subscription | networking/hubnetworking/main.bicep |
| 18 | Networking-Virtual WAN | subscription | networking/virtualwan/main.bicep |

## 2. Management Groups

12 Management Groups (IDs ggf. mit Präfix/Postfix gemäß `config/`):

| ID | Anzeigename | Parent | Zweck |
|---|---|---|---|
| alz | Azure Landing Zones | Tenant Root | Intermediate Root |
| platform | Platform | alz | Plattform-Dienste |
| connectivity | Connectivity | platform | Hub-Netzwerk, Firewall, DNS |
| identity | Identity | platform | Identity-Dienste |
| management | Management | platform | Logging, Monitoring |
| security | Security | platform | Security-Tooling |
| landingzones | Landing Zones | alz | Workload-Container |
| corp | Corp | landingzones | interne Workloads (keine Public Endpoints) |
| online | Online | landingzones | internetseitige Workloads |
| local | Local | landingzones | souveräne/lokale Workloads |
| sandbox | Sandbox | alz | Experimente (gelockerte Policies) |
| decommissioned | Decommissioned | alz | Stilllegung (gesperrt) |

## 3. Azure Verified Modules (Versionen)

Alle verwendeten AVM-Module aus der öffentlichen MCR:

| Modul | Version | Verwendungen |
|---|---|---|
| avm/ptn/alz/empty | 0.3.6 | 12 |
| avm/ptn/authorization/role-assignment | 0.2.4 | 10 |
| avm/res/resources/resource-group | 0.4.3 | 7 |
| avm/res/network/virtual-network | 0.7.2 | 3 |
| avm/res/network/virtual-network-gateway | 0.10.1 | 2 |
| avm/res/network/route-table | 0.5.0 | 2 |
| avm/res/network/firewall-policy | 0.3.4 | 2 |
| avm/res/network/dns-resolver | 0.5.6 | 2 |
| avm/res/network/ddos-protection-plan | 0.3.2 | 2 |
| avm/res/network/bastion-host | 0.8.2 | 2 |
| avm/res/network/azure-firewall | 0.9.2 | 2 |
| avm/ptn/network/private-link-private-dns-zones | 0.7.2 | 2 |
| avm/res/operational-insights/workspace | 0.14.2 | 1 |
| avm/res/network/vpn-server-configuration | 0.1.2 | 1 |
| avm/res/network/vpn-gateway | 0.2.2 | 1 |
| avm/res/network/virtual-wan | 0.4.3 | 1 |
| avm/res/network/virtual-hub | 0.4.3 | 1 |
| avm/res/network/public-ip-address | 0.12.0 | 1 |
| avm/res/network/network-security-group | 0.5.2 | 1 |
| avm/res/network/express-route-gateway | 0.8.0 | 1 |
| avm/res/automation/automation-account | 0.17.1 | 1 |
| avm/ptn/alz/ama | 0.2.0 | 1 |

## 4. Governance – Policy-Assignments je Management-Group-Ebene

Konkret zugewiesene Policies/Guardrails (extrahiert aus den Templates; Vererbung an Kind-MGs greift zusätzlich):

### alz (Intermediate Root) — 17 Assignment(s)

| Assignment | Anzeigename | Enforcement |
|---|---|---|
| Audit-ResourceRGLocation | Resource Group and Resource locations should match | Default |
| Audit-TrustedLaunch | Audit virtual machines for Trusted Launch support | Default |
| Audit-UnusedResources | Unused resources driving cost should be avoided | Default |
| Audit-ZoneResiliency | Resources should be Zone Resilient | Default |
| Deny-Classic-Resources | Deny the deployment of classic resources | Default |
| Deny-UnmanagedDisk | Deny virtual machines and virtual machine scale sets that do not use managed disk | Default |
| Deploy-ASC-Monitoring | Microsoft Cloud Security Benchmark | Default |
| Deploy-AzActivity-Log | Configure Azure Activity logs to stream to specified Log Analytics workspace | Default |
| Deploy-Diag-LogsCat | Enable category group resource logging for supported resources to Log Analytics | Default |
| Deploy-MCSB2-Monitoring | Microsoft Cloud Security Benchmark v2 | Default |
| Deploy-MDEndpoints | [[Preview]: Deploy Microsoft Defender for Endpoint agent | Default |
| Deploy-MDEndpointsAMA | Configure multiple Microsoft Defender for Endpoint integration settings with Microsoft Defender for Cloud | Default |
| Deploy-MDFC-Config-H224 | Deploy Microsoft Defender for Cloud configuration | Default |
| Deploy-MDFC-OssDb | Configure Advanced Threat Protection to be enabled on open-source relational databases | Default |
| Deploy-MDFC-SqlAtp | Configure Azure Defender to be enabled on SQL Servers and SQL Managed Instances | Default |
| Deploy-SvcHealth-BuiltIn | Configure subscriptions to enable service health alert monitoring rule | Default |
| Enforce-ACSB | Enforce Azure Compute Security Baseline compliance auditing | Default |

### landingzones — 53 Assignment(s)

| Assignment | Anzeigename | Enforcement |
|---|---|---|
| Audit-AppGW-WAF | Web Application Firewall (WAF) should be enabled for Application Gateway | Default |
| Deny-IP-forwarding | Network interfaces should disable IP forwarding | Default |
| Deny-MgmtPorts-Internet | Management port access from the Internet should be blocked | Default |
| Deny-Priv-Esc-AKS | Kubernetes clusters should not allow container privilege escalation | Default |
| Deny-Privileged-AKS | Kubernetes cluster should not allow privileged containers | Default |
| Deny-Storage-http | Secure transfer to storage accounts should be enabled | Default |
| Deny-Subnet-Without-Nsg | Subnets should have a Network Security Group | Default |
| Deploy-AzSqlDb-Auditing | Configure SQL servers to have auditing enabled to Log Analytics workspace | Default |
| Deploy-GuestAttest | Configure prerequisites to enable Guest Attestation on Trusted Launch enabled VMs | Default |
| Deploy-MDFC-DefSQL-AMA | Enable Defender for SQL on SQL VMs and Arc-enabled SQL Servers | Default |
| Deploy-SQL-TDE | Deploy TDE on SQL servers | Default |
| Deploy-SQL-Threat | Deploy Threat Detection on SQL servers | Default |
| Deploy-VM-Backup | Configure backup on virtual machines without a given tag to a new recovery services vault with a default policy | Default |
| Deploy-VM-ChangeTrack | Enable ChangeTracking and Inventory for virtual machines | Default |
| Deploy-VM-Monitoring | Enable Azure Monitor for VMs | Default |
| Deploy-VMSS-ChangeTrack | Enable ChangeTracking and Inventory for virtual machine scale sets | Default |
| Deploy-VMSS-Monitoring | Enable Azure Monitor for Virtual Machine Scale Sets | Default |
| Deploy-vmArc-ChangeTrack | Enable ChangeTracking and Inventory for Arc-enabled virtual machines | Default |
| Deploy-vmHybr-Monitoring | Enable Azure Monitor for Hybrid Virtual Machines | Default |
| Enable-AUM-CheckUpdates | Configure periodic checking for missing system updates on azure virtual machines and Arc-enabled virtual machines. | Default |
| Enable-DDoS-VNET | Virtual networks should be protected by Azure DDoS Network Protection | Default |
| Enforce-AKS-HTTPS | Kubernetes clusters should be accessible only over HTTPS | Default |
| Enforce-ASR | Enforce enhanced recovery and backup policies | Default |
| Enforce-Encrypt-CMK0 | Enforce recommended guardrails for Customer Managed Keys | DoNotEnforce |
| Enforce-GR-APIM0 | Enforce recommended guardrails for API Management | DoNotEnforce |
| Enforce-GR-AppServices0 | Enforce recommended guardrails for App Services | DoNotEnforce |
| Enforce-GR-Automation0 | Enforce recommended guardrails for Automation Accounts | DoNotEnforce |
| Enforce-GR-BotService0 | Enforce recommended guardrails for Bot Service | DoNotEnforce |
| Enforce-GR-CogServ0 | Enforce recommended guardrails for Cognitive Services | DoNotEnforce |
| Enforce-GR-Compute0 | Enforce recommended guardrails for Compute | DoNotEnforce |
| Enforce-GR-ContApps0 | Enforce recommended guardrails for Container Apps | DoNotEnforce |
| Enforce-GR-ContInst0 | Enforce recommended guardrails for Container Instance | DoNotEnforce |
| Enforce-GR-ContReg0 | Enforce recommended guardrails for Container Registry | DoNotEnforce |
| Enforce-GR-CosmosDb0 | Enforce recommended guardrails for Cosmos DB | DoNotEnforce |
| Enforce-GR-DataExpl0 | Enforce recommended guardrails for Data Explorer | DoNotEnforce |
| Enforce-GR-DataFactory0 | Enforce recommended guardrails for Data Factory | DoNotEnforce |
| Enforce-GR-EventGrid0 | Enforce recommended guardrails for Event Grid | DoNotEnforce |
| Enforce-GR-EventHub0 | Enforce recommended guardrails for Event Hub | DoNotEnforce |
| Enforce-GR-KeyVault | Enforce recommended guardrails for Azure Key Vault | Default |
| Enforce-GR-KeyVaultSup0 | Enforce recommended guardrails for Key Vault Supplementary | DoNotEnforce |
| Enforce-GR-Kubernetes0 | Enforce recommended guardrails for Kubernetes | DoNotEnforce |
| Enforce-GR-MachLearn0 | Enforce recommended guardrails for Machine Learning | DoNotEnforce |
| Enforce-GR-MySQL0 | Enforce recommended guardrails for MySQL | DoNotEnforce |
| Enforce-GR-Network0 | Enforce recommended guardrails for Network and Networking services | DoNotEnforce |
| Enforce-GR-OpenAI0 | Enforce recommended guardrails for OpenAI | DoNotEnforce |
| Enforce-GR-PostgreSQL0 | Enforce recommended guardrails for PostgreSQL | DoNotEnforce |
| Enforce-GR-SQL0 | Enforce recommended guardrails for SQL | DoNotEnforce |
| Enforce-GR-ServiceBus0 | Enforce recommended guardrails for Service Bus | DoNotEnforce |
| Enforce-GR-Storage0 | Enforce recommended guardrails for Storage | DoNotEnforce |
| Enforce-GR-Synapse0 | Enforce recommended guardrails for Synapse | DoNotEnforce |
| Enforce-GR-VirtualDesk0 | Enforce recommended guardrails for Virtual Desktop | DoNotEnforce |
| Enforce-Subnet-Private | Subnets should be private | DoNotEnforce |
| Enforce-TLS-SSL-Q225 | Deny or Deploy and append TLS requirements and SSL enforcement on resources without Encryption in transit | Default |

### landingzones-corp — 5 Assignment(s)

| Assignment | Anzeigename | Enforcement |
|---|---|---|
| Audit-PeDnsZones | Audit Private Link Private DNS Zone resources | Default |
| Deny-HybridNetworking | Deny the deployment of vWAN/ER/VPN gateway resources | Default |
| Deny-Public-Endpoints | Public network access should be disabled for PaaS services | Default |
| Deny-Public-IP-On-NIC | Deny network interfaces having a public IP associated | Default |
| Deploy-Private-DNS-Zones | Configure Azure PaaS services to use private DNS zones | Default |

### landingzones-online — 0 Assignment(s)

_keine eigenen Assignments (erbt von übergeordneter MG)_

### landingzones-local — 1 Assignment(s)

| Assignment | Anzeigename | Enforcement |
|---|---|---|
| Enforce-ALDO-Services | Audit resource types to Azure services supported in Azure Local disconnected operations | Default |

### platform — 40 Assignment(s)

| Assignment | Anzeigename | Enforcement |
|---|---|---|
| DenyAction-DeleteUAMIAMA | Do not allow deletion of the User Assigned Managed Identity used by AMA | Default |
| Deploy-GuestAttest | Configure prerequisites to enable Guest Attestation on Trusted Launch enabled VMs | Default |
| Deploy-MDFC-DefSQL-AMA | Enable Defender for SQL on SQL VMs and Arc-enabled SQL Servers | Default |
| Deploy-VM-ChangeTrack | Enable ChangeTracking and Inventory for virtual machines | Default |
| Deploy-VM-Monitoring | Enable Azure Monitor for VMs | Default |
| Deploy-VMSS-ChangeTrack | Enable ChangeTracking and Inventory for virtual machine scale sets | Default |
| Deploy-VMSS-Monitoring | Enable Azure Monitor for Virtual Machine Scale Sets | Default |
| Deploy-vmArc-ChangeTrack | Enable ChangeTracking and Inventory for Arc-enabled virtual machines | Default |
| Deploy-vmHybr-Monitoring | Enable Azure Monitor for Hybrid Virtual Machines | Default |
| Enable-AUM-CheckUpdates | Configure periodic checking for missing system updates on azure virtual machines and Arc-enabled virtual machines. | Default |
| Enforce-ASR | Enforce enhanced recovery and backup policies | Default |
| Enforce-Encrypt-CMK0 | Enforce recommended guardrails for Customer Managed Keys | DoNotEnforce |
| Enforce-GR-APIM0 | Enforce recommended guardrails for API Management | DoNotEnforce |
| Enforce-GR-AppServices0 | Enforce recommended guardrails for App Services | DoNotEnforce |
| Enforce-GR-Automation0 | Enforce recommended guardrails for Automation Accounts | DoNotEnforce |
| Enforce-GR-BotService0 | Enforce recommended guardrails for Bot Service | DoNotEnforce |
| Enforce-GR-CogServ0 | Enforce recommended guardrails for Cognitive Services | DoNotEnforce |
| Enforce-GR-Compute0 | Enforce recommended guardrails for Compute | DoNotEnforce |
| Enforce-GR-ContApps0 | Enforce recommended guardrails for Container Apps | DoNotEnforce |
| Enforce-GR-ContInst0 | Enforce recommended guardrails for Container Instance | DoNotEnforce |
| Enforce-GR-ContReg0 | Enforce recommended guardrails for Container Registry | DoNotEnforce |
| Enforce-GR-CosmosDb0 | Enforce recommended guardrails for Cosmos DB | DoNotEnforce |
| Enforce-GR-DataExpl0 | Enforce recommended guardrails for Data Explorer | DoNotEnforce |
| Enforce-GR-DataFactory0 | Enforce recommended guardrails for Data Factory | DoNotEnforce |
| Enforce-GR-EventGrid0 | Enforce recommended guardrails for Event Grid | DoNotEnforce |
| Enforce-GR-EventHub0 | Enforce recommended guardrails for Event Hub | DoNotEnforce |
| Enforce-GR-KeyVault | Enforce recommended guardrails for Azure Key Vault | Default |
| Enforce-GR-KeyVaultSup0 | Enforce recommended guardrails for Key Vault Supplementary | DoNotEnforce |
| Enforce-GR-Kubernetes0 | Enforce recommended guardrails for Kubernetes | DoNotEnforce |
| Enforce-GR-MachLearn0 | Enforce recommended guardrails for Machine Learning | DoNotEnforce |
| Enforce-GR-MySQL0 | Enforce recommended guardrails for MySQL | DoNotEnforce |
| Enforce-GR-Network0 | Enforce recommended guardrails for Network and Networking services | DoNotEnforce |
| Enforce-GR-OpenAI0 | Enforce recommended guardrails for OpenAI | DoNotEnforce |
| Enforce-GR-PostgreSQL0 | Enforce recommended guardrails for PostgreSQL | DoNotEnforce |
| Enforce-GR-SQL0 | Enforce recommended guardrails for SQL | DoNotEnforce |
| Enforce-GR-ServiceBus0 | Enforce recommended guardrails for Service Bus | DoNotEnforce |
| Enforce-GR-Storage0 | Enforce recommended guardrails for Storage | DoNotEnforce |
| Enforce-GR-Synapse0 | Enforce recommended guardrails for Synapse | DoNotEnforce |
| Enforce-GR-VirtualDesk0 | Enforce recommended guardrails for Virtual Desktop | DoNotEnforce |
| Enforce-Subnet-Private | Subnets should be private | DoNotEnforce |

### platform-connectivity — 1 Assignment(s)

| Assignment | Anzeigename | Enforcement |
|---|---|---|
| Enable-DDoS-VNET | Virtual networks should be protected by Azure DDoS Network Protection | Default |

### platform-identity — 4 Assignment(s)

| Assignment | Anzeigename | Enforcement |
|---|---|---|
| Deny-MgmtPorts-Internet | Management port access from the Internet should be blocked | Default |
| Deny-Public-IP | Deny the creation of public IP | Default |
| Deny-Subnet-Without-Nsg | Subnets should have a Network Security Group | Default |
| Deploy-VM-Backup | Configure backup on virtual machines without a given tag to a new recovery services vault with a default policy | Default |

### platform-management — 0 Assignment(s)

_keine eigenen Assignments (erbt von übergeordneter MG)_

### platform-security — 0 Assignment(s)

_keine eigenen Assignments (erbt von übergeordneter MG)_

### sandbox — 1 Assignment(s)

| Assignment | Anzeigename | Enforcement |
|---|---|---|
| Enforce-ALZ-Sandbox | Enforce ALZ Sandbox Guardrails | Default |

### decommissioned — 1 Assignment(s)

| Assignment | Anzeigename | Enforcement |
|---|---|---|
| Enforce-ALZ-Decomm | Enforce ALZ Decommissioned Guardrails | Default |


**Summe direkt zugewiesener Assignments: 123** (zzgl. Vererbung an Kind-MGs).

## 5. Governance – Policy-Definitionen (Custom)

**149** Custom-Policy-Definitionen werden via `loadJsonContent` aus `lib/alz/` geladen. Verteilung nach Kategorie:

| Kategorie | Anzahl |
|---|---|
| Monitoring | 55 |
| Network | 20 |
| Storage | 16 |
| SQL | 13 |
| App Service | 6 |
| Machine Learning | 6 |
| Cost Optimization | 4 |
| Budget | 3 |
| Cache | 3 |
| Cognitive Services | 3 |
| Databricks | 3 |
| Logic Apps | 3 |
| Event Hub | 2 |
| Tags | 2 |
| API Management | 1 |
| Automation | 1 |
| Compute | 1 |
| General | 1 |
| Guest Configuration | 1 |
| Key Vault | 1 |
| Kubernetes | 1 |
| Managed Identity | 1 |
| Networking | 1 |
| Security Center | 1 |


Vollständige Liste:

| Name | Anzeigename | Kategorie | Default-Effekt |
|---|---|---|---|
| Append-AppService-httpsonly | AppService append enable https only setting to enforce https setting. | App Service | Append |
| Append-AppService-latestTLS | AppService append sites with minimum TLS version to enforce. | App Service | Append |
| Append-KV-SoftDelete | KeyVault SoftDelete should be enabled | Key Vault | append |
| Append-Redis-disableNonSslPort | Azure Cache for Redis Append and the enforcement that enableNonSslPort is disabled. | Cache | Append |
| Append-Redis-sslEnforcement | Azure Cache for Redis Append a specific min TLS version requirement and enforce TLS. | Cache | Append |
| Audit-AKS-kubenet | Detect AKS clusters using kubenet network plugin | Kubernetes | Audit |
| Audit-AzureHybridBenefit | Audit AHUB for eligible VMs | Cost Optimization | Audit |
| Audit-Disks-UnusedResourcesCostOptimization | Unused Disks driving cost should be avoided | Cost Optimization | Audit |
| Audit-MachineLearning-PrivateEndpointId | Control private endpoint connections to Azure Machine Learning | Machine Learning | Audit |
| Audit-PrivateLinkDnsZones | Audit or Deny the creation of Private Link Private DNS Zones | Network | Audit |
| Audit-PublicIpAddresses-UnusedResourcesCostOptimization | Unused Public IP addresses driving cost should be avoided | Cost Optimization | Audit |
| Audit-ServerFarms-UnusedResourcesCostOptimization | Unused App Service plans driving cost should be avoided | Cost Optimization | Audit |
| Audit-Tags-Mandatory-Rg | Audit for mandatory tags on resource groups | Tags | Audit |
| Audit-Tags-Mandatory | Audit for mandatory tags on resources | Tags | Audit |
| Deny-AA-child-resources | No child resources in Automation Account | Automation | Deny |
| Deny-APIM-TLS | API Management services should use TLS version 1.2 | API Management | Deny |
| Deny-AppGW-Without-WAF | Application Gateway should be deployed with WAF enabled | Network | Deny |
| Deny-AppGw-Without-Tls | Application Gateway should be deployed with predefined Microsoft policy that is using TLS version 1.2 | Network | Deny |
| Deny-AppService-without-BYOC | App Service certificates must be stored in Key Vault | App Service | Audit |
| Deny-AppServiceApiApp-http | API App should only be accessible over HTTPS | App Service | Deny |
| Deny-AppServiceFunctionApp-http | Function App should only be accessible over HTTPS | App Service | Deny |
| Deny-AppServiceWebApp-http | Web Application should only be accessible over HTTPS | App Service | Deny |
| Deny-AzFw-Without-Policy | Azure Firewall should have a default Firewall Policy | Network | Deny |
| Deny-CognitiveServices-NetworkAcls | Network ACLs should be restricted for Cognitive Services | Cognitive Services | Deny |
| Deny-CognitiveServices-Resource-Kinds | Only explicit kinds for Cognitive Services should be allowed | Cognitive Services | Deny |
| Deny-CognitiveServices-RestrictOutboundNetworkAccess | Outbound network access should be restricted for Cognitive Services | Cognitive Services | Deny |
| Deny-Databricks-NoPublicIp | Deny public IPs for Databricks cluster | Databricks | Deny |
| Deny-Databricks-Sku | Deny non-premium Databricks sku | Databricks | Deny |
| Deny-Databricks-VirtualNetwork | Deny Databricks workspaces without Vnet injection | Databricks | Deny |
| Deny-EH-Premium-CMK | Event Hub namespaces (Premium) should use a customer-managed key for encryption | Event Hub | Deny |
| Deny-EH-minTLS | Event Hub namespaces should use a valid TLS version | Event Hub | Deny |
| Deny-FileServices-InsecureAuth | File Services with insecure authentication methods should be denied | Storage | Deny |
| Deny-FileServices-InsecureKerberos | File Services with insecure Kerberos ticket encryption should be denied | Storage | Deny |
| Deny-FileServices-InsecureSmbChannel | File Services with insecure SMB channel encryption should be denied | Storage | Deny |
| Deny-FileServices-InsecureSmbVersions | File Services with insecure SMB versions should be denied | Storage | Deny |
| Deny-LogicApp-Public-Network | Logic apps should disable public network access | Logic Apps | Deny |
| Deny-LogicApps-Without-Https | Logic app should only be accessible over HTTPS | Logic Apps | Deny |
| Deny-MachineLearning-Aks | Deny AKS cluster creation in Azure Machine Learning | Machine Learning | Deny |
| Deny-MachineLearning-Compute-SubnetId | Enforce subnet connectivity for Azure Machine Learning compute clusters and compute instances | Machine Learning | Deny |
| Deny-MachineLearning-Compute-VmSize | Limit allowed vm sizes for Azure Machine Learning compute clusters and compute instances | Budget | Deny |
| Deny-MachineLearning-ComputeCluster-RemoteLoginPortPublicAccess | Deny public access of Azure Machine Learning clusters via SSH | Machine Learning | Deny |
| Deny-MachineLearning-ComputeCluster-Scale | Enforce scale settings for Azure Machine Learning compute clusters | Budget | Deny |
| Deny-MachineLearning-HbiWorkspace | Enforces high business impact Azure Machine Learning Workspaces | Machine Learning | Deny |
| Deny-MachineLearning-PublicAccessWhenBehindVnet | Deny public access behind vnet to Azure Machine Learning workspace | Machine Learning | Deny |
| Deny-MgmtPorts-From-Internet | Management port access from the Internet should be blocked | Network | Deny |
| Deny-MySql-http | MySQL database servers enforce SSL connections. | SQL | Deny |
| Deny-PostgreSql-http | PostgreSQL database servers enforce SSL connection. | SQL | Deny |
| Deny-Private-DNS-Zones | Deny the creation of private DNS | Network | Deny |
| Deny-Redis-http | Azure Cache for Redis only secure connections should be enabled | Cache | Deny |
| Deny-Service-Endpoints | Deny or Audit service endpoints on subnets | Network | Deny |
| Deny-Sql-minTLS | Azure SQL Database should have the minimal TLS version set to the highest version | SQL | Audit |
| Deny-SqlMi-minTLS | SQL Managed Instance should have the minimal TLS version set to the highest version | SQL | Audit |
| Deny-Storage-ContainerDeleteRetentionPolicy | Storage Accounts should use a container delete retention policy | Storage | Deny |
| Deny-Storage-CopyScope | Allowed Copy scope should be restricted for Storage Accounts | Storage | Deny |
| Deny-Storage-CorsRules | Storage Accounts should restrict CORS rules | Storage | Deny |
| Deny-Storage-LocalUser | Local users should be restricted for Storage Accounts | Storage | Deny |
| Deny-Storage-NetworkAclsBypass | Network ACL bypass option should be restricted for Storage Accounts | Storage | Deny |
| Deny-Storage-NetworkAclsVirtualNetworkRules | Virtual network rules should be restricted for Storage Accounts | Storage | Deny |
| Deny-Storage-ResourceAccessRulesResourceId | Resource Access Rules resource IDs should be restricted for Storage Accounts | Storage | Deny |
| Deny-Storage-ResourceAccessRulesTenantId | Resource Access Rules Tenants should be restricted for Storage Accounts | Storage | Deny |
| Deny-Storage-SFTP | Storage Accounts with SFTP enabled should be denied | Storage | Deny |
| Deny-Storage-ServicesEncryption | Encryption for storage services should be enforced for Storage Accounts | Storage | Deny |
| Deny-StorageAccount-CustomDomain | Storage Accounts with custom domains assigned should be denied | Storage | Deny |
| Deny-Subnet-Without-Nsg | Subnets should have a Network Security Group | Network | Deny |
| Deny-Subnet-Without-Penp | Subnets without Private Endpoint Network Policies enabled should be denied | Network | Deny |
| Deny-Subnet-Without-Udr | Subnets should have a User Defined Route | Network | Deny |
| Deny-UDR-With-Specific-NextHop | User Defined Routes with 'Next Hop Type' set to 'Internet' or 'VirtualNetworkGateway' should be denied | Network | Deny |
| Deny-VNET-Peer-Cross-Sub | Deny vNet peering cross subscription. | Network | Deny |
| Deny-VNET-Peering-To-Non-Approved-VNETs | Deny vNet peering to non-approved vNets | Network | Deny |
| Deny-VNet-Peering | Deny vNet peering  | Network | Deny |
| DenyAction-ActivityLogs | DenyAction implementation on Activity Logs | Monitoring | denyAction |
| DenyAction-DeleteResources | Do not allow deletion of specified resource and resource type | General | DenyAction |
| DenyAction-DiagnosticLogs | DenyAction implementation on Diagnostic Logs. | Monitoring | denyAction |
| Deploy-ASC-SecurityContacts | Deploy Microsoft Defender for Cloud Security Contacts | Security Center | DeployIfNotExists |
| Deploy-Budget | Deploy a default budget on all subscriptions under the assigned scope | Budget | DeployIfNotExists |
| Deploy-Custom-Route-Table | Deploy a route table with specific user defined routes | Network | DeployIfNotExists |
| Deploy-DDoSProtection | Deploy an Azure DDoS Network Protection | Network | DeployIfNotExists |
| Deploy-Diagnostics-AA | [[Deprecated]: Deploy Diagnostic Settings for Automation to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-ACI | [[Deprecated]: Deploy Diagnostic Settings for Container Instances to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-ACR | [[Deprecated]: Deploy Diagnostic Settings for Container Registry to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-APIMgmt | [[Deprecated]: Deploy Diagnostic Settings for API Management to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-AVDScalingPlans | [[Deprecated]: Deploy Diagnostic Settings for AVD Scaling Plans to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-AnalysisService | [[Deprecated]: Deploy Diagnostic Settings for Analysis Services to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-ApiForFHIR | [[Deprecated]: Deploy Diagnostic Settings for Azure API for FHIR to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-ApplicationGateway | [[Deprecated]: Deploy Diagnostic Settings for Application Gateway to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-Bastion | [[Deprecated]: Deploy Diagnostic Settings for Azure Bastion to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-CDNEndpoints | [[Deprecated]: Deploy Diagnostic Settings for CDN Endpoint to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-CognitiveServices | [[Deprecated]: Deploy Diagnostic Settings for Cognitive Services to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-CosmosDB | [[Deprecated]: Deploy Diagnostic Settings for Cosmos DB to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-DLAnalytics | [[Deprecated]: Deploy Diagnostic Settings for Data Lake Analytics to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-DataExplorerCluster | [[Deprecated]: Deploy Diagnostic Settings for Azure Data Explorer Cluster to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-DataFactory | [[Deprecated]: Deploy Diagnostic Settings for Data Factory to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-Databricks | [[Deprecated]: Deploy Diagnostic Settings for Databricks to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-EventGridSub | [[Deprecated]: Deploy Diagnostic Settings for Event Grid subscriptions to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-EventGridSystemTopic | [[Deprecated]: Deploy Diagnostic Settings for Event Grid System Topic to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-EventGridTopic | [[Deprecated]: Deploy Diagnostic Settings for Event Grid Topic to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-ExpressRoute | [[Deprecated]: Deploy Diagnostic Settings for ExpressRoute to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-Firewall | [[Deprecated]: Deploy Diagnostic Settings for Firewall to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-FrontDoor | [[Deprecated]: Deploy Diagnostic Settings for Front Door to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-Function | [[Deprecated]: Deploy Diagnostic Settings for Azure Function App to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-HDInsight | [[Deprecated]: Deploy Diagnostic Settings for HDInsight to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-LoadBalancer | [[Deprecated]: Deploy Diagnostic Settings for Load Balancer to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-LogAnalytics | [[Deprecated]: Deploy Diagnostic Settings for Log Analytics to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-LogicAppsISE | [[Deprecated]: Deploy Diagnostic Settings for Logic Apps integration service environment to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-MariaDB | [[Deprecated] Diagnostic Settings for MariaDB to Log Analytics Workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-MediaService | [[Deprecated]: Deploy Diagnostic Settings for Azure Media Service to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-MlWorkspace | [[Deprecated]: Deploy Diagnostic Settings for Machine Learning workspace to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-MySQL | [[Deprecated]: Deploy Diagnostic Settings for Database for MySQL to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-NIC | [[Deprecated]: Deploy Diagnostic Settings for Network Interfaces to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-NetworkSecurityGroups | [[Deprecated]: Deploy Diagnostic Settings for Network Security Groups to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-PostgreSQL | [[Deprecated]: Deploy Diagnostic Settings for Database for PostgreSQL to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-PowerBIEmbedded | [[Deprecated]: Deploy Diagnostic Settings for Power BI Embedded to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-RedisCache | [[Deprecated]: Deploy Diagnostic Settings for Redis Cache to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-Relay | [[Deprecated]: Deploy Diagnostic Settings for Relay to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-SQLElasticPools | [[Deprecated]: Deploy Diagnostic Settings for SQL Elastic Pools to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-SQLMI | [[Deprecated]: Deploy Diagnostic Settings for SQL Managed Instances to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-SignalR | [[Deprecated]: Deploy Diagnostic Settings for SignalR to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-TimeSeriesInsights | [[Deprecated]: Deploy Diagnostic Settings for Time Series Insights to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-TrafficManager | [[Deprecated]: Deploy Diagnostic Settings for Traffic Manager to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-VM | [[Deprecated]: Deploy Diagnostic Settings for Virtual Machines to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-VMSS | [[Deprecated]: Deploy Diagnostic Settings for Virtual Machine Scale Sets to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-VNetGW | [[Deprecated]: Deploy Diagnostic Settings for VPN Gateway to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-VWanS2SVPNGW | [[Deprecated]: Deploy Diagnostic Settings for VWAN S2S VPN Gateway to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-VirtualNetwork | [[Deprecated]: Deploy Diagnostic Settings for Virtual Network to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-WVDAppGroup | [[Deprecated]: Deploy Diagnostic Settings for AVD Application group to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-WVDHostPools | [[Deprecated]: Deploy Diagnostic Settings for AVD Host Pools to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-WVDWorkspace | [[Deprecated]: Deploy Diagnostic Settings for AVD Workspace to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-WebServerFarm | [[Deprecated]: Deploy Diagnostic Settings for App Service Plan to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-Website | [[Deprecated]: Deploy Diagnostic Settings for App Service to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-Diagnostics-iotHub | [[Deprecated]: Deploy Diagnostic Settings for IoT Hub to Log Analytics workspace | Monitoring | DeployIfNotExists |
| Deploy-FirewallPolicy | Deploy Azure Firewall Manager policy in the subscription | Network | DeployIfNotExists |
| Deploy-LogicApp-TLS | Configure Logic apps to use the latest TLS version | Logic Apps | DeployIfNotExists |
| Deploy-MySQL-sslEnforcement | Azure Database for MySQL server deploy a specific min TLS version and enforce SSL. | SQL | DeployIfNotExists |
| Deploy-PostgreSQL-sslEnforcement | Azure Database for PostgreSQL server deploy a specific min TLS version requirement and enforce SSL  | SQL | DeployIfNotExists |
| Deploy-Private-DNS-Generic | Deploy-Private-DNS-Generic | Networking | DeployIfNotExists |
| Deploy-SQL-minTLS | SQL servers deploys a specific min TLS version requirement. | SQL | DeployIfNotExists |
| Deploy-Sql-AuditingSettings | Deploy SQL database auditing settings | SQL | DeployIfNotExists |
| Deploy-Sql-SecurityAlertPolicies | Deploy SQL Database security Alert Policies configuration with email admin accounts | SQL | DeployIfNotExists |
| Deploy-Sql-Tde | [[Deprecated] Deploy SQL Database Transparent Data Encryption | SQL | DeployIfNotExists |
| Deploy-Sql-vulnerabilityAssessments | [[Deprecated]: Deploy SQL Database vulnerability Assessments | SQL | DeployIfNotExists |
| Deploy-Sql-vulnerabilityAssessments_20230706 | Deploy SQL Database Vulnerability Assessments | SQL | DeployIfNotExists |
| Deploy-SqlMi-minTLS | SQL managed instances deploy a specific min TLS version requirement. | SQL | DeployIfNotExists |
| Deploy-Storage-sslEnforcement | Azure Storage deploy a specific min TLS version requirement and enforce SSL/HTTPS  | Storage | DeployIfNotExists |
| Deploy-UserAssignedManagedIdentity-VMInsights | [[Deprecated]: Deploy User Assigned Managed Identity for VM Insights | Managed Identity | DeployIfNotExists |
| Deploy-VNET-HubSpoke | Deploy Virtual Network with peering to the hub | Network | deployIfNotExists |
| Deploy-Vm-autoShutdown | Deploy Virtual Machine Auto Shutdown Schedule | Compute | deployIfNotExists |
| Deploy-Windows-DomainJoin | Deploy Windows Domain Join Extension with keyvault configuration | Guest Configuration | DeployIfNotExists |
| Modify-NSG | Enforce specific configuration of Network Security Groups (NSG) | Network | Modify |
| Modify-UDR | Enforce specific configuration of User-Defined Routes (UDR) | Network | Modify |

## 6. Governance – Initiativen (Policy-Set-Definitionen)

**42** Custom-Initiativen:

| Name | Anzeigename | Kategorie | # Policies |
|---|---|---|---|
| Audit-TrustedLaunch | Audit virtual machines for Trusted Launch support | Trusted Launch | 2 |
| Audit-UnusedResourcesCostOptimization | Unused resources driving cost should be avoided | Cost Optimization | 4 |
| Deny-PublicPaaSEndpoints | Public network access should be disabled for PaaS services | Network | 45 |
| DenyAction-DeleteProtection | DenyAction Delete - Activity Log Settings and Diagnostic Settings | Monitoring | 2 |
| Deploy-AUM-CheckUpdates | Configure periodic checking for missing system updates on azure virtual machines and Arc-enabled virtual machines | Security Center | 4 |
| Deploy-MDFC-Config_20240319 | Deploy Microsoft Defender for Cloud configuration | Security Center | 18 |
| Deploy-Private-DNS-Zones | Configure Azure PaaS services to use private DNS zones | Network | 59 |
| Deploy-Sql-Security_20240529 | Deploy SQL Database built-in SQL security configuration | SQL | 4 |
| Enforce-ACSB | Enforce Azure Compute Security Benchmark compliance auditing | Guest Configuration | 5 |
| Enforce-ALZ-Decomm | Enforce policies in the Decommissioned Landing Zone | Decommissioned | 2 |
| Enforce-ALZ-Sandbox | Enforce policies in the Sandbox Landing Zone | Sandbox | 2 |
| Enforce-Backup | Enforce enhanced recovery and backup policies | Backup | 6 |
| Enforce-EncryptTransit_20240509 | [[[Deprecated]: Deny or Deploy and append TLS requirements and SSL enforcement on resources without Encryption in transit | Encryption | 38 |
| Enforce-EncryptTransit_20241211 | Deny or Deploy and append TLS requirements and SSL enforcement on resources without Encryption in transit | Encryption | 37 |
| Enforce-Encryption-CMK_20250218 | Deny or Audit resources without Encryption with a customer-managed key (CMK) | Encryption | 31 |
| Enforce-Guardrails-APIM | Enforce recommended guardrails for API Management | API Management | 11 |
| Enforce-Guardrails-AppServices | Enforce recommended guardrails for App Service | App Service | 19 |
| Enforce-Guardrails-Automation | Enforce recommended guardrails for Automation Account | Automation | 6 |
| Enforce-Guardrails-BotService | Enforce recommended guardrails for Bot Service | Bot Service | 4 |
| Enforce-Guardrails-CognitiveServices | Enforce recommended guardrails for Cognitive Services | Cognitive Services | 9 |
| Enforce-Guardrails-Compute | Enforce recommended guardrails for Compute | Compute | 2 |
| Enforce-Guardrails-ContainerApps | Enforce recommended guardrails for Container Apps | Container Apps | 2 |
| Enforce-Guardrails-ContainerInstance | Enforce recommended guardrails for Container Instance | Container Instances | 1 |
| Enforce-Guardrails-ContainerRegistry | Enforce recommended guardrails for Container Registry | Container Registry | 12 |
| Enforce-Guardrails-CosmosDb | Enforce recommended guardrails for Cosmos DB | Cosmos DB | 6 |
| Enforce-Guardrails-DataExplorer | Enforce recommended guardrails for Data Explorer | Azure Data Explorer | 4 |
| Enforce-Guardrails-DataFactory | Enforce recommended guardrails for Data Factory | Data Factory | 5 |
| Enforce-Guardrails-EventGrid | Enforce recommended guardrails for Event Grid | Event Grid | 8 |
| Enforce-Guardrails-EventHub | Enforce recommended guardrails for Event Hub | Event Hub | 4 |
| Enforce-Guardrails-KeyVault-Sup | Enforce additional recommended guardrails for Key Vault | Key Vault | 2 |
| Enforce-Guardrails-KeyVault_20260203 | Enforce recommended guardrails for Azure Key Vault | Key Vault | 29 |
| Enforce-Guardrails-Kubernetes | Enforce recommended guardrails for Kubernetes | Kubernetes | 17 |
| Enforce-Guardrails-MachineLearning | Enforce recommended guardrails for Machine Learning | Machine Learning | 14 |
| Enforce-Guardrails-MySQL | Enforce recommended guardrails for MySQL | MySQL | 2 |
| Enforce-Guardrails-Network_20250326 | Enforce recommended guardrails for Network and Networking services | Network | 17 |
| Enforce-Guardrails-OpenAI | Enforce recommended guardrails for Open AI (Cognitive Service) | Cognitive Services | 11 |
| Enforce-Guardrails-PostgreSQL | Enforce recommended guardrails for PostgreSQL | PostgreSQL | 1 |
| Enforce-Guardrails-SQL | Enforce recommended guardrails for SQL and SQL Managed Instance | SQL | 7 |
| Enforce-Guardrails-ServiceBus | Enforce recommended guardrails for Service Bus | Service Bus | 4 |
| Enforce-Guardrails-Storage | Enforce recommended guardrails for Storage Account | Storage | 22 |
| Enforce-Guardrails-Synapse | Enforce recommended guardrails for Synapse workspaces | Synapse | 9 |
| Enforce-Guardrails-VirtualDesktop | Enforce recommended guardrails for Virtual Desktop | Desktop Virtualization | 2 |

## 7. Governance – Custom Role-Definitionen

**5** Custom-Rollen:

| Rolle | Beschreibung | # Actions |
|---|---|---|
| Subscription-Owner (alz) | Delegated role for subscription owner generated from subscription Owner role | 1 |
| Security-Operations (alz) | Security Administrator role with a horizontal view across the entire Azure estat | 12 |
| Network-Management (alz) | Platform-wide global connectivity management: virtual networks, UDRs, NSGs, NVAs | 4 |
| Application-Owners (alz) | Contributor role granted for application/operations team at resource group level | 1 |
| Network-Subnet-Contributor (alz) | Enterprise-scale custom Role Definition. Grants full access to manage Virtual Ne | 8 |

## 8. Logging-Ressourcen (Management-Subscription)

| Ressource | Name / Konvention | AVM-Modul |
|---|---|---|
| Resource Group | rg-alz-logging-<region> | avm/res/resources/resource-group:0.4.3 |
| Log Analytics Workspace | law-alz-<region> (PerGB2018, 365 Tage Retention) | avm/res/operational-insights/workspace:0.14.2 |
| LAW Solution | ChangeTracking | (im Workspace) |
| User-Assigned Managed Identity | mi-alz-<region> | avm/ptn/alz/ama:0.2.0 |
| Data Collection Rule – VM Insights | dcr-vmi-alz-<region> | avm/ptn/alz/ama:0.2.0 |
| Data Collection Rule – Change Tracking | dcr-ct-alz-<region> | avm/ptn/alz/ama:0.2.0 |
| Data Collection Rule – Defender SQL | dcr-mdfcsql-alz-<region> | avm/ptn/alz/ama:0.2.0 |
| Automation Account (optional, default aus) | aa-alz-<region> (Basic) | avm/res/automation/automation-account:0.17.1 |

## 9. Hub-Networking-Ressourcen (Connectivity-Subscription)

Zwei Hub-VNets, bidirektional gepeert: **Hub 1** `10.0.0.0/22` (primär), **Hub 2** `10.1.0.0/22` (sekundär). Resource Group `rg-alz-conn-<region>`.

### Subnetze je Hub

| Subnetz | Hub 1 (primär) | Hub 2 (sekundär) |
|---|---|---|
| AzureFirewallSubnet | 10.0.0.0/26 | 10.1.0.0/26 |
| AzureFirewallManagementSubnet | 10.0.0.192/26 | 10.1.0.192/26 |
| AzureBastionSubnet | 10.0.0.64/26 | 10.1.0.64/26 |
| GatewaySubnet | 10.0.0.128/27 | 10.1.0.128/27 |
| DNSPrivateResolverInboundSubnet | 10.0.0.160/28 | 10.1.0.160/28 |
| DNSPrivateResolverOutboundSubnet | 10.0.0.176/28 | 10.1.0.176/28 |

### Dienste & Default-Schalter (Microsoft-Standard)

| Dienst | Schalter | Hub 1 Default | Hub 2 Default | Kosten |
|---|---|---|---|---|
| Azure Firewall (Standard) | deployAzureFirewall | true | true | ~€1.100/Hub/Monat |
| Azure Bastion (Standard) | deployBastion | true | true | ~€120/Hub/Monat |
| VPN Gateway (VpnGw1AZ, activeActiveBgp, ASN 65515) | deployVpnGateway | true | true | ~€140/Hub/Monat |
| ExpressRoute Gateway | deployExpressRouteGateway | true | true | ~€280/Hub/Monat |
| DDoS Network Protection | deployDdosProtectionPlan | true | false | ~€2.500/Monat (nur Hub 1) |
| Private DNS Zones | deployPrivateDnsZones | true | true | ~€15/Monat |
| DNS Private Resolver | deployDnsPrivateResolver | true | true | ~€25/Hub/Monat |

> ⚠️ **Alle Dienste sind im Microsoft-Default aktiviert** (Summe ≈ €5.800/Monat). Für kostenarme Rollouts siehe `docs/ACCELERATOR-BOOTSTRAP.md` (kostenarme Variante).

## 10. Virtual WAN (Alternative zu Hub-and-Spoke)

Aktiv nur bei `network_type: vwanConnectivity`. Ressourcen: Virtual WAN (`vwan-alz-<region>`, Standard), Virtual Hub (`vhub-alz-<region>`, `10.0.0.0/22`), Azure Firewall, ExpressRoute Gateway (default an), S2S/P2S VPN Gateway (default aus). Module: `avm/res/network/virtual-wan:0.4.3`, `virtual-hub:0.4.3`.
