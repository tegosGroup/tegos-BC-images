﻿try {
    . (Join-Path $PSScriptRoot "ServiceSettings.ps1")
    $CustomConfigFile = Join-Path (Get-Item "C:\Program Files\Microsoft Dynamics NAV\*\Service").FullName "CustomSettings.config"
    $CustomConfig = [xml](Get-Content $CustomConfigFile)
    $publicWebBaseUrl = $CustomConfig.SelectSingleNode("//appSettings/add[@key='PublicWebBaseUrl']").Value
    $serverInstance = $CustomConfig.SelectSingleNode("//appSettings/add[@key='ServerInstance']").Value
    if ($publicWebBaseUrl -ne "") {
        # WebClient installed use WebClient base Health endpoint
        if (!($publicWebBaseUrl.EndsWith("/"))) { $publicWebBaseUrl += "/" }
        $result = Invoke-WebRequest -Uri "${publicWebBaseUrl}Health/System" -UseBasicParsing -TimeoutSec 10
        if ($result.StatusCode -eq 200 -and ((ConvertFrom-Json $result.Content).result)) {
            # Web Client Health Check Endpoint will test Web Client, Service Tier and Database Connection
            exit 0
        }
    } else {
        # WebClient not installed, check Service Tier
        if ((Get-service -name "$NavServiceName").Status -eq 'Running') {
            exit 0
        }
    }
} catch {
}
exit 1