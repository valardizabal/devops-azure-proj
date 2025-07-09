terraform {
  required_version = ">= 1.9.6"
  backend "azurerm" {
    resource_group_name  = "rg-devops-proj"
    storage_account_name = "devopsprojst"
    container_name       = "tfstate"
    key                  = "la-terraform.tfstate"
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
  subscription_id = var.subscription_id

}

data "azurerm_resource_group" "resource_group" {
  name = var.rgname
}

resource "azurerm_log_analytics_workspace" "Log_Analytics_WorkSpace" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.name}-la"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  sku                 = "PerGB2018"

  tags = var.tags

}

resource "azurerm_log_analytics_solution" "Log_Analytics_Solution_ContainerInsights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.location
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  workspace_resource_id = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.id
  workspace_name        = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}