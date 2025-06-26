module "avm_res_insights_component" {
  source  = "Azure/avm-res-insights-component/azurerm"
  version = "~> 0.1"

  location                   = local.location
  name                       = module.naming.application_insights.name
  resource_group_name        = module.avm-res-resources-resourcegroup.name
  workspace_id               = module.avm_res_log_analytics_workspace.resource_id
  internet_ingestion_enabled = false
  internet_query_enabled     = true
  tags                       = local.tags
}