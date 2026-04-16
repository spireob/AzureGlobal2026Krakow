terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">4.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
provider "azurerm" {
  subscription_id = "4c569ea4-8bfc-4063-9557-390e4b28a153"
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-user7" #change here
    storage_account_name = "rguser7sta01" #change here
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
