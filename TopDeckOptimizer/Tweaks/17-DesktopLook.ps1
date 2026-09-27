<#
Desktop & Look tweaks, ported from FR33THY Ultimate and ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'look.snap'; Name = 'Turn off Snap layouts and suggestions'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Stops the snap layout pop-up and suggestions when dragging windows. Win+arrow snapping still works.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'EnableSnapAssistFlyout'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'EnableSnapBar'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'EnableTaskGroups'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'SnapAssist'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'DITest'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'SnapFill'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'JointResize'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'look.quick-settings'; Name = 'Trim the quick settings panel'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Unpins Night light, Accessibility, Nearby share, Cast and Project from the Wi-Fi/sound panel.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Quick Actions\Control Center\Unpinned'; Name = 'Microsoft.QuickAction.BlueLightReduction'; Kind = 'None'; Value = @() }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Quick Actions\Control Center\Unpinned'; Name = 'Microsoft.QuickAction.Accessibility'; Kind = 'None'; Value = @() }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Quick Actions\Control Center\Unpinned'; Name = 'Microsoft.QuickAction.NearShare'; Kind = 'None'; Value = @() }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Quick Actions\Control Center\Unpinned'; Name = 'Microsoft.QuickAction.Cast'; Kind = 'None'; Value = @() }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Quick Actions\Control Center\Unpinned'; Name = 'Microsoft.QuickAction.ProjectL2'; Kind = 'None'; Value = @() }
        )
    }
    @{
        Id = 'look.dark-theme'; Name = 'Dark theme with dark grey accent'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Switches Windows and apps to dark mode and sets a dark grey accent colour.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name = 'AppsUseLightTheme'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name = 'SystemUsesLightTheme'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name = 'AppsUseLightTheme'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name = 'ColorPrevalence'; Kind = 'DWord'; Value = 1; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'; Name = 'AccentPalette'; Kind = 'Binary'; Value = @(0x95,0x95,0x95,0xFF,0x8B,0x8B,0x8B,0xFF,0x19,0x19,0x19,0xFF,0x19,0x19,0x19,0xFF,0x19,0x19,0x19,0xFF,0x19,0x19,0x19,0xFF,0x19,0x19,0x19,0xFF,0x19,0x19,0x19,0x00); Default = @(0x99,0xEB,0xFF,0x00,0x4C,0xC2,0xFF,0x00,0x00,0x91,0xF8,0x00,0x00,0x78,0xD4,0x00,0x00,0x67,0xC0,0x00,0x00,0x3E,0x92,0x00,0x00,0x1A,0x68,0x00,0xF7,0x63,0x0C,0x00) }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'; Name = 'StartColorMenu'; Kind = 'DWord'; Value = -15132391; Default = -4167936 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'; Name = 'AccentColorMenu'; Kind = 'DWord'; Value = -15132391; Default = -2852864 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\DWM'; Name = 'EnableWindowColorization'; Kind = 'DWord'; Value = 1; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\DWM'; Name = 'AccentColor'; Kind = 'DWord'; Value = -15132391; Default = -2852864 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\DWM'; Name = 'ColorizationColor'; Kind = 'DWord'; Value = -1004988135; Default = -1006602028 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\DWM'; Name = 'ColorizationAfterglow'; Kind = 'DWord'; Value = -1004988135; Default = -1006602028 }
        )
    }
    @{
        Id = 'look.transparency'; Name = 'Turn off transparency'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Solid colours instead of see-through Start and taskbar. Slightly less GPU use.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name = 'EnableTransparency'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'look.startup-sound'; Name = 'Turn off the startup sound'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'No sound when Windows starts.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation'; Name = 'DisableStartupSound'; Kind = 'DWord'; Value = 1; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\EditionOverrides'; Name = 'UserSetting_DisableStartupSound'; Kind = 'DWord'; Value = 1; Default = 0 }
        )
    }
    @{
        Id = 'look.alt-tab'; Name = 'Alt+Tab shows windows only'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Alt+Tab stops listing individual Edge tabs.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'MultiTaskingAltTabFilter'; Kind = 'DWord'; Value = 3; Default = 'Delete' }
        )
    }
    @{
        Id = 'look.black-background'; Name = 'Solid black desktop background'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Removes the wallpaper and sets a plain black background.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers'; Name = 'BackgroundType'; Kind = 'DWord'; Value = 1; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop'; Name = 'WallPaper'; Kind = 'String'; Value = ''; Default = 'C:\Windows\web\wallpaper\Windows\img0.jpg' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Colors'; Name = 'Background'; Kind = 'String'; Value = '0 0 0'; Default = '0 0 0' }
        )
    }
    @{
        Id = 'look.sign-in-image'; Name = 'Plain sign-in screen'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Sign-in screen shows a solid colour instead of the lock screen picture.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'DisableLogonBackgroundImage'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'look.spotlight'; Name = 'Turn off Windows Spotlight on the desktop'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Stops the desktop wallpaper changing daily with Bing photos and the "Learn about this picture" icon.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\DesktopSpotlight\Settings'; Name = 'EnabledState'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'look.powershell-black'; Name = 'Black PowerShell window'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Windows PowerShell opens with a black background.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe'; Name = 'ScreenColors'; Kind = 'DWord'; Value = 15; Default = 86 }
            @{ Type = 'Registry'; Path = 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe'; Name = 'ColorTable06'; Kind = 'DWord'; Value = 16777215 }
            @{ Type = 'Registry'; Path = 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe'; Name = 'ColorTable15'; Kind = 'DWord'; Value = 16777215 }
            @{ Type = 'Registry'; Path = 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe'; Name = 'ColorTable00'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe'; Name = 'FaceName'; Kind = 'String'; Value = 'Consolas' }
            @{ Type = 'Registry'; Path = 'HKCU:\Console\%SystemRoot%_system32_cmd.exe'; Name = 'ColorTable07'; Kind = 'DWord'; Value = 16777215 }
            @{ Type = 'Registry'; Path = 'HKCU:\Console\%SystemRoot%_system32_cmd.exe'; Name = 'ColorTable00'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'look.big-clock'; Name = 'Big clock in the notification centre'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'ZOICWARE'
        Description = 'Shows a large clock with seconds above the calendar.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ShowClockInNotificationCenter'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'look.wallpaper-quality'; Name = 'Full-quality wallpaper'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Windows compressing your wallpaper image.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop'; Name = 'JPEGImportQuality'; Kind = 'DWord'; Value = 100 }
        )
    }
    @{
        Id = 'look.no-sounds'; Name = 'No Windows sounds'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'FR33THY Ultimate'
        Description = 'Sets the sound scheme to "No Sounds".'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes'; Name = ''; Kind = 'String'; Value = '.None'; Default = '.Default' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\.Default\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Background.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\CriticalBatteryAlarm\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Foreground.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\DeviceConnect\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Hardware Insert.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\DeviceDisconnect\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Hardware Remove.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\DeviceFail\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Hardware Fail.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\FaxBeep\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Notify Email.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\LowBatteryAlarm\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Background.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\MailBeep\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Notify Email.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\MessageNudge\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Message Nudge.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\Notification.Default\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Notify System Generic.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\Notification.IM\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Notify Messaging.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\Notification.Mail\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Notify Email.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\Notification.Proximity\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Proximity Notification.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\Notification.Reminder\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Notify Calendar.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\Notification.SMS\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Notify Messaging.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\ProximityConnection\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Proximity Connection.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\SystemAsterisk\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Background.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\SystemExclamation\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Background.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\SystemHand\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Foreground.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\SystemNotification\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows Background.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\.Default\WindowsUAC\.Current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Windows User Account Control.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\sapisvr\DisNumbersSound\.current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Speech Disambiguation.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\sapisvr\HubOffSound\.current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Speech Off.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\sapisvr\HubOnSound\.current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Speech On.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\sapisvr\HubSleepSound\.current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Speech Sleep.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\sapisvr\MisrecoSound\.current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Speech Misrecognition.wav' }
            @{ Type = 'Registry'; Path = 'HKCU:\AppEvents\Schemes\Apps\sapisvr\PanelSound\.current'; Name = ''; Kind = 'String'; Value = ''; Default = 'C:\Windows\media\Speech Disambiguation.wav' }
        )
    }
    @{
        Id = 'look.recycle-bin'; Name = 'Hide the Recycle Bin from the desktop'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $true; Source = 'FR33THY Ultimate'
        Description = 'Removes the Recycle Bin icon from the desktop. It is still in Explorer.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu'; Name = '{645FF040-5081-101B-9F08-00AA002F954E}'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name = '{645FF040-5081-101B-9F08-00AA002F954E}'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'look.sign-in-blur'; Name = 'No blur on the sign-in screen'; Category = 'Desktop & Look'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'FR33THY Ultimate'
        Description = 'Sign-in background stays sharp instead of blurred.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'DisableAcrylicBackgroundOnLogon'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'look.dpi-100'; Name = 'Force 100% display scaling'; Category = 'Desktop & Look'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Sets scaling to 100%. Everything gets smaller on laptops and 4K screens. Only for 1080p desktop monitors.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop'; Name = 'LogPixels'; Kind = 'DWord'; Value = 96; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop'; Name = 'Win8DpiScaling'; Kind = 'DWord'; Value = 0; Default = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\DWM'; Name = 'UseDpiScaling'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'look.dpi-fix-apps'; Name = 'Turn off "Fix scaling for apps"'; Category = 'Desktop & Look'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Windows trying to fix blurry apps, and resets per-monitor scaling.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop'; Name = 'EnablePerProcessSystemDPI'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'RegistryKey'; Path = 'HKCU:\Control Panel\Desktop\PerMonitorSettings'; Ensure = 'Absent' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Desktop\WindowMetrics'; Name = 'AppliedDPI'; Kind = 'DWord'; Value = 96 }
        )
    }
)
