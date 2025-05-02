<#
    - Create group for AKS Admins using PowerShell and Microsoft.Graph
#>

Install-Module Microsoft.Graph -Scope CurrentUser
Import-Module Microsoft.Graph.Groups

$adGroupName = "devops-ks-group"
$userId = "7a2b7483-cc12-4a69-840a-3da5874ef125"

# Connect to MG Graph
Connect-Mggraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Group.ReadWrite.All" -NoWelcome

# Add group if it doesn't exist
if (Get-MgGroup -Filter "DisplayName eq '$adGroupName'" -ErrorAction Stop) {
    Write-Host "Group Exists. Skipping creation of group."
}
else {
    New-MgGroup -DisplayName $adGroupName -GroupTypes "Unified" -MailEnabled:$False -MailNickName 'aksgroup' -SecurityEnabled:$False
    Write-Host "$($adGroupName) group is now created."
}

$groupId = (Get-MgGroup -Filter "DisplayName eq '$adGroupName'").Id
Write-Host "Group Id: $($groupId)"

# Add user as a member to the group
try {
    New-MgGroupMember -GroupId $groupId -DirectoryObjectId $userId -ErrorAction Stop

    Write-Host "User has now been added as a member to the group."
}
catch {
    if ($_.Exception.Message -like "*added object referenced already exist*") {
        Write-Host "User is already a member of the group. Skipping addition."
    }
    else {
        Write-Error "Error adding user to group: $($_)"
    }
}

# Add user as a owner to the group - if there is a new owner
# try {
#     New-MgGroupOwner -GroupId $groupId -DirectoryObjectId $userId -ErrorAction Stop

#     Write-Host "User has now been added as an owner to group."
# } catch {
#     if ($_.Exception.Message -like "*added object referenced already exist*") {
#         Write-Host "User is already a member of the group. Skipping addition."
#     } else {
#         Write-Error "Error adding user to group: $($_)"
#     }
# }

Disconnect-MgGraph | Out-Null
