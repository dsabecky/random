if ($env:computername -NotMatch "^MTS(|2)$") { Write-Host "BIG OOF"; Read-Host "Press enter to exit"; exit 1 }

Write-Host -NoNewLine "Loading AD module... "
if (-Not (Get-Module ActiveDirectory)) { Import-Module ActiveDirectory }
if (-Not (Get-Module ActiveDirectory)) { Write-Host "failed!"; Read-Host "Press enter to exit"; exit 1 }
else { Write-Host "success!" }

Write-Host -NoNewLine "Building locked user list... "
$a = Get-ADUser -Filter * -Properties LockedOut | Where-Object { $_.LockedOut -eq $True }
$ac = $a.Count

Write-Host "$ac.`n`nUnlocking accounts...`n"
$a | ForEach-Object { Unlock-ADAccount $_.SamAccountName -Verbose }

Write-Host "`n`nJobs done!"
Read-Host "Press Enter to exit"
exit 0