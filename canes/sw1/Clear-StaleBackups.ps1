Write-Host -NoNewLine "Checking server... "
if ($env:computername -NotMatch "^BU0[12]$") { Write-Host "WRONG SERVER BUD"; Read-Host "Press Enter to exit"; exit 1 }
Write-Host "OK! We gucci."

Write-Host "`nClearing G:..."
Start-Sleep 3

Set-Location "G:\"
Get-ChildItem "G:\NW_Backup" |
Where-Object { $_.Name -Match "^[0-9]{2}$" } |
ForEach-Object {
    $FP = $_.FullName
    Get-ChildItem $FP |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-31) } |
    % { echo y | cmd.exe /c rmdir /s $_.FullName }
}

Write-Host "`nClearing H:..."
Start-Sleep 3

Set-Location "H:\"
Get-ChildItem "H:\NW_Backup3" |
Where-Object { $_.Name -Match "^[0-9]{2}$" } |
ForEach-Object {
    $FP = $_.FullName
    Get-ChildItem $FP |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-31) } |
    % { echo y | cmd.exe /c rmdir /s $_.FullName }
}

Write-Host "`nClearing INDEX:..."
Start-Sleep 3

Set-Location "F:\Program Files\Legato\nsr"
Get-ChildItem "F:\Program Files\Legato\nsr\index" |
ForEach-Object {
    $FP = $_.FullName
    Get-ChildItem $FP\db6 |
    Where-Object { $_.Name -NotMatch "v6hdr.lck|v6journal|v6hdr" -and $_.LastWriteTime -lt (Get-Date).AddDays(-31) } |
    % { echo y | cmd.exe /c rmdir /s $_.FullName }
}

Write-Host "Jobs done!"
Read-Host "Press Enter to exit"