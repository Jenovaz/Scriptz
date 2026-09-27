<#
File Explorer tweaks. Field meanings are listed at the top of 01-Privacy.ps1.
#>

$classicMenuKey = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'

@(
    @{
        Id = 'ui.file-extensions'; Name = 'Show file extensions'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'TopDeck'
        Description = 'Shows ".exe", ".pdf" etc. on file names. Makes it much harder to be tricked by a fake "invoice.pdf.exe".'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'HideFileExt'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'ui.classic-context-menu'; Name = 'Classic right-click menu (Windows 11)'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'TopDeck'
        Description = 'Brings back the full Windows 10 right-click menu, so you do not have to click "Show more options" every time.'
        Actions = @(
            @{
                Type = 'Command'
                Describe = 'Add the registry key that disables the Windows 11 compact menu'
                Test = { Test-Path "$classicMenuKey\InprocServer32" }.GetNewClosure()
                Apply = {
                    New-Item -Path "$classicMenuKey\InprocServer32" -Force | Out-Null
                    Set-Item -Path "$classicMenuKey\InprocServer32" -Value ''
                }.GetNewClosure()
                Revert = { param($Backup) Remove-Item -Path $classicMenuKey -Recurse -Force -ErrorAction SilentlyContinue }.GetNewClosure()
            }
        )
    }
)
