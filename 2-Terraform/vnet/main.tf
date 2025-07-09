terraform {
  required_version = ">= 1.9.6"
  backend "azurerm" {
    resource_group_name  = "rg-devops-proj"
    storage_account_name = "devopsprojst"
    container_name       = "tfstate"
    key                  = "vnet-terraform.tfstate"
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

# Create a Virtual Network
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.name}-vnet"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  address_space       = [var.network_address_space]

  tags = var.tags
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_address_name
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.aks_subnet_address_prefix]
}

resource "azurerm_subnet" "app_gwsubnet" {
  name                 = var.subnet_address_name
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.subnet_address_prefix]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ServiceNetworking/trafficControllers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Create an NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "aks_subnet" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "app_gwsubnet" {
  subnet_id                 = azurerm_subnet.app_gwsubnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create application load balancer for containers
resource "azurerm_application_load_balancer" "alb" {
  name                = "${var.name}-alb"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  tags = var.tags
}

resource "azurerm_application_load_balancer_subnet_association" "alb" {
  name                         = "alb-subnet-association"
  application_load_balancer_id = azurerm_application_load_balancer.alb.id
  subnet_id                    = azurerm_subnet.app_gwsubnet.id
}

resource "azurerm_application_load_balancer_frontend" "alb_frontend" {
  name                         = "alb-frontend"
  application_load_balancer_id = azurerm_application_load_balancer.alb.id
}