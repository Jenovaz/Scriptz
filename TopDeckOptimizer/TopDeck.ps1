<#
TopDeck.ps1 - Jenovaz "Top Deck" OS Optimizer.

Windows debloat and tuning with on/off switches. Every switch can be turned back off: the
original settings are saved before anything changes.

How to run: double-click Run-TopDeck.cmd (it asks for admin rights), or
  powershell -ExecutionPolicy Bypass -File .\TopDeck.ps1

Options:
  -Check   Validate the tweak files and print the current state of every tweak. Changes nothing.
           Run it from an admin window for accurate app states.

How the switches work: each switch shows what is on this PC right now. Flip the ones you want
changed, press Preview to see exactly what will happen, then Apply. Nothing changes until Apply.
#>
[CmdletBinding()]
param(
    [switch]$Check
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$enginePath = Join-Path $root 'Core\Engine.psm1'

#region Start-up: right PowerShell, admin rights

function Test-Admin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Needs Windows PowerShell 5.1: restore points and app removal don't work in PowerShell 7.
if (-not $Check -and ($PSVersionTable.PSEdition -ne 'Desktop' -or -not (Test-Admin))) {
    $exe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    try {
        Start-Process -FilePath $exe -Verb RunAs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-File', "`"$PSCommandPath`"")
    } catch {
        Write-Host 'Top Deck needs admin rights to change system settings. Run it again and click Yes on the prompt.' -ForegroundColor Yellow
    }
    return
}

Import-Module $enginePath -Force

if ($Check) {
    $problems = @(Test-TopDeckDefinition)
    if ($problems.Count) { $problems | ForEach-Object { Write-Host "PROBLEM: $_" -ForegroundColor Red }; exit 1 }
    $tweaks = @(Get-TopDeckTweak)
    Write-Host "$($tweaks.Count) tweaks, $(@(Get-TopDeckTool).Count) tools, definitions OK." -ForegroundColor Green
    if ($env:OS -eq 'Windows_NT') {
        $state = Get-TopDeckState
        $tweaks | ForEach-Object { '{0,-12} {1,-11} {2}' -f $_.Category, $state[$_.Id], $_.Name }
    }
    exit 0
}

#endregion

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

#region Window

[xml]$xaml = Get-Content -Path (Join-Path $root 'Core\MainWindow.xaml') -Raw
$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$ui = @{}
foreach ($name in 'NavList', 'ContentHost', 'LogBox', 'StatusText', 'HeaderSub', 'ChkRestorePoint',
    'BtnRecommended', 'BtnUndoAll', 'BtnReset', 'BtnLoadProfile', 'BtnSaveProfile', 'BtnPreview', 'BtnApply') {
    $ui[$name] = $window.FindName($name)
}

function New-Brush([string]$Hex) { New-Object Windows.Media.SolidColorBrush ([Windows.Media.ColorConverter]::ConvertFromString($Hex)) }

$riskColour = @{ Safe = '#22C55E'; Moderate = '#F59E0B'; Advanced = '#EF4444' }
$categoryBlurb = @{
    Privacy     = 'Stop Windows sending data about you and showing you ads.'
    Debloat     = 'Remove built-in apps and features you do not use.'
    Performance = 'Make Windows start and respond faster.'
    Gaming      = 'Lower input lag and get steadier frame rates.'
    Interface   = 'Small changes that make Windows nicer to use.'
    Tools       = 'One-off clean-up and repair jobs. These run straight away when you press Run.'
}

#endregion

#region Background jobs
# Tweaks run in a separate PowerShell runspace (a second worker thread) so the window never freezes.
# The worker loads the engine and tweak files itself and only passes plain data back.

$logQueue = New-Object 'System.Collections.Concurrent.ConcurrentQueue[string]'
$script:job = $null

function Start-TopDeckJob {
    param([string]$Script, $Argument, [scriptblock]$OnDone, [string]$Status = 'Working...')
    $rs = [runspacefactory]::CreateRunspace()
    $rs.Open()
    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    $wrapper = {
        param($EnginePath, $Queue, $Script, $Argument)
        Import-Module $EnginePath
        Set-TopDeckLogSink $Queue
        & ([scriptblock]::Create($Script)) $Argument
    }
    [void]$ps.AddScript($wrapper.ToString()).AddArgument($enginePath).AddArgument($logQueue).AddArgument($Script).AddArgument($Argument)
    $script:job = @{ PS = $ps; Runspace = $rs; Handle = $ps.BeginInvoke(); OnDone = $OnDone }
    Set-Busy $true $Status
}

function Complete-TopDeckJob {
    $j = $script:job
    $script:job = $null
    $result = @()
    try {
        $result = @($j.PS.EndInvoke($j.Handle) | Where-Object { $null -ne $_ } | ForEach-Object { $_.psobject.BaseObject })
        foreach ($err in $j.PS.Streams.Error) { Add-Log "ERROR: $err" }
    } catch {
        Add-Log "ERROR: $($_.Exception.Message)"
    } finally {
        $j.PS.Dispose()
        $j.Runspace.Dispose()
    }
    Set-Busy $false
    if ($j.OnDone) { & $j.OnDone $result }
}

function Add-Log([string]$Line) {
    $ui.LogBox.AppendText($Line + "`r`n")
    $ui.LogBox.ScrollToEnd()
}

# Every 150 ms: move log lines from the worker into the window, and notice when the worker is done.
$timer = New-Object Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(150)
$timer.Add_Tick({
    $line = $null
    while ($logQueue.TryDequeue([ref]$line)) { Add-Log $line }
    if ($script:job -and $script:job.Handle.IsCompleted) { Complete-TopDeckJob }
})

function Set-Busy([bool]$Busy, [string]$Status = '') {
    foreach ($b in 'BtnRecommended', 'BtnUndoAll', 'BtnReset', 'BtnLoadProfile', 'BtnSaveProfile', 'BtnPreview', 'BtnApply', 'ChkRestorePoint') {
        $ui[$b].IsEnabled = -not $Busy
    }
    $ui.ContentHost.IsEnabled = -not $Busy
    if ($Busy) { $ui.StatusText.Text = $Status } else { Update-Pending }
}

#endregion

#region Tweak rows

$tweaks = @(Get-TopDeckTweak)
$tools  = @(Get-TopDeckTool)
$rows = @{}           # tweak ID -> @{ Tweak; Check; Status; State }
$panels = [ordered]@{}  # category -> StackPanel
$script:loadingState = $true

function New-Badge([string]$Text, [string]$Hex) {
    $b = New-Object Windows.Controls.Border
    $b.CornerRadius = 4; $b.Padding = '6,1'; $b.Margin = '8,0,0,0'; $b.VerticalAlignment = 'Center'
    $b.BorderBrush = New-Brush $Hex; $b.BorderThickness = 1
    $t = New-Object Windows.Controls.TextBlock
    $t.Text = $Text; $t.FontSize = 11; $t.Foreground = New-Brush $Hex
    $b.Child = $t
    return $b
}

function New-CategoryPanel([string]$Category) {
    $panel = New-Object Windows.Controls.StackPanel
    $title = New-Object Windows.Controls.TextBlock
    $title.Text = $Category; $title.FontSize = 20; $title.FontWeight = 'SemiBold'
    $sub = New-Object Windows.Controls.TextBlock
    $sub.Text = $categoryBlurb[$Category]; $sub.Foreground = New-Brush '#9AA3B2'; $sub.Margin = '0,2,0,14'
    [void]$panel.Children.Add($title)
    [void]$panel.Children.Add($sub)
    return $panel
}

function New-Card {
    $card = New-Object Windows.Controls.Border
    $card.Background = New-Brush '#1D212A'; $card.CornerRadius = 8; $card.Padding = '16,12'; $card.Margin = '0,0,0,8'
    $grid = New-Object Windows.Controls.Grid
    [void]$grid.ColumnDefinitions.Add((New-Object Windows.Controls.ColumnDefinition -Property @{ Width = New-Object Windows.GridLength 1, 'Star' }))
    [void]$grid.ColumnDefinitions.Add((New-Object Windows.Controls.ColumnDefinition -Property @{ Width = [Windows.GridLength]::Auto }))
    $card.Child = $grid
    return $card
}

foreach ($t in $tweaks) {
    if (-not $panels.Contains($t.Category)) { $panels[$t.Category] = New-CategoryPanel $t.Category }

    $card = New-Card
    $left = New-Object Windows.Controls.StackPanel
    $line = New-Object Windows.Controls.StackPanel
    $line.Orientation = 'Horizontal'
    $name = New-Object Windows.Controls.TextBlock
    $name.Text = $t.Name; $name.FontSize = 14; $name.FontWeight = 'SemiBold'
    [void]$line.Children.Add($name)
    [void]$line.Children.Add((New-Badge $t.Risk $riskColour[$t.Risk]))
    if ($t.Reboot) { [void]$line.Children.Add((New-Badge 'Restart' '#7C8599')) }
    $status = New-Object Windows.Controls.TextBlock
    $status.Margin = '10,0,0,0'; $status.VerticalAlignment = 'Center'; $status.FontSize = 12
    [void]$line.Children.Add($status)
    $desc = New-Object Windows.Controls.TextBlock
    $desc.Text = $t.Description; $desc.TextWrapping = 'Wrap'; $desc.Foreground = New-Brush '#9AA3B2'; $desc.Margin = '0,4,20,0'
    [void]$left.Children.Add($line)
    [void]$left.Children.Add($desc)

    $check = New-Object Windows.Controls.CheckBox
    $check.Style = $window.FindResource('Switch'); $check.VerticalAlignment = 'Center'; $check.Tag = $t.Id
    $check.IsEnabled = $false
    $check.Add_Click({ Update-Pending })
    [Windows.Controls.Grid]::SetColumn($check, 1)

    [void]$card.Child.Children.Add($left)
    [void]$card.Child.Children.Add($check)
    [void]$panels[$t.Category].Children.Add($card)
    $rows[$t.Id] = @{ Tweak = $t; Check = $check; Status = $status; State = 'NotApplied' }
}

# Tools tab
$toolPanel = New-CategoryPanel 'Tools'
foreach ($tool in $tools) {
    $card = New-Card
    $left = New-Object Windows.Controls.StackPanel
    $line = New-Object Windows.Controls.StackPanel
    $line.Orientation = 'Horizontal'
    $name = New-Object Windows.Controls.TextBlock
    $name.Text = $tool.Name; $name.FontSize = 14; $name.FontWeight = 'SemiBold'
    [void]$line.Children.Add($name)
    [void]$line.Children.Add((New-Badge $tool.Duration '#7C8599'))
    $desc = New-Object Windows.Controls.TextBlock
    $desc.Text = $tool.Description; $desc.TextWrapping = 'Wrap'; $desc.Foreground = New-Brush '#9AA3B2'; $desc.Margin = '0,4,20,0'
    [void]$left.Children.Add($line)
    [void]$left.Children.Add($desc)

    $run = New-Object Windows.Controls.Button
    $run.Content = 'Run'; $run.Tag = $tool.Id; $run.VerticalAlignment = 'Center'
    $run.Add_Click({
        param($source)
        Start-TopDeckJob -Script 'param($id) Invoke-TopDeckTool -Id $id' -Argument $source.Tag -Status 'Running tool...'
    })
    [Windows.Controls.Grid]::SetColumn($run, 1)

    [void]$card.Child.Children.Add($left)
    [void]$card.Child.Children.Add($run)
    [void]$toolPanel.Children.Add($card)
}
$panels['Tools'] = $toolPanel

foreach ($c in $panels.Keys) { [void]$ui.NavList.Items.Add($c) }
$ui.NavList.Add_SelectionChanged({ $ui.ContentHost.Content = $panels[[string]$ui.NavList.SelectedItem] })
$ui.NavList.SelectedIndex = 0

#endregion

#region Pending changes

function Get-Plan {
    # Compares each switch with what is on the PC now. Returns tweak ID -> 'Apply' or 'Revert'.
    $plan = @{}
    foreach ($id in $rows.Keys) {
        $r = $rows[$id]
        $want = [bool]$r.Check.IsChecked
        if ($want -and $r.State -ne 'Applied') { $plan[$id] = 'Apply' }
        elseif (-not $want -and $r.State -eq 'Applied') { $plan[$id] = 'Revert' }
    }
    return $plan
}

function Update-Pending {
    if ($script:loadingState) { return }
    $plan = Get-Plan
    foreach ($id in $rows.Keys) {
        $r = $rows[$id]
        if ($plan.ContainsKey($id)) {
            # [char]0x25CF is a dot; built from its code so the file stays plain ASCII for PowerShell 5.1.
            $r.Status.Text = if ($plan[$id] -eq 'Apply') { "$([char]0x25CF) will turn on" } else { "$([char]0x25CF) will turn off" }
            $r.Status.Foreground = New-Brush '#F5B942'
        } elseif ($r.State -eq 'Partial') {
            $r.Status.Text = 'partly on (something else changed it)'
            $r.Status.Foreground = New-Brush '#7C8599'
        } else {
            $r.Status.Text = ''
        }
    }
    $n = $plan.Count
    $ui.BtnApply.Content = if ($n) { "Apply $n change$(if ($n -ne 1) { 's' })" } else { 'Apply' }
    $ui.BtnApply.IsEnabled = $n -gt 0 -and -not $script:job
    $ui.BtnPreview.IsEnabled = $n -gt 0 -and -not $script:job
    $applied = @($rows.Values | Where-Object { $_.State -eq 'Applied' }).Count
    $ui.StatusText.Text = "$applied of $($rows.Count) tweaks on.  " + $(if ($n) { "$n change(s) waiting - press Apply." } else { 'No changes waiting.' })
}

function Update-State {
    # Re-reads what is actually on the PC, then sets every switch to match.
    $script:loadingState = $true
    Start-TopDeckJob -Script 'Get-TopDeckState' -Status 'Checking what is currently set on this PC...' -OnDone {
        param($result)
        $state = @($result | Where-Object { $_ -is [hashtable] }) | Select-Object -Last 1
        foreach ($id in $rows.Keys) {
            $r = $rows[$id]
            $r.State = if ($state -and $state.ContainsKey($id)) { $state[$id] } else { 'NotApplied' }
            $r.Check.IsChecked = $r.State -eq 'Applied'
            $r.Check.IsEnabled = $true
        }
        $script:loadingState = $false
        Update-Pending
    }
}

#endregion

#region Buttons

$ui.BtnRecommended.Add_Click({
    foreach ($r in $rows.Values) { if ($r.Tweak.Recommended) { $r.Check.IsChecked = $true } }
    Update-Pending
})

$ui.BtnUndoAll.Add_Click({
    foreach ($r in $rows.Values) { $r.Check.IsChecked = $false }
    Update-Pending
})

$ui.BtnReset.Add_Click({
    foreach ($r in $rows.Values) { $r.Check.IsChecked = $r.State -eq 'Applied' }
    Update-Pending
})

$ui.BtnSaveProfile.Add_Click({
    $dlg = New-Object Microsoft.Win32.SaveFileDialog
    $dlg.Filter = 'Top Deck profile (*.json)|*.json'; $dlg.FileName = 'TopDeck-profile.json'
    if ($dlg.ShowDialog($window)) {
        $on = @($rows.Keys | Where-Object { $rows[$_].Check.IsChecked })
        Export-TopDeckProfile -Path $dlg.FileName -On $on
        Add-Log "Saved profile with $($on.Count) tweaks to $($dlg.FileName)"
    }
})

$ui.BtnLoadProfile.Add_Click({
    $dlg = New-Object Microsoft.Win32.OpenFileDialog
    $dlg.Filter = 'Top Deck profile (*.json)|*.json'
    if ($dlg.ShowDialog($window)) {
        try {
            $on = Import-TopDeckProfile -Path $dlg.FileName
            foreach ($id in $on) { $rows[$id].Check.IsChecked = $true }
            Add-Log "Loaded profile: $($on.Count) tweaks switched on. Press Apply to make the changes."
            Update-Pending
        } catch {
            [void][Windows.MessageBox]::Show($window, $_.Exception.Message, 'Could not load profile', 'OK', 'Warning')
        }
    }
})

$ui.BtnPreview.Add_Click({
    Start-TopDeckJob -Script 'param($plan) Get-TopDeckPreview -Plan $plan' -Argument (Get-Plan) -Status 'Working out what will change...' -OnDone {
        param($lines)
        $box = New-Object Windows.Controls.TextBox
        $box.Text = "Nothing has been changed yet. This is what Apply will do:`r`n" + (@($lines) -join "`r`n")
        $box.IsReadOnly = $true; $box.FontFamily = 'Consolas'; $box.FontSize = 12
        $box.Background = New-Brush '#0B0D10'; $box.Foreground = New-Brush '#E6E8EE'; $box.BorderThickness = 0; $box.Padding = 14
        $box.VerticalScrollBarVisibility = 'Auto'; $box.HorizontalScrollBarVisibility = 'Auto'
        $w = New-Object Windows.Window
        $w.Title = 'Preview'; $w.Width = 900; $w.Height = 560; $w.Owner = $window
        $w.WindowStartupLocation = 'CenterOwner'; $w.Content = $box
        [void]$w.ShowDialog()
    }
})

$ui.BtnApply.Add_Click({
    $plan = Get-Plan
    if (-not $plan.Count) { return }
    $names = @($plan.Keys | ForEach-Object { '  {0}  {1}' -f $(if ($plan[$_] -eq 'Apply') { 'ON ' } else { 'OFF' }), $rows[$_].Tweak.Name })
    $risky = @($plan.Keys | Where-Object { $plan[$_] -eq 'Apply' -and $rows[$_].Tweak.Risk -ne 'Safe' })
    $msg = "Make these $($plan.Count) change(s)?`n`n" + ($names -join "`n")
    if ($risky.Count) { $msg += "`n`n$($risky.Count) of these are Moderate or Advanced risk. Read their descriptions first." }
    if ([Windows.MessageBox]::Show($window, $msg, 'Apply changes', 'YesNo', 'Question') -ne 'Yes') { return }

    # Kept in script scope so the restore-point callback below can reach it.
    $script:pendingPlan = $plan
    $script:runPlan = {
        Start-TopDeckJob -Script 'param($plan) Invoke-TopDeckPlan -Plan $plan' -Argument $script:pendingPlan -Status 'Applying changes...' -OnDone {
            param($result)
            $r = @($result | Where-Object { $_ -is [hashtable] }) | Select-Object -Last 1
            if ($r -and $r.Failed) { Add-Log "$($r.Failed) step(s) failed - see the lines marked ERROR above." }
            if ($r -and $r.Reboot) {
                [void][Windows.MessageBox]::Show($window, 'Some changes need a restart (or sign out and back in) to take effect.', 'Restart needed', 'OK', 'Information')
            }
            Update-State
        }
    }

    if ($ui.ChkRestorePoint.IsChecked) {
        Start-TopDeckJob -Script 'New-TopDeckRestorePoint' -Status 'Creating a restore point (can take a minute)...' -OnDone {
            param($result)
            if (-not ($result -contains $true)) {
                $go = [Windows.MessageBox]::Show($window, "The restore point could not be created (details in the log).`n`nYour settings are still backed up and can be undone from the switches. Continue anyway?", 'No restore point', 'YesNo', 'Warning')
                if ($go -ne 'Yes') { Add-Log 'Cancelled - nothing was changed.'; return }
            }
            & $script:runPlan
        }
    } else {
        & $script:runPlan
    }
})

$window.Add_Closing({
    param($source, $e)
    if ($script:job) {
        $answer = [Windows.MessageBox]::Show($window, 'A job is still running. Closing now could leave a change half-done. Close anyway?', 'Still working', 'YesNo', 'Warning')
        if ($answer -ne 'Yes') { $e.Cancel = $true }
    }
})

#endregion

$ui.HeaderSub.Text = "by Jenovaz  -  $($tweaks.Count) tweaks, $($tools.Count) tools  -  log: $env:ProgramData\TopDeckOptimizer\topdeck.log"
$window.Add_ContentRendered({ $timer.Start(); Update-State })
[void]$window.ShowDialog()
$timer.Stop()
