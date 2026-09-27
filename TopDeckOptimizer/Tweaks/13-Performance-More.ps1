<#
Performance tweaks, ported from FR33THY Ultimate and ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'perf.visual-effects'; Name = 'Visual effects: best performance (keep smooth fonts)'; Category = 'Performance'
        Risk = 'Safe'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Turns off animations, fades and shadows but keeps smooth fonts, thumbnails and window contents while dragging. Same as "Custom" in Performance Options.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'; Name = 'VisualFXSetting'; Kind = 'DWord'; Value = 3; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop'; Name = 'UserPreferencesMask'; Kind = 'Binary'; Value = @(0x90,0x12,0x02,0x80,0x10,0x01,0x00,0x00); Default = @(0x9E,0x1E,0x07,0x80,0x12,0x00,0x00,0x00) }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop\WindowMetrics'; Name = 'MinAnimate'; Kind = 'String'; Value = '0'; Default = '1' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarAnimations'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\DWM'; Name = 'EnableAeroPeek'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\DWM'; Name = 'AlwaysHibernateThumbnails'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'IconsOnly'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ListviewAlphaSelect'; Kind = 'DWord'; Value = 1; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop'; Name = 'DragFullWindows'; Kind = 'String'; Value = '1'; Default = '1' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop'; Name = 'FontSmoothing'; Kind = 'String'; Value = '2'; Default = '2' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ListviewShadow'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'perf.foreground-priority'; Name = 'Favour the active program'; Category = 'Performance'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Gives the window you are using more CPU time than background tasks (Win32PrioritySeparation 0x26). Effect is small; test in your own games.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl'; Name = 'Win32PrioritySeparation'; Kind = 'DWord'; Value = 38; Default = 2 }
        )
    }
    @{
        Id = 'perf.background-apps'; Name = 'Stop Store apps running in the background'; Category = 'Performance'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Saves some RAM and CPU. Store apps (Phone Link, Teams, Mail) will not notify you while closed.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'; Name = 'LetAppsRunInBackground'; Kind = 'DWord'; Value = 2; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'; Name = 'BackgroundAppGlobalToggle'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'; Name = 'GlobalUserDisabled'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'perf.last-access'; Name = 'Stop updating "last accessed" time on files'; Category = 'Performance'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Saves a disk write every time a file is opened.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'; Name = 'NtfsDisableLastAccessUpdate'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'perf.fault-tolerant-heap'; Name = 'Turn off Fault Tolerant Heap'; Category = 'Performance'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Windows applying slow "compatibility" memory fixes to apps that crashed before. A crashy app may crash more.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\FTH'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'perf.icon-cache'; Name = 'Bigger icon cache'; Category = 'Performance'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Lets Windows keep more icons in memory so folders draw faster.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'MaxCachedIcons'; Kind = 'String'; Value = '4096' }
        )
    }
    @{
        Id = 'perf.sleep-study'; Name = 'Turn off sleep study logging'; Category = 'Performance'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Windows logging detailed sleep diagnostics in the background.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'; Name = 'SleepStudyDisabled'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'perf.explorer-prelaunch'; Name = 'Preload File Explorer'; Category = 'Performance'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Keeps Explorer loaded in memory so it opens instantly. Uses a little RAM.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ShouldPrelaunchFileExplorer'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'perf.input-preload'; Name = 'Do not preload touch keyboard and Widgets'; Category = 'Performance'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'FR33THY Ultimate'
        Description = 'Stops Windows loading the touch keyboard and Widgets at sign-in when you do not use them.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\input'; Name = 'IsInputAppPreloadEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Dsh'; Name = 'IsPrelaunchEnabled'; Kind = 'DWord'; Value = 0 }
        )
    }
)
