# are you santa?
if ($env:computername -NotMatch "^(RODC|DC0[12]|MTS(2|$))") { Read-Host "Please run from a Domain Controller or Management Terminal."; exit 1 }

# is it christmas?
Import-Module ActiveDirectory
if (-Not (Get-Module ActiveDirectory)) { "Failed to load Active Directory module!"; exit 1 }

# are you completely sure?
if ((Read-Host "Type YES if you are completely sure you want to do this") -NotMatch "yes") { exit 1 }

# he's making a list...
$WS = Get-ADComputer -Filter * | Select Name | Where-Object { $_.Name -Match '[A-Z]\-(WS|LT)[0-9]{2,5}' }
echo "Log available at F:\Mass-RebootWorkstations.log"

# checking it twice...
$WS | ForEach-Object {
    if (Test-Connection -Count 1 -Quiet -ComputerName $_.Name) {
        
        # everybody's naughty :^)
        echo "[$(Get-Date)] Restarting $($_.Name)" >> F:\Mass-RebootWorkstations.log
        shutdown /m $($_.Name) /r /f /t 120 /c 'Installing Windows Updates in 2 minutes. Please save your work.'
    }
    else {
        echo "[$(Get-Date)] Failed to contact $($_.Name)" >> F:\Mass-RebootWorkstations.log
    }
}