$RESOURCE_GROUP = "rg-devops-proj"
$AKS_NAME = "devopsprojaks"
$helm_resource_namespace = "azure-alb-system"
$VNET_NAME = "devopsproj-vnet"
$ALB_SUBNET_NAME = "appgw"
$ALB_CONTROLLER_VERSION = "1.0.0"

# Create namespace
kubectl create namespace $helm_resource_namespace

# Get the client ID from Azure
$clientId = az identity show `
  --resource-group $RESOURCE_GROUP `
  --name "azure-alb-identity" `
  --query "clientId" `
  --output tsv

# Install ALB controller via Helm
helm install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller `
  --namespace $helm_resource_namespace `
  --version $ALB_CONTROLLER_VERSION `
  --set "albController.namespace=$helm_resource_namespace" `
  --set "albController.podIdentity.clientID=$clientId"
