# import common code
function IsValidHost($Type) {
    if ($Type -eq 'dc' -And $env:ComputerName -Match '^DC0[12]$') { return $True }
    elseif ($Type -eq 'mts' -And $env:ComputerName -Match '^MTS(2|)$') { return $True }
    elseif ($Type -eq 'ex' -And $env:ComputerName -Match '^EX0[12]$|IAEXET') { return $True }
    else { return $False }
}

$Exec = "\\DC01\Software\SabeckyScripts"
$ExeName = "NavFIT98A"

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
    else { Write-Host "failed!"; Read-Host -Prompt "Press Enter to exit."; exit 1 }

    psexec \\$Remote -s powershell "$Exec\Install-NavFIT.ps1"
}

# local launch
else {
    Write-Host "locally!"
    
    Write-Host "Copying $ExeName localy..."
    Copy-Item "\\DC01\Software\NavFIT98A\NAVFIT98A.msi" "F:\NAVFIT98A.msi"
    Copy-Item "\\DC01\Software\NavFIT98A\AccessDatabaseEngine.exe" "F:\AccessDatabaseEngine.exe"
    
    Write-Host "Installing NavFit98A..."
    msiexec /i "F:\NAVFIT98A.msi" /passive /log F:\navfit-install.log
    
    Start-Sleep 3
    while (-Not (Get-Content "F:\navfit-install.log" | Select-Object -Last 1) -Match "Logging stopped") {
        Write-Host "$(Get-Date -Format '[HH:mm:ss]') Installing! Checking again in 10 seconds..."
        Start-Sleep 10
    }
    
    Write-Host "Installing Access Database Engine..."
    & "F:\AccessDatabaseEngine.exe" /quiet
    
    Start-Sleep 3
    while (Get-Process | Where-Object { $_.Name -Match "AccessDatabaseEngine" }) {
        Write-Host "$(Get-Date -Format '[HH:mm:ss]') Installing! Checking again in 10 seconds..."
        Start-Sleep 10
    }
    
    Write-Host "Creating desktop shortcut..."
    $WshShell = New-Object -ComObject WScript.Shell;$Shortcut = $WshShell.CreateShortcut('C:\Users\All Users\Desktop\NavFit98A.lnk');$Shortcut.TargetPath = 'C:\Program Files (x86)\NAVFIT98A\NAVFIT98A.exe';$Shortcut.IconLocation = 'C:\Program Files (x86)\NAVFIT98A\NavFit98A.ico';$Shortcut.Save()
}

Write-Host "Jobs done!"
Read-Host -Prompt "Press enter to exit."