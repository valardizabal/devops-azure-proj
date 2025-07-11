variable "name" {
  type        = string
  default     = "devopsproj"
  description = "Name for resources"
}

variable "rgname" {
  type        = string
  default     = "rg-devops-proj"
  description = "Name for rg"
}

variable "location" {
  type        = string
  default     = "southeastasia"
  description = "Azure Location of resources"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "kubernetes_cluster_rbac_enabled" {
  default = "true"
}

variable "kubernetes_version" {
}

variable "agent_count" {
}

variable "vm_size" {
}

variable "ssh_public_key" {
}

variable "aks_admins_group_object_id" {
}


variable "tags" {
  type = map(string)
}