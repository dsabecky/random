# configure me
$ChromePath = "\\dc01\software\googlechrome\googlechrome.msi"

# validate correct server
Write-Host -NoNewLine "Checking host... "
if ($env:ComputerName -NotMatch "^MTS(2$|$)") { Read-Host -Prompt "Oopsie woopsie! Pwease wun fwum MTS"; exit }
else { Write-Host "valid!" }

if ((Test-Path $ChromePath) -eq $False) { Write-Host "Cannot find Chrome installer. :( Send help."; Read-Host -Prompt "Press Enter to continue."; exit }

$Remote = Read-Host "Computer name"

Write-Host "Pinging $Remote to check availability..."
ping -n 1 $Remote

if ($LastExitCode -ne 0) { Write-Host "Sad. Big oof. Many yikes. Wow. Wow. $Remote not available. :'("; Read-Host -Prompt "Press Enter to continue."; exit }

Write-Host "Copying Google Chrome..."
copy $ChromePath "\\$Remote\f$\GoogleChrome.msi"

Write-Host "Installing Google Chrome as $env:username..."
psexec \\$Remote -sd cmd /c "msiexec /I "F:\GoogleChrome.msi""

Read-Host -Prompt "Jobs done! Press enter to continue"
exit