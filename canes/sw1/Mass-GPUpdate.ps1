# config me
$hostreg = "^U-WS[0-9]{4}"

Write-Host -NoNewLine "Are you on on MTS or a Domain Controller? "
if ($env:ComputerName -NotMatch "^(MTS|DC0[12])$") { Write-Host "Nope!"; Read-Host "Press Enter to exit"; exit 1 }
else { Write-Host "Yuhh!" }

import-module ActiveDirectory

#Get-ADComputer -Filter * | ForEach-Object {
#    $name = "$_.Name"
#    if ((Test-Connection -Count 1 -Quiet $name) -And ($name -Match "$hostreg")) { psexec \\$($name) -s -d cmd.exe /c "gpupdate /force" }
#}

Get-ADComputer -Filter * | Select-Object Name | Where-Object { $_.Name -Match "$hostreg" } | Export-CSV .\computers.csv

Get-Content .\computers.csv | Where-Object { $_.Trim('"') -Match "$hostreg" } | ForEach-Object {
    $l = $_.Trim('"')
    if (Test-Connection -Count 1 -Quiet $l) { psexec \\$l -sid cmd.exe /c "echo y | gpupdate /force"; "$l" | Add-Content .\Success-MassGPUpdate.log }
    else { "$l" | Add-Content .\Success-MassGPUpdate.log }
} 

Write-Host "Jobs done!"
Read-Host "Press enter to exit"
exit 0