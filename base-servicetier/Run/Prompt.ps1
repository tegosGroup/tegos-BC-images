﻿param
(
    [switch]$silent
)

. "c:\run\ServiceSettings.ps1"

$serviceTierFolder = (Get-Item "C:\Program Files\Microsoft Dynamics NAV\*\Service").FullName
if (Test-Path "$serviceTierFolder\Microsoft.Dynamics.Nav.Management.psm1") {
    Import-Module "$serviceTierFolder\Microsoft.Dynamics.Nav.Management.psm1" -wa SilentlyContinue
} else {
    Import-Module "$serviceTierFolder\Microsoft.Dynamics.Nav.Management.dll" -wa SilentlyContinue
}

$serviceTierFolder = (Get-Item "C:\Program Files\Microsoft Dynamics NAV\*\Service").FullName
$roleTailoredClientItem = Get-Item "C:\Program Files (x86)\Microsoft Dynamics NAV\*\RoleTailored Client" -ErrorAction Ignore
if ($roleTailoredClientItem) {
    $roleTailoredClientFolder = $roleTailoredClientItem.FullName
    $NavIde = Join-Path $roleTailoredClientFolder "finsql.exe"
    if (!(Test-Path $NavIde)) {
        $NavIde = ""
    }
    if (Test-Path "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Ide.psm1") {
        Import-Module "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Ide.psm1" -wa SilentlyContinue
    }
    if (Test-Path "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Management.psd1") {
        Import-Module "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Management.psd1" -wa SilentlyContinue
    }
    elseif (Test-Path "$serviceTierFolder\Microsoft.Dynamics.Nav.Apps.Management.psd1") {
        Import-Module "$serviceTierFolder\Microsoft.Dynamics.Nav.Apps.Management.psd1" -wa SilentlyContinue
    }
    if (Test-Path "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Tools.psd1") {
        Import-Module "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Tools.psd1" -wa SilentlyContinue
    }
    elseif (Test-Path "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Tools.dll") {
        Import-Module "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Apps.Tools.dll" -wa SilentlyContinue
    }
    if (Test-Path "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Model.Tools.psd1") {
        Import-Module "$roleTailoredClientFolder\Microsoft.Dynamics.Nav.Model.Tools.psd1" -wa SilentlyContinue
    }
}
else {
    $roleTailoredClientFolder = ""
    $NavIde = ""
    if (Test-Path "$serviceTierFolder\Microsoft.Dynamics.Nav.Apps.Management.psd1") {
        Import-Module "$serviceTierFolder\Microsoft.Dynamics.Nav.Apps.Management.psd1" -wa SilentlyContinue
    }
}

cd $PSScriptRoot
if (!$silent) {
    Write-Host -ForegroundColor Green "Welcome to the NAV Container PowerShell prompt"
    Write-Host
}