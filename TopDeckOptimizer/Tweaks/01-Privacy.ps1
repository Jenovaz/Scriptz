<#
Privacy tweaks. Each entry is one toggle in the window.

Fields:
  Id           unique, never change once released (profiles and backups refer to it)
  Name         what the toggle says
  Category     which tab it lives on
  Risk         Safe | Moderate | Advanced
  Recommended  $true = switched on by the "Recommended" button
  Reboot       $true = needs a restart or sign-out to take effect
  Source       where the idea came from
  Description  one or two plain-English lines shown under the toggle
  Actions      what it changes (see Core\Engine.psm1 for the action types)

Registry "Default" is what Windows ships with. It is only used if there is no saved backup;
'Delete' means the value normally doesn't exist.
#>

$cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'

@(
    @{
        Id = 'privacy.telemetry'; Name = 'Reduce Windows telemetry'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Source = 'TopDeck'
        Description = 'Sets diagnostic data to the minimum and stops the Connected User Experiences (DiagTrack) service that uploads it.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'AllowTelemetry'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Service'; Name = 'DiagTrack'; Startup = 'Disabled'; Default = 'Automatic' }
            @{ Type = 'Service'; Name = 'dmwappushservice'; Startup = 'Disabled'; Default = 'Manual' }
            @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Customer Experience Improvement Program\'; Name = 'Consolidator' }
            @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Customer Experience Improvement Program\'; Name = 'UsbCeip' }
        )
    }
    @{
        Id = 'privacy.advertising-id'; Name = 'Turn off advertising ID'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Source = 'TopDeck'
        Description = 'Stops apps using a per-user ID to show you targeted ads.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; Name = 'Enabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'; Name = 'DisabledByGroupPolicy'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'privacy.activity-history'; Name = 'Turn off activity history'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Source = 'TopDeck'
        Description = 'Stops Windows recording which apps and files you open and syncing that to Microsoft.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'EnableActivityFeed'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'PublishUserActivities'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'UploadUserActivities'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'privacy.suggestions'; Name = 'Turn off tips, suggestions and sponsored apps'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Source = 'TopDeck'
        Description = 'Stops Start menu ads, "suggested" apps installing themselves, and tips popping up in Settings.'
        Actions = @(
            @{ Type = 'Registry'; Path = $cdm; Name = 'SilentInstalledAppsEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = $cdm; Name = 'SystemPaneSuggestionsEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = $cdm; Name = 'SoftLandingEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = $cdm; Name = 'SubscribedContent-338388Enabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = $cdm; Name = 'SubscribedContent-338389Enabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = $cdm; Name = 'SubscribedContent-353694Enabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = $cdm; Name = 'SubscribedContent-353696Enabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsConsumerFeatures'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableTailoredExperiencesWithDiagnosticData'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'privacy.bing-search'; Name = 'Remove Bing web results from Start search'; Category = 'Privacy'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Source = 'TopDeck'
        Description = 'Start menu search only looks at your PC, not the web. Faster, and your typing is not sent to Bing.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'; Name = 'DisableSearchBoxSuggestions'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'; Name = 'BingSearchEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
)
