<#
App Permissions tweaks, ported from FR33THY Ultimate and ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'perm.account-info'; Name = 'Block apps from your account info (name, picture)'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access your account info (name, picture). Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.contacts'; Name = 'Block apps from your contacts'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access your contacts. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.calendar'; Name = 'Block apps from your calendar'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access your calendar. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.phone-calls'; Name = 'Block apps from phone calls'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access phone calls. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.call-history'; Name = 'Block apps from your call history'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access your call history. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.email'; Name = 'Block apps from your email'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access your email. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.tasks'; Name = 'Block apps from your tasks'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access your tasks. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.messaging'; Name = 'Block apps from text messages'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access text messages. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.app-diagnostics'; Name = 'Block apps from diagnostic info about other apps'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access diagnostic info about other apps. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.foreground-text'; Name = 'Block apps from text on your screen'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access text on your screen. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\foregroundTextAccess'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
        )
    }
    @{
        Id = 'perm.human-presence'; Name = 'Block apps from presence sensors'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access presence sensors. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'; Name = 'LetAppsAccessHumanPresence'; Kind = 'DWord'; Value = 2 }
        )
    }
    @{
        Id = 'perm.spatial'; Name = 'Block apps from spatial perception in the background'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access spatial perception in the background. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'; Name = 'LetAppsAccessBackgroundSpatialPerception'; Kind = 'DWord'; Value = 2 }
        )
    }
    @{
        Id = 'perm.eye-tracker'; Name = 'Block apps from eye trackers'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access eye trackers. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'; Name = 'LetAppsAccessGazeInput'; Kind = 'DWord'; Value = 2 }
        )
    }
    @{
        Id = 'perm.diagnostic-info'; Name = 'Block apps from diagnostic info (policy)'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access diagnostic info (policy). Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'; Name = 'LetAppsGetDiagnosticInfo'; Kind = 'DWord'; Value = 2 }
        )
    }
    @{
        Id = 'perm.motion'; Name = 'Block apps from motion sensors'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer access motion sensors. Rarely needed on a desktop PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'; Name = 'LetAppsAccessMotion'; Kind = 'DWord'; Value = 2 }
        )
    }
    @{
        Id = 'perm.ai-models'; Name = 'Block apps from Windows AI models'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Store apps can no longer use the built-in text and image generation models.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'; Name = 'LetAppsAccessSystemAIModels'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\systemAIModels'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.location'; Name = 'Block apps from your location'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Weather, Maps and "find my device" will not know where you are.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CPSS\Store\UserLocationOverridePrivacySetting'; Name = 'Value'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'perm.passkeys'; Name = 'Block apps from passkeys'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Apps (not browsers) will not be able to use your saved passkeys.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\passkeys'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\passkeysEnumeration'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.camera'; Name = 'Block apps from the camera'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps like Camera and Teams will not see your webcam. Desktop apps like Discord and Zoom are not affected.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.voice'; Name = 'Block apps from voice activation'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Assistants can no longer listen for a wake word.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps'; Name = 'AgentActivationEnabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps'; Name = 'AgentActivationLastUsed'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'perm.notifications'; Name = 'Block apps from your notifications'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Apps can no longer read your notifications (used by smartwatch and phone-link apps).'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.radios'; Name = 'Block apps from radios (Wi-Fi, Bluetooth)'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer switch Bluetooth or Wi-Fi on and off.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.bluetooth-sync'; Name = 'Block apps from other devices'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps can no longer sync with Bluetooth and other paired devices.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
        )
    }
    @{
        Id = 'perm.documents'; Name = 'Block apps from your Documents folder'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps lose access to Documents.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.downloads'; Name = 'Block apps from your Downloads folder'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps lose access to Downloads.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
        )
    }
    @{
        Id = 'perm.music'; Name = 'Block apps from your Music folder'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps (e.g. Media Player) lose access to Music.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.pictures'; Name = 'Block apps from your Pictures folder'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps (e.g. Photos) lose access to Pictures.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Deny' }
        )
    }
    @{
        Id = 'perm.videos'; Name = 'Block apps from your Videos folder'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps lose access to Videos.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.file-system'; Name = 'Block apps from your whole file system'; Category = 'App Permissions'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Store apps lose broad file access.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess'; Name = 'Value'; Kind = 'String'; Value = 'Deny'; Default = 'Allow' }
        )
    }
    @{
        Id = 'perm.location-prompt'; Name = 'Stop location permission pop-ups'; Category = 'App Permissions'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops the "Let apps access your location?" prompt appearing.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'; Name = 'ShowGlobalPrompts'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
)
