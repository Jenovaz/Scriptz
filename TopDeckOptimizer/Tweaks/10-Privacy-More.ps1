<#
Privacy tweaks, ported from FR33THY Ultimate and ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'priv.typing-insights'; Name = 'Turn off typing insights'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Windows collecting what you type to "improve" suggestions.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\input\Settings'; Name = 'InsightsEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'priv.cross-device'; Name = 'Turn off cross-device sharing'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Nearby Sharing and "continue on another device" linking this PC to your phone and other PCs.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP'; Name = 'RomeSdkChannelUserAuthzPolicy'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP'; Name = 'NearShareChannelUserAuthzPolicy'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP'; Name = 'CdpSessionUserAuthzPolicy'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CrossDeviceResume\Configuration'; Name = 'IsResumeAllowed'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CrossDeviceResume\Configuration'; Name = 'IsOneDriveResumeAllowed'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Connectivity\DisableCrossDeviceResume'; Name = 'value'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\1387020943'; Name = 'EnabledState'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\1694661260'; Name = 'EnabledState'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'priv.search-history'; Name = 'Turn off search history'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Start menu search stops remembering what you searched for on this PC.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings'; Name = 'IsDeviceSearchHistoryEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'priv.language-list'; Name = 'Hide your language list from websites'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Websites can no longer read your installed languages to fingerprint you.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\International\User Profile'; Name = 'HttpAcceptLanguageOptOut'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'priv.app-launch-tracking'; Name = 'Turn off app launch tracking'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Windows stops recording which apps you open to rank Start and search results.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Policies\Microsoft\Windows\EdgeUI'; Name = 'DisableMFUTracking'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI'; Name = 'DisableMFUTracking'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'priv.inking-typing'; Name = 'Turn off inking and typing personalisation'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Windows building a personal dictionary from your handwriting and typing.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\InputPersonalization'; Name = 'RestrictImplicitInkCollection'; Kind = 'DWord'; Value = 1; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\InputPersonalization'; Name = 'RestrictImplicitTextCollection'; Kind = 'DWord'; Value = 1; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore'; Name = 'HarvestContacts'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Personalization\Settings'; Name = 'AcceptedPrivacyPolicy'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'priv.feedback'; Name = 'Never ask for feedback'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Windows popping up "How likely are you to recommend Windows?" surveys.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'; Name = 'NumberOfSIUFInPeriod'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'; Name = 'PeriodInNanoSeconds'; Ensure = 'Absent' }
        )
    }
    @{
        Id = 'priv.cloud-search'; Name = 'Search only this PC, not OneDrive or Outlook'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Start menu search stops including results from your Microsoft or work account in the cloud.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings'; Name = 'IsAADCloudSearchEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings'; Name = 'IsMSACloudSearchEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'priv.sign-in-after-restart'; Name = 'Do not auto sign-in after updates'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Windows stops using your saved sign-in to log you in automatically after an update restart.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'DisableAutomaticRestartSignOn'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'priv.web-search-policy'; Name = 'Block web search in Windows search (policy)'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'A second, policy-based block on web results in Start search. Works alongside "Remove Bing web results".'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search'; Name = 'ConnectedSearchUseWeb'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search'; Name = 'DisableWebSearch'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'priv.explorer-web-services'; Name = 'No web services in Explorer'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops File Explorer contacting Microsoft to look up file types and online help.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoWebServices'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'priv.document-history'; Name = 'Do not track recent documents anywhere'; Category = 'Privacy'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Clears and stops the recent documents list system-wide. Jump lists and "Recent" in apps will be empty.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoRecentDocsHistory'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'ClearRecentDocsOnExit'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start'; Name = 'ShowRecentList'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoInstrumentation'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoStartMenuMFUprogramsList'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'; Name = 'HideRecommendedPersonalizedSites'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'priv.find-my-device'; Name = 'Turn off Find My Device'; Category = 'Privacy'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops the PC reporting its location to your Microsoft account. Leave on for laptops you might lose.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\MdmCommon\SettingValues'; Name = 'LocationSyncEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'priv.personalized-offers'; Name = 'Turn off personalised offers'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Microsoft using your diagnostic data to target tips, ads and recommendations.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy'; Name = 'TailoredExperiencesWithDiagnosticDataEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store\TailoredExperiencesWithDiagnosticDataEnabled'; Name = 'Value'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'priv.diagnostic-data'; Name = 'Diagnostic data: required only'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Limits diagnostic data to the minimum Windows allows on Home and Pro.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name = 'AllowTelemetry'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name = 'MaxTelemetryAllowed'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store\AllowTelemetry'; Name = 'Value'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'priv.backup-sync'; Name = 'Turn off Windows settings sync'; Category = 'Privacy'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops syncing your settings, passwords and theme to your Microsoft account. You will set up each PC separately.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableAccessibilitySettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableAccessibilitySettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableAppSyncSettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableAppSyncSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableApplicationSettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableApplicationSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableCredentialsSettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableCredentialsSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableDesktopThemeSettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableDesktopThemeSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableLanguageSettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableLanguageSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisablePersonalizationSettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisablePersonalizationSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableSettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableStartLayoutSettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableStartLayoutSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableSyncOnPaidNetwork'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableWebBrowserSettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableWebBrowserSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableWindowsSettingSync'; Kind = 'DWord'; Value = 2 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableWindowsSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'EnableWindowsBackup'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'priv.error-reporting'; Name = 'Turn off Windows Error Reporting'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'FR33THY Ultimate'
        Description = 'Crash reports are no longer sent to Microsoft.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name = 'Disabled'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'priv.more-suggestions'; Name = 'Turn off all built-in ads and suggestions (full list)'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Covers every known "suggested content" switch: lock screen tips, pre-installed promo apps, Settings ads and more.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-310093Enabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338393Enabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-353698Enabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338387Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-314563Enabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-314559Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-202914Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280810Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280811Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280815Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-310091Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000045Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000161Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000163Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000165Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000325Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000326Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338380Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338382Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338381Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338386Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-353697Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-353695Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000106Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000105Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-314566Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-314567Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-310094Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280812Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-310092Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280814Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-202913Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-314562Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-314558Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000531Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000530Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-353699Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000044Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280797Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280817Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000162Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000164Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-88000166Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'OemPreInstalledAppsEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'PreInstalledAppsEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'ContentDeliveryAllowed'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'PreInstalledAppsEverEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContentEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-LocksreenEnabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'RegistryKey'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions'; Ensure = 'Absent' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'FeatureManagementEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'RotatingLockScreenEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'RotatingLockScreenOverlayEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SlideshowEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'priv.device-usage'; Name = 'Clear "how will you use this device" answers'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Removes the gaming/business/family answers from setup that Windows uses to push related apps and ads.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\business'; Name = 'Intent'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\creative'; Name = 'Intent'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\developer'; Name = 'Intent'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\DeviceMetaDataBackup'; Name = 'Intent'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\entertainment'; Name = 'Intent'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\family'; Name = 'Intent'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\gaming'; Name = 'Intent'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\IntroIneligible'; Name = 'Intent'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\IntroPostponed'; Name = 'Intent'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\IntroSkipped'; Name = 'Intent'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\OffDeviceConsent'; Name = 'Intent'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\schoolwork'; Name = 'Intent'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\developer'; Name = 'Priority'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\gaming'; Name = 'Priority'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\family'; Name = 'Priority'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\creative'; Name = 'Priority'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\schoolwork'; Name = 'Priority'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\entertainment'; Name = 'Priority'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\business'; Name = 'Priority'; Kind = 'DWord'; Value = 0; Default = 0 }
        )
    }
)
