<#
One-shot tools: buttons on the Tools tab that do a job once (clean, repair), rather than toggles.
Each Run script's output lines are written to the log.

Fields: Id, Name, Description, Duration (rough guide shown on the button), Run.
Confirm (optional): a warning shown in a Yes/No box before the tool runs.
File cleanup lives in Cleanup.ps1 (the Cleanup tab), not here.
#>

@(
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
    @{
        Id = 'tool.chkdsk'; Name = 'Check the system drive for errors'; Duration = 'A few minutes'
        Description = 'Scans the Windows drive for file system errors while you keep working (chkdsk /scan). Tells you if a repair at restart is needed.'
        Run = { & chkdsk.exe $env:SystemDrive /scan }
    }
    @{
        Id = 'tool.icon-cache'; Name = 'Rebuild the icon cache'; Duration = 'Seconds'
        Description = 'Fixes blank or wrong icons on the desktop, taskbar and in Explorer.'
        Run = {
            & ie4uinit.exe -show
            'Icon cache refreshed. If icons still look wrong, sign out and back in.'
        }
    }
    @{
        Id = 'tool.store-reset'; Name = 'Reset the Microsoft Store cache'; Duration = 'Under a minute'
        Description = 'Fixes Store downloads that are stuck or will not start. The Store opens by itself when finished.'
        Run = {
            Start-Process -FilePath "$env:SystemRoot\System32\wsreset.exe"
            'Store cache reset started. Wait for the Store to open.'
        }
    }
    @{
        Id = 'tool.network-reset'; Name = 'Reset the network stack'; Duration = 'Seconds, then restart'
        Description = 'Fixes "connected but no internet" and broken DNS by resetting Winsock and TCP/IP. Needs a restart.'
        Confirm = "This resets Winsock and TCP/IP settings.`n`nAny static IP address you typed in by hand is removed, and some VPN software may need reinstalling. A restart is needed afterwards.`n`nContinue?"
        Run = {
            & netsh.exe winsock reset
            & netsh.exe int ip reset
            & ipconfig.exe /flushdns
            'Done. Restart the PC to finish the reset.'
        }
    }
    @{
        Id = 'tool.update-reset'; Name = 'Reset Windows Update'; Duration = 'Under a minute'
        Description = 'Fixes updates that fail or stay stuck by clearing Windows Update''s working folders. Update history in Settings will look empty afterwards; installed updates are not affected.'
        Confirm = "This stops Windows Update, renames its working folders (SoftwareDistribution and catroot2) to .old, and starts it again.`n`nDo not use it while an update is installing. Continue?"
        Run = {
            $services = 'wuauserv', 'bits', 'cryptsvc', 'msiserver'
            Stop-Service -Name $services -Force -ErrorAction SilentlyContinue
            foreach ($dir in "$env:SystemRoot\SoftwareDistribution", "$env:SystemRoot\System32\catroot2") {
                $old = "$dir.old"
                if (Test-Path -LiteralPath $old) { Remove-Item -LiteralPath $old -Recurse -Force -ErrorAction SilentlyContinue }
                if (Test-Path -LiteralPath $dir) {
                    try { Rename-Item -LiteralPath $dir -NewName (Split-Path $old -Leaf) -ErrorAction Stop; "Renamed $dir" }
                    catch { "Could not rename $dir (in use): $($_.Exception.Message)" }
                }
            }
            Start-Service -Name $services -ErrorAction SilentlyContinue
            'Windows Update reset. Check for updates again in Settings.'
        }
    }
)
