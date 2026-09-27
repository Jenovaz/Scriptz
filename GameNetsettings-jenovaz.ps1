# ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗    ██████╗ ██╗   ██╗
# ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝    ██╔══██╗╚██╗ ██╔╝
# ███████╗██║     ██████╔╝██║██████╔╝   ██║       ██████╔╝ ╚████╔╝
# ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║       ██╔══██╗  ╚██╔╝
# ███████║╚██████╗██║  ██║██║██║        ██║       ██████╔╝   ██║
# ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝       ╚═════╝    ╚═╝
#
#      ██╗███████╗███╗   ██╗ ██████╗ ██╗   ██╗ █████╗ ███████╗
#      ██║██╔════╝████╗  ██║██╔═══██╗██║   ██║██╔══██╗╚══███╔╝
#      ██║█████╗  ██╔██╗ ██║██║   ██║██║   ██║███████║  ███╔╝
# ██   ██║██╔══╝  ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║ ███╔╝
# ╚█████╔╝███████╗██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║███████╗
#  ╚════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚══════╝
#
<#
GameNet.ps1 - cut lag spikes when gaming on a laptop over a phone's 5G hotspot (Wi-Fi).

Modes:
  Check    Shows your connection and runs a ping test. Changes nothing. No admin needed.
  Game     Saves your current settings to a backup file, then applies the gaming tweaks. Needs admin.
  Restore  Puts everything back from the backup. Needs admin. Run this when you finish gaming.

Run it with no options to get a menu:
  powershell -ExecutionPolicy Bypass -File .\GameNet.ps1

Or pick a mode directly:
  powershell -ExecutionPolicy Bypass -File .\GameNet.ps1 -Mode Check
  powershell -ExecutionPolicy Bypass -File .\GameNet.ps1 -Mode Game
  powershell -ExecutionPolicy Bypass -File .\GameNet.ps1 -Mode Restore

Optional:
  -Target <IP or hostname>   ping a specific game server instead of 1.1.1.1
  -Seconds <10-600>          length of the ping test (default 60)

Assumes English-language Windows (it reads text output from netsh and powercfg).
#>
[CmdletBinding()]
param(
    [ValidateSet('Check', 'Game', 'Restore')]
    [string]$Mode,

    [string]$Target = '1.1.1.1',

    [ValidateRange(10, 600)]
    [int]$Seconds = 60,

    [switch]$Pause   # used by the menu: keeps the admin window open until you press Enter
)

$BackupPath    = Join-Path $PSScriptRoot 'GameNet-backup.json'
$HighPerfGuid  = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'   # built-in High Performance power plan
$WifiPowerGuid = '12bbebe6-58d6-4636-95bb-3217ef867c1a'   # Wireless Adapter Settings > Power Saving Mode
$PauseServices = @('wuauserv', 'BITS', 'DoSvc')            # Windows Update, background transfers, Delivery Optimization
$GuidPattern   = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

# ============================================================ helpers

function Test-Admin {
    $p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Admin {
    if (-not (Test-Admin)) {
        Write-Host "This mode needs admin. Run it from the menu (it asks for admin itself), or from an admin PowerShell window." -ForegroundColor Red
        return $false
    }
    $true
}

# Runs netsh with an exact argument string (safe for hotspot names with spaces or apostrophes).
function Invoke-Netsh([string]$Arguments) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'netsh.exe'
    $psi.Arguments = $Arguments
    $psi.RedirectStandardOutput = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $out = $p.StandardOutput.ReadToEnd()
    $p.WaitForExit()
    [pscustomobject]@{ ExitCode = $p.ExitCode; Lines = ($out -split "`r?`n") }
}

function Get-WlanInfo {
    $r = Invoke-Netsh 'wlan show interfaces'
    $info = @{}
    foreach ($line in $r.Lines) {
        if ($line -match '^\s+([^:]+?)\s+:\s(.*)$') {
            $key = $Matches[1].Trim()
            if (-not $info.ContainsKey($key)) { $info[$key] = $Matches[2].Trim() }
        }
    }
    if ($info['State'] -ne 'connected') { return $null }
    [pscustomobject]$info
}

function Wait-WifiConnected([int]$TimeoutSec = 30) {
    for ($i = 0; $i -lt $TimeoutSec; $i++) {
        if (Get-WlanInfo) { return $true }
        Start-Sleep -Seconds 1
    }
    $false
}

function Get-AutoConfig([string]$IfName) {
    $pattern = 'Auto configuration logic is (enabled|disabled) on interface "' + [regex]::Escape($IfName) + '"'
    foreach ($line in (Invoke-Netsh 'wlan show settings').Lines) {
        if ($line -match $pattern) { return ($Matches[1] -eq 'enabled') }
    }
    $null
}

function Get-ProfileCost([string]$ProfileName) {
    foreach ($line in (Invoke-Netsh ('wlan show profile name="{0}"' -f $ProfileName)).Lines) {
        if ($line -match '^\s+Cost\s+:\s+(\S+)') { return $Matches[1] }
    }
    $null
}

function Get-DefaultGateway([string]$InterfaceAlias) {
    $r = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -InterfaceAlias $InterfaceAlias -ErrorAction SilentlyContinue |
         Sort-Object RouteMetric | Select-Object -First 1
    if ($r) { $r.NextHop } else { $null }
}

function Get-ActiveScheme {
    $line = "$(powercfg /getactivescheme)"
    if ($line -match "($GuidPattern)\s+\((.*)\)") {
        [pscustomobject]@{ Guid = $Matches[1]; Name = $Matches[2] }
    }
}

function Get-WifiPowerSubgroup([string]$Scheme) {
    $sub = $null
    foreach ($line in (powercfg /q $Scheme)) {
        if ($line -match "Subgroup GUID:\s+($GuidPattern)") { $sub = $Matches[1] }
        elseif ($line -match "Power Setting GUID:\s+$WifiPowerGuid") { return $sub }
    }
    $null
}

function Get-PowerValue([string]$Scheme, [string]$Sub, [string]$Setting) {
    $ac = $null; $dc = $null
    foreach ($line in (powercfg /q $Scheme $Sub $Setting)) {
        if ($line -match 'Current AC Power Setting Index:\s+0x([0-9a-fA-F]+)') { $ac = [Convert]::ToInt32($Matches[1], 16) }
        if ($line -match 'Current DC Power Setting Index:\s+0x([0-9a-fA-F]+)') { $dc = [Convert]::ToInt32($Matches[1], 16) }
    }
    [pscustomobject]@{ AC = $ac; DC = $dc }
}

function Invoke-PingTest([string[]]$Targets, [int]$Seconds) {
    $pinger = New-Object System.Net.NetworkInformation.Ping
    $results = @{}
    foreach ($t in $Targets) { $results[$t] = New-Object System.Collections.Generic.List[object] }
    for ($i = 1; $i -le $Seconds; $i++) {
        $start = Get-Date
        foreach ($t in $Targets) {
            try {
                $reply = $pinger.Send($t, 1000)
                if ($reply.Status -eq 'Success') { $results[$t].Add([int]$reply.RoundtripTime) } else { $results[$t].Add($null) }
            } catch { $results[$t].Add($null) }
        }
        Write-Progress -Activity 'Ping test' -Status "$i of $Seconds seconds" -PercentComplete ($i / $Seconds * 100)
        $wait = [int](1000 - ((Get-Date) - $start).TotalMilliseconds)
        if ($wait -gt 0) { Start-Sleep -Milliseconds $wait }
    }
    Write-Progress -Activity 'Ping test' -Completed
    $results
}

function Get-PingStats([string]$Label, $Samples) {
    $all = [object[]]$Samples.ToArray()
    $ok  = @($all | Where-Object { $null -ne $_ })
    $loss = if ($all.Count) { [math]::Round(100 * ($all.Count - $ok.Count) / $all.Count, 1) } else { 100 }
    if ($ok.Count -eq 0) {
        return [pscustomobject]@{ Target = $Label; 'Loss %' = $loss; 'Avg ms' = $null; 'Min ms' = $null; 'Max ms' = $null; 'Jitter ms' = $null; Spikes = $null }
    }
    $diffs = @(for ($j = 1; $j -lt $ok.Count; $j++) { [math]::Abs($ok[$j] - $ok[$j - 1]) })
    $jitter = if ($diffs.Count) { ($diffs | Measure-Object -Average).Average } else { 0 }
    $sorted = @($ok | Sort-Object)
    $median = $sorted[[int][math]::Floor($sorted.Count / 2)]
    $spikeAt = [math]::Max($median * 2, $median + 30)
    [pscustomobject]@{
        Target      = $Label
        'Loss %'    = $loss
        'Avg ms'    = [math]::Round(($ok | Measure-Object -Average).Average, 1)
        'Min ms'    = $sorted[0]
        'Max ms'    = $sorted[-1]
        'Jitter ms' = [math]::Round($jitter, 1)
        Spikes      = @($ok | Where-Object { $_ -gt $spikeAt }).Count
    }
}

# ============================================================ Check

function Show-Status {
    $w = Get-WlanInfo
    $gateway = $null

    Write-Host "`n=== Connection ===" -ForegroundColor Cyan
    if ($w) {
        $band = if ($w.PSObject.Properties['Band']) { $w.Band }
                elseif ($w.Channel -match '^\d+$') { if ([int]$w.Channel -le 14) { '2.4 GHz' } else { '5 GHz' } }
                else { 'Unknown' }
        Write-Host ("Hotspot       : {0}" -f $w.SSID)
        Write-Host ("Band          : {0}  (channel {1}, {2})" -f $band, $w.Channel, $w.'Radio type')
        Write-Host ("Wi-Fi signal  : {0}" -f $w.Signal)
        Write-Host ("Link speed    : {0} down / {1} up Mbps" -f $w.'Receive rate (Mbps)', $w.'Transmit rate (Mbps)')
        if ($band -like '2.4*') {
            Write-Host "  ! On 2.4 GHz. Switch the hotspot to 5 GHz (iPhone: turn OFF 'Maximise Compatibility'; Android: set hotspot band to 5 GHz)." -ForegroundColor Yellow
        }
        $sig = 0; [void][int]::TryParse(($w.Signal -replace '\D', ''), [ref]$sig)
        if ($sig -gt 0 -and $sig -lt 70) { Write-Host "  ! Weak Wi-Fi signal. Put the phone closer to the laptop." -ForegroundColor Yellow }
        $gateway = Get-DefaultGateway $w.Name
    } else {
        Write-Host "Not connected over Wi-Fi." -ForegroundColor Yellow
    }

    Write-Host "`n=== Laptop ===" -ForegroundColor Cyan
    $scheme = Get-ActiveScheme
    Write-Host ("Power plan    : {0}" -f $(if ($scheme) { $scheme.Name } else { 'Unknown' }))
    $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($bat -and $bat.BatteryStatus -eq 1) {
        Write-Host "Power source  : BATTERY - plug in for gaming; Windows throttles Wi-Fi and CPU on battery" -ForegroundColor Yellow
    } else {
        Write-Host "Power source  : Plugged in"
    }
    if ($w) {
        $cost = Get-ProfileCost $w.Profile
        Write-Host ("Metered       : {0}" -f $(if ($cost -in 'Fixed', 'Variable') { 'Yes' } elseif ($cost) { 'No' } else { 'Unknown' }))
        $ac = Get-AutoConfig $w.Name
        Write-Host ("Wi-Fi scans   : {0}" -f $(if ($ac -eq $true) { 'On (causes periodic ping spikes)' } elseif ($ac -eq $false) { 'Off' } else { 'Unknown' }))
    }
    Write-Host ("Game mode     : {0}" -f $(if (Test-Path $BackupPath) { 'ON - turn it OFF when finished' } else { 'Off' }))

    Write-Host "`n=== Ping test: $Seconds seconds (pause downloads while it runs) ===" -ForegroundColor Cyan
    $targets = @()
    if ($gateway) { $targets += $gateway }
    $targets += $Target
    $samples = Invoke-PingTest -Targets $targets -Seconds $Seconds
    $rows = @(foreach ($t in $targets) {
        $label = if ($t -eq $gateway) { "Phone (Wi-Fi hop) $t" } else { "Internet $t" }
        Get-PingStats -Label $label -Samples $samples[$t]
    })
    $rows | Format-Table -AutoSize | Out-String | Write-Host

    $gw  = if ($gateway) { $rows[0] } else { $null }
    $net = $rows[-1]
    $gwNoPing = $gw -and $gw.'Loss %' -eq 100 -and $net.'Loss %' -lt 100
    $wifiBad  = $gw -and -not $gwNoPing -and ($gw.'Loss %' -gt 0 -or $gw.'Jitter ms' -gt 10)
    $netBad   = ($net.'Loss %' -ge 1) -or ($net.'Jitter ms' -gt 15) -or ($net.Spikes -gt [math]::Max(2, $Seconds / 20))

    Write-Host "Rough guide:" -ForegroundColor Cyan
    if ($gwNoPing) { Write-Host "- Your phone doesn't answer pings, so the Wi-Fi hop can't be tested separately." }
    if ($wifiBad) {
        Write-Host "- The Wi-Fi hop between laptop and phone is unstable. Fix this first: phone closer, 5 GHz, or USB tethering (most reliable)." -ForegroundColor Yellow
    } elseif ($netBad) {
        Write-Host "- Laptop-to-phone is fine; the instability is on the 5G side. Put the phone by a window, turn off its battery saver," -ForegroundColor Yellow
        Write-Host "  keep it charging and uncovered, and compare different times of day (evening tower congestion is common)." -ForegroundColor Yellow
    } else {
        Write-Host "- Stable enough for gaming. If a game still lags, the cause is more likely the game server or its route than your connection." -ForegroundColor Green
    }
    Write-Host "Jitter = how much ping jumps between pings (what you feel as stutter). Spikes = pings well above your normal." -ForegroundColor DarkGray
}

# ============================================================ Game

function Enable-GameMode {
    if (-not (Assert-Admin)) { return }
    if (Test-Path $BackupPath) {
        Write-Host "Game mode is already on (backup exists: $BackupPath)." -ForegroundColor Yellow
        Write-Host "Turn Game mode OFF first. Running it twice would overwrite your original settings."
        return
    }
    $w = Get-WlanInfo
    if (-not $w) { Write-Host "Connect to your phone's hotspot first, then run this again." -ForegroundColor Red; return }

    $ifName      = $w.Name
    $wifiProfile = $w.Profile
    $scheme      = Get-ActiveScheme
    if (-not $scheme) { Write-Host "Couldn't read the current power plan. Stopping without changing anything." -ForegroundColor Red; return }
    $hasHighPerf = [bool]((powercfg /list) -match $HighPerfGuid)

    # ---- 1. Record the original value of everything we're about to change
    $b = [ordered]@{
        Created        = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Interface      = $ifName
        WifiProfile    = $wifiProfile
        OriginalScheme = $scheme.Guid
        TargetScheme   = $(if ($hasHighPerf) { $HighPerfGuid } else { $scheme.Guid })
        WifiPowerSub   = $null
        WifiPowerAC    = $null
        WifiPowerDC    = $null
        NicTurnOff     = $null
        AutoConfig     = $null
        ProfileCost    = $null
        Services       = @()
        OneDrivePath   = $null
    }

    $sub = Get-WifiPowerSubgroup $b.TargetScheme
    if ($sub) {
        $v = Get-PowerValue $b.TargetScheme $sub $WifiPowerGuid
        if ($null -ne $v.AC -and $null -ne $v.DC -and ($v.AC -ne 0 -or $v.DC -ne 0)) {
            $b.WifiPowerSub = $sub; $b.WifiPowerAC = $v.AC; $b.WifiPowerDC = $v.DC
        }
    }
    try {
        $pm = Get-NetAdapterPowerManagement -Name $ifName -ErrorAction Stop
        if ("$($pm.AllowComputerToTurnOffDevice)" -eq 'Enabled') { $b.NicTurnOff = 'Enabled' }
    } catch { }
    if ((Get-AutoConfig $ifName) -eq $true) { $b.AutoConfig = 'enabled' }
    $cost = Get-ProfileCost $wifiProfile
    if ($cost -eq 'Unrestricted') { $b.ProfileCost = $cost }
    foreach ($s in $PauseServices) {
        $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -eq 'Running') { $b.Services += $s }
    }
    $od = Get-Process -Name OneDrive -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($od -and $od.Path) { $b.OneDrivePath = $od.Path }

    $b | ConvertTo-Json | Set-Content -Path $BackupPath -Encoding UTF8
    Write-Host "Saved current settings to $BackupPath" -ForegroundColor Green

    # ---- 2. Apply changes
    $done = New-Object System.Collections.Generic.List[string]
    $notDone = New-Object System.Collections.Generic.List[string]

    # Adapter power management first, because the driver may briefly drop Wi-Fi while it applies.
    if ($b.NicTurnOff) {
        try {
            Set-NetAdapterPowerManagement -Name $ifName -AllowComputerToTurnOffDevice Disabled -ErrorAction Stop
            $done.Add('Wi-Fi adapter: Windows can no longer switch it off to save power')
        } catch { $notDone.Add("Wi-Fi adapter power management: driver refused the change") }
    } else { $notDone.Add('Wi-Fi adapter power management: already off or not supported by the driver') }

    if ($b.ProfileCost) {
        $r = Invoke-Netsh ('wlan set profileparameter name="{0}" cost=Fixed' -f $wifiProfile)
        if ($r.ExitCode -eq 0) { $done.Add('Hotspot set to metered: Windows Update and Store downloads hold off') }
        else { $notDone.Add('Metered setting: netsh refused the change') }
    } else { $notDone.Add('Metered setting: hotspot already treated as metered') }

    if (-not (Wait-WifiConnected 30)) {
        Write-Host "Wi-Fi didn't reconnect within 30 seconds. Stopping here." -ForegroundColor Red
        Write-Host "Reconnect to the hotspot manually, then turn Game mode OFF to undo what was changed."
        return
    }

    if ($b.TargetScheme -ne $b.OriginalScheme) {
        powercfg /setactive $b.TargetScheme | Out-Null
        $done.Add('Power plan: High Performance')
    } elseif (-not $hasHighPerf) {
        $notDone.Add("Power plan: High Performance isn't available on this laptop. Set Power mode to 'Best performance' yourself (Settings > System > Power & battery).")
    }
    if ($b.WifiPowerSub) {
        powercfg /setacvalueindex $b.TargetScheme $b.WifiPowerSub $WifiPowerGuid 0 | Out-Null
        powercfg /setdcvalueindex $b.TargetScheme $b.WifiPowerSub $WifiPowerGuid 0 | Out-Null
        powercfg /setactive $b.TargetScheme | Out-Null
        $done.Add('Wi-Fi power saving: Maximum Performance (plugged in and on battery)')
    } else { $notDone.Add('Wi-Fi power saving: already Maximum Performance or not exposed on this laptop') }

    if ($b.AutoConfig) {
        $r = Invoke-Netsh ('wlan set autoconfig enabled=no interface="{0}"' -f $ifName)
        if ($r.ExitCode -eq 0) { $done.Add("Wi-Fi background scanning: off (Wi-Fi won't auto-reconnect until you Restore)") }
        else { $notDone.Add('Wi-Fi background scanning: netsh refused the change') }
    } else { $notDone.Add('Wi-Fi background scanning: already off') }

    foreach ($s in $b.Services) {
        try { Stop-Service -Name $s -Force -ErrorAction Stop; $done.Add("Paused service: $s") }
        catch { $notDone.Add("Couldn't pause $s (Windows protects it on some versions); the metered setting still limits it") }
    }

    if ($b.OneDrivePath) {
        Get-Process -Name OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        $done.Add('OneDrive: closed (restarts on Restore)')
    }

    Write-Host "`n=== Game mode ON ===" -ForegroundColor Green
    $done | ForEach-Object { Write-Host "  + $_" }
    if ($notDone.Count) {
        Write-Host "`nNot changed:" -ForegroundColor DarkGray
        $notDone | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkGray }
    }
    Write-Host "`nAlso pause Steam / Epic / Discord / game-launcher updates yourself." -ForegroundColor Yellow
    Write-Host "When you're done gaming, run this again and choose Game mode OFF." -ForegroundColor Yellow
}

# ============================================================ Restore

function Disable-GameMode {
    if (-not (Assert-Admin)) { return }
    if (-not (Test-Path $BackupPath)) {
        Write-Host "Game mode isn't on - nothing to restore."
        return
    }
    $b = Get-Content -Path $BackupPath -Raw | ConvertFrom-Json

    # Scanning back on first so Wi-Fi can reconnect by itself if anything below drops it.
    if ($b.AutoConfig -eq 'enabled') {
        $r = Invoke-Netsh ('wlan set autoconfig enabled=yes interface="{0}"' -f $b.Interface)
        if ($r.ExitCode -eq 0) { Write-Host "  + Wi-Fi background scanning: back on" } else { Write-Host "  ! Couldn't turn Wi-Fi scanning back on" -ForegroundColor Red }
    }
    if ($b.ProfileCost) {
        $r = Invoke-Netsh ('wlan set profileparameter name="{0}" cost={1}' -f $b.WifiProfile, $b.ProfileCost)
        if ($r.ExitCode -eq 0) { Write-Host "  + Hotspot metered setting: back to $($b.ProfileCost)" } else { Write-Host "  ! Couldn't restore the metered setting" -ForegroundColor Red }
    }
    if ($b.WifiPowerSub) {
        powercfg /setacvalueindex $b.TargetScheme $b.WifiPowerSub $WifiPowerGuid $b.WifiPowerAC | Out-Null
        powercfg /setdcvalueindex $b.TargetScheme $b.WifiPowerSub $WifiPowerGuid $b.WifiPowerDC | Out-Null
        Write-Host "  + Wi-Fi power saving: back to original"
    }
    powercfg /setactive $b.OriginalScheme | Out-Null
    Write-Host "  + Power plan: back to original"
    if ($b.NicTurnOff -eq 'Enabled') {
        try {
            Set-NetAdapterPowerManagement -Name $b.Interface -AllowComputerToTurnOffDevice Enabled -ErrorAction Stop
            Write-Host "  + Wi-Fi adapter power management: back to original"
        } catch { Write-Host "  ! Couldn't restore Wi-Fi adapter power management" -ForegroundColor Red }
    }
    foreach ($s in @($b.Services)) {
        if (-not $s) { continue }
        try { Start-Service -Name $s -ErrorAction Stop; Write-Host "  + Restarted service: $s" }
        catch { Write-Host "  - $s didn't start now; Windows starts it again when needed" -ForegroundColor DarkGray }
    }
    if ($b.OneDrivePath -and (Test-Path $b.OneDrivePath) -and -not (Get-Process -Name OneDrive -ErrorAction SilentlyContinue)) {
        # Launch through Explorer so OneDrive runs as you, not as admin.
        Start-Process -FilePath explorer.exe -ArgumentList ('"{0}"' -f $b.OneDrivePath)
        Write-Host "  + OneDrive: started"
    }

    $newName = 'GameNet-backup-restored-{0}.json' -f (Get-Date -Format 'yyyyMMdd-HHmmss')
    Rename-Item -Path $BackupPath -NewName $newName
    Write-Host "`n=== Restored. Backup kept as $newName ===" -ForegroundColor Green
}

# ============================================================ menu

$Banner = @'
 ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗    ██████╗ ██╗   ██╗
 ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝    ██╔══██╗╚██╗ ██╔╝
 ███████╗██║     ██████╔╝██║██████╔╝   ██║       ██████╔╝ ╚████╔╝
 ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║       ██╔══██╗  ╚██╔╝
 ███████║╚██████╗██║  ██║██║██║        ██║       ██████╔╝   ██║
 ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝       ╚═════╝    ╚═╝

      ██╗███████╗███╗   ██╗ ██████╗ ██╗   ██╗ █████╗ ███████╗
      ██║██╔════╝████╗  ██║██╔═══██╗██║   ██║██╔══██╗╚══███╔╝
      ██║█████╗  ██╔██╗ ██║██║   ██║██║   ██║███████║  ███╔╝
 ██   ██║██╔══╝  ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║ ███╔╝
 ╚█████╔╝███████╗██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║███████╗
  ╚════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚══════╝
'@

# Runs one mode, asking Windows for admin first if this window doesn't have it.
function Invoke-AdminMode([string]$RunMode) {
    if (Test-Admin) {
        if ($RunMode -eq 'Game') { Enable-GameMode } else { Disable-GameMode }
        return
    }
    Write-Host "Asking Windows for admin permission (click Yes)..." -ForegroundColor Cyan
    $argLine = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -Mode {1} -Pause' -f $PSCommandPath, $RunMode
    try {
        Start-Process -FilePath powershell.exe -Verb RunAs -ArgumentList $argLine -Wait -ErrorAction Stop
    } catch {
        Write-Host "Admin permission was declined, so nothing was changed." -ForegroundColor Yellow
    }
}

function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host $Banner -ForegroundColor Green
        $state = if (Test-Path $BackupPath) { 'ON' } else { 'OFF' }
        Write-Host "  GameNet - laptop gaming over a 5G phone hotspot" -ForegroundColor Cyan
        Write-Host ("  Game mode is currently: {0}`n" -f $state) -ForegroundColor $(if ($state -eq 'ON') { 'Green' } else { 'Gray' })
        Write-Host "  [1]  Check connection   (ping test, changes nothing)"
        Write-Host "  [2]  Game mode ON       (applies the tweaks, saves a backup first)"
        Write-Host "  [3]  Game mode OFF      (puts everything back)"
        Write-Host "  [Q]  Quit`n"
        $choice = (Read-Host "  Choose").Trim().ToUpper()
        switch ($choice) {
            '1' { Show-Status }
            '2' { Invoke-AdminMode 'Game' }
            '3' { Invoke-AdminMode 'Restore' }
            'Q' { return }
            default { Write-Host "  Type 1, 2, 3 or Q." -ForegroundColor Yellow }
        }
        Read-Host "`nPress Enter to go back to the menu" | Out-Null
    }
}

# ============================================================ main

if (-not $Mode) {
    Show-Menu
} else {
    Write-Host $Banner -ForegroundColor Green
    switch ($Mode) {
        'Check'   { Show-Status }
        'Game'    { Enable-GameMode }
        'Restore' { Disable-GameMode }
    }
    if ($Pause) { Read-Host "`nPress Enter to close" | Out-Null }
}
