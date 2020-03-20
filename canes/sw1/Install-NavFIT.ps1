# import common code
. .\Common.ps1

# validate files exist
Write-Host "Checking files... "
if ((Test-Path "\\DC01\Software\NavFIT98A\NAVFIT98A.msi") -And (Test-Path "\\DC01\Software\NavFIT98A\AccessDatabaseEngine.exe")) { Write-Host "success!" }
else { Write-Host "failed!"; Read-Host -Prompt "Press enter to exit."; exit 1 }

Write-Host -NoNewLine "Running script... "

# remote launch
if (IsValidHost('mts')) {
    Write-Host "remotely!"
    $Remote = Read-Host "Enter computer name"
    Write-Host -NoNewLine "Checking connectivity to $Remote... "
    if (Test-Connection $Remote -quiet -count 1) { Write-Host "success!" }
    else { Write-Host "failed!"; Read-Host "Press Enter to exit."; exit 1 }

    psexec \\$Remote $(whoami) -s powershell $Exec\Install-NavFIT.ps1
}

# local launch
else {
    Write-Host "locally!"
    Write-Host "Installing NavFit98A..."
    msiexec /i "\\DC01\Software\NavFIT98A\NAVFIT98A.msi" /quiet
    Read-Prompt "Wait 30 seconds then hit enter"
    Write-Host "Installing Access Database Engine..."
    & "\\DC01\Software\NavFIT98A\AccessDatabaseEngine.exe" /quiet
    Read-Prompt "Wait 30 seconds then hit enter"
    Write-Host "Creating desktop shortcut..."
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut('C:\Users\Public\Public Desktop\NavFIT98A.lnk')
    $Shortcut.TargetPath = 'C:\Program Files (x86)\NavFIT98A\NAVFIT98A.exe'
    $Shortcut.IconLocation = 'C:\Program Files (x86)\NavFIT98A\NAVFIT98A.ico'
    $Shortcut.Save()
}

Write-Host "Jobs done!"
Read-Host -Prompt "Press enter to exit."