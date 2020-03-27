$os = (Get-CimInstance Win32_OperatingSystem)
if ($os.OSType -ne 18 -or !$os.Version.StartsWith("10.0.")) {
    throw "Unknown Host Operating System"
}
$UBR = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name UBR).UBR
$hostOsVersion = [System.Version]::Parse("$($os.Version).$UBR")

Write-Host "Host OS Version is $hostOsVersion"

#$baseimage = "mcr.microsoft.com/windows/servercore/insider:$hostOsVersion"

#1809

$baseimage = "mcr.microsoft.com/dotnet/framework/runtime:4.8-20190910-windowsservercore-ltsc2019"
$isolation = "hyperv"
$image = "mygenericwebclient"
$genericVersion = "0.0.9.8"
$created = [DateTime]::Now.ToUniversalTime().ToString("yyyyMMddHHmm") 

docker pull $baseimage
$osversion = docker inspect --format "{{.OsVersion}}" $baseImage

docker images --format "{{.Repository}}:{{.Tag}}" | % { 
    if ($_ -eq $image) 
    {
        docker rmi $image -f
    }
}

docker build --build-arg baseimage=$baseimage `
             --build-arg created=$created `
             --build-arg tag="$genericVersion" `
             --build-arg osversion="$osversion" `
             --isolation=$isolation `
             --tag $image `
             $PSScriptRoot

if ($LASTEXITCODE -ne 0) {
    throw "Failed with exit code $LastExitCode"
}
Write-Host "SUCCESS"
