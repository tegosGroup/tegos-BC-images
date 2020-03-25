# Json format:
#
$baseimage = "mygeneric"
$platform = "ltsc2019"

    $osSuffix = $platform

    $image = "bc:$($json.version)-base-$osSuffix"

    docker pull $baseimage 2>NULL
    docker images --format "{{.Repository}}:{{.Tag}}" | % { 
        if ($_ -eq $image) 
        {
            docker rmi $image -f
        }
    }

    Write-Host "Build $image from $baseimage"
    $created = [DateTime]::Now.ToUniversalTime().ToString("yyyyMMddHHmm")

    #if ($osSuffix -eq "ltsc2016") {
    #    $isolation = "process"
    #}
    #else {
        $isolation = "hyperv"
    #}

    $navdvdurl = "https://csbe7aa018c6d87x490dxb26.file.core.windows.net/tegos/Dynamics.365.BC.39040.W1.DVD.zip?st=2020-03-14T10%3A17%3A53Z&se=2021-03-18T10%3A17%3A00Z&sp=rl&sv=2018-03-28&sr=f&sig=FqN8iZiD%2B0bJzfi%2BuyRQp31AAv6lEIWxrXlLL1wrJwg%3D"
    
    docker build --build-arg baseimage="$baseimage" `
                 --build-arg navdvdurl="$navdvdurl" `
                 --build-arg vsixurl="$($json.vsixbloburl)" `
                 --build-arg legal="$($json.legal)" `
                 --build-arg created="$created" `
                 --build-arg cu="$($json.cu)" `
                 --build-arg country="$($json.country)" `
                 --build-arg version="$($json.version)" `
                 --build-arg platform="$($json.platformversion)" `
                 --isolation=$isolation `
                 --memory 10G `
                 --tag "myservicetier" `
                 $PSScriptRoot

