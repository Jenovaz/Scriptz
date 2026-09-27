<#
ZomboidMods.psm1 - the logic behind the Zomboid Mod Enabler. No window code here.

A Project Zomboid server needs three lines in its settings file (Zomboid\Server\<name>.ini):
  WorkshopItems=  Steam Workshop numbers. Tells Steam what to download.
  Mods=           Mod IDs from each mod's mod.info file. Tells the game what to switch on.
  Map=            Map folder names for map mods, with the vanilla map "Muldraugh, KY" last.

This module reads the settings file and the Workshop downloads on this PC, builds a checklist,
and works out those three lines from whatever is ticked. Works in Windows PowerShell 5.1.
#>

$script:AppId = '108600'
$script:DefaultMap = 'Muldraugh, KY'

#region Small helpers

function Split-ZmList([string]$Value, [string]$Pattern = ';') {
    if (-not $Value) { return }
    $Value -split $Pattern | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

function New-ZmSet { New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase) }

# Adds to an ordered list only if not already there (case-insensitive). $Seen is the matching set.
function Add-ZmUnique($List, $Seen, [string]$Value) {
    if ($Value -and $Seen.Add($Value)) { [void]$List.Add($Value) }
}

function ConvertTo-ZmVersion([string]$Name) {
    $parts = @($Name.Split('.') | Select-Object -First 4)
    while ($parts.Count -lt 2) { $parts += '0' }
    try { [version]($parts -join '.') } catch { [version]'0.0' }
}

# Pulls Workshop numbers out of pasted text: plain numbers or Steam links (...?id=2875848298).
function Get-ZmWorkshopIdFromText([string]$Text) {
    [regex]::Matches([string]$Text, '(?<!\d)\d{6,12}(?!\d)') | ForEach-Object { $_.Value } | Select-Object -Unique
}

#endregion

#region Server settings file

function Get-ZmServerIni {
    param([Parameter(Mandatory)][string]$ZomboidDir)
    $dir = Join-Path $ZomboidDir 'Server'
    if (-not (Test-Path -LiteralPath $dir)) { return }
    Get-ChildItem -LiteralPath $dir -Filter '*.ini' -File | Sort-Object Name
}

function Read-ZmIni {
    param([Parameter(Mandatory)][string]$Path)
    $bytes = [IO.File]::ReadAllBytes($Path)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    $text = [IO.File]::ReadAllText($Path)
    $newLine = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $lines = @($text -split "`r?`n")

    $values = @{}
    foreach ($line in $lines) {
        if ($line -match '^\s*([A-Za-z0-9_]+)\s*=(.*)$') { $values[$Matches[1]] = $Matches[2].Trim() }
    }

    # Workshop numbers, remembering any listed twice so we can say we removed them.
    $workshop = New-Object System.Collections.ArrayList
    $seen = New-ZmSet
    $duplicates = New-Object System.Collections.ArrayList
    foreach ($id in (Split-ZmList $values['WorkshopItems'])) {
        if ($seen.Add($id)) { [void]$workshop.Add($id) } else { [void]$duplicates.Add($id) }
    }

    # Mod IDs. Early Build 42 wrote them as \ModID (sometimes 12345\ModID); copy whatever style is there.
    $style = 'Plain'
    $mods = New-Object System.Collections.ArrayList
    $modSeen = New-ZmSet
    foreach ($entry in (Split-ZmList $values['Mods'])) {
        $id = $entry
        if ($entry -match '^(.*)\\([^\\]+)$') {
            $id = $Matches[2]
            if ($Matches[1]) { $style = 'WorkshopPrefix' } elseif ($style -eq 'Plain') { $style = 'Backslash' }
        }
        Add-ZmUnique $mods $modSeen $id
    }

    [pscustomobject]@{
        Path          = $Path
        Name          = [IO.Path]::GetFileNameWithoutExtension($Path)
        Lines         = $lines
        NewLine       = $newLine
        HasBom        = $hasBom
        WorkshopItems = @($workshop)
        Duplicates    = @($duplicates)
        Mods          = @($mods)
        ModStyle      = $style
        Maps          = @(Split-ZmList $values['Map'])
    }
}

function Save-ZmIni {
    param(
        [Parameter(Mandatory)]$Ini,
        [Parameter(Mandatory)]$Plan,
        [string]$BackupDir
    )
    if (-not $BackupDir) { $BackupDir = Join-Path (Split-Path -Parent $Ini.Path) 'ModEnablerBackups' }
    if (-not (Test-Path -LiteralPath $BackupDir)) { [void](New-Item -ItemType Directory -Path $BackupDir) }
    $backup = Join-Path $BackupDir ('{0}-{1}.ini.bak' -f $Ini.Name, (Get-Date -Format 'yyyyMMdd-HHmmss'))
    Copy-Item -LiteralPath $Ini.Path -Destination $backup -Force

    $newValues = [ordered]@{ WorkshopItems = $Plan.WorkshopItemsLine; Mods = $Plan.ModsLine; Map = $Plan.MapLine }
    $written = New-ZmSet
    $out = New-Object System.Collections.ArrayList
    foreach ($line in $Ini.Lines) {
        $replaced = $false
        foreach ($key in $newValues.Keys) {
            if ($line -match "^\s*$key\s*=") {
                [void]$out.Add("$key=$($newValues[$key])"); [void]$written.Add($key); $replaced = $true; break
            }
        }
        if (-not $replaced) { [void]$out.Add($line) }
    }
    # A key the file didn't have yet goes at the end, before the trailing blank line if there is one.
    $insertAt = $out.Count
    if ($insertAt -gt 0 -and $out[$insertAt - 1] -eq '') { $insertAt-- }
    foreach ($key in $newValues.Keys) {
        if (-not $written.Contains($key)) { $out.Insert($insertAt, "$key=$($newValues[$key])"); $insertAt++ }
    }

    $encoding = New-Object System.Text.UTF8Encoding $Ini.HasBom
    [IO.File]::WriteAllText($Ini.Path, ($out -join $Ini.NewLine), $encoding)
    $backup
}

#endregion

#region Steam Workshop downloads

# Every Steam library folder on this PC (Steam can have libraries on several drives).
function Get-ZmSteamLibrary {
    $steamDirs = New-Object System.Collections.ArrayList
    foreach ($key in 'HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
        try { $p = Get-ItemProperty -Path $key -ErrorAction Stop } catch { continue }
        foreach ($name in 'SteamPath', 'InstallPath') {
            if ($p.PSObject.Properties[$name] -and $p.$name) { [void]$steamDirs.Add(($p.$name -replace '/', '\')) }
        }
    }
    if (${env:ProgramFiles(x86)}) { [void]$steamDirs.Add((Join-Path ${env:ProgramFiles(x86)} 'Steam')) }

    $libraries = New-Object System.Collections.ArrayList
    $seen = New-ZmSet
    foreach ($steam in $steamDirs) {
        if (-not (Test-Path -LiteralPath $steam)) { continue }
        Add-ZmUnique $libraries $seen ([IO.Path]::GetFullPath($steam))
        $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $vdf) {
            foreach ($m in [regex]::Matches([IO.File]::ReadAllText($vdf), '"path"\s+"([^"]+)"')) {
                $lib = $m.Groups[1].Value -replace '\\\\', '\'
                if (Test-Path -LiteralPath $lib) { Add-ZmUnique $libraries $seen ([IO.Path]::GetFullPath($lib)) }
            }
        }
    }
    $libraries
}

# The folders Steam downloads Zomboid Workshop items into: <library>\steamapps\workshop\content\108600
function Get-ZmWorkshopRoot {
    foreach ($lib in (Get-ZmSteamLibrary)) {
        $dir = Join-Path $lib "steamapps\workshop\content\$script:AppId"
        if (Test-Path -LiteralPath $dir) { $dir }
    }
}

function Read-ZmModInfo([string]$Path) {
    $info = @{}
    foreach ($line in [IO.File]::ReadAllLines($Path)) {
        if ($line -match '^\s*([A-Za-z_]+)\s*=\s*(.*?)\s*$' -and -not $info.ContainsKey($Matches[1])) {
            $info[$Matches[1]] = $Matches[2]
        }
    }
    $info
}

# Map mods carry media\maps\<MapName>\map.info. The vanilla map folder is skipped: it's always added last anyway.
function Get-ZmMapFolder([string[]]$ContentDirs) {
    $seen = New-ZmSet
    foreach ($dir in $ContentDirs) {
        $maps = Join-Path (Join-Path $dir 'media') 'maps'
        if (-not (Test-Path -LiteralPath $maps)) { continue }
        foreach ($m in Get-ChildItem -LiteralPath $maps -Directory) {
            if ($m.Name -ne $script:DefaultMap -and (Test-Path -LiteralPath (Join-Path $m.FullName 'map.info')) -and $seen.Add($m.Name)) {
                $m.Name
            }
        }
    }
}

<#
One mod folder inside a Workshop download (<item>\mods\<folder>).
Build 42 layout: <folder>\common\ plus version folders like <folder>\42\ or <folder>\42.13\, each with mod.info.
Build 41 layout: mod.info and media\ sit straight in <folder>.
We read the highest version folder for the build you play (the game picks the closest one too).
#>
function Read-ZmModFolder {
    param([Parameter(Mandatory)][string]$Path, [int]$Build = 42)
    $versionDirs = @(Get-ChildItem -LiteralPath $Path -Directory |
        Where-Object { $_.Name -match '^\d+(\.\d+)*$' } |
        Sort-Object { ConvertTo-ZmVersion $_.Name } -Descending)
    $sameBuild = @($versionDirs | Where-Object { $_.Name.Split('.')[0] -eq "$Build" })
    $common = Join-Path $Path 'common'
    $hasInfo = { param($d) Test-Path -LiteralPath (Join-Path $d 'mod.info') }

    $infoDir = $null; $layout = $null
    $pick = @($sameBuild | Where-Object { & $hasInfo $_.FullName } | Select-Object -First 1)
    if ($pick) { $infoDir = $pick[0].FullName; $layout = "$Build" }
    elseif ($Build -ge 42 -and (& $hasInfo $common)) { $infoDir = $common; $layout = 'common' }
    elseif (& $hasInfo $Path) { $infoDir = $Path; $layout = 'root' }
    else {
        $pick = @($versionDirs | Where-Object { & $hasInfo $_.FullName } | Select-Object -First 1)
        if ($pick) { $infoDir = $pick[0].FullName; $layout = $pick[0].Name }
    }
    if (-not $infoDir) { return }

    $info = Read-ZmModInfo (Join-Path $infoDir 'mod.info')
    $id = ([string]$info['id']) -replace '^.*\\', ''
    if (-not $id) { return }

    $contentDirs = @($Path, $common) + @($sameBuild | ForEach-Object { $_.FullName }) + @($infoDir)
    [pscustomobject]@{
        Id       = $id
        Name     = $(if ($info['name']) { $info['name'] } else { $id })
        Requires = @(Split-ZmList ([string]$info['require']) '[,;]' | ForEach-Object { $_ -replace '^.*\\', '' } | Where-Object { $_ })
        Maps     = @(Get-ZmMapFolder $contentDirs)
        Layout   = $layout
        Folder   = $Path
    }
}

function Read-ZmWorkshopItem {
    param([Parameter(Mandatory)][string]$Path, [int]$Build = 42)
    $modsDir = Join-Path $Path 'mods'
    $mods = @()
    if (Test-Path -LiteralPath $modsDir) {
        $mods = @(Get-ChildItem -LiteralPath $modsDir -Directory | Sort-Object Name | ForEach-Object { Read-ZmModFolder -Path $_.FullName -Build $Build })
    }
    [pscustomobject]@{ Id = (Split-Path -Leaf $Path); Path = $Path; Mods = $mods }
}

# Every downloaded Zomboid Workshop item: an ordered table of Workshop number -> item.
function Get-ZmInstalledItem {
    param([string[]]$WorkshopRoot, [int]$Build = 42)
    $items = [ordered]@{}
    foreach ($root in $WorkshopRoot) {
        if (-not (Test-Path -LiteralPath $root)) { continue }
        foreach ($dir in Get-ChildItem -LiteralPath $root -Directory | Where-Object { $_.Name -match '^\d+$' } | Sort-Object Name) {
            if (-not $items.Contains($dir.Name)) { $items[$dir.Name] = Read-ZmWorkshopItem -Path $dir.FullName -Build $Build }
        }
    }
    $items
}

#endregion

#region Checklist and result

<#
Builds the checklist. One row per mod, grouped by Workshop item.
  Section 'Server'    Workshop items already in this server's list (plus any you pasted in).
  Section 'Missing'   Items in the list that aren't downloaded on this PC. Can't be ticked.
  Section 'Installed' Other downloaded Zomboid mods, not on this server.
  Section 'Orphan'    Mod IDs switched on in the file that aren't in any download (for example a local mod).
What starts ticked:
  - anything already switched on;
  - every mod of a server item where none of its mods are on yet (it was added to the Workshop list but
    never switched on - the usual reason mods "don't load");
  - nothing else. If an item has some mods on and some off, the off ones were left off on purpose (variants).
#>
function Get-ZmChecklist {
    param(
        [Parameter(Mandatory)]$Ini,
        [Parameter(Mandatory)][AllowEmptyCollection()]$Installed,
        [string[]]$AddIds = @(),
        [int]$Build = 42
    )
    $enabled = New-ZmSet
    foreach ($m in $Ini.Mods) { [void]$enabled.Add($m) }
    $serverIds = New-Object System.Collections.ArrayList
    $seen = New-ZmSet
    foreach ($id in @($Ini.WorkshopItems) + @($AddIds)) { Add-ZmUnique $serverIds $seen $id }
    $pasted = New-ZmSet
    foreach ($id in $AddIds) { if ($Ini.WorkshopItems -notcontains $id) { [void]$pasted.Add($id) } }

    $rows = New-Object System.Collections.ArrayList
    $covered = New-ZmSet   # mod IDs that a server item provides

    $newRow = {
        param($Section, $WorkshopId, $Mod, [bool]$Checked, [bool]$Selectable, [string]$Note)
        [pscustomobject]@{
            Key        = "$WorkshopId|$(if ($Mod) { $Mod.Id })"
            Section    = $Section
            WorkshopId = $WorkshopId
            ModId      = $(if ($Mod) { $Mod.Id })
            Name       = $(if ($Mod) { $Mod.Name } else { '' })
            Requires   = $(if ($Mod) { @($Mod.Requires) } else { @() })
            Maps       = $(if ($Mod) { @($Mod.Maps) } else { @() })
            Layout     = $(if ($Mod) { $Mod.Layout })
            IsNew      = [bool]($Mod -and -not $enabled.Contains($Mod.Id))
            Checked    = $Checked
            Selectable = $Selectable
            Note       = $Note
        }
    }

    foreach ($id in $serverIds) {
        $item = if ($Installed.Contains($id)) { $Installed[$id] }
        if (-not $item) {
            [void]$rows.Add((& $newRow 'Missing' $id $null $false $false 'Not downloaded on this PC yet.'))
            continue
        }
        if (-not @($item.Mods).Count) {
            [void]$rows.Add((& $newRow 'Missing' $id $null $false $false 'Downloaded, but no mod.info found inside. It may be a collection or a broken upload.'))
            continue
        }
        $anyOn = @($item.Mods | Where-Object { $enabled.Contains($_.Id) }).Count -gt 0
        foreach ($mod in $item.Mods) {
            $on = $enabled.Contains($mod.Id) -or -not $anyOn -or $pasted.Contains($id)
            [void]$rows.Add((& $newRow 'Server' $id $mod $on $true ''))
            [void]$covered.Add($mod.Id)
        }
    }

    foreach ($id in $Installed.Keys) {
        if ($seen.Contains($id)) { continue }
        foreach ($mod in $Installed[$id].Mods) {
            # Switched on in the file but its Workshop item is missing from the list: clients would never download it.
            $on = $enabled.Contains($mod.Id) -and $covered.Add($mod.Id)
            $note = if ($on) { 'Switched on, but its Workshop item was missing from the server list. Saving adds it.' } else { '' }
            [void]$rows.Add((& $newRow 'Installed' $id $mod $on $true $note))
        }
    }

    $known = New-ZmSet
    foreach ($r in $rows) { if ($r.ModId) { [void]$known.Add($r.ModId) } }
    foreach ($m in $Ini.Mods) {
        if (-not $known.Contains($m)) {
            $row = & $newRow 'Orphan' '' ([pscustomobject]@{ Id = $m; Name = $m; Requires = @(); Maps = @(); Layout = $null }) $true $true 'Switched on, but not found in any Workshop download on this PC (a local mod, or not downloaded).'
            $row.IsNew = $false
            [void]$rows.Add($row)
        }
    }
    @($rows)
}

# Works out the new WorkshopItems / Mods / Map lines from the ticked rows, plus anything worth warning about.
function Get-ZmPlan {
    param(
        [Parameter(Mandatory)]$Ini,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Rows,
        [ValidateSet('Plain', 'Backslash', 'WorkshopPrefix')][string]$ModStyle = 'Plain',
        [int]$Build = 42
    )
    $warnings = New-Object System.Collections.ArrayList
    $on = @($Rows | Where-Object { $_.Checked -and $_.Selectable })

    # WorkshopItems: items with at least one ticked mod, plus items not downloaded yet (so Steam fetches them).
    $wsOrder = New-Object System.Collections.ArrayList
    $wsSeen = New-ZmSet
    foreach ($id in @($Ini.WorkshopItems) + @($Rows | ForEach-Object { $_.WorkshopId })) { Add-ZmUnique $wsOrder $wsSeen $id }
    $keepWs = New-ZmSet
    foreach ($r in $Rows) { if (($r.Checked -and $r.Selectable) -or $r.Section -eq 'Missing') { if ($r.WorkshopId) { [void]$keepWs.Add($r.WorkshopId) } } }
    $workshop = @($wsOrder | Where-Object { $keepWs.Contains($_) })

    foreach ($d in $Ini.Duplicates) { [void]$warnings.Add("Removed a duplicate Workshop entry: $d.") }
    foreach ($r in $Rows | Where-Object { $_.Section -eq 'Missing' }) {
        [void]$warnings.Add("Workshop item $($r.WorkshopId): $($r.Note) It stays in the list. Subscribe to it on Steam, let it download, then Rescan to switch its mods on.")
    }

    # Mods: current order first, then newly ticked ones, then shuffled so a mod's requirements load before it.
    $byId = [ordered]@{}
    $firstWs = @{}
    foreach ($id in $Ini.Mods) { $r = $on | Where-Object { $_.ModId -eq $id } | Select-Object -First 1; if ($r) { $byId[$id] = $r } }
    foreach ($r in $on) {
        if ($byId.Contains($r.ModId)) {
            if ($byId[$r.ModId].WorkshopId -ne $r.WorkshopId -and $r.WorkshopId -and $byId[$r.ModId].WorkshopId) {
                [void]$warnings.Add("Mod ID '$($r.ModId)' is in two Workshop items ($($byId[$r.ModId].WorkshopId) and $($r.WorkshopId)). They are probably copies of the same mod; keep one.")
            }
            continue
        }
        $byId[$r.ModId] = $r
    }
    $ordered = New-Object System.Collections.ArrayList
    $done = New-ZmSet
    $visiting = New-ZmSet
    $visit = $null
    $visit = {
        param($id)
        if ($done.Contains($id) -or -not $visiting.Add($id)) { return }
        foreach ($req in $byId[$id].Requires) { if ($byId.Contains($req)) { & $visit $req } }
        [void]$done.Add($id); [void]$ordered.Add($id)
    }
    foreach ($id in @($byId.Keys)) { & $visit $id }

    $allIds = New-ZmSet
    foreach ($r in $Rows) { if ($r.ModId) { [void]$allIds.Add($r.ModId) } }
    foreach ($id in $ordered) {
        $r = $byId[$id]
        foreach ($req in $r.Requires) {
            if ($byId.Contains($req)) { continue }
            if ($allIds.Contains($req)) {
                $where = ($Rows | Where-Object { $_.ModId -eq $req } | Select-Object -First 1).WorkshopId
                [void]$warnings.Add("NEEDS: '$($r.Name)' needs '$req', which is downloaded but not ticked (Workshop item $where).")
            } else {
                [void]$warnings.Add("NEEDS: '$($r.Name)' needs '$req', which isn't downloaded. Check 'Required items' on its Workshop page.")
            }
        }
        if ($r.Layout -eq 'root' -and $Build -ge 42) {
            [void]$warnings.Add("'$($r.Name)' has no Build 42 folder, so it looks like a Build 41 mod and may not load.")
        }
        if ($r.Section -eq 'Orphan') {
            [void]$warnings.Add("'$id' is switched on but isn't in any Workshop download here. Kept as is. Untick it if you removed that mod.")
        }
    }

    $modEntries = foreach ($id in $ordered) {
        $ws = $byId[$id].WorkshopId
        switch ($ModStyle) {
            'Backslash'      { "\$id" }
            'WorkshopPrefix' { "$ws\$id" }
            default          { $id }
        }
    }

    # Map: keep the existing order, drop maps of unticked mods, add newly ticked map mods, vanilla map last.
    $modMaps = New-ZmSet
    foreach ($r in $Rows) { foreach ($m in $r.Maps) { [void]$modMaps.Add($m) } }
    $wanted = New-ZmSet
    foreach ($id in $ordered) { foreach ($m in $byId[$id].Maps) { [void]$wanted.Add($m) } }
    $maps = New-Object System.Collections.ArrayList
    $mapSeen = New-ZmSet
    foreach ($m in $Ini.Maps) {
        if ($m -eq $script:DefaultMap) { continue }
        if (-not $modMaps.Contains($m) -or $wanted.Contains($m)) { Add-ZmUnique $maps $mapSeen $m }
    }
    foreach ($id in $ordered) { foreach ($m in $byId[$id].Maps) { Add-ZmUnique $maps $mapSeen $m } }
    [void]$maps.Add($script:DefaultMap)

    [pscustomobject]@{
        WorkshopItems     = @($workshop)
        Mods              = @($ordered)
        Maps              = @($maps)
        WorkshopItemsLine = ($workshop -join ';')
        ModsLine          = (@($modEntries) -join ';')
        MapLine           = ($maps -join ';')
        Warnings          = @($warnings)
    }
}

#endregion

Export-ModuleMember -Function Get-ZmServerIni, Read-ZmIni, Save-ZmIni, Get-ZmSteamLibrary, Get-ZmWorkshopRoot,
    Read-ZmModFolder, Read-ZmWorkshopItem, Get-ZmInstalledItem, Get-ZmChecklist, Get-ZmPlan, Get-ZmWorkshopIdFromText
