$Switches  = @("u-eua-sw-101", "u-eua-sw-102", "u-eua-sw-121", "u-eua-sw-122", "u-eua-sw-123", "u-eua-sw-124", "u-eua-sw-125", "u-eua-sw-126", "u-eua-sw-127", "u-eua-sw-128", "u-eua-sw-129", "u-eua-sw-130", "u-eua-sw-131", "u-eua-sw-132", "u-eua-sw-133", "u-eua-sw-134", "u-eua-sw-135")
$Routers   = @("u-bb-rtr-101", "u-bor-rtr-108")
$Firewalls = @("u-bor-fw-108")
$ISE       = @("u-ise-107")

$Devices = @($Switches, $Routers, $Firewalls, $UPS)

while (1 -eq 1) {
    Write-Host "Testing Switch connectivity"
    Write-Host "------------------------------"
    $Switches | ForEach-Object {
        Write-Host -NoNewLine "$_ : "
        if (Test-Connection -Count 1 $_) { Write-Host "CONNECTED" }
        else { Write-Host "FAILED" }
    }
    
    Write-Host ""; Write-Host "Testing Router connectivity"
    Write-Host "------------------------------"
    $Routers | ForEach-Object {
        Write-Host -NoNewLine "$_.ToUpper() : "
        if (Test-Connection -Count 1 $_) { Write-Host "CONNECTED" }
        else { Write-Host "FAILED" }
    }
    
    Write-Host ""; Write-Host "Testing Firewall connectivity"
    Write-Host "------------------------------"
    $Firewalls | ForEach-Object {
        Write-Host -NoNewLine "$_.ToUpper() : "
        if (Test-Connection -Count 1 $_) { Write-Host "CONNECTED" }
        else { Write-Host "FAILED" }
    }
    
    Write-Host ""; Write-Host "Testing ISE connectivity"
    Write-Host "------------------------------"
    $ISE | ForEach-Object {
        Write-Host -NoNewLine "$_.ToUpper() : "
        if (Test-Connection -Count 1 $_) { Write-Host "CONNECTED" }
        else { Write-Host "FAILED" }
    }
    
    Write-Host ""; Write-Host "Sleeping for 30 seconds before retesting..."
    Start-Sleep 30
    clear
}