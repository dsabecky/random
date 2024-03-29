# logfile name build
$logfile="F:\SmartcardLogonNonUsers-" + $(get-date -format yyyy-MM-dd-HH-mm) + ".csv"

# check host
if ($env:computername -NotMatch "^(MTS(|2)|DC0[12])$") { "BIG OOF, wrong server!"; Read-Host "Press enter to exit"; exit 1 }

# load & check activedirectory
Write-Host -NoNewLine "Loading AD module... "
if (-Not (Get-Module ActiveDirectory)) { Import-Module ActiveDirectory }
if (-Not (Get-Module ActiveDirectory)) { "failed!"; Read-Host "Press enter to exit"; exit 1 }
Write-Host "success!"

# grab every user...
Get-ADUser -Filter * -Properties DisplayName, SmartcardLogonRequired |
# ...but only ones without smartcard login...
Where-Object { $_.SmartcardLogonRequired -eq $False -And $_.DisplayName -Match "[\[\(].*[\]\)]$" -And $_.SamAccountName -NotMatch "^adm\." } |
# ...only usernames please...
Select-Object SamAccountName, DisplayName, SmartcardLogonRequired |
# ...and save it as an excel file!
Export-CSV $logfile -NoTypeInformation

# let the person know where to find it
"File saved to $logfile"; Read-Host "Press Enter to exit."; exit 0