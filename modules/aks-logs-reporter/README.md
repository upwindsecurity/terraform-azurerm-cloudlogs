# AKS Logs Reporter Module

This Terraform module creates the Azure infrastructure needed to stream AKS Kubernetes audit logs to Upwind via Azure
Event Hubs. It provisions one Event Hub stack per Azure region (auto-detected from AKS cluster locations or explicitly
specified), a shared Service Principal, and a Key Vault for storing credentials. Optionally, it configures AKS
diagnostic settings to route logs from each cluster to the Event Hub in its region.

## Usage

### Basic Usage — AKS Cluster with Auto-Detected Region

```hcl
module "upwind_aks_logs_reporter" {
  source = "upwindsecurity/cloudlogs/azurerm//modules/aks-logs-reporter"

  tenant_id                              = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id         = "87654321-4321-4321-4321-210987654321"
  onboarding_service_principal_client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  infrastructure_region                  = "eastus"

  aks_cluster_ids = [
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/my-rg/providers/Microsoft.ContainerService/managedClusters/my-aks",
  ]

  create_diagnostic_settings = true
}
```

### Explicit Regions — No AKS Cluster Access Required

Use when cross-subscription AKS data-source access is unavailable, or to pre-provision infrastructure before clusters
exist.

```hcl
module "upwind_aks_logs_reporter" {
  source = "upwindsecurity/cloudlogs/azurerm//modules/aks-logs-reporter"

  tenant_id                              = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id         = "87654321-4321-4321-4321-210987654321"
  onboarding_service_principal_client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  infrastructure_region                  = "eastus"

  regions = ["eastus", "westeurope"]

  create_diagnostic_settings = false
}
```

### Multi-Region — Clusters Across Several Regions

The module auto-detects each cluster's region and creates one Event Hub stack per unique region.

```hcl
module "upwind_aks_logs_reporter" {
  source = "upwindsecurity/cloudlogs/azurerm//modules/aks-logs-reporter"

  tenant_id                              = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id         = "87654321-4321-4321-4321-210987654321"
  onboarding_service_principal_client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  infrastructure_region                  = "eastus"

  aks_cluster_ids = [
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-eastus/providers/Microsoft.ContainerService/managedClusters/aks-prod-eastus",
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-westeurope/providers/Microsoft.ContainerService/managedClusters/aks-prod-westeurope",
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-southeastasia/providers/Microsoft.ContainerService/managedClusters/aks-prod-southeastasia",
  ]

  create_diagnostic_settings = true
  log_categories             = ["kube-audit", "kube-audit-admin"]
}
```

## Region Selection

The module determines which regions to deploy Event Hub infrastructure into using the following logic:

- **Auto-detection**: When `aks_cluster_ids` is provided, the module reads each cluster's location and deploys one
  Event Hub stack per unique region.
- **Explicit regions**: When `regions` is provided, Event Hub stacks are created in those regions directly — no AKS
  cluster access needed.
- **Combined**: Both can be used together; the union of detected and explicit regions is used.

At least one of `aks_cluster_ids` or `regions` must be non-empty.

## Diagnostic Settings

Setting `create_diagnostic_settings = true` (requires `aks_cluster_ids` to be non-empty) will create
`azurerm_monitor_diagnostic_setting` resources on each AKS cluster, routing its logs to the Event Hub deployed in the
same region. If you prefer to manage diagnostic settings separately, set `create_diagnostic_settings = false` and use
the `eventhub_by_region` output to configure them.

## Examples

See the [examples](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/) directory:

- **[aks-logs-reporter-basic](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/aks-logs-reporter-basic/)**:
  Single cluster with auto-detected region and diagnostic settings
- **[aks-logs-reporter-regions](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/aks-logs-reporter-regions/)**:
  Explicit regions without AKS cluster access
- **[aks-logs-reporter-multi-region](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/aks-logs-reporter-multi-region/)**:
  Multiple clusters spread across several Azure regions

## Prerequisites

- Azure subscription with appropriate permissions
- Azure AD tenant access
- Terraform >= 1.9
- Azure CLI or service principal authentication

## Permissions Required

- **Subscription level**: `Contributor` or `Owner` on the infrastructure subscription
- **Azure AD level**: `Application Administrator` or `Cloud Application Administrator`
- **AKS clusters** (when using `aks_cluster_ids`): read access (`Reader`) to each cluster

> **Note:** The `Monitoring Reader` role is granted on the infrastructure subscription only.
> If AKS clusters reside in other subscriptions, you must manually grant `Monitoring Reader`
> to the integration service principal in each of those subscriptions.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
