<#
Network and display tweaks in the style of Wagnardsoft WTools (written for Top Deck; no WTools code).
Field meanings are listed at the top of 01-Privacy.ps1.
#>

$interfacesKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'
# Network adapters that currently have an IPv4 address, as registry paths.
$getActiveInterfaces = {
    Get-ChildItem -Path $interfacesKey -ErrorAction SilentlyContinue | Where-Object {
        $p = Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue
        $ips = @()
        if ($p.PSObject.Properties['DhcpIPAddress']) { $ips += $p.DhcpIPAddress }
        if ($p.PSObject.Properties['IPAddress']) { $ips += @($p.IPAddress) }
        @($ips | Where-Object { $_ -and $_ -ne '0.0.0.0' }).Count -gt 0
    } | ForEach-Object { $_.PSPath }
}.GetNewClosure()

@(
    @{
        Id = 'gaming.nagle'; Name = "Turn off Nagle's algorithm"; Category = 'Gaming'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Source = 'TopDeck (WTools-style)'
        Description = 'Sends small network packets straight away instead of bundling them. Only helps games that use TCP (some MMOs such as World of Warcraft); most shooters use UDP and see no change.'
        Actions = @(
            @{
                Type = 'Command'
                Describe = 'Set TcpAckFrequency=1 and TCPNoDelay=1 on every connected network adapter'
                Test = {
                    $active = @(& $getActiveInterfaces)
                    if (-not $active.Count) { return $false }
                    foreach ($path in $active) {
                        $p = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
                        if (-not ($p.PSObject.Properties['TcpAckFrequency'] -and $p.TcpAckFrequency -eq 1 -and
                                  $p.PSObject.Properties['TCPNoDelay'] -and $p.TCPNoDelay -eq 1)) { return $false }
                    }
                    $true
                }.GetNewClosure()
                Backup = {
                    # One record per adapter: its path and the two values as they were (or $null if not set).
                    @(foreach ($path in & $getActiveInterfaces) {
                        $p = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
                        @{
                            Path    = $path
                            Ack     = if ($p.PSObject.Properties['TcpAckFrequency']) { $p.TcpAckFrequency } else { $null }
                            NoDelay = if ($p.PSObject.Properties['TCPNoDelay']) { $p.TCPNoDelay } else { $null }
                        }
                    })
                }.GetNewClosure()
                Apply = {
                    foreach ($path in & $getActiveInterfaces) {
                        New-ItemProperty -Path $path -Name TcpAckFrequency -Value 1 -PropertyType DWord -Force | Out-Null
                        New-ItemProperty -Path $path -Name TCPNoDelay -Value 1 -PropertyType DWord -Force | Out-Null
                    }
                }.GetNewClosure()
                Revert = {
                    param($Backup)
                    $records = @($Backup | Where-Object { $_ })
                    if (-not $records.Count) {
                        # No backup: these values don't exist on a fresh Windows install, so remove them.
                        $records = @(& $getActiveInterfaces | ForEach-Object { @{ Path = $_; Ack = $null; NoDelay = $null } })
                    }
                    foreach ($r in $records) {
                        foreach ($pair in @(@('TcpAckFrequency', $r.Ack), @('TCPNoDelay', $r.NoDelay))) {
                            if ($null -eq $pair[1]) { Remove-ItemProperty -Path $r.Path -Name $pair[0] -ErrorAction SilentlyContinue }
                            else { New-ItemProperty -Path $r.Path -Name $pair[0] -Value $pair[1] -PropertyType DWord -Force | Out-Null }
                        }
                    }
                }.GetNewClosure()
            }
        )
    }
    @{
        Id = 'gaming.mpo'; Name = 'Turn off Multi-Plane Overlay (MPO)'; Category = 'Gaming'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Source = 'TopDeck (WTools-style)'
        Description = 'Fixes flickering, black screens and stutter on some multi-monitor NVIDIA and AMD setups. Only use it if you have those problems: MPO saves power and can lower latency when it works.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm'; Name = 'OverlayTestMode'; Kind = 'DWord'; Value = 5; Default = 'Delete' }
        )
    }
    @{
        Id = 'privacy.cdp-services'; Name = 'Turn off Connected Devices services'; Category = 'Privacy'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Source = 'TopDeck (WTools-style)'
        Description = 'Stops the Connected Devices Platform services that link this PC to your phone and other PCs. Phone Link, Nearby Share and clipboard sync stop working.'
        Actions = @(
            @{ Type = 'Service'; Name = 'CDPSvc'; Startup = 'Disabled'; Default = 'Automatic' }
            @{ Type = 'Service'; Name = 'CDPUserSvc'; Startup = 'Disabled'; Default = 'Automatic' }
        )
    }
)
