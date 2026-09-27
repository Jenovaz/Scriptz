<#
Gaming tweaks. Field meanings are listed at the top of 01-Privacy.ps1.
#>

@(
    @{
        Id = 'gaming.game-dvr'; Name = 'Turn off background game recording'; Category = 'Gaming'
        Risk = 'Safe'; Recommended = $true; Reboot = $false; Source = 'TopDeck'
        Description = 'Stops Xbox Game Bar constantly recording the last few minutes of gameplay in the background. Costs FPS on weaker PCs.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\System\GameConfigStore'; Name = 'GameDVR_Enabled'; Kind = 'DWord'; Value = 0; Default = 1 }
            @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'AppCaptureEnabled'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        )
    }
    @{
        Id = 'gaming.mouse-accel'; Name = 'Turn off mouse acceleration'; Category = 'Gaming'
        Risk = 'Safe'; Recommended = $true; Reboot = $true; Source = 'TopDeck'
        Description = 'Unticks "Enhance pointer precision", so the cursor moves the same distance however fast you flick. Better aim. Takes effect after sign-out.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Mouse'; Name = 'MouseSpeed'; Kind = 'String'; Value = '0'; Default = '1' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Mouse'; Name = 'MouseThreshold1'; Kind = 'String'; Value = '0'; Default = '6' }
            @{ Type = 'Registry'; Path = 'HKCU:\Control Panel\Mouse'; Name = 'MouseThreshold2'; Kind = 'String'; Value = '0'; Default = '10' }
        )
    }
    @{
        Id = 'gaming.hags'; Name = 'Hardware-accelerated GPU scheduling'; Category = 'Gaming'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Source = 'TopDeck'
        Description = 'Lets the graphics card manage its own memory. Needed for DLSS Frame Generation. Can cause stutter on some older GPUs; turn off if so.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'; Name = 'HwSchMode'; Kind = 'DWord'; Value = 2; Default = 'Delete' }
        )
    }
    @{
        Id = 'gaming.network-throttling'; Name = 'Turn off network throttling'; Category = 'Gaming'
        Risk = 'Moderate'; Recommended = $false; Reboot = $true; Source = 'TopDeck'
        Description = 'Windows limits network processing while media plays. This lifts the limit and gives games more CPU priority over background tasks.'
        Actions = @(
            # -1 is stored as 0xFFFFFFFF, meaning "no throttling".
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; Name = 'NetworkThrottlingIndex'; Kind = 'DWord'; Value = -1; Default = 10 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; Name = 'SystemResponsiveness'; Kind = 'DWord'; Value = 10; Default = 20 }
        )
    }
)
