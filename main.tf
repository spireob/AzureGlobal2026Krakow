locals {
    umi_name = "rg-user7-umi"
    resource_group = "rg-user7"
    location = "polandcentral"
    tags = {
        owner = "user7"
    }
    
    acr_name = "rguser7acr"
    keyvault_name = "rg-user7-kv"
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

  network_acls = {
    principal_id = module.umi.managed_identity_client_id
    role_definition_name = "Key Vault Administrator"
    skip_service_principal_aad_check = true
  }

  # list(object({
  #   principal_id                     = string
  #   role_definition_name             = string
  #   skip_service_principal_aad_check = optional(bool, false)
  # }))
  tags = local.tags
}
