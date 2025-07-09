terraform {
  required_version = ">= 1.9.6"
  backend "azurerm" {
    resource_group_name  = "rg-devops-proj"
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

# Configure the Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create a Resource Group
resource "azurerm_resource_group" "acr_rg" {
  name     = var.rgname
  location = var.location
  tags     = var.tags
}

# Create an Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "${var.name}azurecr"
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = var.tags
}