<#
Cleanup categories for the Cleanup tab. Each is scanned first (size shown), then cleaned if ticked.

Fields:
  Id, Name, Description
  Selected     $true = ticked by default
  Folders      scriptblock returning folders to empty (wildcards allowed). The folders themselves
               are kept; only what is inside them is deleted. Junctions and symbolic links are
               never followed, so nothing outside these folders can be touched.
  Files        optional scriptblock returning single files to delete (wildcards allowed)
  MinAgeHours  only delete files older than this (protects files an installer is using right now)
  Before/After optional scriptblocks run around the clean. Whatever Before returns is passed to After.
  Measure/Clean optional scriptblocks that replace the folder logic entirely (Recycle Bin).
#>


@(
    @{
        Id = 'clean.user-temp'; Name = 'Your temporary files'; Selected = $true; MinAgeHours = 24
        Description = 'Leftovers from installers and apps in your Temp folder. Files from the last 24 hours are kept in case something is still using them.'
        Folders = { $env:TEMP }
    }
    @{
        Id = 'clean.windows-temp'; Name = 'Windows temporary files'; Selected = $true; MinAgeHours = 24
        Description = 'The same for Windows itself (C:\Windows\Temp).'
        Folders = { "$env:SystemRoot\Temp" }
    }
    @{
        Id = 'clean.update-cache'; Name = 'Windows Update download cache'; Selected = $true
        Description = 'Update files Windows already installed. Windows Update is paused for a moment while cleaning. Do not use while an update is installing.'
        Folders = { "$env:SystemRoot\SoftwareDistribution\Download" }
        Before = {
            $running = @(Get-Service -Name wuauserv, bits -ErrorAction SilentlyContinue | Where-Object Status -eq 'Running' | ForEach-Object Name)
            Stop-Service -Name wuauserv, bits -Force -ErrorAction SilentlyContinue
            $running
        }
        After = { param($running) foreach ($s in @($running)) { Start-Service -Name $s -ErrorAction SilentlyContinue } }
    }
    @{
        Id = 'clean.delivery-optimization'; Name = 'Delivery Optimization cache'; Selected = $true
        Description = 'Update pieces Windows keeps to share with other PCs.'
        Folders = { "$env:SystemRoot\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache" }
        Before = { if (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) { Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue } }
    }
    @{
        Id = 'clean.crash-dumps'; Name = 'Crash dumps and error reports'; Selected = $true
        Description = 'Memory dumps from blue screens and app crashes, and queued error reports. Keep them if you are troubleshooting crashes with someone.'
        Folders = { "$env:SystemRoot\Minidump", "$env:LOCALAPPDATA\CrashDumps", "$env:ProgramData\Microsoft\Windows\WER\ReportArchive", "$env:ProgramData\Microsoft\Windows\WER\ReportQueue", "$env:LOCALAPPDATA\Microsoft\Windows\WER" }
        Files = { "$env:SystemRoot\MEMORY.DMP" }
    }
    @{
        Id = 'clean.thumbnails'; Name = 'Thumbnail cache'; Selected = $false
        Description = 'Saved picture and video previews. Explorer rebuilds them as you browse. Files Explorer has open are skipped.'
        Folders = { }
        Files = { "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" }
    }
    @{
        Id = 'clean.shader-cache'; Name = 'Graphics shader caches'; Selected = $false
        Description = 'DirectX, NVIDIA, AMD and Intel shader caches. Fixes some stutter after driver updates, but the next launch of each game may stutter while they rebuild.'
        Folders = { "$env:LOCALAPPDATA\D3DSCache", "$env:LOCALAPPDATA\NVIDIA\DXCache", "$env:LOCALAPPDATA\NVIDIA\GLCache", "$env:LOCALAPPDATA\AMD\DxCache", "$env:LOCALAPPDATA\AMD\DxcCache", "$env:LOCALAPPDATA\AMD\VkCache", "$env:LOCALAPPDATA\Intel\ShaderCache", "$env:ProgramData\NVIDIA Corporation\NV_Cache" }
    }
    @{
        Id = 'clean.browser-cache'; Name = 'Browser caches (Edge, Chrome, Firefox)'; Selected = $false
        Description = 'Cached web pages and images only. Passwords, cookies, history and logins are not touched. Close your browsers first or open files are skipped.'
        Folders = {
            foreach ($b in "$env:LOCALAPPDATA\Microsoft\Edge\User Data", "$env:LOCALAPPDATA\Google\Chrome\User Data", "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data") {
                foreach ($sub in 'Cache\Cache_Data', 'Code Cache', 'GPUCache') { "$b\*\$sub" }
            }
            "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2"
        }
    }
    @{
        Id = 'clean.recycle-bin'; Name = 'Recycle Bin (all drives)'; Selected = $false
        Description = 'Permanently deletes everything in the Recycle Bin. Check it first if unsure.'
        Measure = {
            $total = [long]0; $count = 0
            foreach ($d in Get-PSDrive -PSProvider FileSystem) {
                foreach ($f in Get-TopDeckSafeFile -Root (Join-Path $d.Root '$Recycle.Bin')) { $total += $f.Length; $count++ }
            }
            @{ Bytes = $total; Files = $count }
        }
        Clean = {
            foreach ($d in Get-PSDrive -PSProvider FileSystem) {
                if (Test-Path -LiteralPath (Join-Path $d.Root '$Recycle.Bin')) { Clear-RecycleBin -DriveLetter $d.Name -Force -ErrorAction SilentlyContinue }
            }
        }
    }
)
