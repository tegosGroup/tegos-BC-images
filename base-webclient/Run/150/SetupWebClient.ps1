﻿# Remove Default Web Site
Get-WebSite | Remove-WebSite
Get-WebBinding | Remove-WebBinding

$certparam = @{}
if ($servicesUseSSL) {
    $certparam += @{CertificateThumbprint = $certificateThumbprint}
}

Write-Host "Registering event sources"
"MicrosoftDynamicsNAVClientWebClient","MicrosoftDynamicsNAVClientClientService" | % {
    if (-not [System.Diagnostics.EventLog]::SourceExists($_)) {
        $frameworkDir =  (Get-Item "HKLM:\SOFTWARE\Microsoft\.NETFramework").GetValue("InstallRoot")
        New-EventLog -LogName Application -Source $_ -MessageResourceFile (get-item (Join-Path $frameworkDir "*\EventLogMessages.dll")).FullName
    }
}

Write-Host "Creating DotNetCore Web Server Instance"
$publishFolder = "$webClientFolder\WebPublish"

$NAVWebClientManagementModule = "$webClientFolder\Modules\NAVWebClientManagement\NAVWebClientManagement.psm1"
if (!(Test-Path $NAVWebClientManagementModule)) {
    $NAVWebClientManagementModule = "$webClientFolder\Scripts\NAVWebClientManagement.psm1"
}
Import-Module $NAVWebClientManagementModule
New-NAVWebServerInstance -PublishFolder $publishFolder `
                         -WebServerInstance "$WebServerInstance" `
                         -Server "$env:navServer" `
                         -ServerInstance "$env:navServerInstance" `
                         -ClientServicesCredentialType $Auth `
                         -ClientServicesPort "$clientServicesPort" `
                         -WebSitePort $webClientPort @certparam

$navsettingsFile = Join-Path $wwwRootPath "$WebServerInstance\navsettings.json"
$config = Get-Content $navSettingsFile | ConvertFrom-Json
Add-Member -InputObject $config.NAVWebSettings -NotePropertyName "RequireSSL" -NotePropertyValue "false" -ErrorAction SilentlyContinue
$config.NAVWebSettings.RequireSSL = $false
Add-Member -InputObject $config.NAVWebSettings -NotePropertyName "PersonalizationEnabled" -NotePropertyValue "true" -ErrorAction SilentlyContinue
$config.NAVWebSettings.PersonalizationEnabled = $true
$config.NAVWebSettings.ManagementServicesPort = $ManagementServicesPort

if ($customWebSettings -ne "") {
    Write-Host "Modifying Web Client config with settings from environment variable"        

    $customWebSettingsArray = $customWebSettings -split ","
    foreach ($customWebSetting in $customWebSettingsArray) {
        $customWebSettingArray = $customWebSetting -split "="
        $customWebSettingKey = $customWebSettingArray[0]
        $customWebSettingValue = $customWebSettingArray[1]
        if ($config.NAVWebSettings.$customWebSettingKey -eq $null) {
            Write-Host "Creating $customWebSettingKey and setting it to $customWebSettingValue"
            $config.NAVWebSettings | Add-Member $customWebSettingKey $customWebSettingValue
        } else {
            Write-Host "Setting $customWebSettingKey to $customWebSettingValue"
            $config.NAVWebSettings.$customWebSettingKey = $customWebSettingValue
        }
    }
}

$config | ConvertTo-Json | set-content $navSettingsFile
