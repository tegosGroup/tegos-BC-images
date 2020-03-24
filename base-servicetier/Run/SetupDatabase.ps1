# INPUT
#     $restartingInstance (optional)
#     $bakFile (optional)
#     $appBacpac and tenantBacpac (optional)
#     $databaseCredentials (optional)
#
# OUTPUT
#     $databaseServer
#     $databaseInstance
#     $databaseName
#

if ($restartingInstance) {

    # Nothing to do

} elseif ($databaseCredentials) {

    if (Test-Path $myPath -PathType Container) {
        $EncryptionKeyFile = Join-Path $myPath 'DynamicsNAV.key'
    } else {
        $EncryptionKeyFile = Join-Path $runPath 'DynamicsNAV.key'
    }

    $EncryptionSecurePassword = $EncryptionSecurePassword = ConvertTo-SecureString -String $env:encryptionSecurePassword -AsPlainText -Force

    Write-Host "Downloading Encryption Key"
    (New-Object System.Net.WebClient).DownloadFile("$env:encryptionKeyURL", $EncryptionKeyFile)

    Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName "EnableSqlConnectionEncryption" -KeyValue "true" -WarningAction SilentlyContinue
    Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName "TrustSQLServerCertificate" -KeyValue "true" -WarningAction SilentlyContinue

    $databaseServerInstance = $databaseServer
    if ("$databaseInstance" -ne "") {
        $databaseServerInstance += "\$databaseInstance"
    }

    Write-Host "Import Encryption Key"
    
    Write-Host $databaseServerInstance
    Write-Host $databaseName
    Write-Host $databaseCredentials

    Import-NAVEncryptionKey -ServerInstance $serverInstance `
                            -ApplicationDatabaseServer $databaseServerInstance `
                            -ApplicationDatabaseCredentials $databaseCredentials `
                            -ApplicationDatabaseName $databaseName `
                            -KeyPath $EncryptionKeyFile `
                            -Password $EncryptionSecurePassword `
                            -WarningAction SilentlyContinue `
                            -Force
    
    Set-NavServerConfiguration -serverinstance $ServerInstance -databaseCredentials $DatabaseCredentials -WarningAction SilentlyContinue

}

