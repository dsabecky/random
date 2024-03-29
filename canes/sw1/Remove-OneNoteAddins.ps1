# validate correct server
Write-Host -NoNewLine "Checking host... "
if ($env:ComputerName -NotMatch "^MTS(2$|$)") { "failed!"; Read-Host -Prompt "Oopsie woopsie! Pwease wun fwum MTS"; exit }
"valid!"

$Remote = Read-Host "Computer name"
"Pinging $Remote to check availability..."
ping -n 1 $Remote
if ($LastExitCode -ne 0) { "Sad. Big oof. Many yikes. Wow. Wow. $Remote not available. :'("; Read-Host -Prompt "Press Enter to continue."; exit }

"Changing directory to $Remote Office14..."
Set-Location "\\$Remote\c$\Program Files\Microsoft Office\Office14"
Remove-Item ONBttn*.dll -Force -Verbose

Read-Host "Jobs done!"