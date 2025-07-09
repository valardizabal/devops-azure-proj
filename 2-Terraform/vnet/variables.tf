variable "name" {
  type        = string
  default     = "devopsproj"
  description = "Name for resources"
}

variable "rgname" {
  type        = string
  default     = "rg-devops-proj"
  description = "Name for resource group"
}

variable "location" {
  type        = string
  default     = "southeastasia"
  description = "Azure Location of resources"
}

variable "subscription_id" {
  type        = string
  default     = "8c6f346b-200d-4475-99b4-d26874174cbd"
  description = "Azure Subscription ID"
}

variable "network_address_space" {
  type        = string
  description = "Azure VNET Address Space"
}

variable "aks_subnet_address_name" {
  type        = string
  description = "AKS Subnet Address Name"
}

variable "aks_subnet_address_prefix" {
  type        = string
  description = "AKS Subnet Address Space"
}

variable "subnet_address_name" {
  type        = string
  description = "Subnet Address Name"
}

variable "subnet_address_prefix" {
  type        = string
  description = "Subnet Address Space"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for resources"
}
