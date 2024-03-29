# configure me
$ExeName = "ActivClient 7.1.0.205"
$ExePath = "\\dc01\Software\ActivClient\AC7.1.0.205\AC_710205_x64-R1.exe"

# validate correct server
Write-Host -NoNewLine "Checking host... "
if ($env:ComputerName -NotMatch "^MTS(2|)$") { Read-Host -Prompt "Oopsie woopsie! Pwease wun fwum MTS"; exit }
else { Write-Host "valid!" }

if ((Test-Path $ExePath) -eq $False) { Write-Host "Cannot find $ExeName installer. :( Send help."; Read-Host -Prompt "Press Enter to continue."; exit }

$Remote = Read-Host "Computer name"

Write-Host "Checking $Remote availability..."
ping -n 1 $Remote
if ($LastExitCode -ne 0) { Write-Host "Sad. Big oof. Many yikes. Wow. Wow. $Remote not available. :'("; Read-Host -Prompt "Press Enter to continue."; exit }

Write-Host "Copying $ExeName..."
copy $ExePath "\\$Remote\f$\AC_710205_x64-R1.exe"

Write-Host "Installing $ExeName as $env:username..."
psexec \\$Remote -sid cmd.exe /c "F:\AC_710205_x64-R1.exe"

Write-Host ""; Write-Host "Waiting 30 seconds for $ExeName to start."
Write-Host "!! DO NOT CLOSE THE WINDOW !!"
Start-Sleep 30

while (Get-Process -ComputerName $Remote | Where-Object { $_.Name -Match "AC_" }) {
    Write-Host "$(Get-Date -Format '[HH:mm:ss]') Installing! Checking again in 15 seconds..."
    Start-Sleep 15
}

Read-Host -Prompt "Jobs done! Press enter to continue"
exit