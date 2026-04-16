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
    application_insights_name = "rg-user7-applins"
    log_analytics_name = "rg-user7-la"
    app_service_plan_name = "rg-user7-asp"
    app_service_name = "rg-user7-aps"

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


# module "acr" {
#   source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git//container_registry"
#   container_registry_name = local.acr_name
#   resource_group = {
#     name = "${local.resource_group}"
#     location = "${local.location}"
#   }
#   tags = local.tags
# }


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
  databases = [{
    name                 = "appdata"
    size                 = 2
    sku                  = "S0"
    storage_account_type = "Local"
    collation            = "SQL_Latin1_General_CP1_CI_AS"
  }]
}


module "application_insights" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=application_insights/v1.0.0"
  # also any inputs for the module (see below)
  application_insights_name = local.application_insights_name
  log_analytics_name = local.log_analytics_name
  resource_group = {
    name = "${local.resource_group}"
    location = "${local.location}"
  }
}


module "service_plan" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=service_plan/v2.0.0"
  # also any inputs for the module (see below)
  app_service_plan_name = local.app_service_plan_name
  resource_group = {
    name = "${local.resource_group}"
    location = "${local.location}"
  }
  sku_name = "B1"
  tags = local.tags 

}


module "app_service" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=app_service/v1.0.0"
  # also any inputs for the module (see below)
  app_service_name = local.app_service_name
  app_service_plan_id = module.service_plan.app_service_plan.id
  app_settings = {

  }
  identity_client_id = module.umi.managed_identity_client_id
  identity_id = module.umi.managed_identity_id
  resource_group = {
    name = "${local.resource_group}"
    location = "${local.location}"
  }
}


