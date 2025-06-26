module "avm-res-containerregistry-registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.4.0"
  name                          = module.naming.container_registry.name
  location                      = local.location
  resource_group_name           = module.avm-res-resources-resourcegroup.name
  public_network_access_enabled = false
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [module.private_dns_zone_acr.resource_id]
      subnet_resource_id            = module.avm-res-network-virtualnetwork.subnets["private-endpoints"].resource_id
    }
  }
  depends_on = [ module.avm-res-network-virtualnetwork, 
                 module.avm-res-resources-resourcegroup, 
                 module.private_dns_zone_acr ]
}