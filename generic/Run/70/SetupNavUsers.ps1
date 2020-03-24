# INPUT
#     $auth
#     $username (optional)
#     $securePassword (optional)
#
# OUTPUT
#

if ($auth -eq "Windows") {
    if ($username -ne "") {
        if (!(Get-NAVServerUser -ServerInstance NAV @tenantParam -ErrorAction Ignore | Where-Object { ($_.UserName) -and ($_.UserName.EndsWith("\$username", [System.StringComparison]::InvariantCultureIgnoreCase) -or $_.UserName -eq $username) })) {
            Write-Host "Creating SUPER user with authentication Windows"
            New-NavServerUser -ServerInstance NAV @tenantParam -WindowsAccount $username
            New-NavServerUserPermissionSet -ServerInstance NAV @tenantParam -WindowsAccount $username -PermissionSetId SUPER
        }
    }
} else {
    if (!(Get-NAVServerUser -ServerInstance NAV @tenantParam -ErrorAction Ignore | Where-Object { $_.UserName -eq $username })) {
        Write-Host "Creating SUPER user with other authentication"
        New-NavServerUser -ServerInstance NAV @tenantParam -Username $username -Password $securePassword
        New-NavServerUserPermissionSet -ServerInstance NAV @tenantParam -username $username -PermissionSetId SUPER
    }
}
