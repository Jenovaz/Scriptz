<#
Engine.psm1 - the tweak engine behind Jenovaz "Top Deck" OS Optimizer.

Every tweak is a list of actions. Each action type knows how to:
  Test      is the tweak's setting already in place?
  Backup    record what the setting is right now, before we touch it
  Apply     make the change
  Revert    put the recorded original back (or the Windows default if no backup exists)
  Describe  one line saying what it will change, for the preview

Action types: Registry, Service, ScheduledTask, Appx, Command.
Originals are saved to %ProgramData%\TopDeckOptimizer\backups.json the first time a
tweak is applied, and are never overwritten until that tweak is reverted.

Written for Windows PowerShell 5.1 (the version built into Windows), so no PowerShell 7 syntax.
#>

Set-StrictMode -Version 2.0

$script:Root       = Split-Path -Parent $PSScriptRoot
$script:DataDir    = Join-Path $env:ProgramData 'TopDeckOptimizer'
$script:BackupFile = Join-Path $script:DataDir 'backups.json'
$script:LogFile    = Join-Path $script:DataDir 'topdeck.log'
$script:LogSink    = $null

#region Logging

function Set-TopDeckLogSink {
    # The GUI hands us a thread-safe queue; every log line is also pushed there so the window can show it.
    param($Queue)
    $script:LogSink = $Queue
}

function Write-TopDeckLog {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Message,
        [ValidateSet('Info', 'Ok', 'Warn', 'Error')][string]$Level = 'Info'
    )
    $line = '{0} [{1}] {2}' -f (Get-Date -Format 'HH:mm:ss'), $Level.ToUpper(), $Message
    try {
        if (-not (Test-Path $script:DataDir)) { New-Item -ItemType Directory -Path $script:DataDir -Force | Out-Null }
        Add-Content -Path $script:LogFile -Value $line -Encoding UTF8
    } catch { }   # a locked log file must never stop a tweak
    if ($script:LogSink) { $script:LogSink.Enqueue($line) } else { Write-Host $line }
}

#endregion

#region Loading tweak and tool definitions

function Get-TopDeckTweak {
    <# Loads every tweak from the Tweaks folder. Each file returns an array of hashtables. #>
    param([string[]]$Id)
    $all = @()
    foreach ($file in Get-ChildItem -Path (Join-Path $script:Root 'Tweaks') -Filter '*.ps1' | Sort-Object Name) {
        foreach ($t in @(& $file.FullName)) {
            if ($t -is [hashtable]) { $all += $t }
        }
    }
    if ($Id) { $all = @($all | Where-Object { $Id -contains $_.Id }) }
    return $all
}

function Get-TopDeckTool {
    <# Loads the one-shot tools (cleanup, repair). These are buttons, not toggles. #>
    param([string]$Id)
    $all = @(& (Join-Path $script:Root 'Tools\Tools.ps1'))
    if ($Id) { $all = @($all | Where-Object { $_.Id -eq $Id }) }
    return $all
}

function Test-TopDeckDefinition {
    <# Checks the tweak files for mistakes (missing fields, duplicate IDs, bad action types). Returns a list of problems. #>
    $problems = @()
    $seen = @{}
    $validTypes = 'Registry', 'RegistryKey', 'Service', 'ScheduledTask', 'Appx', 'Command'
    foreach ($t in Get-TopDeckTweak) {
        foreach ($field in 'Id', 'Name', 'Category', 'Risk', 'Description', 'Actions') {
            if (-not $t.ContainsKey($field)) { $problems += "Tweak '$($t.Id)' is missing '$field'" }
        }
        if ($seen.ContainsKey($t.Id)) { $problems += "Duplicate tweak ID '$($t.Id)'" }
        $seen[$t.Id] = $true
        if ($t.Risk -notin 'Safe', 'Moderate', 'Advanced') { $problems += "Tweak '$($t.Id)' has unknown risk '$($t.Risk)'" }
        foreach ($a in @($t.Actions)) {
            if ($a.Type -notin $validTypes) { $problems += "Tweak '$($t.Id)' has unknown action type '$($a.Type)'"; continue }
            $need = switch ($a.Type) {
                'Registry'      { if ($a.ContainsKey('Ensure')) { 'Path', 'Name' } else { 'Path', 'Name', 'Kind', 'Value' } }
                'RegistryKey'   { 'Path', 'Ensure' }
                'Service'       { 'Name', 'Startup' }
                'ScheduledTask' { 'Path', 'Name' }
                'Appx'          { 'Package' }
                'Command'       { 'Test', 'Apply', 'Revert', 'Describe' }
            }
            foreach ($f in $need) {
                if (-not $a.ContainsKey($f)) { $problems += "Tweak '$($t.Id)' $($a.Type) action is missing '$f'" }
            }
        }
    }
    return $problems
}

#endregion

#region Backup store

function Read-TopDeckBackup {
    # Returns a hashtable: tweak ID -> array of per-action backup records (@{ K = action key; B = data }).
    $store = @{}
    if (Test-Path $script:BackupFile) {
        $raw = Get-Content -Path $script:BackupFile -Raw -Encoding UTF8
        if ($raw -and $raw.Trim()) {
            foreach ($p in ($raw | ConvertFrom-Json).PSObject.Properties) { $store[$p.Name] = @($p.Value) }
        }
    }
    return $store
}

function Save-TopDeckBackup {
    param([hashtable]$Store)
    if (-not (Test-Path $script:DataDir)) { New-Item -ItemType Directory -Path $script:DataDir -Force | Out-Null }
    $Store | ConvertTo-Json -Depth 40 | Set-Content -Path $script:BackupFile -Encoding UTF8
}

#endregion

#region Registry actions
# Uses the .NET registry API directly rather than the PowerShell registry cmdlets, because the
# cmdlets can't handle every value type (REG_NONE) or a key's unnamed "(Default)" value cleanly.
#
# Registry action fields:
#   Path, Name        Name '' means the key's (Default) value
#   Kind, Value       what to set: DWord, QWord, String, ExpandString, MultiString, Binary, None
#   Ensure = 'Absent' instead of Kind/Value: the tweak deletes the value
#   Default           Windows' own value, used for undo when there is no backup.
#                     'Delete' = the value normally doesn't exist. DefaultKind if Kind isn't set.
#
# RegistryKey action fields: Path, Ensure = 'Absent'. Deletes a whole key; the backup is a full
# snapshot of the key, its values and sub-keys, so undo can rebuild it exactly.

function ConvertTo-RegistryValue {
    # Values read back from JSON come out as generic types; turn them back into what the registry expects.
    param($Value, [string]$Kind)
    # The leading comma stops PowerShell unwrapping arrays: an empty or one-item array would
    # otherwise come back as $null or a single item, and the registry would reject it.
    switch ($Kind) {
        'DWord'       { return [int]$Value }
        'QWord'       { return [long]$Value }
        'Binary'      { return , [byte[]]@($Value) }
        'None'        { return , [byte[]]@($Value) }
        'MultiString' { return , [string[]]@($Value) }
        default       { return [string]$Value }
    }
}

function Split-RegistryPath {
    param([string]$Path)
    $hive, $sub = $Path -split ':\\', 2
    $root = switch ($hive) {
        'HKLM' { [Microsoft.Win32.Registry]::LocalMachine }
        'HKCU' { [Microsoft.Win32.Registry]::CurrentUser }
        'HKCR' { [Microsoft.Win32.Registry]::ClassesRoot }
        'HKU'  { [Microsoft.Win32.Registry]::Users }
        default { throw "Unsupported registry hive in '$Path'" }
    }
    return @{ Root = $root; Sub = [string]$sub }
}

function Open-RegistryKey {
    # Returns the opened key, or $null if it doesn't exist (and -Create wasn't asked for). Caller must Close() it.
    param([string]$Path, [switch]$Writable, [switch]$Create)
    $p = Split-RegistryPath $Path
    if ($Create) { return $p.Root.CreateSubKey($p.Sub) }
    return $p.Root.OpenSubKey($p.Sub, [bool]$Writable)
}

function Test-RegistryKeyExists {
    param([string]$Path)
    $k = Open-RegistryKey $Path
    if ($k) { $k.Close(); return $true }
    return $false
}

function Get-RegistryState {
    param([string]$Path, [string]$Name)
    $key = Open-RegistryKey $Path
    if (-not $key) { return @{ Exists = $false } }
    try {
        if ($key.GetValueNames() -notcontains $Name) { return @{ Exists = $false } }
        return @{
            Exists = $true
            Value  = $key.GetValue($Name, $null, 'DoNotExpandEnvironmentNames')
            Kind   = $key.GetValueKind($Name).ToString()
        }
    } finally { $key.Close() }
}

function Set-RegistryState {
    param([string]$Path, [string]$Name, $Value, [string]$Kind)
    $key = Open-RegistryKey $Path -Create
    try { $key.SetValue($Name, (ConvertTo-RegistryValue $Value $Kind), [Microsoft.Win32.RegistryValueKind]$Kind) }
    finally { $key.Close() }
}

function Remove-RegistryState {
    param([string]$Path, [string]$Name)
    $key = Open-RegistryKey $Path -Writable
    if ($key) { try { $key.DeleteValue($Name, $false) } finally { $key.Close() } }
}

function Test-IsAbsentAction { param([hashtable]$A) $A.ContainsKey('Ensure') -and $A.Ensure -eq 'Absent' }

function Format-RegistryValue {
    param($Value)
    $text = @($Value) -join ','
    if ($text.Length -gt 60) { $text = $text.Substring(0, 57) + '...' }
    return $text
}

function Test-RegistryAction {
    param([hashtable]$A)
    $s = Get-RegistryState $A.Path $A.Name
    if (Test-IsAbsentAction $A) { return -not $s.Exists }
    if (-not $s.Exists) { return $false }
    if ($A.Kind -in 'Binary', 'None', 'MultiString') { return (@($s.Value) -join ',') -eq (@($A.Value) -join ',') }
    return [string](ConvertTo-RegistryValue $s.Value $A.Kind) -eq [string](ConvertTo-RegistryValue $A.Value $A.Kind)
}

function Backup-RegistryAction {
    param([hashtable]$A)
    $s = Get-RegistryState $A.Path $A.Name
    if ($s.Exists) { return @{ Existed = $true; Value = $s.Value; Kind = $s.Kind } }
    return @{ Existed = $false }
}

function Invoke-RegistryAction {
    param([hashtable]$A)
    if (Test-IsAbsentAction $A) { Remove-RegistryState $A.Path $A.Name }
    else { Set-RegistryState $A.Path $A.Name $A.Value $A.Kind }
}

function Undo-RegistryAction {
    param([hashtable]$A, $Backup)
    if ($Backup) {
        if ($Backup.Existed) { Set-RegistryState $A.Path $A.Name $Backup.Value $Backup.Kind }
        else { Remove-RegistryState $A.Path $A.Name }
        return
    }
    # No backup: the tweak was applied by something else. Use the Windows default if the definition has one.
    if ($A.ContainsKey('Default')) {
        if ($A.Default -eq 'Delete') { Remove-RegistryState $A.Path $A.Name; return }
        $kind = if ($A.ContainsKey('DefaultKind')) { $A.DefaultKind } else { $A.Kind }
        Set-RegistryState $A.Path $A.Name $A.Default $kind
        return
    }
    # Group Policy values don't exist on a fresh Windows install, so deleting them is the true default.
    if ($A.Path -match '\\Policies\\' -and -not (Test-IsAbsentAction $A)) { Remove-RegistryState $A.Path $A.Name; return }
    Write-TopDeckLog "  No saved original for $($A.Path)\$($A.Name); left as it is." 'Warn'
}

function Get-RegistryDescription {
    param([hashtable]$A)
    $s = Get-RegistryState $A.Path $A.Name
    $now = if ($s.Exists) { Format-RegistryValue $s.Value } else { '(not set)' }
    $target = if (Test-IsAbsentAction $A) { '(delete)' } else { Format-RegistryValue $A.Value }
    $label = if ($A.Name) { $A.Name } else { '(Default)' }
    return 'Registry  {0}\{1}: {2} -> {3}' -f $A.Path, $label, $now, $target
}

function Get-RegistryKeySnapshot {
    # Everything under a key, as plain data that survives a round trip through JSON.
    param($Key)   # a Microsoft.Win32.RegistryKey (untyped so tests can pass a stand-in)
    $values = @()
    foreach ($n in $Key.GetValueNames()) {
        $values += @{ Name = $n; Kind = $Key.GetValueKind($n).ToString(); Value = $Key.GetValue($n, $null, 'DoNotExpandEnvironmentNames') }
    }
    $subs = @{}
    foreach ($n in $Key.GetSubKeyNames()) {
        $child = $Key.OpenSubKey($n)
        if ($child) { try { $subs[$n] = Get-RegistryKeySnapshot $child } finally { $child.Close() } }
    }
    return @{ Values = $values; Keys = $subs }
}

function Restore-RegistryKeySnapshot {
    param([string]$Path, $Snapshot)
    $key = Open-RegistryKey $Path -Create
    try {
        foreach ($v in @($Snapshot.Values)) {
            if ($v) { $key.SetValue([string]$v.Name, (ConvertTo-RegistryValue $v.Value $v.Kind), [Microsoft.Win32.RegistryValueKind]$v.Kind) }
        }
    } finally { $key.Close() }
    # Sub-keys are a hashtable when fresh, or an object when read back from the backup file.
    $subs = $Snapshot.Keys
    $pairs = if ($subs -is [hashtable]) { $subs.GetEnumerator() } elseif ($subs) { $subs.PSObject.Properties } else { @() }
    foreach ($pair in $pairs) { Restore-RegistryKeySnapshot "$Path\$($pair.Name)" $pair.Value }
}

function Test-RegistryKeyAction { param([hashtable]$A) -not (Test-RegistryKeyExists $A.Path) }

function Backup-RegistryKeyAction {
    param([hashtable]$A)
    $key = Open-RegistryKey $A.Path
    if (-not $key) { return @{ Existed = $false } }
    try { return @{ Existed = $true; Snapshot = Get-RegistryKeySnapshot $key } } finally { $key.Close() }
}

function Invoke-RegistryKeyAction {
    param([hashtable]$A)
    $p = Split-RegistryPath $A.Path
    $p.Root.DeleteSubKeyTree($p.Sub, $false)
}

function Undo-RegistryKeyAction {
    param([hashtable]$A, $Backup)
    if ($Backup -and $Backup.Existed) { Restore-RegistryKeySnapshot $A.Path $Backup.Snapshot }
    elseif (-not $Backup) { Write-TopDeckLog "  No saved copy of $($A.Path); it can't be rebuilt." 'Warn' }
}

function Get-RegistryKeyDescription {
    param([hashtable]$A)
    if (Test-RegistryKeyExists $A.Path) { return "Registry  delete key $($A.Path) (a full copy is saved first)" }
    return "Registry  key $($A.Path): already gone"
}

#endregion

#region Service actions
# Startup type is read and written through the registry 'Start' value. Set-Service refuses some
# protected services that the registry route handles, and it gives one consistent code path.

$script:StartCodes = @{ Automatic = 2; Manual = 3; Disabled = 4 }

function Get-ServiceKeyPath { param([string]$Name) "HKLM:\SYSTEM\CurrentControlSet\Services\$Name" }

function Get-ServiceStartName {
    param([string]$Name)
    $path = Get-ServiceKeyPath $Name
    if (-not (Test-Path $path)) { return $null }
    $code = (Get-ItemProperty -Path $path -Name Start -ErrorAction SilentlyContinue).Start
    foreach ($k in $script:StartCodes.Keys) { if ($script:StartCodes[$k] -eq $code) { return $k } }
    return [string]$code
}

function Test-ServiceAction {
    param([hashtable]$A)
    $now = Get-ServiceStartName $A.Name
    if ($null -eq $now) { return $true }   # service not on this PC: nothing to do
    return $now -eq $A.Startup
}

function Backup-ServiceAction { param([hashtable]$A) @{ Startup = Get-ServiceStartName $A.Name } }

function Set-ServiceStart {
    param([string]$Name, [string]$Startup)
    $path = Get-ServiceKeyPath $Name
    if (-not (Test-Path $path)) { return }
    $code = if ($script:StartCodes.ContainsKey($Startup)) { $script:StartCodes[$Startup] } else { [int]$Startup }
    Set-ItemProperty -Path $path -Name Start -Value $code -Type DWord
}

function Invoke-ServiceAction {
    param([hashtable]$A)
    Set-ServiceStart $A.Name $A.Startup
    if ($A.Startup -eq 'Disabled') { Stop-Service -Name $A.Name -Force -ErrorAction SilentlyContinue }
}

function Undo-ServiceAction {
    param([hashtable]$A, $Backup)
    $target = if ($Backup -and $Backup.Startup) { $Backup.Startup } elseif ($A.ContainsKey('Default')) { $A.Default } else { 'Manual' }
    Set-ServiceStart $A.Name $target
}

function Get-ServiceDescription {
    param([hashtable]$A)
    $now = Get-ServiceStartName $A.Name
    if ($null -eq $now) { return "Service   $($A.Name): not installed, skipped" }
    return "Service   $($A.Name) startup: $now -> $($A.Startup)"
}

#endregion

#region Scheduled task actions

function Get-TaskObject {
    param([hashtable]$A)
    Get-ScheduledTask -TaskPath $A.Path -TaskName $A.Name -ErrorAction SilentlyContinue
}

function Test-TaskAction {
    param([hashtable]$A)
    $t = Get-TaskObject $A
    if (-not $t) { return $true }
    return $t.State -eq 'Disabled'
}

function Backup-TaskAction {
    param([hashtable]$A)
    $t = Get-TaskObject $A
    @{ Enabled = [bool]($t -and $t.State -ne 'Disabled') }
}

function Invoke-TaskAction {
    param([hashtable]$A)
    if (Get-TaskObject $A) { Disable-ScheduledTask -TaskPath $A.Path -TaskName $A.Name | Out-Null }
}

function Undo-TaskAction {
    param([hashtable]$A, $Backup)
    $enable = if ($Backup) { [bool]$Backup.Enabled } else { $true }
    if ($enable -and (Get-TaskObject $A)) { Enable-ScheduledTask -TaskPath $A.Path -TaskName $A.Name | Out-Null }
}

function Get-TaskDescription {
    param([hashtable]$A)
    $t = Get-TaskObject $A
    if (-not $t) { return "Task      $($A.Path)$($A.Name): not found, skipped" }
    return "Task      $($A.Path)$($A.Name): $($t.State) -> Disabled"
}

#endregion

#region Appx (built-in app) actions
# Removing an app cannot be undone from a backup. Revert reinstalls from the Microsoft Store with
# winget when the definition gives a StoreId; otherwise the log says to reinstall it manually.

$script:ProvisionedCache = $null

function Get-ProvisionedApps {
    # Listing provisioned apps takes several seconds, so do it once and reuse it until something is removed.
    if ($null -eq $script:ProvisionedCache) {
        $script:ProvisionedCache = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue)
    }
    return $script:ProvisionedCache
}

function Test-AppxAction {
    param([hashtable]$A)
    $installed   = Get-AppxPackage -AllUsers -Name $A.Package -ErrorAction SilentlyContinue
    $provisioned = Get-ProvisionedApps | Where-Object { $_.DisplayName -like $A.Package }
    return -not ($installed -or $provisioned)
}

function Backup-AppxAction { param([hashtable]$A) @{ } }

function Invoke-AppxAction {
    param([hashtable]$A)
    Get-AppxPackage -AllUsers -Name $A.Package -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    }
    # Provisioned = the copy Windows installs for every new user account. Remove it too or the app comes back.
    Get-ProvisionedApps | Where-Object { $_.DisplayName -like $A.Package } | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
    }
    $script:ProvisionedCache = $null
}

function Undo-AppxAction {
    param([hashtable]$A, $Backup)
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($A.ContainsKey('StoreId') -and $winget) {
        Write-TopDeckLog "Reinstalling $($A.Package) from the Microsoft Store..."
        & $winget.Source install --id $A.StoreId --source msstore --accept-package-agreements --accept-source-agreements --silent | Out-Null
    } else {
        Write-TopDeckLog "$($A.Package) can't be reinstalled automatically. Get it from the Microsoft Store if you want it back." 'Warn'
    }
    $script:ProvisionedCache = $null
}

function Get-AppxDescription {
    param([hashtable]$A)
    if (Test-AppxAction $A) { return "App       $($A.Package): not installed, skipped" }
    return "App       $($A.Package): remove for all users"
}

#endregion

#region Command actions (one-off scripts with their own test/apply/revert)

function Test-CommandAction    { param([hashtable]$A) [bool](& $A.Test) }
function Backup-CommandAction  { param([hashtable]$A) if ($A.ContainsKey('Backup')) { & $A.Backup } else { $null } }
function Invoke-CommandAction  { param([hashtable]$A) & $A.Apply | Out-Null }
function Undo-CommandAction    { param([hashtable]$A, $Backup) & $A.Revert $Backup | Out-Null }
function Get-CommandDescription { param([hashtable]$A) "Command   $($A.Describe)" }

#endregion

#region Dispatch

$script:Handlers = @{
    Registry      = @{ Test = 'Test-RegistryAction'; Backup = 'Backup-RegistryAction'; Apply = 'Invoke-RegistryAction'; Revert = 'Undo-RegistryAction'; Describe = 'Get-RegistryDescription' }
    RegistryKey   = @{ Test = 'Test-RegistryKeyAction'; Backup = 'Backup-RegistryKeyAction'; Apply = 'Invoke-RegistryKeyAction'; Revert = 'Undo-RegistryKeyAction'; Describe = 'Get-RegistryKeyDescription' }
    Service       = @{ Test = 'Test-ServiceAction';  Backup = 'Backup-ServiceAction';  Apply = 'Invoke-ServiceAction';  Revert = 'Undo-ServiceAction';  Describe = 'Get-ServiceDescription' }
    ScheduledTask = @{ Test = 'Test-TaskAction';     Backup = 'Backup-TaskAction';     Apply = 'Invoke-TaskAction';     Revert = 'Undo-TaskAction';     Describe = 'Get-TaskDescription' }
    Appx          = @{ Test = 'Test-AppxAction';     Backup = 'Backup-AppxAction';     Apply = 'Invoke-AppxAction';     Revert = 'Undo-AppxAction';     Describe = 'Get-AppxDescription' }
    Command       = @{ Test = 'Test-CommandAction';  Backup = 'Backup-CommandAction';  Apply = 'Invoke-CommandAction';  Revert = 'Undo-CommandAction';  Describe = 'Get-CommandDescription' }
}

function Invoke-ActionStep {
    param([hashtable]$Action, [ValidateSet('Test', 'Backup', 'Apply', 'Revert', 'Describe')][string]$Step, $Backup)
    $fn = $script:Handlers[$Action.Type][$Step]
    if ($Step -eq 'Revert') { return & $fn $Action $Backup }
    return & $fn $Action
}

#endregion

#region Public: state, preview, apply, revert

function Get-TopDeckTweakState {
    <# Returns 'Applied', 'NotApplied' or 'Partial' for one tweak, by testing each action. #>
    param([Parameter(Mandatory)][hashtable]$Tweak)
    $on = 0; $total = 0
    foreach ($a in @($Tweak.Actions)) {
        $total++
        try { if (Invoke-ActionStep $a 'Test') { $on++ } } catch { }   # unreadable counts as not applied
    }
    if ($on -eq $total) { return 'Applied' }
    if ($on -eq 0) { return 'NotApplied' }
    return 'Partial'
}

function Get-TopDeckState {
    <# Current state of every tweak, as a hashtable of ID -> state. Plain data, safe to pass between threads. #>
    $result = @{}
    foreach ($t in Get-TopDeckTweak) { $result[$t.Id] = Get-TopDeckTweakState $t }
    return $result
}

function Get-TopDeckPreview {
    <# Lines describing exactly what a plan would change. Plan = hashtable of tweak ID -> 'Apply' or 'Revert'. #>
    param([Parameter(Mandatory)][hashtable]$Plan)
    $backups = Read-TopDeckBackup
    $lines = @()
    foreach ($t in Get-TopDeckTweak -Id @($Plan.Keys)) {
        $op = $Plan[$t.Id]
        $lines += ''
        $lines += "[$op] $($t.Name)  ($($t.Risk))"
        if ($op -eq 'Apply') {
            foreach ($a in @($t.Actions)) {
                try { $lines += '    ' + (Invoke-ActionStep $a 'Describe') } catch { $lines += "    $($a.Type): could not read current value ($($_.Exception.Message))" }
            }
        } else {
            $src = if ($backups.ContainsKey($t.Id)) { 'your saved originals' } else { 'Windows defaults (no backup found)' }
            $lines += "    Put back $(@($t.Actions).Count) setting(s) from $src"
        }
    }
    return $lines
}

function Get-ActionKey {
    # Identifies an action by what it touches, so backups still match after a tweak's action list is edited.
    param([hashtable]$A)
    $parts = switch ($A.Type) {
        'Registry'      { $A.Path, $A.Name }
        'RegistryKey'   { $A.Path }
        'Service'       { $A.Name }
        'ScheduledTask' { $A.Path, $A.Name }
        'Appx'          { $A.Package }
        'Command'       { $A.Describe }
    }
    return (@($A.Type) + @($parts) -join '|').ToLowerInvariant()
}

function Find-BackupRecord {
    # Records are @{ K = action key; B = backup data }. Older backups were a plain list in action order.
    param($Records, [hashtable]$Action, [int]$Index)
    $key = Get-ActionKey $Action
    foreach ($r in @($Records)) {
        if ($r -and $r.PSObject.Properties['K'] -and $r.K -eq $key) { return @{ Found = $true; Data = $r.B } }
        if ($r -is [hashtable] -and $r.ContainsKey('K') -and $r.K -eq $key) { return @{ Found = $true; Data = $r.B } }
    }
    $list = @()
    if ($null -ne $Records) { $list = @($Records) }   # keep null entries: old backups are matched by position
    $anyKeyed = @($list | Where-Object { $_ -and ($_.PSObject.Properties['K'] -or ($_ -is [hashtable] -and $_.ContainsKey('K'))) }).Count
    if (-not $anyKeyed -and $Index -lt $list.Count) { return @{ Found = $true; Data = $list[$Index] } }
    return @{ Found = $false; Data = $null }
}

function Invoke-TopDeckPlan {
    <#
    Runs a plan: hashtable of tweak ID -> 'Apply' or 'Revert'.
    Apply: saves the original of each setting (first time only), then applies each action.
    Revert: restores originals in reverse order, then forgets the backup.
    One failing action is logged and the rest carry on.
    Returns @{ Reboot; Explorer; Failed }.
    #>
    param([Parameter(Mandatory)][hashtable]$Plan)
    $backups = Read-TopDeckBackup
    $reboot = $false
    $explorer = $false
    $failed = 0

    foreach ($t in Get-TopDeckTweak -Id @($Plan.Keys)) {
        $op = $Plan[$t.Id]
        Write-TopDeckLog "$op`: $($t.Name)"
        $actions = @($t.Actions)
        $failedBefore = $failed

        if ($op -eq 'Apply') {
            # Back up any setting that has no saved original yet. Existing originals are never overwritten.
            # @() around the whole 'if': an if/else that yields an empty array otherwise gives $null.
            $records = @(if ($backups.ContainsKey($t.Id)) { $backups[$t.Id] })
            $changed = $false
            for ($i = 0; $i -lt $actions.Count; $i++) {
                if ((Find-BackupRecord $records $actions[$i] $i).Found) { continue }
                $data = $null
                try { $data = Invoke-ActionStep $actions[$i] 'Backup' } catch { }   # unreadable: undo falls back to the default
                $records += , @{ K = Get-ActionKey $actions[$i]; B = $data }
                $changed = $true
            }
            if ($changed) { $backups[$t.Id] = $records; Save-TopDeckBackup $backups }
            foreach ($a in $actions) {
                try { Invoke-ActionStep $a 'Apply' | Out-Null }
                catch { $failed++; Write-TopDeckLog "  $($a.Type) failed: $($_.Exception.Message)" 'Error' }
            }
        } else {
            # @() around the whole 'if': an if/else that yields an empty array otherwise gives $null.
            $records = @(if ($backups.ContainsKey($t.Id)) { $backups[$t.Id] })
            for ($i = $actions.Count - 1; $i -ge 0; $i--) {
                $b = (Find-BackupRecord $records $actions[$i] $i).Data
                try { Invoke-ActionStep $actions[$i] 'Revert' $b | Out-Null }
                catch { $failed++; Write-TopDeckLog "  $($actions[$i].Type) revert failed: $($_.Exception.Message)" 'Error' }
            }
            $backups.Remove($t.Id)
            Save-TopDeckBackup $backups
        }

        if ($t.ContainsKey('Reboot') -and $t.Reboot) { $reboot = $true }
        if ($t.ContainsKey('Explorer') -and $t.Explorer) { $explorer = $true }
        if ($failed -eq $failedBefore) { Write-TopDeckLog '  done' 'Ok' } else { Write-TopDeckLog '  finished with errors' 'Warn' }
    }
    return @{ Reboot = $reboot; Explorer = $explorer; Failed = $failed }
}

function Restart-TopDeckExplorer {
    <# Restarts File Explorer so taskbar, Start and Explorer changes show without signing out. #>
    Write-TopDeckLog 'Restarting File Explorer...'
    Get-Process -Name explorer -ErrorAction SilentlyContinue | Stop-Process -Force
    # Windows restarts the shell itself as the normal (non-admin) user. Starting it from here would
    # run the whole desktop as admin, so only do that if Windows hasn't brought it back in 10 seconds.
    for ($i = 0; $i -lt 20; $i++) {
        Start-Sleep -Milliseconds 500
        if (Get-Process -Name explorer -ErrorAction SilentlyContinue) { Write-TopDeckLog 'File Explorer restarted' 'Ok'; return }
    }
    Start-Process explorer.exe
    Write-TopDeckLog 'File Explorer was started by Top Deck. Sign out and back in if anything looks odd.' 'Warn'
}

function Invoke-TopDeckTool {
    <# Runs one of the one-shot tools from Tools\Tools.ps1 and logs its output. #>
    param([Parameter(Mandatory)][string]$Id)
    $tool = Get-TopDeckTool -Id $Id | Select-Object -First 1
    if (-not $tool) { throw "No tool with ID '$Id'" }
    Write-TopDeckLog "Running: $($tool.Name)"
    try {
        & $tool.Run | ForEach-Object {
            $text = ([string]$_) -replace "`0", ''   # sfc prints UTF-16; strip the stray null characters
            if ($text.Trim()) { Write-TopDeckLog "  $($text.Trim())" }
        }
        Write-TopDeckLog "$($tool.Name) finished" 'Ok'
    } catch {
        Write-TopDeckLog "$($tool.Name) failed: $($_.Exception.Message)" 'Error'
    }
}

#endregion

#region Restore point and profiles

function New-TopDeckRestorePoint {
    <#
    Creates a Windows restore point. Windows normally allows only one every 24 hours, so the
    frequency limit is lifted for this call and put back afterwards. Returns $true on success.
    #>
    $key  = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
    $name = 'SystemRestorePointCreationFrequency'
    $before = Get-RegistryState $key $name
    try {
        Write-TopDeckLog 'Creating a restore point (this can take a minute)...'
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Set-RegistryState $key $name 0 'DWord'
        Checkpoint-Computer -Description 'Top Deck Optimizer' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
        Write-TopDeckLog 'Restore point created' 'Ok'
        return $true
    } catch {
        Write-TopDeckLog "Restore point failed: $($_.Exception.Message)" 'Error'
        return $false
    } finally {
        if ($before.Exists) { Set-RegistryState $key $name $before.Value $before.Kind } else { Remove-RegistryState $key $name }
    }
}

function Export-TopDeckProfile {
    <# Saves the list of tweak IDs that should be on. #>
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][AllowEmptyCollection()][string[]]$On)
    [ordered]@{ App = 'TopDeckOptimizer'; Version = 1; Saved = (Get-Date).ToString('s'); On = @($On) } |
        ConvertTo-Json | Set-Content -Path $Path -Encoding UTF8
}

function Import-TopDeckProfile {
    <# Returns the tweak IDs a profile turns on. Unknown IDs (from a newer version) are dropped. #>
    param([Parameter(Mandatory)][string]$Path)
    $p = Get-Content -Path $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($p.App -ne 'TopDeckOptimizer') { throw 'That file is not a Top Deck profile.' }
    $known = @(Get-TopDeckTweak | ForEach-Object { $_.Id })
    return @(@($p.On) | Where-Object { $known -contains $_ })
}

#endregion

Export-ModuleMember -Function Set-TopDeckLogSink, Write-TopDeckLog, Get-TopDeckTweak, Get-TopDeckTool,
    Test-TopDeckDefinition, Get-TopDeckTweakState, Get-TopDeckState, Get-TopDeckPreview, Invoke-TopDeckPlan,
    Invoke-TopDeckTool, Restart-TopDeckExplorer, New-TopDeckRestorePoint, Export-TopDeckProfile, Import-TopDeckProfile, Read-TopDeckBackup
