<#
    - Create a storage account to store the remote Terraform State file using PowerShell and Az module
#>

Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Import-Module Az

$tenantId = "e1858381-60c4-4a56-9e29-7d9efe1ddc47"
$subscriptionId = "8c6f346b-200d-4475-99b4-d26874174cbd"
$rgGroupName = "rg-devops-proj"
$storageAccountName = "devopsprojst"
$containerName = "tfstate"

# Connect to Az Account
Connect-AzAccount -Tenant $tenantId -Subscription $subscriptionId

# Check if rg exists
try {
    Get-AzResourceGroup -Name $rgGroupName -ErrorAction Stop
    Write-Host "$($rgGroupName) exists. Skipping creation of group."
} catch {
    New-AzResourceGroup -Name $rgGroupName -Location "Southeast Asia" -Tag @{Projects = "DevOps" }
    Write-Host "$($rgGroupName) group created."
}

# Check if SA exists
try {
    Get-AzStorageAccount -ResourceGroupName $rgGroupName -Name $storageAccountName -ErrorAction Stop 
    Write-Host "$($storageAccountName) exists. Skipping creation of Storage Account."
}
catch {
    New-AzStorageAccount -ResourceGroupName $rgGroupName `
        -Name $storageAccountName `
        -Location "Southeast Asia" `
        -SkuName Standard_LRS `
        -Kind StorageV2 `
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