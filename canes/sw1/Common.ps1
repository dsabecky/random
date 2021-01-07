# check if dc01/2 or rodc
if ($env:computername -NotMatch '^(RODC|DC0[12])$') { exit 1 }

# check if mts/2
if ($env:computername -NotMatch '^mts(2|)$') { exit 1 }

# check if ex01/2
if ($env:computername -NotMatch '^ex0[12]$') { exit 1 }