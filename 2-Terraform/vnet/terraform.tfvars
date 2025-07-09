name                      = "devopsproj"
location                  = "southeastasia"
rgname                    = "rg-devops-proj"
subscription_id           = "8c6f346b-200d-4475-99b4-d26874174cbd"
network_address_space     = "192.168.0.0/16"
aks_subnet_address_name   = "aks"
aks_subnet_address_prefix = "192.168.0.0/24"
subnet_address_name       = "appgw"
subnet_address_prefix     = "192.168.1.0/24"

tags = {
  "DeployedBy"  = "Terraform"
  "Environment" = "production"
  "Projects"    = "DevOps"
}