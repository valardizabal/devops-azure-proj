variable "name" {
  type        = string
  default     = "devopsproj-vl"
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
  default     = "8c6f346b-200d-4475-99b4-d26874174cbd"
  description = "Azure Subscription ID"
}

variable "tags" {
  type = map(string)
}