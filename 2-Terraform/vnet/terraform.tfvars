name                      = "devopsproj"
location                  = "southeastasia"
rgname                    = "devops-proj-rg"
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