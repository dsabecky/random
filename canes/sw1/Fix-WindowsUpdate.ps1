# load modules
Import-Module BitsTransfer
if (-Not (Get-Module BitsTransfer)) { Read-Host "!! ERROR !! FAILED TO LOAD BITS TRANSFER MODULE !!`n`nPress [Enter] to exit"; exit 1 }


# CHECK ADMINISTRATOR

# sometimes the wsus server information goes stale and its best to just purge it
Read-Host "`n!! CAUTION !!`n`nCLEAR OUT $env:ComputerName FROM PROV01 BEFORE CONTINUING !!`n`nPress Enter to continue"

# this supresses UNC noise from invoking cmd
Set-Location C:\

# stop services
# need to stop cryptsvc to clear catroot2
Write-Host "[::] Stopping services..."
Stop-Service bits, wuauserv, cryptsvc -Verbose -Force

# delete files
Write-Host "`n[::] Clearing update directories..."
% {
    cmd /c "rmdir /q /s C:\Windows\SoftwareDistribution"
    cmd /c "rmdir /q /s C:\Windows\system32\catroot2"
    mkdir "c:\Windows\system32\catroot2" | Out-Null
    cmd /c "del /q C:\ProgramData\Microsoft\Network\Downloader\qmgr*.dat"
}

if (-Not (Test-Path C:\Windows\SoftwareDistribution\*)) { Write-Host "- Reset update cache successfully." }
if (-Not (Test-Path C:\Windows\system32\catroot2\*)) { Write-Host "- Reset update catalogs successfully." }
if (-Not (Test-Path C:\ProgramData\Microsoft\Network\Downloader\qmgr*.dat)) { Write-Host "- Reset bits queue manager successfully." }

# reset bits descriptors
Write-Host "`n[::] Resetting BITS service descriptors..."
% {
    cmd /c "sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
    cmd /c "sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
}

# re-register bits dlls
Write-Host "`n[::] Registering BITS dynamic link libraries..."
Set-Location C:\Windows\system32
% {
    regsvr32.exe /s atl.dll
    regsvr32.exe /s urlmon.dll
    regsvr32.exe /s mshtml.dll
    regsvr32.exe /s shdocvw.dll
    regsvr32.exe /s browseui.dll
    regsvr32.exe /s jscript.dll
    regsvr32.exe /s vbscript.dll
    regsvr32.exe /s scrrun.dll
    regsvr32.exe /s msxml.dll
    regsvr32.exe /s msxml3.dll
    regsvr32.exe /s msxml6.dll
    regsvr32.exe /s actxprxy.dll
    regsvr32.exe /s softpub.dll
    regsvr32.exe /s wintrust.dll
    regsvr32.exe /s dssenh.dll
    regsvr32.exe /s rsaenh.dll
    regsvr32.exe /s gpkcsp.dll
    regsvr32.exe /s sccbase.dll
    regsvr32.exe /s slbcsp.dll
    regsvr32.exe /s cryptdlg.dll
    regsvr32.exe /s oleaut32.dll
    regsvr32.exe /s ole32.dll
    regsvr32.exe /s shell32.dll
    regsvr32.exe /s initpki.dll
    regsvr32.exe /s wuapi.dll
    regsvr32.exe /s wuaueng.dll
    regsvr32.exe /s wuaueng1.dll
    regsvr32.exe /s wucltui.dll
    regsvr32.exe /s wups.dll
    regsvr32.exe /s wups2.dll
    regsvr32.exe /s wuweb.dll
    regsvr32.exe /s qmgr.dll
    regsvr32.exe /s qmgrprxy.dll
    regsvr32.exe /s wucltux.dll
    regsvr32.exe /s muweb.dll
    regsvr32.exe /s wuwebv.dll
}

# reset winsock
Write-Host "`n[::] Resetting winsock catalog..."
% { netsh winsock reset }

# reset bits admin
Write-Host "`n[::] Resetting all bits jobs..."
Get-BitsTransfer -AllUsers | Remove-BitsTransfer -Verbose

# system file check
Write-Host "`n[::] Executing System File Check..."
% { cmd /c sfc /scannow }

# start services
Write-Host "`n[::] Starting services..."
Start-Service bits, wuauserv, cryptsvc -Verbose

# reset wsus identity
# Write-Host "`n[::] Windows Update commands..."
# Write-Host "- Resetting WSUS Identifier, please be patient."
# % { cmd /c wuauclt /ResetAuthorization }
# Start-Sleep 30

# initial checkin to wsus
# Write-Host "- Checking into WSUS, please be patient."
# % { cmd /c wuauclt /detectnow /reportnow }
# Start-Sleep 30

# warn about a reboot and exit
Read-Host "`n!! FOR YOUR INFORMATION !!`n`n!! YOU SHOULD REALLY REBOOT THIS COMPUTER NOW !!`n`nPress enter to exit"
exit 0