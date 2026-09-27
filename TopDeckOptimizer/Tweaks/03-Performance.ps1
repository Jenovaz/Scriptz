<#
Performance tweaks. Field meanings are listed at the top of 01-Privacy.ps1.
#>

$ultimateGuid = 'e9a42b02-d5df-448d-aa00-03f14749eb61'   # Windows' built-in (hidden) Ultimate Performance template
$balancedGuid = '381b4222-f694-41f0-9685-ff5bb260df2e'
$markerKey    = 'HKLM:\SOFTWARE\TopDeckOptimizer'
$guidPattern  = '[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}'

@(
    @{
        Id = 'perf.ultimate-power'; Name = 'Ultimate Performance power plan'; Category = 'Performance'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Source = 'TopDeck'
        Description = 'Unlocks and switches to the hidden Ultimate Performance plan: CPU never idles down. Desktops only; on a laptop it drains the battery.'
        Actions = @(
            @{
                Type = 'Command'
                Describe = 'Create the Ultimate Performance power plan and make it active'
                # Reads GUIDs, not plan names, so it works on any Windows language.
                Test = {
                    $mine = (Get-ItemProperty -Path $markerKey -Name UltimatePlanGuid -ErrorAction SilentlyContinue).UltimatePlanGuid
                    $active = [regex]::Match((powercfg /getactivescheme | Out-String), $guidPattern).Value
                    [bool]$mine -and $active -eq $mine
                }.GetNewClosure()
                Backup = { @{ Previous = [regex]::Match((powercfg /getactivescheme | Out-String), $guidPattern).Value } }.GetNewClosure()
                Apply = {
                    $out = powercfg -duplicatescheme $ultimateGuid | Out-String
                    $new = [regex]::Match($out, $guidPattern).Value
                    if (-not $new) { throw "Windows would not create the plan: $out" }
                    powercfg /setactive $new
                    if (-not (Test-Path $markerKey)) { New-Item -Path $markerKey -Force | Out-Null }
                    Set-ItemProperty -Path $markerKey -Name UltimatePlanGuid -Value $new
                }.GetNewClosure()
                Revert = {
                    param($Backup)
                    $previous = if ($Backup -and $Backup.Previous) { $Backup.Previous } else { $balancedGuid }
                    powercfg /setactive $previous
                    $mine = (Get-ItemProperty -Path $markerKey -Name UltimatePlanGuid -ErrorAction SilentlyContinue).UltimatePlanGuid
                    if ($mine -and $mine -ne $previous) { powercfg /delete $mine }
                    Remove-ItemProperty -Path $markerKey -Name UltimatePlanGuid -ErrorAction SilentlyContinue
                }.GetNewClosure()
            }
        )
    }
    @{
        Id = 'perf.hibernation'; Name = 'Turn off hibernation'; Category = 'Performance'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Source = 'TopDeck'
        Description = 'Deletes hiberfil.sys (frees several GB). Also turns off Fast Startup. Leave on for laptops that hibernate on low battery.'
        Actions = @(
            @{
                Type = 'Command'
                Describe = 'powercfg /hibernate off'
                Test = { (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name HibernateEnabled -ErrorAction SilentlyContinue).HibernateEnabled -eq 0 }
                Backup = { @{ Enabled = [bool]((Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name HibernateEnabled -ErrorAction SilentlyContinue).HibernateEnabled) } }
                Apply = { powercfg /hibernate off }
                Revert = { param($Backup) if (-not $Backup -or $Backup.Enabled) { powercfg /hibernate on } }
            }
        )
    }
    @{
        Id = 'perf.startup-delay'; Name = 'Remove startup app delay'; Category = 'Performance'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Source = 'TopDeck'
        Description = 'Windows waits about 10 seconds after sign-in before launching startup apps. This removes the wait.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize'; Name = 'StartupDelayInMSec'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'perf.menu-delay'; Name = 'Faster menus'; Category = 'Performance'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Source = 'TopDeck'
        Description = 'Sub-menus open instantly instead of after a 0.4 second pause. Takes effect after sign-out.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop'; Name = 'MenuShowDelay'; Kind = 'String'; Value = '0'; Default = '400' }
        )
    }
)
