<#
ZomboidModEnabler.ps1 - switch on Project Zomboid multiplayer mods from one checklist.

It reads your server's settings file and the Workshop mods Steam has downloaded, shows every mod
with a tick box, and writes the WorkshopItems=, Mods= and Map= lines for you. The settings file is
backed up before every save.

How to run: double-click Run-ZomboidModEnabler.cmd, or
  powershell -ExecutionPolicy Bypass -File .\ZomboidModEnabler.ps1

Options:
  -Server <name>      Server to open (the .ini file name without .ini). Default: asks / first one.
  -Add <ids/links>    Workshop numbers or links to add, e.g. -Add 2875848298,3790089095
  -List               No window. Print what would be written. Changes nothing.
  -Apply              No window. Write the default choices (same as opening the window and pressing Save).
  -Build <41|42>      Game build you host. Default 42.
  -ZomboidDir <path>  Your Zomboid folder. Default %USERPROFILE%\Zomboid.
  -WorkshopDir <path> Steam's ...\workshop\content\108600 folder, if it isn't found automatically.
#>
[CmdletBinding()]
param(
    [string]$Server,
    [string[]]$Add = @(),
    [switch]$List,
    [switch]$Apply,
    [ValidateSet(41, 42)][int]$Build = 42,
    [string]$ZomboidDir = $(if ($env:USERPROFILE) { Join-Path $env:USERPROFILE 'Zomboid' } else { Join-Path $HOME 'Zomboid' }),
    [string[]]$WorkshopDir
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path (Join-Path $PSScriptRoot 'Core') 'ZomboidMods.psm1') -Force

$iniFiles = @(Get-ZmServerIni -ZomboidDir $ZomboidDir)
if (-not $WorkshopDir) { $WorkshopDir = @(Get-ZmWorkshopRoot) }
$addIds = @(Get-ZmWorkshopIdFromText ($Add -join ' '))

function Get-GameRunning {
    @(Get-Process -Name 'ProjectZomboid*' -ErrorAction SilentlyContinue).Count -gt 0
}

#region No-window modes

if ($List -or $Apply) {
    if (-not $iniFiles.Count) { Write-Host "No server settings found in $ZomboidDir\Server. Host a server once from the game menu first." -ForegroundColor Red; exit 1 }
    $file = if ($Server) { $iniFiles | Where-Object { $_.BaseName -eq $Server } | Select-Object -First 1 } elseif ($iniFiles.Count -eq 1) { $iniFiles[0] }
    if (-not $file) {
        Write-Host 'Pick a server with -Server <name>. Found:' -ForegroundColor Yellow
        $iniFiles | ForEach-Object { "  $($_.BaseName)" }
        exit 1
    }
    if (-not $WorkshopDir) { Write-Host 'Could not find Steam''s Zomboid Workshop folder. Use -WorkshopDir.' -ForegroundColor Red; exit 1 }

    $ini = Read-ZmIni -Path $file.FullName
    $installed = Get-ZmInstalledItem -WorkshopRoot $WorkshopDir -Build $Build
    $rows = @(Get-ZmChecklist -Ini $ini -Installed $installed -AddIds $addIds -Build $Build)
    $plan = Get-ZmPlan -Ini $ini -Rows $rows -ModStyle $ini.ModStyle -Build $Build

    Write-Host "Server: $($ini.Name)  ($($file.FullName))" -ForegroundColor Cyan
    Write-Host "Workshop folders: $($WorkshopDir -join ', ')"
    Write-Host ''
    foreach ($r in $rows | Where-Object { $_.Section -ne 'Installed' -or $_.Checked }) {
        $box = if (-not $r.Selectable) { '[!]' } elseif ($r.Checked) { '[x]' } else { '[ ]' }
        $label = if ($r.ModId) { "$($r.Name)  (ID: $($r.ModId))" } else { $r.Note }
        '{0} {1,-12} {2}' -f $box, $r.WorkshopId, $label
    }
    Write-Host ''
    "WorkshopItems=$($plan.WorkshopItemsLine)"
    "Mods=$($plan.ModsLine)"
    "Map=$($plan.MapLine)"
    if ($plan.Warnings.Count) { Write-Host ''; $plan.Warnings | ForEach-Object { Write-Host "! $_" -ForegroundColor Yellow } }

    if ($Apply) {
        $backup = Save-ZmIni -Ini $ini -Plan $plan
        Write-Host ''
        Write-Host "Saved. Backup: $backup" -ForegroundColor Green
    } else {
        Write-Host ''
        Write-Host 'Nothing changed (-List). Use -Apply to write it, or run without switches for the checklist.' -ForegroundColor DarkGray
    }
    exit 0
}

#endregion

#region Window

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Zomboid Mod Enabler"
        Width="1120" Height="760" MinWidth="880" MinHeight="560"
        WindowStartupLocation="CenterScreen"
        Background="#0F1115" Foreground="#E6E8EE"
        FontFamily="Segoe UI" FontSize="13">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#242935"/>
            <Setter Property="Foreground" Value="#E6E8EE"/>
            <Setter Property="BorderBrush" Value="#2B303C"/>
            <Setter Property="Padding" Value="12,5"/>
            <Setter Property="Margin" Value="6,0,0,0"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#161920"/>
            <Setter Property="Foreground" Value="#E6E8EE"/>
            <Setter Property="BorderBrush" Value="#2B303C"/>
            <Setter Property="CaretBrush" Value="#E6E8EE"/>
            <Setter Property="Padding" Value="6,4"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#E6E8EE"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
        </Style>
    </Window.Resources>

    <Grid Margin="18">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Margin="0,0,0,12">
            <TextBlock Text="Zomboid Mod Enabler" FontSize="22" FontWeight="SemiBold"/>
            <TextBlock Foreground="#9AA3B2" TextWrapping="Wrap" Margin="0,2,0,0"
                       Text="Tick the mods you want on the server and press Save. It fills in the Workshop list, the Mods list and the Map list for you."/>
            <Border x:Name="GameWarning" Visibility="Collapsed" Background="#3A2A10" CornerRadius="6" Padding="10,6" Margin="0,10,0,0">
                <TextBlock Foreground="#F5B942" TextWrapping="Wrap"
                           Text="Project Zomboid is running. If its Edit Settings screen is open, press Cancel there after saving here, or the game will overwrite these changes."/>
            </Border>
        </StackPanel>

        <Grid Grid.Row="1" Margin="0,0,0,10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="260"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock Text="Server" VerticalAlignment="Center" Margin="0,0,8,0"/>
            <ComboBox x:Name="ServerBox" Grid.Column="1" Padding="6,4"/>
            <TextBox x:Name="FilterBox" Grid.Column="2" Margin="12,0,0,0" ToolTip="Filter the list by name, mod ID or Workshop number"/>
            <TextBlock x:Name="FilterHint" Grid.Column="2" Margin="21,0,0,0" VerticalAlignment="Center" Foreground="#6B7383"
                       IsHitTestVisible="False" Text="Search mods..."/>
            <StackPanel Grid.Column="3" Orientation="Horizontal">
                <Button x:Name="BtnTickServer" Content="Tick all on server"/>
                <Button x:Name="BtnUntickAll" Content="Untick all"/>
                <Button x:Name="BtnRescan" Content="Rescan" ToolTip="Look again for mods Steam has downloaded"/>
            </StackPanel>
        </Grid>

        <Grid Grid.Row="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="360"/>
            </Grid.ColumnDefinitions>

            <Border Background="#161920" CornerRadius="8" Padding="12">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel x:Name="ModList"/>
                </ScrollViewer>
            </Border>

            <Grid Grid.Column="1" Margin="12,0,0,0">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Border Background="#161920" CornerRadius="8" Padding="12" Margin="0,0,0,10">
                    <StackPanel>
                        <TextBlock Text="Add Workshop items" FontWeight="SemiBold"/>
                        <TextBlock Foreground="#9AA3B2" TextWrapping="Wrap" Margin="0,2,0,6" FontSize="12"
                                   Text="Paste Steam Workshop links or numbers, one or many. Subscribe to them on Steam so they download."/>
                        <TextBox x:Name="AddBox" Height="54" AcceptsReturn="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>
                        <Button x:Name="BtnAdd" Content="Add to server" HorizontalAlignment="Right" Margin="0,6,0,0"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="1" Background="#161920" CornerRadius="8" Padding="12" Margin="0,0,0,10">
                    <StackPanel>
                        <CheckBox x:Name="ChkBackslash" Content="Put \ before each mod ID"/>
                        <TextBlock Foreground="#9AA3B2" TextWrapping="Wrap" Margin="22,2,0,0" FontSize="12"
                                   Text="Early Build 42 multiplayer wrote Mods=\ModA;\ModB. This is set to match what your file already uses."/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="2" Background="#161920" CornerRadius="8" Padding="12" Margin="0,0,0,10">
                    <DockPanel>
                        <TextBlock DockPanel.Dock="Top" Text="Check before saving" FontWeight="SemiBold" Margin="0,0,0,6"/>
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <TextBlock x:Name="WarningText" TextWrapping="Wrap" FontSize="12"/>
                        </ScrollViewer>
                    </DockPanel>
                </Border>

                <Border Grid.Row="3" Background="#161920" CornerRadius="8" Padding="12">
                    <DockPanel>
                        <TextBlock DockPanel.Dock="Top" Text="Will be written" FontWeight="SemiBold" Margin="0,0,0,6"/>
                        <TextBox x:Name="PreviewBox" IsReadOnly="True" TextWrapping="Wrap" FontFamily="Consolas" FontSize="11"
                                 VerticalScrollBarVisibility="Auto" Background="#0F1115"/>
                    </DockPanel>
                </Border>
            </Grid>
        </Grid>

        <Grid Grid.Row="3" Margin="0,12,0,0">
            <TextBlock x:Name="StatusText" Foreground="#9AA3B2" VerticalAlignment="Center" TextTrimming="CharacterEllipsis"/>
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                <Button x:Name="BtnOpenFolder" Content="Open settings folder"/>
                <Button x:Name="BtnClose" Content="Close"/>
                <Button x:Name="BtnSave" Content="Save" Background="#F5B942" Foreground="#16130A" FontWeight="SemiBold" Padding="22,5"/>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
'@

$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$ui = @{}
foreach ($name in 'GameWarning', 'ServerBox', 'FilterBox', 'FilterHint', 'BtnTickServer', 'BtnUntickAll', 'BtnRescan', 'ModList',
    'AddBox', 'BtnAdd', 'ChkBackslash', 'WarningText', 'PreviewBox', 'StatusText', 'BtnOpenFolder', 'BtnClose', 'BtnSave') {
    $ui[$name] = $window.FindName($name)
}

function New-Brush([string]$Hex) { New-Object Windows.Media.SolidColorBrush ([Windows.Media.ColorConverter]::ConvertFromString($Hex)) }

function New-TextBlock([string]$Text, [string]$Hex = '#E6E8EE', [double]$Size = 13, [string]$Weight = 'Normal') {
    $t = New-Object Windows.Controls.TextBlock
    $t.Text = $Text; $t.Foreground = New-Brush $Hex; $t.FontSize = $Size; $t.FontWeight = $Weight
    $t.VerticalAlignment = 'Center'; $t.TextWrapping = 'Wrap'
    $t
}

function New-Badge([string]$Text, [string]$Hex) {
    $b = New-Object Windows.Controls.Border
    $b.CornerRadius = 4; $b.Padding = '6,0'; $b.Margin = '8,0,0,0'; $b.VerticalAlignment = 'Center'
    $b.BorderBrush = New-Brush $Hex; $b.BorderThickness = 1
    $b.Child = New-TextBlock $Text $Hex 11
    $b
}

#endregion

#region State

$script:ini = $null
$script:installed = $null
$script:rows = @()
$script:addIds = New-Object System.Collections.ArrayList
foreach ($id in $addIds) { [void]$script:addIds.Add($id) }
$script:cards = New-Object System.Collections.ArrayList   # @{ Card; Search }
$script:checks = New-Object System.Collections.ArrayList  # CheckBoxes, Tag = row
$script:plan = $null

$sectionText = [ordered]@{
    Server    = @('ON THIS SERVER', 'Workshop items in this server''s list. Items with several mods inside often have variants (Lite, Full...) - tick only one of those.')
    Missing   = @('NOT DOWNLOADED YET', 'These stay in the Workshop list so they download, but their mods can''t be switched on until they are on this PC.')
    Orphan    = @('SWITCHED ON, BUT NOT FOUND', 'Mod IDs in the Mods list that aren''t in any Workshop download on this PC.')
    Installed = @('OTHER DOWNLOADED ZOMBOID MODS', 'Downloaded on this PC but not on this server. Tick one to add it.')
}

function Get-ModStyle {
    if (-not $ui.ChkBackslash.IsChecked) { return 'Plain' }
    if ($script:ini -and $script:ini.ModStyle -eq 'WorkshopPrefix') { return 'WorkshopPrefix' }
    'Backslash'
}

function Update-Plan {
    if (-not $script:ini) { return }
    $script:plan = Get-ZmPlan -Ini $script:ini -Rows $script:rows -ModStyle (Get-ModStyle) -Build $Build
    $ui.PreviewBox.Text = "WorkshopItems=$($script:plan.WorkshopItemsLine)`r`n`r`nMods=$($script:plan.ModsLine)`r`n`r`nMap=$($script:plan.MapLine)"

    $ui.WarningText.Inlines.Clear()
    if (-not $script:plan.Warnings.Count) {
        $ui.WarningText.Inlines.Add((New-Object Windows.Documents.Run 'Nothing to fix.' -Property @{ Foreground = New-Brush '#22C55E' }))
    }
    foreach ($w in $script:plan.Warnings) {
        $colour = if ($w -like 'NEEDS:*') { '#EF4444' } else { '#F5B942' }
        $ui.WarningText.Inlines.Add((New-Object Windows.Documents.Run ("- " + ($w -replace '^NEEDS: ', '') + "`n") -Property @{ Foreground = New-Brush $colour }))
    }
    $on = @($script:rows | Where-Object { $_.Checked -and $_.Selectable }).Count
    $ui.StatusText.Text = "$on mods ticked, $($script:plan.WorkshopItems.Count) Workshop items, $($script:plan.Maps.Count - 1) extra maps.  File: $($script:ini.Path)"
}

function Add-ItemCard($Panel, [object[]]$ItemRows) {
    $first = $ItemRows[0]
    $card = New-Object Windows.Controls.Border
    $card.Background = New-Brush '#1D212A'; $card.CornerRadius = 6; $card.Padding = '12,8'; $card.Margin = '0,0,0,6'
    $stack = New-Object Windows.Controls.StackPanel
    $card.Child = $stack

    $head = New-Object Windows.Controls.StackPanel
    $head.Orientation = 'Horizontal'
    $title = if ($first.WorkshopId) { "Workshop $($first.WorkshopId)" } else { 'Local or unknown mod' }
    [void]$head.Children.Add((New-TextBlock $title '#9AA3B2' 11))
    if ($ItemRows.Count -gt 1) { [void]$head.Children.Add((New-Badge "$($ItemRows.Count) mods inside - pick the ones you want" '#60A5FA')) }
    [void]$stack.Children.Add($head)

    $search = "$($first.WorkshopId)"
    foreach ($r in $ItemRows) {
        $search += " $($r.Name) $($r.ModId)"
        if (-not $r.Selectable) {
            [void]$stack.Children.Add((New-TextBlock $r.Note '#F5B942'))
            continue
        }
        $line = New-Object Windows.Controls.WrapPanel
        [void]$line.Children.Add((New-TextBlock $r.Name '#E6E8EE' 14 'SemiBold'))
        [void]$line.Children.Add((New-TextBlock "   ID: $($r.ModId)" '#9AA3B2' 12))
        if ($r.IsNew -and $r.Section -ne 'Installed') { [void]$line.Children.Add((New-Badge 'NOT SWITCHED ON BEFORE' '#22C55E')) }
        foreach ($m in $r.Maps) { [void]$line.Children.Add((New-Badge "MAP: $m" '#A78BFA')) }
        if ($r.Requires.Count) { [void]$line.Children.Add((New-Badge "needs: $($r.Requires -join ', ')" '#9AA3B2')) }
        if ($r.Layout -eq 'root' -and $Build -ge 42) { [void]$line.Children.Add((New-Badge 'BUILD 41 LAYOUT' '#EF4444')) }

        $cb = New-Object Windows.Controls.CheckBox
        $cb.Content = $line; $cb.Margin = '0,4,0,0'; $cb.Tag = $r; $cb.IsChecked = $r.Checked
        $cb.Add_Click({ $this.Tag.Checked = [bool]$this.IsChecked; Update-Plan })
        [void]$stack.Children.Add($cb)
        [void]$script:checks.Add($cb)
        if ($r.Note) { [void]$stack.Children.Add((New-TextBlock $r.Note '#F5B942' 12)) }
    }
    [void]$Panel.Children.Add($card)
    [void]$script:cards.Add(@{ Card = $card; Search = $search })
}

function Show-Checklist {
    $ui.ModList.Children.Clear()
    $script:cards.Clear()
    $script:checks.Clear()
    foreach ($section in $sectionText.Keys) {
        $sectionRows = @($script:rows | Where-Object { $_.Section -eq $section })
        if (-not $sectionRows.Count) { continue }
        $headText = New-TextBlock $sectionText[$section][0] '#F5B942' 12 'SemiBold'
        $headText.Margin = '0,8,0,0'
        [void]$ui.ModList.Children.Add($headText)
        $sub = New-TextBlock $sectionText[$section][1] '#9AA3B2' 12
        $sub.Margin = '0,0,0,6'
        [void]$ui.ModList.Children.Add($sub)
        foreach ($group in ($sectionRows | Group-Object WorkshopId)) { Add-ItemCard $ui.ModList @($group.Group) }
    }
    Set-Filter
    Update-Plan
}

function Set-Filter {
    $text = $ui.FilterBox.Text.Trim()
    $ui.FilterHint.Visibility = if ($text) { 'Collapsed' } else { 'Visible' }
    foreach ($c in $script:cards) {
        $c.Card.Visibility = if (-not $text -or $c.Search -like "*$text*") { 'Visible' } else { 'Collapsed' }
    }
}

# Rebuilds the checklist, keeping any ticks you already changed.
function Update-Checklist([switch]$Rescan) {
    $old = @{}
    foreach ($r in $script:rows) { $old[$r.Key] = $r.Checked }
    if ($Rescan -or -not $script:installed) {
        $ui.StatusText.Text = 'Looking for downloaded Workshop mods...'
        $script:installed = Get-ZmInstalledItem -WorkshopRoot $WorkshopDir -Build $Build
    }
    $script:rows = @(Get-ZmChecklist -Ini $script:ini -Installed $script:installed -AddIds @($script:addIds) -Build $Build)
    foreach ($r in $script:rows) { if ($old.ContainsKey($r.Key) -and $r.Selectable) { $r.Checked = $old[$r.Key] } }
    Show-Checklist
}

function Open-Server($File) {
    $script:ini = Read-ZmIni -Path $File.FullName
    $script:rows = @()
    $script:addIds.Clear()
    foreach ($id in $addIds) { [void]$script:addIds.Add($id) }
    $ui.ChkBackslash.IsChecked = $script:ini.ModStyle -ne 'Plain'
    Update-Checklist
}

#endregion

#region Buttons

$ui.ServerBox.Add_SelectionChanged({
    $f = $iniFiles | Where-Object { $_.BaseName -eq $ui.ServerBox.SelectedItem } | Select-Object -First 1
    if ($f) { Open-Server $f }
})
$ui.FilterBox.Add_TextChanged({ Set-Filter })
$ui.ChkBackslash.Add_Click({ Update-Plan })
$ui.BtnRescan.Add_Click({ Update-Checklist -Rescan })

$ui.BtnTickServer.Add_Click({
    foreach ($cb in $script:checks) { if ($cb.Tag.Section -in 'Server', 'Orphan') { $cb.IsChecked = $true; $cb.Tag.Checked = $true } }
    Update-Plan
})
$ui.BtnUntickAll.Add_Click({
    foreach ($cb in $script:checks) { $cb.IsChecked = $false; $cb.Tag.Checked = $false }
    Update-Plan
})

$ui.BtnAdd.Add_Click({
    $ids = @(Get-ZmWorkshopIdFromText $ui.AddBox.Text)
    if (-not $ids.Count) {
        [void][Windows.MessageBox]::Show($window, 'No Workshop numbers found. Paste a link like https://steamcommunity.com/sharedfiles/filedetails/?id=2875848298 or just the number.', 'Add Workshop items')
        return
    }
    foreach ($id in $ids) { if ($script:addIds -notcontains $id) { [void]$script:addIds.Add($id) } }
    # Mods of a newly added item start ticked, even if it was already listed under "other downloaded mods".
    foreach ($r in $script:rows) { if ($ids -contains $r.WorkshopId -and $r.Section -eq 'Installed') { $r.Checked = $true } }
    $ui.AddBox.Text = ''
    Update-Checklist -Rescan
})

$ui.BtnOpenFolder.Add_Click({
    $dir = Join-Path $ZomboidDir 'Server'
    if (Test-Path -LiteralPath $dir) { Start-Process explorer.exe -ArgumentList "`"$dir`"" }
})
$ui.BtnClose.Add_Click({ $window.Close() })

$ui.BtnSave.Add_Click({
    if (-not $script:ini) { return }
    Update-Plan
    $needs = @($script:plan.Warnings | Where-Object { $_ -like 'NEEDS:*' })
    if ($needs.Count) {
        $msg = "Some ticked mods need other mods that aren't ticked:`n`n" + (($needs -replace '^NEEDS: ', '- ') -join "`n") + "`n`nSave anyway?"
        if ([Windows.MessageBox]::Show($window, $msg, 'Missing requirements', 'YesNo', 'Warning') -ne 'Yes') { return }
    }
    try {
        # Re-read the file first so settings changed elsewhere since opening aren't lost.
        $fresh = Read-ZmIni -Path $script:ini.Path
        $backup = Save-ZmIni -Ini $fresh -Plan $script:plan
        $script:ini = Read-ZmIni -Path $script:ini.Path
        Update-Checklist
        $msg = "Saved $($script:plan.Mods.Count) mods to $($script:ini.Name).`n`nBackup of the old file:`n$backup`n`nStart (or restart) the server for the change to take effect."
        if (Get-GameRunning) { $msg += "`n`nThe game is running: if its Edit Settings screen is open, press Cancel there, or it will overwrite this." }
        [void][Windows.MessageBox]::Show($window, $msg, 'Saved')
    } catch {
        [void][Windows.MessageBox]::Show($window, "Could not save: $($_.Exception.Message)", 'Save failed', 'OK', 'Error')
    }
})

#endregion

#region Start

if (-not $iniFiles.Count) {
    [void][Windows.MessageBox]::Show("No server settings found in:`n$ZomboidDir\Server`n`nIn Project Zomboid go to Host, create or pick a server and press Save once, then run this again.", 'Zomboid Mod Enabler', 'OK', 'Warning')
    return
}
if (-not $WorkshopDir) {
    [void][Windows.MessageBox]::Show("Could not find Steam's Project Zomboid Workshop folder (steamapps\workshop\content\108600).`n`nRun this again with -WorkshopDir ""<that folder>"".", 'Zomboid Mod Enabler', 'OK', 'Warning')
    return
}

if (Get-GameRunning) { $ui.GameWarning.Visibility = 'Visible' }
foreach ($f in $iniFiles) { [void]$ui.ServerBox.Items.Add($f.BaseName) }
$startName = if ($Server -and ($iniFiles.BaseName -contains $Server)) { $Server } else { $iniFiles[0].BaseName }
$ui.ServerBox.SelectedItem = $startName   # triggers Open-Server

[void]$window.ShowDialog()

#endregion
