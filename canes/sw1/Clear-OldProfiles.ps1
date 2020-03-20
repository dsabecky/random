#configure me
$Exec = "\\dc01\software\Scripts\Clear-OldProfiles.ps1"

function IsValidHost($Type) {
    if ($Type -eq 'dc' -And $env:ComputerName -Match '^DC0[12]$') { return $True }
    elseif ($Type -eq 'mts' -And $env:ComputerName -Match '^MTS(2|)$') { return $True }
    elseif ($Type -eq 'ex' -And $env:ComputerName -Match '^EX0[12]$|IAEXET') { return $True }
    else { return $False }
}