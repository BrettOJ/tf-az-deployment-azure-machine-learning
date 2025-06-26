resource "azurerm_user_assigned_identity" "azml_msi" {
  location            = local.location
  resource_group_name = module.avm-res-resources-resourcegroup.name
  name                = "azml-boj-test-msi"
  tags                = local.tags
}

module "avm-res-machinelearningservices-workspace" {
  source  = "Azure/avm-res-machinelearningservices-workspace/azurerm"
  version = "0.7.0"
  location            = local.location
  name                = module.naming.machine_learning_workspace.name
  resource_group_name = module.avm-res-resources-resourcegroup.name
  application_insights = {
    resource_id = module.avm_res_insights_component.resource_id
  }
  container_registry = {
    resource_id = module.avm-res-containerregistry-registry.resource_id
  }
  enable_telemetry = false
  ip_allowlist = ["151.192.158.82/32"]
  is_private       = true
  key_vault = {
    resource_id = module.avm-res-keyvault-vault.resource_id
  }
  managed_identities = {
    system_assigned = false
    user_assigned = [azurerm_user_assigned_identity.azml_msi.id]
  }
    private_endpoints = {
    api = {
      name                          = "pe-api-aml"
      subnet_resource_id            = module.avm-res-network-virtualnetwork.subnets["private-endpoints"].resource_id
      private_dns_zone_resource_ids = [module.private_dns_zone_aml_api.resource_id]
      inherit_lock                  = false
    }
    notebooks = {
      name                          = "pe-notebooks-aml"
      subnet_resource_id            = module.avm-res-network-virtualnetwork.subnets["private-endpoints"].resource_id
      private_dns_zone_resource_ids = [module.private_dns_zone_notebooks.resource_id]
      inherit_lock                  = false
    }
  }
  storage_account = {
    resource_id = module.avm_res_storage_storageaccount.resource_id
  }
  tags                    = local.tags
  workspace_description   = "A private AML workspace"
  workspace_friendly_name = "private-aml-workspace"
  workspace_managed_network = {
    isolation_mode = "Disabled"
  }
  depends_on = [ module.avm-res-resources-resourcegroup, 
                 module.avm-res-network-virtualnetwork, 
                 module.avm-res-containerregistry-registry, 
                 module.avm-res-keyvault-vault, 
                 module.avm_res_log_analytics_workspace, 
                 module.avm_res_storage_storageaccount, 
                 module.avm_res_insights_component,
                 azurerm_user_assigned_identity.azml_msi ]
}

resource "azurerm_role_assignment" "rg-aienca" {
  scope                = module.avm-res-resources-resourcegroup.resource_id
  role_definition_name = "Azure AI Enterprise Network Connection Approver"
  principal_id         = module.avm-res-machinelearningservices-workspace.workspace_identity.principal_id
  depends_on = [
    module.avm-res-machinelearningservices-workspace
  ]
}

/*
resource "azapi_resource" "privateds-file" {
  type = "Microsoft.MachineLearningServices/workspaces/datastores@2025-01-01-preview"
  name      = "privateds_file"
  parent_id = module.avm-res-machinelearningservices-workspace.resource_id
  body = {
    properties = {
      credentials = {
        credentialsType = "None"
      }
      description = "Custom private file datastore"
      fileShareName = "boj-test-privateds-file"
      accountName   = module.avm_res_storage_storageaccount.name
      tags = local.tags
      datastoreType = "AzureFile"
      endpoint = "core.windows.net"
      protocol = "https"
      resourceGroup = module.avm-res-resources-resourcegroup.name
      serviceDataAccessAuthIdentity = "WorkspaceUserAssignedIdentity"
      subscriptionId = data.azurerm_client_config.current.subscription_id
    }
  }
  depends_on = [
    module.avm-res-machinelearningservices-workspace,
    module.avm-res-resources-resourcegroup,
    module.avm_res_storage_storageaccount
  ]
}
*/