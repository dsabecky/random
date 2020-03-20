# Name: IsValidHost
# Description: Checks server name against the host type.
# Example: IsValidHost('dc')
#####################################################################
function IsValidHost($Type) {
    if ($Type -eq 'dc' -And $env:ComputerName -Match '^DC0[12]$') { return $True }
    elseif ($Type -eq 'mts' -And $env:ComputerName -Match '^MTS(2|)$') { return $True }
    elseif ($Type -eq 'ex' -And $env:ComputerName -Match '^EX0[12]$|IAEXET') { return $True }
    else { return $False }
}

$Exec = "\\DC01\Software\SabeckyScripts"