<#
File Explorer tweaks, ported from FR33THY Ultimate and ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'explorer.gallery'; Name = 'Remove Gallery from Explorer'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Removes the Gallery shortcut from the navigation pane.'
        Actions = @(
            @{ Type = 'RegistryKey'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}'; Ensure = 'Absent' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}'; Name = 'System.IsPinnedToNameSpaceTree'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'explorer.home'; Name = 'Remove Home from Explorer'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removes the Home shortcut from the navigation pane.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'; Name = ''; Kind = 'String'; Value = 'CLSID_MSGraphHomeFolder' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'; Name = 'System.IsPinnedToNameSpaceTree'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'; Name = ''; Kind = 'String'; Value = 'CLSID_MSGraphHomeFolder' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu'; Name = '{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name = '{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu'; Name = '{679f85cb-0220-4080-b29b-5540cc05aab6}'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name = '{679f85cb-0220-4080-b29b-5540cc05aab6}'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'explorer.this-pc'; Name = 'Open Explorer to This PC'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'File Explorer opens on your drives instead of Home.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'HubMode'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'LaunchTo'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'explorer.frequent-folders'; Name = 'Hide frequent folders in Quick Access'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Quick Access only shows folders you pinned.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'ShowFrequent'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'explorer.hidden-files'; Name = 'Show hidden files'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Shows hidden files and folders in Explorer.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Hidden'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'explorer.folder-type'; Name = 'Stop Explorer guessing folder types'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Stops Explorer scanning folders to pick a layout, the usual cause of a slow Downloads folder.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell'; Name = 'FolderType'; Kind = 'String'; Value = 'NotSpecified' }
        )
    }
    @{
        Id = 'explorer.new-tab'; Name = 'Open folders in a new window, not a tab'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Double-clicking a folder in a new window opens it there instead of in a tab.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'OpenFolderInNewTab'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'explorer.removable-drives'; Name = 'Do not list USB drives twice'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removable drives appear once under This PC instead of also at the bottom of the navigation pane.'
        Actions = @(
            @{ Type = 'RegistryKey'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}'; Ensure = 'Absent' }
        )
    }
    @{
        Id = 'explorer.sync-ads'; Name = 'No OneDrive ads in Explorer'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Stops Explorer showing "sync provider" promotions.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ShowSyncProviderNotifications'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'explorer.sharing-wizard'; Name = 'Turn off the Sharing Wizard'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Shows the full sharing and permissions options instead of the simplified wizard.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'SharingWizardOn'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'explorer.office-files'; Name = 'No Office.com files in Quick Access'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'FR33THY Ultimate'
        Description = 'Quick Access stops listing files from your Microsoft 365 account.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'ShowCloudFilesInQuickAccess'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'explorer.full-path'; Name = 'Show the full path in the title bar'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'FR33THY Ultimate'
        Description = 'Explorer windows show the full folder path.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState'; Name = 'FullPath'; Kind = 'DWord'; Value = 1; Default = 0 }
        )
    }
    @{
        Id = 'explorer.network'; Name = 'Hide Network from Explorer'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'FR33THY Ultimate'
        Description = 'Removes Network from the navigation pane. Mapped drives still show under This PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}'; Name = 'System.IsPinnedToNameSpaceTree'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'explorer.3d-objects'; Name = 'Remove 3D Objects (Windows 10)'; Category = 'File Explorer'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'FR33THY Ultimate'
        Description = 'Removes the 3D Objects folder from This PC.'
        Actions = @(
            @{ Type = 'RegistryKey'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}'; Ensure = 'Absent' }
            @{ Type = 'RegistryKey'; Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}'; Ensure = 'Absent' }
        )
    }
)
