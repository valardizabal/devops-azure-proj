<#
    - Create a storage account to store the remote Terraform State file using PowerShell and Az module
#>

Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Import-Module Az

$tenantId = ""
$subscriptionId = ""
$rgGroupName = "devops-proj-rg"
$storageAccountName = "devopsprojst"
$containerName = "tfstate"

# Connect to Az Account
Connect-AzAccount -Tenant $tenantId -Subscription $subscriptionId

# Check if rg exists
if (Get-AzResourceGroup -Name $rgGroupName -ErrorAction Stop) {
    Write-Host "$($rgGrouName) exists. Skipping creation of group."
}
else {
    New-AzResourceGroup -Name $rgGroupName -Location "Southeast Asia" -Tag @{Projects = "DevOps" }
    Write-Host "$($rgGrouName) group created."
}

# Check if SA exists
if (Get-AzStorageAccount -ResourceGroupName $rgGroupName -Name $storageAccountName -ErrorAction Stop) {
    Write-Host "$($storageAccountName) exists. Skipping creation of Storage Account."
}
else {
    New-AzStorageAccount -ResourceGroupName $rgGroupName `
        -Name $storageAccountName `
        -Location "Southeast Asia" `
        -SkuName Standard_LRS `
        -Kind StorageV2
    -Tag @{Projects = "DevOps" }
    Write-Host "$($storageAccountName) created."
}

# Create a container
try {
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $rgGroupName -Name $storageAccountName
    $ctx = $storageAccount.Context
    
    New-AzStorageContainer -Name $containerName -Context $ctx -Permission Off
    
    Write-Host "$($containerName) container created in storage account $($storageAccountName)."
}
catch {
    Write-Error "Error creating a container: $($_)"
}

Disconnect-AzAccount | Out-Null