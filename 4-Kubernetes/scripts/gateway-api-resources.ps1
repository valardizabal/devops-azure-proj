$RESOURCE_GROUP = "rg-devops-proj"
$ALB_RESOURCE_NAME = "devopsproj-alb"
$ALB_FRONTEND_NAME = "alb-frontend"

# Get the ALB resource ID from Azure
$RESOURCE_ID = az network alb show `
    --resource-group $RESOURCE_GROUP `
    --name $ALB_RESOURCE_NAME `
    --query id `
    --output tsv

# Create a Gateway
$gatewayYaml = @"
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-01
  namespace: ads-verifiedids-react-cloud
  annotations:
    alb.networking.azure.io/alb-id: $RESOURCE_ID
spec:
  gatewayClassName: azure-alb-external
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
  addresses:
  - type: alb.networking.azure.io/alb-frontend
    value: $ALB_FRONTEND_NAME
"@

$gatewayYaml | kubectl apply -f -

# Create HTTP Route
$httpRouteYaml = @"
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: traffic-ads-verifiedids-react-cloud
  namespace: ads-verifiedids-react-cloud
spec:
  parentRefs:
  - name: gateway-01
  rules:
  - backendRefs:
    - name: ads-verifiedids-react
      port: 80
"@

$httpRouteYaml | kubectl apply -f -

# Access App via Azure Application Gateway Controller for Containers 
$fqdn = kubectl get gateway gateway-01 -n ads-verifiedids-react-cloud -o jsonpath="{.status.addresses[0].value}"
Write-Output $fqdn
