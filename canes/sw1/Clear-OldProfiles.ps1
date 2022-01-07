$Exec = "\\DC01\Software\SabeckyScripts"
$AdminRegex = "^Administrator$|^Public$|^adm\.(canes|internal)$"

# check server source
Write-Host -NoNewLine "Running script... "
if ($env:ComputerName -Match '^MTS(2|)$|^(RO|)DC(0[12]|)$') {
    Write-Host "remotely!"

    # check for psexec
    if (-Not (psexec)) { Write-Host "Failed to locate PSExec!"; Read-Host "Press Enter to exit"; exit 1 }

    # ask/validate remote host
    $Remote = Read-Host "Computer name"
    if ($Remote -eq "") { Write-Host "Nothing entered, running locally!" }
    else { psexec \\$Remote -s powershell "$Exec\Clear-OldProfiles.ps1"; Read-Host "Press Enter to exit"; exit 0 }
}

# locally running
Write-Host "locally!"

# C:\UsersWrite-Host "Deleting home folders..."
Get-ChildItem "C:\Users" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) -And $_.Name -NotMatch "$AdminRegex" } | ForEach-Object { echo y | cmd.exe /c rmdir /s $_.FullName }

# RegEdit
Write-Host "Deleting registry entries..."
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | ForEach-Object {
    $RPath = $_.ProfileImagePath
    $RSID  = $_.PSChildName
    
    Write-Host -NoNewLine "$RPath is... "
    if (Test-Path "$RPath") { Write-Host "valid, skipping." }
    else {
        Write-Host "invalid!"; Write-Host -NoNewLine "Purging $RSID... "
        Remove-Item -Recurse "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$RSID"
        if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$RSID") { Write-Host "failed!" }
        else { Write-Host "success!" }
    }
}

Write-Host "Jobs done!"
Read-Host "Press Enter to exit"; exit 0