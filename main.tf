locals {
    umi_name = "rg-user7-umi"
    resource_group = "rg-user7"
    location = "polandcentral"
    tags = {
        owner = "user7"
    }
    
    acr_name = "rguser7acr"
    keyvault_name = "rg-user7-kv"
    sql_server_name = "rg-user7-sql"
}
resource "azurerm_resource_group" "rg" {
  name = "${local.resource_group}"
  location = "${local.location}"
}

module "umi" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git//managed_identity"
  name = local.umi_name
  resource_group = {
    name = "${local.resource_group}"
    location = "${local.location}"
  }
  tags = local.tags

}


module "acr" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git//container_registry"
  container_registry_name = local.acr_name
  resource_group = {
    name = "${local.resource_group}"
    location = "${local.location}"
  }
  tags = local.tags
}


module "keyvault" {
  #source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=keyvault/v1.0.0"
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git//keyvault"
  # also any inputs for the module (see below)
  keyvault_name = local.keyvault_name
  resource_group = {
    name = "${local.resource_group}"
    location = "${local.location}"
  }

  permissions =[]
  
  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
  }

  tags = local.tags
}


module "mssql_server" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=mssql_server/v1.0.0"
  # also any inputs for the module (see below)
  resource_group = {
    name = "${local.resource_group}"
    location = "${local.location}"
  }
  sql_server_admin = "sqladmin"
  sql_server_name = local.sql_server_name
  sql_server_version = "12.0"

}
