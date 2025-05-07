terraform {
  required_version = ">= 1.9.6"
  backend "azurerm" {
    resource_group_name  = "devops-proj-rg"
    storage_account_name = "devopsprojst"
    container_name       = "tfstate"
    key                  = "acr-terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "8c6f346b-200d-4475-99b4-d26874174cbd"

}

resource "azurerm_container_registry" "acr" {
  name                = "${var.name}azurecr"
  resource_group_name = var.rgname
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false

  tags = var.tags

}