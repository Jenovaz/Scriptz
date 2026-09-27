<#
Security tweaks, ported from ZOICWARE (MIT licence, see THIRD-PARTY-NOTICES.txt).
Field meanings are listed at the top of 01-Privacy.ps1. Explorer = $true means File Explorer is
restarted after applying so the change shows straight away.
#>

@(
    @{
        Id = 'security.core-isolation'; Name = 'Turn off Core Isolation (Memory Integrity)'; Category = 'Security'
        Risk = 'Advanced'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Turns off virtualisation-based security. Can give a few percent more FPS, but removes protection against kernel-level malware.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'; Name = 'WasEnabledBy'; Ensure = 'Absent' }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'; Name = 'ChangedInBootCycle'; Ensure = 'Absent' }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'; Name = 'EnableVirtualizationBasedSecurity'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'; Name = 'RequirePlatformSecurityFeatures'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'; Name = 'Mandatory'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'; Name = 'HypervisorEnforcedCodeIntegrity'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name = 'EnableVirtualizationBasedSecurity'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name = 'LsaCfgFlags'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks'; Name = 'AuditModeEnabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks'; Name = 'WasEnabledBy'; Ensure = 'Absent' }
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows Security Health\Miscellaneous'; Name = 'HvciKeyDismissed'; Kind = 'DWord'; Value = 1 }
        )
    }
    @{
        Id = 'security.uac'; Name = 'Turn off User Account Control'; Category = 'Security'
        Risk = 'Advanced'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'Programs get admin rights silently with no Yes/No prompt, including any malware you run. Not recommended.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'PromptOnSecureDesktop'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'EnableLUA'; Kind = 'DWord'; Value = 0 }
            @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'ConsentPromptBehaviorAdmin'; Kind = 'DWord'; Value = 0 }
        )
    }
    @{
        Id = 'security.ucpd'; Name = 'Turn off the default-app protection driver'; Category = 'Security'
        Risk = 'Advanced'; Recommended = $false; Reboot = $true; Explorer = $false; Source = 'ZOICWARE'
        Description = 'UCPD stops programs changing your default browser and PDF app. Only turn off if a tool you trust needs it off.'
        Actions = @(
            @{ Type = 'Registry'; Path = 'HKLM:\SYSTEM\ControlSet001\Services\UCPD'; Name = 'Start'; Kind = 'DWord'; Value = 4 }
        )
    }
)
