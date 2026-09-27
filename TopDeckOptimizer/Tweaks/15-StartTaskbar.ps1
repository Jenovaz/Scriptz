<#
Start & Taskbar tweaks, ported from FR33THY Ultimate and ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'start.search-highlights'; Name = 'Turn off search highlights'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Removes the doodles, trending searches and weather from the search box.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings'; Name = 'IsDynamicSearchBoxEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'; Name = 'GleamEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'; Name = 'WeatherEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'; Name = 'HolidayEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'start.taskbar-left'; Name = 'Taskbar icons on the left'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Moves Start and taskbar icons to the left, like Windows 10.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarAl'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'start.more-pins'; Name = 'More pins in Start'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Shows more pinned apps and fewer recommendations.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_Layout'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'start.end-task'; Name = 'Add "End task" to taskbar right-click'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Right-click a taskbar app to force-close it without opening Task Manager.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings'; Name = 'TaskbarEndTask'; Kind = 'DWord'; Value = 1; Default = 0 }
        )
    }
    @{
        Id = 'start.chat'; Name = 'Remove Chat from the taskbar'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removes the Teams chat button.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarMn'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'start.task-view'; Name = 'Remove Task View from the taskbar'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removes the Task View button. Win+Tab still works.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ShowTaskViewButton'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'start.search-box'; Name = 'Remove search from the taskbar'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removes the search box and icon. Press Start and type to search.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'; Name = 'SearchboxTaskbarMode'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'start.meet-now'; Name = 'Remove Meet Now (Windows 10)'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removes the Skype Meet Now icon.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'HideSCAMeetNow'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'start.news-interests'; Name = 'Remove News and Interests (Windows 10)'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removes the weather and news button from the Windows 10 taskbar.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds'; Name = 'EnableFeeds'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'start.most-used'; Name = 'Hide most used apps in Start'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Start stops listing your most used apps.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'; Name = 'ShowOrHideMostUsedApps'; Kind = 'DWord'; Value = 2 }
        )
    }
    @{
        Id = 'start.recently-added'; Name = 'Hide recently added apps in Start'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Start stops listing newly installed apps.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'; Name = 'HideRecentlyAddedApps'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'HideRecentlyAddedApps'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'start.recent-items'; Name = 'Hide recent items in Start and jump lists'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Start, jump lists and Explorer stop showing recently opened files.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_TrackDocs'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_TrackProgs'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'start.recommended'; Name = 'Remove the Recommended section from Start'; Category = 'Start & Taskbar'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Hides Recommended in Start. Works by marking Windows as an education PC, which can also change a few other defaults.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_IrisRecommendations'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_AccountNotifications'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'HideRecommendedSection'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education'; Name = 'IsEducationEnvironment'; Kind = 'DWord'; Value = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'; Name = 'HideRecommendedSection'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'start.browsing-history'; Name = 'No websites from browsing history in Start'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'FR33THY Ultimate'
        Description = 'Start stops recommending websites from your Edge history.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_RecoPersonalizedSites'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'start.lock-option'; Name = 'Hide Lock in the power menu'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removes "Lock" from the Start power menu. Win+L still works.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings'; Name = 'ShowLockOption'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'start.sleep-option'; Name = 'Hide Sleep in the power menu'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removes "Sleep" from the Start power menu.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings'; Name = 'ShowSleepOption'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'start.apps-list'; Name = 'All apps as a list'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Shows All apps in Start as a list instead of a grid.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start'; Name = 'AllAppsViewMode'; Kind = 'DWord'; Value = 2; Default = 0 }
        )
    }
    @{
        Id = 'start.tray-icons'; Name = 'Show all tray icons'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Shows every notification-area icon instead of hiding some behind the arrow.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'EnableAutoTray'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify'; Name = 'SystemTrayChevronVisibility'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'start.jumplist-hover'; Name = 'No jump lists when hovering inactive apps'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Hovering a taskbar app that is not running no longer pops up its jump list.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'JumplistOnHover'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'start.last-active-click'; Name = 'Click a taskbar group to open the last window'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Clicking an app with several windows opens the one you used last instead of showing thumbnails.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'LastActiveClick'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'start.share-window'; Name = 'Remove "Share this window" from the taskbar'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Removes the Teams screen-share button that appears when hovering taskbar apps.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarSn'; Kind = 'DWord'; Value = 0; Default = 0 }
        )
    }
    @{
        Id = 'start.desktop-peek'; Name = 'Turn off the show-desktop corner'; Category = 'Start & Taskbar'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'FR33THY Ultimate'
        Description = 'Clicking the far right of the taskbar no longer minimises everything.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarSd'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
)
