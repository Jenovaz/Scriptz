<#
FakeRegistry.Tests.ps1 - checks every registry tweak without touching a real registry.

Runs each Registry/RegistryKey tweak through apply -> "is it on?" -> undo against an in-memory
fake registry, and checks the registry ends up exactly as it started. Works on any OS with
PowerShell 7 (pwsh); it does not need Windows.

  pwsh -File Tests\FakeRegistry.Tests.ps1                  start from an empty registry
  $env:TD_MODE = 'custom'; pwsh -File Tests\FakeRegistry.Tests.ps1
                                                           start with every value set to a custom
                                                           value, so undo must restore that value
  $env:TD_ONLY = '<tweak id>'                              test one tweak
  $env:TD_DEBUG = '<tweak id>'                             print the backup file and any difference
#>
# The fake registry is global on purpose: the engine module's own scope has to reach it.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param([string]$Root = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$env:ProgramData = Join-Path ([IO.Path]::GetTempPath()) ("tdtest" + [guid]::NewGuid())
New-Item -ItemType Directory $env:ProgramData | Out-Null

class FakeKey {
    [hashtable]$Store; [string]$Path
    FakeKey([hashtable]$s, [string]$p) { $this.Store = $s; $this.Path = $p }
    [string[]] GetValueNames() { return @($this.Store[$this.Path].Keys) }
    [object] GetValue([string]$n, $d, $o) { $v = $this.Store[$this.Path][$n]; if ($null -eq $v) { return $d }; return $v.Value }
    [object] GetValueKind([string]$n) { return [Microsoft.Win32.RegistryValueKind]$this.Store[$this.Path][$n].Kind }
    [void] SetValue([string]$n, $v, $k) {
        $kind = [string]$k
        if ($kind -eq 'DWord' -and $v -isnot [int]) { throw "DWord needs Int32, got $($v.GetType())" }
        if ($kind -in 'Binary', 'None' -and $v -isnot [byte[]]) { throw "$kind needs byte[], got $($v.GetType())" }
        $this.Store[$this.Path][$n] = @{ Kind = $kind; Value = $v }
    }
    [void] DeleteValue([string]$n, [bool]$t) { $this.Store[$this.Path].Remove($n) }
    [string[]] GetSubKeyNames() {
        $pre = $this.Path + '\'
        return @($this.Store.Keys | Where-Object { $_.StartsWith($pre) -and $_.Substring($pre.Length) -notmatch '\\' } | ForEach-Object { $_.Substring($pre.Length) })
    }
    [object] OpenSubKey([string]$n) { $p = $this.Path + '\' + $n; if ($this.Store.ContainsKey($p)) { return [FakeKey]::new($this.Store, $p) }; return $null }
    [void] Close() { }
}
class FakeRoot {
    [hashtable]$Store; [string]$Hive
    FakeRoot([hashtable]$s, [string]$h) { $this.Store = $s; $this.Hive = $h }
    [string] Full([string]$sub) { return ($this.Hive + ':\' + $sub).ToLowerInvariant() }
    [object] OpenSubKey([string]$sub, [bool]$w) { $p = $this.Full($sub); if ($this.Store.ContainsKey($p)) { return [FakeKey]::new($this.Store, $p) }; return $null }
    [object] CreateSubKey([string]$sub) {
        $parts = $sub -split '\\'; $acc = $this.Hive + ':'
        foreach ($x in $parts) { $acc = ($acc + '\' + $x); $k = $acc.ToLowerInvariant(); if (-not $this.Store.ContainsKey($k)) { $this.Store[$k] = @{} } }
        return [FakeKey]::new($this.Store, $this.Full($sub))
    }
    [void] DeleteSubKeyTree([string]$sub, [bool]$t) {
        $p = $this.Full($sub)
        foreach ($k in @($this.Store.Keys)) { if ($k -eq $p -or $k.StartsWith($p + '\')) { $this.Store.Remove($k) } }
    }
}

# Fake registry keys are stored lower-case; PowerShell @{} tables already ignore case for value names.
$global:FakeStore = @{}
$mod = Import-Module (Join-Path $Root 'Core/Engine.psm1') -PassThru -Force
& $mod {
    function script:Split-RegistryPath {
        param([string]$Path)
        $hive, $sub = $Path -split ':\\', 2
        return @{ Root = [FakeRoot]::new($global:FakeStore, $hive); Sub = [string]$sub }
    }
}
Set-TopDeckLogSink (New-Object 'System.Collections.Concurrent.ConcurrentQueue[string]')   # keep engine log lines out of the output

function Get-Dump { ($global:FakeStore.GetEnumerator() | Sort-Object Key | ForEach-Object { $_.Key + '=' + (($_.Value.GetEnumerator() | Sort-Object Key | ForEach-Object { "$($_.Key):$($_.Value.Kind):$(@($_.Value.Value) -join ',')" }) -join ';') }) -join "`n" }

$tweaks = @(Get-TopDeckTweak | Where-Object { (-not $env:TD_ONLY -or $_.Id -eq $env:TD_ONLY) -and @($_.Actions | Where-Object { $_.Type -notin 'Registry', 'RegistryKey' }).Count -eq 0 })
"Testing $($tweaks.Count) registry-only tweaks"

# Seed: pretend some keys already exist with Windows values, including every key a tweak deletes.
foreach ($t in $tweaks) {
    foreach ($a in $t.Actions) {
        if ($a.Type -eq 'RegistryKey') {
            $k = $a.Path.ToLowerInvariant(); $global:FakeStore[$k] = @{}
            $global:FakeStore[$k]['Seeded'] = @{ Kind = 'String'; Value = 'original' }
            $global:FakeStore["$k\child"] = @{}
            $global:FakeStore["$k\child"]['Deep'] = @{ Kind = 'DWord'; Value = [int]7 }
        }
    }
}

# Mode 'custom': give every value a user-chosen setting first, so undo must restore that, not the Windows default.
if ($env:TD_MODE -eq 'custom') {
    foreach ($t in $tweaks) {
        foreach ($a in $t.Actions) {
            if ($a.Type -ne 'Registry') { continue }
            $k = $a.Path.ToLowerInvariant()
            $parts = $k -split '\\'
            for ($i = 1; $i -le $parts.Count; $i++) { $p = ($parts[0..($i - 1)] -join '\'); if (-not $global:FakeStore.ContainsKey($p)) { $global:FakeStore[$p] = @{} } }
            $kind = if ($a.ContainsKey('Kind')) { $a.Kind } else { 'String' }
            $v = switch ($kind) { 'DWord' { [int]12345 } 'QWord' { [long]12345 } 'Binary' { [byte[]](1, 2, 3) } 'None' { [byte[]](9) } 'MultiString' { [string[]]('user') } default { 'user-value' } }
            $global:FakeStore[$k][$a.Name] = @{ Kind = $kind; Value = $v }
        }
    }
}

$fail = 0
"Seeded custom values: " + @($global:FakeStore.Values | ForEach-Object { $_.Values } | Where-Object { $_.Value -eq 12345 -or $_.Value -eq "user-value" }).Count
foreach ($t in $tweaks) {
    $before = Get-Dump
    $r = Invoke-TopDeckPlan -Plan @{ $t.Id = "Apply" }
    if ($env:TD_DEBUG -eq $t.Id) { 'BACKUP FILE:'; Get-Content (Join-Path $env:ProgramData 'TopDeckOptimizer/backups.json') -Raw }
    $s1 = Get-TopDeckTweakState $t
    $r2 = Invoke-TopDeckPlan -Plan @{ $t.Id = 'Revert' }
    $after = Get-Dump
    $problem = @()
    if ($r.Failed) { $problem += "apply failed x$($r.Failed)" }
    if ($s1 -ne 'Applied') { $problem += "state after apply = $s1" }
    if ($r2.Failed) { $problem += "revert failed x$($r2.Failed)" }
    # Keys created empty by apply may remain after revert; ignore empty keys when comparing.
    $norm = { param($d) ($d -split "`n" | Where-Object { $_ -notmatch '=$' }) -join "`n" }
    if ((& $norm $before) -ne (& $norm $after)) {
        $problem += 'registry differs after revert'
        if ($env:TD_DEBUG -eq $t.Id) { Compare-Object @((& $norm $before) -split "`n") @((& $norm $after) -split "`n") | Format-Table -AutoSize -Wrap | Out-String -Width 250 }
    }
    if ($problem) { $fail++; "FAIL $($t.Id): $($problem -join '; ')" }
}
"$($tweaks.Count - $fail) passed, $fail failed"
Remove-Item -Recurse -Force $env:ProgramData
if ($fail) { exit 1 }
$plan = @{}; foreach ($t in $tweaks) { $plan[$t.Id] = 'Apply' }
$lines = @(Get-TopDeckPreview -Plan $plan)
"Preview lines: $($lines.Count); unreadable: $(@($lines | Where-Object { $_ -match 'could not read' }).Count)"
$lines | Where-Object { $_ -match 'UserPreferencesMask|3d-objects|0DB7E03F' } | Select-Object -First 3
