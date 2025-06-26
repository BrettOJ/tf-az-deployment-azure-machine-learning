module "avm-res-network-virtualnetwork" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  address_space       = ["192.168.0.0/24"]
  location            = local.location
  name                = module.naming.virtual_network.name
  resource_group_name = module.avm-res-resources-resourcegroup.name
  subnets = {
    private-endpoints = {
      name             = "private-endpoints"
      address_prefixes = ["192.168.0.0/26"]
    }
  }
}

module "private_dns_zone_aml_api" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.2"

  domain_name         = "privatelink.api.azureml.ms"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  virtual_network_links = {
    vnetlink1 = {
      vnetlinkname = "privatelink-api-azureml"
      vnetid       = module.avm-res-network-virtualnetwork.resource_id
    }
  }
}

module "private_dns_zone_notebooks" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.2"

  domain_name         = "privatelink.notebooks.azure.net"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  virtual_network_links = {
    vnetlink1 = {
      vnetlinkname = "privatelink-notebooks-azureml"
      vnetid       = module.avm-res-network-virtualnetwork.resource_id
    }
  }
}

module "private_dns_zone_acr" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.2"

  domain_name         = "privatelink.azurecr.io"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  virtual_network_links = {
    vnetlink1 = {
      vnetlinkname = "container-registry"
      vnetid       = module.avm-res-network-virtualnetwork.resource_id
    }
  }
}

module "private_dns_zone_blob" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.2"

  domain_name         = "privatelink.blob.core.windows.net"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  virtual_network_links = {
    vnetlink1 = {
      vnetlinkname = "storage-account-blob"
      vnetid       = module.avm-res-network-virtualnetwork.resource_id
    }
  }
}

module "private_dns_zone_file" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.2"

  domain_name         = "privatelink.file.core.windows.net"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  virtual_network_links = {
    vnetlink1 = {
      vnetlinkname = "storage-account-file"
      vnetid       = module.avm-res-network-virtualnetwork.resource_id
    }
  }
}


module "private_dns_zone_akv" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.2"

  domain_name         = "privatelink.vaultcore.azure.net"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  virtual_network_links = {
    vnetlink1 = {
      vnetlinkname = "key-vault"
      vnetid       = module.avm-res-network-virtualnetwork.resource_id
    }
  }
}


module "private_dns_monitor" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "~> 0.2"

  domain_name         = "privatelink.monitor.azure.com"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink.monitor.azure.com"
      vnetid       = module.avm-res-network-virtualnetwork.resource_id
    }
  }
}

module "private_dns_oms_opinsights" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "~> 0.2"

  domain_name         = "privatelink.oms.opinsights.azure.com"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink.oms.opinsights.azure.com"
      vnetid       = module.avm-res-network-virtualnetwork.resource_id
    }
  }
}

module "private_dns_ods_opinsights" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "~> 0.2"

  domain_name         = "privatelink.ods.opinsights.azure.com"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink.ods.opinsights.azure.com"
      vnetid       = module.avm-res-network-virtualnetwork.resource_id
    }
  }
}

module "private_dns_agentsvc" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "~> 0.2"

  domain_name         = "privatelink.agentsvc.azure-automation.net"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink.agentsvc.azure-automation.net"
      vnetid       = module.avm-res-network-virtualnetwork.resource_id
    }
  }
}

resource "azurerm_monitor_private_link_scope" "ampls" {
  name                  = "example-ampls"
  resource_group_name   = module.avm-res-resources-resourcegroup.name
  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "PrivateOnly"
}

resource "azurerm_private_endpoint" "privatelinkscope" {
  location            = local.location
  name                = "pe-azuremonitor"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  subnet_id           = module.avm-res-network-virtualnetwork.subnets["private-endpoints"].resource_id
  tags                = local.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = "psc-azuremonitor"
    private_connection_resource_id = azurerm_monitor_private_link_scope.ampls.id
    subresource_names              = ["azuremonitor"]
  }
  private_dns_zone_group {
    name = "azuremonitor-dns-zone-group"
    private_dns_zone_ids = [
        module.private_dns_monitor.resource_id
    ]
  }
  depends_on = [
    module.avm-res-network-virtualnetwork,
    module.avm-res-resources-resourcegroup,
    azurerm_monitor_private_link_scoped_service.law,
    azurerm_monitor_private_link_scoped_service.appinsights
  ]
}

resource "azurerm_monitor_private_link_scoped_service" "law" {
  linked_resource_id  = module.avm_res_log_analytics_workspace.resource_id
  name                = "privatelinkscopedservice.loganalytics"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  scope_name          = azurerm_monitor_private_link_scope.ampls.name
}

resource "azurerm_monitor_private_link_scoped_service" "appinsights" {
  linked_resource_id  = module.avm_res_insights_component.resource_id
  name                = "privatelinkscopedservice.appinsights"
  resource_group_name =  module.avm-res-resources-resourcegroup.name
  scope_name          = azurerm_monitor_private_link_scope.ampls.name
}