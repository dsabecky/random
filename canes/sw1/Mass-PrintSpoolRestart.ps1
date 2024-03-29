# config me
$hostreg = "^U-(WS|LT)[0-9]{4}"

Write-Host -NoNewLine "Are you on on MTS or a Domain Controller? "
if ($env:ComputerName -NotMatch "^(MTS|DC0[12])$") { Write-Host "Nope!"; Read-Host "Press Enter to exit"; exit 1 }
else { Write-Host "Yuhh!" }

import-module ActiveDirectory

#Get-ADComputer -Filter * | ForEach-Object {
#    $name = "$_.Name"
#    if ((Test-Connection -Count 1 -Quiet $name) -And ($name -Match "$hostreg")) { psexec \\$($name) -sd powershell -c "Restart-Service Spooler" }
#}

Get-ADComputer -Filter * | Select-Object Name | Where-Object { $_.Name -Match "$hostreg" } | Export-CSV .\computers.csv

Get-Content .\computers.csv | Where-Object { $_.Trim('"') -Match "$hostreg" } | ForEach-Object {
    $l = $_.Trim('"')
    if (Test-Connection -Count 1 -Quiet $l) { psexec \\$l -sid powershell -c "Restart-Service Spooler -Verbose"; "$l" }
    else { "$l" | Add-Content .\Failed-MassPrintSpoolRestart.log }
} 

Write-Host "Jobs done!"
Read-Host "Press enter to exit"
exit 0