<#
Gaming tweaks, ported from FR33THY Ultimate and ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'gaming.ducking'; Name = 'Do not lower volume during calls'; Category = 'Gaming'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Stops Windows turning your game audio down when Discord or Teams detects a call.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Multimedia\Audio'; Name = 'UserDuckingPreference'; Kind = 'DWord'; Value = 3; Default = 'Delete' }
        )
    }
    @{
        Id = 'gaming.gamebar-controller'; Name = 'Xbox button does not open Game Bar'; Category = 'Gaming'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Pressing the Xbox button on a controller no longer opens Game Bar.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\GameBar'; Name = 'UseNexusForGameBarEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\GameBar'; Name = 'GamepadNexusChordEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'gaming.game-mode'; Name = 'Turn on Game Mode'; Category = 'Gaming'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Windows pauses updates and background work while you play. On by default; this makes sure.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\GameBar'; Name = 'AutoGameModeEnabled'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        )
    }
    @{
        Id = 'gaming.capture'; Name = 'Turn off Xbox Game Bar capture completely'; Category = 'Gaming'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Explorer = $false; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Turns off background recording, mic capture and every Game Bar capture shortcut.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'AudioEncodingBitrate'; Kind = 'DWord'; Value = 128000; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'AudioCaptureEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'HistoricalCaptureEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'EchoCancellationEnabled'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'CursorCaptureEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKToggleGameBar'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKMToggleGameBar'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKSaveHistoricalVideo'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKMSaveHistoricalVideo'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKToggleRecording'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKMToggleRecording'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKTakeScreenshot'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKMTakeScreenshot'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKToggleRecordingIndicator'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKMToggleRecordingIndicator'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKToggleMicrophoneCapture'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKMToggleMicrophoneCapture'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKToggleCameraCapture'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKMToggleCameraCapture'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKToggleBroadcast'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VKMToggleBroadcast'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'MicrophoneCaptureEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'; Name = 'AllowGameDVR'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'CustomVideoEncodingBitrate'; Kind = 'DWord'; Value = 4000000; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'CustomVideoEncodingHeight'; Kind = 'DWord'; Value = 720; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'CustomVideoEncodingWidth'; Kind = 'DWord'; Value = 1280; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'HistoricalBufferLength'; Kind = 'DWord'; Value = 30; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'HistoricalBufferLengthUnit'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'HistoricalCaptureOnBatteryAllowed'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'HistoricalCaptureOnWirelessDisplayAllowed'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'MaximumRecordLength'; Kind = 'QWord'; Value = 72000000000; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VideoEncodingBitrateMode'; Kind = 'DWord'; Value = 2; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VideoEncodingResolutionMode'; Kind = 'DWord'; Value = 2; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'VideoEncodingFrameRateMode'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'SystemAudioGain'; Kind = 'QWord'; Value = 10000; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'MicrophoneGain'; Kind = 'QWord'; Value = 10000; Default = 'Delete' }
        )
    }
    @{
        Id = 'gaming.dynamic-lighting'; Name = 'Turn off Windows Dynamic Lighting'; Category = 'Gaming'
        Risk = 'Safe'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'ZOICWARE + FR33THY Ultimate'
        Description = 'Stops Windows controlling RGB lighting, so your own software (iCUE, Synapse, G Hub) keeps control.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Lighting'; Name = 'AmbientLightingEnabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Lighting'; Name = 'ControlledByForegroundApp'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Lighting'; Name = 'UseSystemAccentColor'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
    @{
        Id = 'gaming.keyboard-repeat'; Name = 'Shortest key repeat delay'; Category = 'Gaming'
        Risk = 'Safe'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Held keys start repeating straight away. Takes effect after sign-out.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Keyboard'; Name = 'KeyboardDelay'; Kind = 'String'; Value = '0' }
        )
    }
    @{
        Id = 'gaming.windowed-optimizations'; Name = 'Optimisations for windowed games'; Category = 'Gaming'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'FR33THY Ultimate'
        Description = 'Turns on flip-model presentation for games in windowed or borderless mode (lower latency) and turns off Windows VRR override.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'; Name = 'DirectXUserGlobalSettings'; Kind = 'String'; Value = 'SwapEffectUpgradeEnable=1;VRROptimizeEnable=0;'; Default = 'Delete' }
        )
    }
    @{
        Id = 'gaming.gamebar-protocol'; Name = 'Silence "ms-gamebar" pop-ups'; Category = 'Gaming'
        Risk = 'Moderate'; Recommended = $false; Reboot = $false; Explorer = $false; Source = 'FR33THY Ultimate'
        Description = 'Only if you removed Xbox Game Bar: stops the "You will need a new app to open this ms-gamebar link" pop-up when a controller is plugged in.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamebar'; Name = '(Default)'; Kind = 'String'; Value = 'URL:ms-gamebar' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamebar'; Name = 'URL Protocol'; Kind = 'String'; Value = ''; Default = '' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamebar'; Name = 'NoOpenWith'; Kind = 'String'; Value = '' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamebar\shell\open\command'; Name = '(Default)'; Kind = 'String'; Value = '%SystemRoot%\System32\systray.exe' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamebarservices'; Name = '(Default)'; Kind = 'String'; Value = 'URL:ms-gamebarservices' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamebarservices'; Name = 'URL Protocol'; Kind = 'String'; Value = '' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamebarservices'; Name = 'NoOpenWith'; Kind = 'String'; Value = '' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamebarservices\shell\open\command'; Name = '(Default)'; Kind = 'String'; Value = '%SystemRoot%\System32\systray.exe' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamingoverlay'; Name = '(Default)'; Kind = 'String'; Value = 'URL:ms-gamingoverlay' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamingoverlay'; Name = 'URL Protocol'; Kind = 'String'; Value = ''; Default = '' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamingoverlay'; Name = 'NoOpenWith'; Kind = 'String'; Value = '' }
            @{ Type = 'Registry'; Path = 'HKCR:\ms-gamingoverlay\shell\open\command'; Name = '(Default)'; Kind = 'String'; Value = '%SystemRoot%\System32\systray.exe' }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter'; Name = 'ActivationType'; Kind = 'DWord'; Value = 0; Default = 1 }
        )
    }
)
