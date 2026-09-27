<#
Accessibility & Input tweaks, ported from FR33THY Ultimate and ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'access.shortcuts'; Name = 'Turn off Sticky, Filter and Toggle Keys shortcuts'; Category = 'Accessibility & Input'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Pressing Shift five times (or holding it) no longer pops up Sticky/Filter Keys mid-game. Covers the high-contrast and Mouse Keys shortcuts too.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\StickyKeys'; Name = 'Flags'; Kind = 'String'; Value = '26'; Default = '510' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\Keyboard Response'; Name = 'AutoRepeatDelay'; Kind = 'String'; Value = '0'; Default = '1000' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\Keyboard Response'; Name = 'AutoRepeatRate'; Kind = 'String'; Value = '0'; Default = '500' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\Keyboard Response'; Name = 'DelayBeforeAcceptance'; Kind = 'String'; Value = '0' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\Keyboard Response'; Name = 'Flags'; Kind = 'String'; Value = '26'; Default = '126' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\HighContrast'; Name = 'Flags'; Kind = 'String'; Value = '4128'; Default = '126' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility'; Name = 'Sound on Activation'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility'; Name = 'Warning Sounds'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\ToggleKeys'; Name = 'Flags'; Kind = 'String'; Value = '58'; Default = '62' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\SlateLaunch'; Name = 'LaunchAT'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\MouseKeys'; Name = 'Flags'; Kind = 'String'; Value = '130'; Default = '62' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\MouseKeys'; Name = 'MaximumSpeed'; Kind = 'String'; Value = '39'; Default = '80' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\MouseKeys'; Name = 'TimeToMaximumSpeed'; Kind = 'String'; Value = '3000'; Default = '3000' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\SoundSentry'; Name = 'Flags'; Kind = 'String'; Value = '0'; Default = '2' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\SoundSentry'; Name = 'FSTextEffect'; Kind = 'String'; Value = '0'; Default = '0' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\SoundSentry'; Name = 'TextEffect'; Kind = 'String'; Value = '0'; Default = '0' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Accessibility\SlateLaunch'; Name = 'ATapp'; Kind = 'String'; Value = ''; Default = 'narrator' }
        )
    }
    @{
        Id = 'access.narrator-shortcut'; Name = 'Turn off the Narrator shortcut'; Category = 'Accessibility & Input'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Win+Ctrl+Enter no longer starts Narrator.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Narrator\NoRoam'; Name = 'DuckAudio'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Narrator\NoRoam'; Name = 'WinEnterLaunchEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Narrator\NoRoam'; Name = 'ScriptingEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Narrator\NoRoam'; Name = 'OnlineServicesEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Narrator\NoRoam'; Name = 'CheckForScriptsEnabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Narrator'; Name = 'NarratorCursorHighlight'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Narrator'; Name = 'CoupleNarratorCursorKeyboard'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'access.language-hotkey'; Name = 'Turn off language-switch hotkeys'; Category = 'Accessibility & Input'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Alt+Shift / Ctrl+Shift switching keyboard layout by accident.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Keyboard Layout\Toggle'; Name = 'Language Hotkey'; Kind = 'String'; Value = '3'; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Keyboard Layout\Toggle'; Name = 'Hotkey'; Kind = 'String'; Value = '3'; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Keyboard Layout\Toggle'; Name = 'Layout Hotkey'; Kind = 'String'; Value = '3'; Default = 'Delete' }
        )
    }
    @{
        Id = 'access.language-bar'; Name = 'Hide the language bar'; Category = 'Accessibility & Input'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Hides the floating language bar.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\CTF\LangBar'; Name = 'ExtraIconsOnMinimized'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\CTF\LangBar'; Name = 'Label'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\CTF\LangBar'; Name = 'ShowStatus'; Kind = 'DWord'; Value = 3; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\SOFTWARE\Microsoft\CTF\LangBar'; Name = 'Transparency'; Kind = 'DWord'; Value = 255; Default = 'Delete' }
        )
    }
    @{
        Id = 'access.touch-keyboard'; Name = 'Touch keyboard: no auto-caps, auto-correct or key sounds'; Category = 'Accessibility & Input'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Only matters on touch screens.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\TabletTip\1.7'; Name = 'EnableAutoShiftEngage'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\TabletTip\1.7'; Name = 'EnableDoubleTapSpace'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\TabletTip\1.7'; Name = 'EnableKeyAudioFeedback'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\TabletTip\1.7'; Name = 'TouchKeyboardTapInvoke'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\TabletTip\1.7'; Name = 'TipbandDesiredVisibility'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\input\Settings'; Name = 'IsVoiceTypingKeyEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\TabletTip\1.7'; Name = 'EnableAutocorrection'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'access.touch-indicator'; Name = 'Hide touch indicators'; Category = 'Accessibility & Input'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'No circles where you touch the screen.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Cursors'; Name = 'ContactVisualization'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Cursors'; Name = 'GestureVisualization'; Kind = 'DWord'; Value = 24; Default = 31 }
        )
    }
    @{
        Id = 'access.fingertip-writing'; Name = 'Turn off writing with your fingertip'; Category = 'Accessibility & Input'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Only matters on touch screens.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\TabletTip\EmbeddedInkControl'; Name = 'EnableInkingWithTouch'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'access.print-screen'; Name = 'Print Screen does not open Snipping Tool'; Category = 'Accessibility & Input'
        Risk = 'Safe'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'FR33THY Ultimate'
        Description = 'Frees the Print Screen key for other apps like ShareX or Lightshot.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Keyboard'; Name = 'PrintScreenKeyForSnippingEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
)
