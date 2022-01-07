# WEB SHARE S:\
# IAEXET F:\
# EX01 F:\
# EX02 F:\
# PKI F:\
# BUEM F:\

$creds = Get-Credential

New-PSDrive -Name "S" -Root "\\web\share"     -Persist -PSProvider "Filesystem" -Credential $creds
New-PSDrive -Name "I" -Root "\\iaexet\f$"     -Persist -PSProvider "Filesystem" -Credential $creds
New-PSDrive -Name "J" -Root "\\ex01\f$"       -Persist -PSProvider "Filesystem" -Credential $creds
New-PSDrive -Name "K" -Root "\\ex02\f$"       -Persist -PSProvider "Filesystem" -Credential $creds
New-PSDrive -Name "P" -Root "\\pki\f$"        -Persist -PSProvider "Filesystem" -Credential $creds
New-PSDrive -Name "T" -Root "\\dc01\software" -Persist -PSProvider "Filesystem" -Credential $creds