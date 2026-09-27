<#
One-shot tools: buttons on the Tools tab that do a job once (clean, repair), rather than toggles.
Each Run script's output lines are written to the log.

Fields: Id, Name, Description, Duration (rough guide shown on the button), Run.
#>

@(
    @{
        Id = 'tool.clean-temp'; Name = 'Clean temporary files'; Duration = 'Under a minute'
        Description = 'Deletes leftover temp files from your user folder and Windows. Files still in use are skipped.'
        Run = {
            # Prefetch is deliberately left alone: Windows rebuilds it and apps launch slower meanwhile.
            $folders = @($env:TEMP, "$env:SystemRoot\Temp") | Select-Object -Unique
            $freed = 0
            foreach ($folder in $folders) {
                if (-not (Test-Path $folder)) { continue }
                foreach ($item in Get-ChildItem -Path $folder -Recurse -Force -File -ErrorAction SilentlyContinue) {
                    try {
                        $size = $item.Length
                        Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop
                        $freed += $size
                    } catch { }   # file in use: skip it
                }
                # Remove folders left empty, deepest first. Only empty ones: Remove-Item on a folder that
                # still has files would stop and ask "are you sure?", which hangs a background job.
                Get-ChildItem -Path $folder -Recurse -Force -Directory -ErrorAction SilentlyContinue |
                    Sort-Object { $_.FullName.Length } -Descending |
                    Where-Object { -not (Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue) } |
                    ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue }
                "Cleaned $folder"
            }
            'Freed {0:N0} MB' -f ($freed / 1MB)
        }
    }
    @{
        Id = 'tool.recycle-bin'; Name = 'Empty the Recycle Bin'; Duration = 'Seconds'
        Description = 'Permanently deletes everything in the Recycle Bin on all drives.'
        Run = {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            'Recycle Bin emptied'
        }
    }
    @{
        Id = 'tool.flush-dns'; Name = 'Flush DNS cache'; Duration = 'Seconds'
        Description = 'Clears saved website addresses. Fixes "site not found" after a site moves or your network changes.'
        Run = {
            Clear-DnsClientCache
            'DNS cache cleared'
        }
    }
    @{
        Id = 'tool.optimize-drives'; Name = 'Optimise drives (TRIM / defrag)'; Duration = 'A few minutes'
        Description = 'Runs TRIM on SSDs and defrag on hard drives. Windows picks the right one for each drive.'
        Run = {
            foreach ($vol in Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' -and $_.FileSystem -eq 'NTFS' }) {
                "Optimising drive $($vol.DriveLetter):"
                Optimize-Volume -DriveLetter $vol.DriveLetter -ErrorAction Continue
                "Drive $($vol.DriveLetter): done"
            }
        }
    }
    @{
        Id = 'tool.dism-repair'; Name = 'Repair Windows image (DISM)'; Duration = '10-20 minutes'
        Description = 'Checks the Windows component store for corruption and downloads fresh copies of damaged files. Run this before the file check below.'
        Run = { & dism.exe /Online /Cleanup-Image /RestoreHealth }
    }
    @{
        Id = 'tool.sfc'; Name = 'Check system files (SFC)'; Duration = '5-15 minutes'
        Description = 'Scans protected Windows files and replaces any that are damaged or missing.'
        Run = { & sfc.exe /scannow }
    }
    @{
        Id = 'tool.component-cleanup'; Name = 'Clean up old Windows updates'; Duration = '5-15 minutes'
        Description = 'Removes superseded update files from the component store (WinSxS). Frees space; installed updates can still be uninstalled.'
        Run = { & dism.exe /Online /Cleanup-Image /StartComponentCleanup }
    }
)
