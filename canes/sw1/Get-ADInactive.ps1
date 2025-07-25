# set variables
Write-Host -NoNewLine "Setting variables... "
$Days = (Get-Date).AddDays(-121)
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
    (LastLogonDate -le $Days -AND SamAccountName -NotLike "svc.*" -AND SamAccountName -NotLike "*Template" -And SamAccountName -NotLike "adm.*")
} |
Select-Object Name,SamAccountName,Enabled,LastLogonDate |
Export-CSV F:\ADDays.csv -NoTypeInformation

$Grab = Import-CSV F:\ADDays.csv

$Grab | ForEach-Object {
	$n = $_.Name
	$l = $_.LastLogonDate
	$s = $_.SamAccountName
	$a = Read-Host "$n has not logged in since $l"
	if ($a -eq "y") { Remove-ADUser -Identity $s }
}

Read-Host -Prompt "Complete! File available at F:\AD90Days.csv"