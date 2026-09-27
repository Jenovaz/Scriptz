<#
Debloat tweaks, ported from FR33THY Ultimate and ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'debloat.windows-ai'; Name = 'Turn off Recall and Windows AI features'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Blocks Recall (regular screenshots of what you do), Click to Do, AI in Paint and Notepad, and the Copilot key.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'; Name = 'DisableAIDataAnalysis'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'; Name = 'AllowRecallEnablement'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'; Name = 'DisableClickToDo'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\Shell\Copilot\BingChat'; Name = 'IsUserEligible'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint'; Name = 'DisableGenerativeFill'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint'; Name = 'DisableCocreator'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint'; Name = 'DisableImageCreator'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\WindowsNotepad'; Name = 'DisableAIFeatures'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarCompanion'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CopilotKey'; Name = 'SetCopilotHardwareKey'; Kind = 'String'; Value = '' }
        )
    }
    @{
        Id = 'debloat.suggested-actions'; Name = 'Turn off suggested actions'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops pop-ups offering to call or add to calendar when you copy a phone number or date.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard'; Name = 'Disabled'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'debloat.widgets-extra'; Name = 'Turn off Widgets on the lock screen'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Removes weather and news widgets from the lock screen. Pairs with "Turn off Widgets".'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh'; Name = 'DisableWidgetsOnLockScreen'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh'; Name = 'DisableWidgetsBoard'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen'; Name = 'AutoSelectWidgetsOnLockScreen'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen'; Name = 'LockScreenWidgetsEnabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests'; Name = 'value'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'debloat.maps-updates'; Name = 'Stop offline maps auto-updating'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Windows downloading map updates in the background.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\Maps'; Name = 'AutoUpdateEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'debloat.finish-setup'; Name = 'Stop "Finish setting up your device" nags'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops the full-screen reminders to set up OneDrive, Microsoft 365 and Phone Link.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement'; Name = 'ScoobeSystemSettingEnabled'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'debloat.publish-to-web'; Name = 'Remove "Publish to web" from Explorer'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Removes the old online publishing wizard.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoPublishingWizard'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'debloat.settings-home'; Name = 'Hide the Home page in Settings'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Settings opens on System instead of a page advertising Microsoft 365 and Game Pass.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'SettingsPageVisibility'; Kind = 'String'; Value = 'hide:home;'; Default = 'Delete' }
        )
    }
    @{
        Id = 'debloat.drag-tray'; Name = 'Turn off the share drag tray'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops the share bar sliding down from the top of the screen when you drag a file.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP'; Name = 'DragTrayEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\14\3895955085'; Name = 'EnabledState'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'debloat.share-suggestions'; Name = 'No suggested apps in the Share menu'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops the Share window advertising apps you do not have.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP'; Name = 'EnablePromotionalAppsForShare'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'debloat.phone-companion'; Name = 'Remove Phone Link from the Start menu'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removes the phone panel beside the Start menu.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start'; Name = 'RightCompanionToggledOpen'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start\Companions\Microsoft.YourPhone_8wekyb3d8bbwe'; Name = 'IsEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start\Companions\Microsoft.YourPhone_8wekyb3d8bbwe'; Name = 'IsAvailable'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'debloat.archive-apps'; Name = 'Do not auto-archive unused apps'; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'FR33THY Ultimate'
        Description = 'Stops Windows removing apps you have not opened for a while.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx'; Name = 'AllowAutomaticAppArchiving'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'debloat.store-autoupdate'; Name = 'Stop Store apps updating automatically'; Category = 'Debloat'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'You update Store apps yourself. They will miss security fixes until you do.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'; Name = 'AutoDownload'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate'; Name = 'AutoDownload'; Kind = 'DWord'; Value = 2 }
        )
    }
)
