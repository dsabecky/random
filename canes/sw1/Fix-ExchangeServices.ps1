$auto    = @('AppHostSvc', 'BFE', 'EventSystem', 'CryptSvc', 'UxSms', 'Dhcp', 'DiagTrack', 'TrkWks', 'Dnscache', 'EFS', 'IISADMIN', 'IKEEXT', 'MSExchangeADTopology', 'MSExchangeAB', 'MSExchangeAntispamUpdate', 'MSExchangeEdgeSync', 'MSExchangeFDS', 'MSExchangeFBA', 'MSExchangeImap4', 'MSExchangeIS', 'MSExchangeMailSubmission', 'MSExchangeMailboxAssistants', 'MSExchangeMailboxReplication', 'MSExchangeProtectedServiceHost', 'MSExchangeRepl', 'MSExchangeRPC', 'MSExchangeSearch', 'MSExchangeServiceHost', 'MSExchangeSA', 'MSExchangeThrottling', 'MSExchangeTransport', 'MSExchangeTransportLogSearch', 'NetPipeActivator', 'NetTcpActivator', 'NetTcpPortSharing', 'NqSmSvc', 'Netlogon', 'NlaSvc', 'nsi', 'NDMPAgent64', 'PlugPlay', 'Power', 'Spooler', 'RemoteRegistry', 'RMAgentPS', 'SamSs', 'LanmanServer', 'ShellHWDetection', 'SENS', 'lmhosts', 'ProfSvc', 'VSS', 'MpsSvc', 'Winmgmt', 'LanmanWorkstation', 'W3SVC', 'DPS', 'MSDTC', 'sppsvc', 'WinRM', 'wuauserv')
$manual  = @('AeLookupSvc', 'AppIDSvc', 'Appinfo', 'ALG', 'AppMgmt', 'aspnet_state', 'BITS', 'wbengine', 'CertPropSvc', 'KeyIso', 'COMSysApp', 'VaultSvc', 'WdiServiceHost', 'WdiSystemHost', 'defragsvc', 'EapHost', 'fdPHost', 'FDResPub', 'hkmsvc', 'hidserv', 'UI0Detect', 'IEEtwCollectorService', 'PolicyAgent', 'KtmRm', 'lltdsvc', 'MSExchangeMonitoring', 'wsbexchange', 'FCRegSvc', 'MSiSCSI', 'msftesql-Exchange', 'swprv', 'MMCSS', 'napagent', 'Netman', 'netprofm', 'PerfHost', 'pla', 'WPDBusEnum', 'ProtectedStorage', 'SessionEnv', 'TermService', 'UmRdpService', 'RpcLocator', 'RM_ExchangeInterface', 'RSoPProv', 'RPCHTTPLBS', 'seclogon', 'SstpSvc', 'SCardSvr', 'SCPolicySvc', 'sacsvr', 'sppuinotify', 'WiaRpc', 'WebClient', 'TrustedInstaller', 'FontCache3.0.0.0', 'WAS', 'W32Time', 'WinHttpAutoProxySvc', 'wmiApSrv')

Write-Host -NoNewLine "Are you on on Exchange? "
if ($env:ComputerName -NotMatch "^EX0[12]$") { Write-Host "Nope!"; Read-Host "Press Enter to exit"; exit 1 }
else { Write-Host "Yuhh!" }

Write-Host "Checking automatic services..."
ForEach ($svc in $auto) {
    Write-Host -NoNewLine "Configuring $svc... "
    if (-Not (Get-Service $svc 2> $null)) { Write-Host "non-existant!" }
    else { Set-Service -Name $svc -StartupType "Automatic"; Write-Host "set!" }
}

Write-Host "Checking manual services..."
ForEach ($svc in $manual) {
    Write-Host -NoNewLine "Configuring $svc... "
    if (-Not (Get-Service $svc 2> $null)) { Write-Host "non-existant!" }
    else { Set-Service -Name $svc -StartupType "Manual"; Write-Host "set!" }
}

Write-Host "Jobs done!"
Read-Host "Press Enter to exit"
exit 0