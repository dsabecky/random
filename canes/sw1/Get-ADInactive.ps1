# set variables
Write-Host -NoNewLine "Setting variables... "
$30Days = (Get-Date).AddDays(-31)
Write-Host "complete!"

# check if valid server (mts)
Write-Host -NoNewLine "Validating server... "
if ($env:computername -NotMatch '^MTS(2$|$)|^DC0[12]$') { Read-Host -Prompt "error! Please run from Management Server or a Domain Controller."; exit }
else { Write-Host "valid!" }

# import active directory module
Write-Host -NoNewLine "Loading AD Powershell module... "
Import-Module ActiveDirectory
if (-Not (Get-Module -Name ActiveDirectory)) { Read-Host -Prompt "failed! :("; exit }
Write-Host "success!"


Write-Host "Gathering information..."
Get-ADUser -Properties * -Filter {
    (LastLogonDate -NotLike "*" -AND LastLogonDate -le $30Days -AND SamAccountName -NotLike "svc.*" -AND SamAccountName -NotMatch "^_.*Template$")
} |
Select-Object Name,SamAccountName,Enabled,LastLogonDate |
Export-CSV F:\AD30Days.csv

Read-Host -Prompt "Complete! File available at F:\AD30Days.csv"