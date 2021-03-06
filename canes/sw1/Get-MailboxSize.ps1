# edit pls
$ExPs  = 'C:\Program Files\Microsoft\Exchange Server\V14\Bin\RemoteExchange.ps1'
$ExSrv = 'EX01'

# validate correct server
Write-Host -NoNewLine "Checking host... "
if ($env:ComputerName -NotMatch "^EX0[12]$") { Read-Host -Prompt "Please run from an Exchange hub server!"; exit }
else { Write-Host "valid!" }

# load modules & connect
Write-Host "Loading modules... "
. $ExPs
Connect-ExchangeServer $ExSrv

# 
Write-Host "Gathering mailboxes..."
Write-Host "" > C:\Mailbox.txt
Get-MailboxDatabase | ForEach-Object {
    $Server=$_.Server
    Write-Host "...for $Server"
    Get-MailboxStatistics -Server $Server |
    Sort-Object TotalItemSize -Descending |
    Format-Table DisplayName, Database, TotalItemSize >> C:\Mailbox.txt
}

Read-Host -Prompt "Jobs done!"