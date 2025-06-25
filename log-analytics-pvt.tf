module "avm_res_log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "~> 0.4"

  location            = local.location
  name                = module.naming.log_analytics_workspace.name
  resource_group_name = module.avm-res-resources-resourcegroup.name
  enable_telemetry    = false
  log_analytics_workspace_identity = {
    type = "SystemAssigned"
  }
  log_analytics_workspace_internet_ingestion_enabled = false
  log_analytics_workspace_internet_query_enabled     = true
  tags                                               = local.tags
}