<#
System tweaks, ported from FR33THY Ultimate and ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'system.storage-sense'; Name = 'Turn off Storage Sense'; Category = 'System'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Stops Windows automatically deleting temp files, Downloads and Recycle Bin contents. You clean up yourself (see Tools).'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense'; Name = 'AllowStorageSenseGlobal'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'; Name = '04'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'; Name = '2048'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'; Name = '08'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'; Name = '256'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'; Name = '32'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'; Name = 'StoragePoliciesChanged'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'system.upgrade-bypass'; Name = 'Skip Windows 11 hardware checks'; Category = 'System'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Lets Windows 11 install or upgrade without TPM 2.0, Secure Boot or a supported CPU, and hides the "requirements not met" watermark.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\UnsupportedHardwareNotificationCache'; Name = 'SV2'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\Setup\LabConfig'; Name = 'BypassCPUCheck'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\Setup\LabConfig'; Name = 'BypassRAMCheck'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\Setup\LabConfig'; Name = 'BypassSecureBootCheck'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\Setup\LabConfig'; Name = 'BypassStorageCheck'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\Setup\LabConfig'; Name = 'BypassTPMCheck'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\Setup\MoSetup'; Name = 'AllowUpgradesWithUnsupportedTPMOrCPU'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'system.remote-assistance'; Name = 'Turn off Remote Assistance'; Category = 'System'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Nobody can be invited to control this PC through Remote Assistance, a common tech-support scam route.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance'; Name = 'fAllowToGetHelp'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'system.notifications'; Name = 'Turn off most notifications'; Category = 'System'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Turns off app and system toast notifications. You will miss messages until you open the app.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications'; Name = 'ToastEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel'; Name = 'Enabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.CapabilityAccess'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.StartupApp'; Name = 'Enabled'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.SkyDrive.Desktop'; Name = 'Enabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications'; Name = 'EnableAccountNotifications'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.ScreenSketch_8wekyb3d8bbwe!App'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.InputSwitchToastHandler'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AutoPlay'; Name = 'Enabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AccountHealth'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\MicrosoftWindows.Client.CBS_cw5n1h2txyewy!WindowsBackup'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'; Name = 'NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'; Name = 'NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'; Name = 'NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackupReminder'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested'; Name = 'Enabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.LowDisk'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'system.driver-search'; Name = 'Do not get drivers from Windows Update'; Category = 'System'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Windows Update stops replacing your drivers (useful if it keeps overwriting your GPU driver). You install driver updates yourself.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching'; Name = 'SearchOrderConfig'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'system.auto-maintenance'; Name = 'Turn off automatic maintenance'; Category = 'System'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops the nightly maintenance run. That run also does SSD TRIM and security scans; run "Optimise drives" in Tools yourself.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance'; Name = 'MaintenanceDisabled'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'system.autoplay'; Name = 'Turn off AutoPlay'; Category = 'System'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Plugging in a USB stick or disc no longer opens anything automatically.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers'; Name = 'DisableAutoplay'; Kind = 'DWord'; Value = 1; Default = 0 }
        )
    }
    @{
        Id = 'system.co-installers'; Name = 'Block device co-installers'; Category = 'System'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops plugging in a mouse, keyboard or headset automatically installing the maker''s software.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer'; Name = 'DisableCoInstallers'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'system.bsod-details'; Name = 'Show details on blue screens'; Category = 'System'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Blue screens show the technical error details.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\System\CurrentControlSet\Control\CrashControl'; Name = 'DisplayParameters'; Kind = 'DWord'; Value = 1; Default = 0 }
        )
    }
    @{
        Id = 'system.long-paths'; Name = 'Allow long file paths'; Category = 'System'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Removes the 260-character path limit for apps that support it.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'; Name = 'LongPathsEnabled'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'system.low-disk-warning'; Name = 'Turn off low disk space warnings'; Category = 'System'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops the "You are running out of disk space" pop-up.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoLowDiskSpaceChecks'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'system.wpbt'; Name = 'Block firmware-installed programs (WPBT)'; Category = 'System'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops your motherboard firmware silently installing vendor software such as Armoury Crate into Windows.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\ControlSet001\Control\Session Manager'; Name = 'DisableWpbtExecution'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'system.auto-troubleshoot'; Name = 'Turn off automatic troubleshooting'; Category = 'System'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Windows stops running recommended troubleshooters on its own.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\WindowsMitigation'; Name = 'UserPreference'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'system.delivery-optimization'; Name = 'Do not share updates with other PCs'; Category = 'System'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops your PC uploading Windows updates to other people over the internet.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKU:\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings'; Name = 'DownloadMode'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'; Name = 'DODownloadMode'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'system.device-metadata'; Name = 'Do not auto-download device apps and icons'; Category = 'System'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Windows fetching manufacturer apps and pictures when you plug in a device.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata'; Name = 'PreventDeviceMetadataFromNetwork'; Kind = 'DWord'; Value = 1; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata'; Name = 'PreventDeviceMetadataFromNetwork'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'system.password-sign-in'; Name = 'Allow password sign-in'; Category = 'System'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'FR33THY Ultimate'
        Description = 'Shows the password option on the sign-in screen even when Windows Hello is set up. Fixes being stuck at a PIN or face prompt.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device'; Name = 'DevicePasswordLessBuildVersion'; Kind = 'DWord'; Value = 0; Default = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device'; Name = 'DevicePasswordLessUpdateType'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'system.classic-console'; Name = 'Use the classic console, not Terminal'; Category = 'System'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'FR33THY Ultimate'
        Description = 'Command Prompt and PowerShell open in the classic console window instead of Windows Terminal.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Console\%%Startup'; Name = 'DelegationConsole'; Kind = 'String'; Value = '{B23D10C0-E52E-411E-9D5B-C09FDF709C7D}'; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Console\%%Startup'; Name = 'DelegationTerminal'; Kind = 'String'; Value = '{B23D10C0-E52E-411E-9D5B-C09FDF709C7D}'; Default = 'Delete' }
        )
    }
)
