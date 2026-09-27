<#
Cleanup.Tests.ps1 - checks the cleanup engine's safety rules on a throw-away folder tree.

  - files inside the target folder are deleted, and the target folder itself is kept
  - a symbolic link inside the target that points elsewhere is NOT followed (the files it points to survive)
  - files newer than MinAgeHours are kept
  - read-only files are deleted; emptied sub-folders are removed
  - the scan size matches what the clean frees
  - every category in Tools\Cleanup.ps1 loads and has the fields it needs

Runs on any OS with PowerShell 7 (pwsh):  pwsh -File Tests\Cleanup.Tests.ps1
#>
# The test folder path is global on purpose: the engine module's own scope has to reach it.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param([string]$Root = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$work = Join-Path ([IO.Path]::GetTempPath()) ('tdclean' + [guid]::NewGuid())
$env:ProgramData = Join-Path $work 'pd'
New-Item -ItemType Directory $env:ProgramData | Out-Null

$mod = Import-Module (Join-Path $Root 'Core/Engine.psm1') -PassThru -Force
Set-TopDeckLogSink (New-Object 'System.Collections.Concurrent.ConcurrentQueue[string]')
$fail = 0
function Check([bool]$Ok, [string]$What) { if ($Ok) { "ok   $What" } else { $script:fail++; "FAIL $What" } }

# Every real category must load and have what it needs.
foreach ($c in Get-TopDeckCleanupItem) {
    $has = $c.ContainsKey('Folders') -or $c.ContainsKey('Files') -or ($c.ContainsKey('Measure') -and $c.ContainsKey('Clean'))
    Check ($c.Id -and $c.Name -and $c.Description -and $has) "category $($c.Id) is complete"
}

# Build the test tree.
$target   = Join-Path $work 'target'
$precious = Join-Path $work 'precious'
New-Item -ItemType Directory "$target/sub/deeper", $precious | Out-Null
Set-Content "$precious/keep.txt" 'must survive'
Set-Content "$target/old1.tmp" ('x' * 1000)
Set-Content "$target/sub/old2.tmp" ('x' * 2000)
Set-Content "$target/sub/deeper/old3.tmp" ('x' * 3000)
Set-Content "$target/readonly.tmp" ('x' * 500)
Set-Content "$target/new.tmp" 'recent'
foreach ($f in Get-ChildItem $target -Recurse -File) { $f.LastWriteTime = (Get-Date).AddDays(-3) }
(Get-Item "$target/new.tmp").LastWriteTime = (Get-Date).AddMinutes(-5)
(Get-Item "$target/readonly.tmp").IsReadOnly = $true
New-Item -ItemType SymbolicLink -Path "$target/link-to-precious" -Target $precious | Out-Null
New-Item -ItemType SymbolicLink -Path "$target/sub/filelink.tmp" -Target "$precious/keep.txt" | Out-Null

# Point the engine at a test category instead of the real ones.
$global:TestTarget = $target
& $mod {
    function script:Get-TopDeckCleanupItem {
        param([string[]]$Id)
        @(@{ Id = 'test'; Name = 'Test'; Description = 'x'; MinAgeHours = 24; Folders = { $global:TestTarget } })
    }
}

$scan = (Measure-TopDeckCleanup -Id 'test')['test']
Check ($scan.Files -eq 4) "scan counts 4 old files, skipping the new file and both links (got $($scan.Files))"
$r = (Invoke-TopDeckCleanup -Id 'test')['test']
Check ($r.Bytes -eq $scan.Bytes) "freed bytes ($($r.Bytes)) match the scan ($($scan.Bytes))"
Check (Test-Path "$precious/keep.txt") 'file behind the symbolic links survived'
Check ((Get-Content "$precious/keep.txt") -eq 'must survive') 'its contents are unchanged'
Check (Test-Path "$target/new.tmp") 'recent file kept'
Check (-not (Test-Path "$target/readonly.tmp")) 'read-only old file deleted'
Check (-not (Test-Path "$target/sub/deeper")) 'emptied sub-folder removed'
Check (Test-Path $target) 'target folder itself kept'
Check (Test-Path "$target/link-to-precious") 'folder link itself left in place (not followed)'

# A target that is itself a link must be ignored entirely.
$global:TestTarget = "$target/link-to-precious"
$r2 = (Invoke-TopDeckCleanup -Id 'test')['test']
Check ($r2.Files -eq 0 -and (Test-Path "$precious/keep.txt")) 'a target folder that is a link is not cleaned'

Check ((Format-TopDeckSize 1536MB) -eq '1.5 GB') 'size formatting'
Remove-Item -Recurse -Force $work
"$fail failure(s)"
if ($fail) { exit 1 }
