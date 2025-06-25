locals {
  location = "southeastasia"

  tags = {
        environment = "dev"
        created-by = "Terraform"
    }
}

data "azurerm_client_config" "current" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
  suffix = [ "boj", "test" ]
 
}

module "avm-res-resources-resourcegroup" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"
  name     = module.naming.resource_group_name
  location = local.location
  tags = local.tags
}