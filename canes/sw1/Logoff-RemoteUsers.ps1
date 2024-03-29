# are you an administrator
Write-Host -NoNewLine "Are you an administrator... "
$isAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
if (-Not $isAdmin) { Write-Host "No!"; Read-Host "Press Enter to exit"; exit 1 }
else { Write-Host "Yuh!" }

# what computer?
$Remote = Read-Host "Enter a computer name"
if ([bool](Test-Connection -ComputerName "$Remote" -Count 1) -eq $False) { Write-Host "Failed to detect host!"; Read-Host "Press Enter to exit"; exit 1 }

# build user list
$l = query user /server:$Remote

# loop through the list
ForEach ($u in $l) {
    if ($u -NotMatch "^ USERNAME") {					# remove the header since it's not a powershell object
        $id = ($u -split ' +')[3]					# set $id to the session ID
        if ($id -NotMatch "[0-9]*") { $id = ($u -split ' +')[2] }	# properly set $id if SESSIONNAME is empty
        logoff $id /server:$Remote /V					# piledrive all the users
    }
}