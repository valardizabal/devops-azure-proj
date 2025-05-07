variable "name" {
  type        = string
  default     = "devopsproj"
  description = "Name for resources"
}

variable "rgname" {
  type        = string
  default     = "devops-proj-rg"
  description = "Name for rg"
}

variable "location" {
  type        = string
  default     = "southeastasia"
  description = "Azure Location of resources"
}

variable "tags" {
  type = map(string)
}