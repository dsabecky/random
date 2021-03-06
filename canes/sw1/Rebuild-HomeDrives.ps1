# validate correct server
Write-Host -NoNewLine "Checking host... "
if ($env:ComputerName -NotMatch "^MTS(2$|$)|^DC0[12]$") { Write-Host "failed!"; Read-Host -Prompt "Please run from MTS or a Domain Controller"; exit }
else { Write-Host "valid!" }

# import activedirectory module
Write-Host -NoNewLine "Loading AD Powershell module... "
Import-Module ActiveDirectory
if (-Not (Get-Module -Name ActiveDirectory)) { Read-Host -Prompt "failed! :("; exit }
Write-Host "success!"

# validate the drive is there
Write-Host -NoNewLine "Checking home share is available... "
if (-Not (Test-Path "\\DC01\HomeShare")) { Read-Host -Prompt "failed! HomeShare not available. :'("; exit }
Write-Host "success!"

# grab everyone and filter accordingly
Write-Host "Grabbing all users..."
Get-ADUser -Filter * |
Select-Object SamAccountName |
ForEach-Object {
    $User=$_.SamAccountName
    Write-Host -NoNewLine "Checking for $User's home share... "
    if (-Not (Test-Path "\\DC01\HomeShare\$User")) {
        Write-Host " not found!"; Write-Host "Building... "
        mkdir "\\DC01\HomeShare\$User" | Out-Null
        echo y | cacls \\DC01\HomeShare\$User /G ($User + ':F')
        Write-Host "done!"
    }
    else { Write-Host "exists!"; }
}

Read-Host -Prompt "Jobs done!"