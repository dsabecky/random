# check host
if ($env:ComputerName -NotMatch "^EX0[12]$") { Read-Host "Error! Please run from an Exchange Hub."; exit 1 }

Write-Host "Welcome! This is the new and *improved* log clearing utility!"
Start-Sleep 3
Write-Host "It's time to take a little from the top... and a little from the bottom. :)"
Start-Sleep 3
Write-Host "You'll have a bunch of words passing by, just know that everything will be okay. :*"
Start-Sleep 5

diskshadow -s C-TL.dsh

Read-Host "Jobs done!"