module "avm-res-keyvault-vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.0"
  name                          = module.naming.key_vault.name
  enable_telemetry              = false
  location                      = local.location
  resource_group_name           = module.avm-res-resources-resourcegroup.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = false
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [module.private_dns_zone_akc.resource_id]
      subnet_resource_id            = module.avm-res-network-virtualnetwork.subnets["subnet1"].id
    }
  }
}