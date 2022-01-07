# check correct server
write-host -NoNewline "domain controller check... "
if ($env:computername -Match "^DC0[12]$") { echo "yeet." }
else { "ugh. try again from domain controller."; read-host "press enter to exit"; exit 1 }

# create log hashtable
$log=@()

# build the logfile name
$logfile="F:\security-" + $(get-date -format yyyy-MM-dd-HH-mm) + ".csv"
echo "the log will be available at $logfile`.`n`n"

# set the right path
cd C:\Windows\System32\winevt\Logs
#echo $((pwd).Path)

# find all log files
$Logs=ls | where { $_.Name -Match "^(|Archive-)Security.*`.evtx" } | select Name
#$($Logs).Name

# itorate through the logs
$Logs | foreach {
    # grab logname
    $l=$_.Name

    # parse through logs (can only do 1 id per hashtable)
    write-host -nonewline "Parsing $l..."
    $log+=get-winevent -filterhashtable @{logname='security';path="$l";keywords=9007199254740992;id=4722;} 2> $Null
    $log+=get-winevent -filterhashtable @{logname='security';path="$l";keywords=9007199254740992;id=4756;} 2> $Null
    $log+=get-winevent -filterhashtable @{logname='security';path="$l";keywords=9007199254740992;id=4757;} 2> $Null
    $log+=get-winevent -filterhashtable @{logname='security';path="$l";keywords=9007199254740992;id=4758;} 2> $Null
    $log+=get-winevent -filterhashtable @{logname='security';path="$l";keywords=9007199254740992;id=4738;} 2> $Null

    <#write-host -nonewline " archiving... "
    Start-Sleep 2
    if ($l -NotMatch "Security.evtx$") { move $l o:\Logs\ }#>
    write-host " done."
}

# save to a .csv and open it in notepad
$log | select TimeCreated, ID, Message | sort TimeCreated | Export-CSV $logfile -notypeinformation
notepad $logfile

<#

    #$l="Archive-Security-2020-07-03-14-47-21-847.evtx"
    #get-winevent -FilterHashtable @{logname='security';path="Archive-Security-2020-07-03-14-47-21-847.evtx";keywords=9007199254740992;}

        Audit Success (Keyword) : 9007199254740992
          User enabled/disabled : 4722
        User was added to group : 4756
    User was removed from group : 4757
              Group was removed : 4758
       User account was changed : 4738

#>