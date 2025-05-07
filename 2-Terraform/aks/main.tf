terraform {
  required_version = ">= 1.9.6"
  backend "azurerm" {
    resource_group_name  = "devops-proj-rg"
    storage_account_name = "devopsprojst"
    container_name       = "tfstate"
    key                  = "aks-terraform.tfstate"
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

data "azurerm_resource_group" "resource_group" {
  name = var.rgname
}

data "azurerm_subnet" "akssubnet" {
  name                 = "aks"
  virtual_network_name = "${var.name}-vnet"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}

data "azurerm_subnet" "appgwsubnet" {
  name                 = "appgw"
  virtual_network_name = "${var.name}-vnet"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}

data "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.name}-vl-la"
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

data "azurerm_container_registry" "acr" {
  name                = "${var.name}azurecr"
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.k8s.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

# create Azure Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                      = "${var.name}aks"
  location                  = var.location
  resource_group_name       = data.azurerm_resource_group.resource_group.name
  dns_prefix                = "${var.name}dns"
  kubernetes_version        = var.kubernetes_version
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  node_resource_group       = "${var.name}-node-rg"

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  default_node_pool {
    name                 = "agentpool"
    node_count           = var.agent_count
    vm_size              = var.vm_size
    vnet_subnet_id       = data.azurerm_subnet.akssubnet.id
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.workspace.id
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = false
    admin_group_object_ids = [var.aks_admins_group_object_id]
  }

  tags = var.tags

}

# Create Managed Identity for ALB
resource "azurerm_user_assigned_identity" "alb_identity" {
  location            = var.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  name                = "azure-alb-identity"
}

resource "azurerm_federated_identity_credential" "alb_federated_identity" {
  name                = "azure-alb-identity"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.alb_identity.id
  subject             = "system:serviceaccount:azure-alb-system:alb-controller-sa"

  depends_on = [
    azurerm_user_assigned_identity.alb_identity,
    azurerm_kubernetes_cluster.k8s

  ]
}

# RBAC
resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "acrpull"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

#fixing for  "The client '62119122-6287-4620-98b4-bf86535e2ece' with object id '62119122-6287-4620-98b4-bf86535e2ece' does not have authorization to perform action 'Microsoft.ServiceNetworking/register/action' over scope '/subscriptions/XXXXX' or the scope is invalid. (As part of App Gw for containers - maanged by ALB controller setup)"

# Delegate AppGw for Containers Configuration Manager role to RG containing Application Gateway for Containers resource
# az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $resourceGroupId --role "fbc52c3f-28ad-4303-a892-8a056630b8f1" 
# resource "azurerm_role_assignment" "appgwcontainerfix2" {
#   principal_id         = azurerm_user_assigned_identity.alb_identity.principal_id
#   scope                = data.azurerm_resource_group.resource_group.id
#   role_definition_name = "AppGw for Containers Configuration Manager"
#   depends_on = [
#     azurerm_kubernetes_cluster.k8s,
#     azurerm_user_assigned_identity.alb_identity
#   ]
# }

# Delegate Network Contributor permission for join to association subnet
# az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $ALB_SUBNET_ID --role "4d97b98b-1d4f-4787-a291-c67834d212e7" 
# resource "azurerm_role_assignment" "appgwcontainerfix3" {
#   principal_id         = azurerm_user_assigned_identity.alb_identity.principal_id
#   scope                = data.azurerm_subnet.appgwsubnet.id
#   role_definition_name = "Network Contributor"
#   depends_on = [
#     azurerm_kubernetes_cluster.k8s,
#     azurerm_user_assigned_identity.alb_identity
#   ]
# }