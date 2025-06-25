module "avm-res-machinelearningservices-workspace_example_private_managed_vnet" {
  source  = "Azure/avm-res-machinelearningservices-workspace/azurerm//examples/private_managed_vnet"
  version = "0.7.0"

  location            = local.location
  name                = module.naming.machine_learning_workspace.name
  resource_group_name = module.avm-res-resources-resourcegroup.name
  application_insights = {
    resource_id = module.avm_res_insights_component.resource_id
  }
  container_registry = {
    resource_id = module.avm_res_containerregistry_registry.resource_id
  }
  enable_telemetry = false
  is_private       = true
  key_vault = {
    resource_id = module.avm_res_keyvault_vault.resource_id
  }
  storage_account = {
    resource_id = module.avm_res_storage_storageaccount.resource_id
  }
  tags                    = local.tags
  workspace_description   = "A private AML workspace"
  workspace_friendly_name = "private-aml-workspace"
  workspace_managed_network = {
    isolation_mode = "AllowInternetOutbound"
  }
}