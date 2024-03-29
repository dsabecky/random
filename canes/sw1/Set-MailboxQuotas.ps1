if ($env:ComputerName -NotMatch "^EX0[1-2]$") { Write-Output "TRY AGAIN FROM AN EXCHANGE HUB!"; Read-Host "Press Enter to exit"; exit 1 }
Write-Output "Valid host!"

Write-Output "Loading Exchange modules..."
. 'C:\Program Files\Microsoft\Exchange Server\V14\Bin\RemoteExchange.ps1'

Write-Output "Connecting to localhost..."
Connect-ExchangeServer $env:ComputerName

Write-Host "Building CSV..."
Get-Mailbox -Database "Expansion4" -ResultSize "Unlimited" | Select-Object SamAccountName, DisplayName | Export-CSV F:\MailboxQuotas.csv -NoTypeInformation

Write-Host "Setting mailbox quotas..."
Import-CSV F:\MailboxQuotas.csv | ForEach-Object {
    $sam = $_.SamAccountName
    $dn  = $_.DisplayName
    Write-Host "Setting $dn..."
    Set-Mailbox $sam -UseDatabaseQuotaDefaults $True -ProhibitSendReceiveQuota "1000MB" -IssueWarningQuota "900MB" -ProhibitSendQuota "1000MB"
}