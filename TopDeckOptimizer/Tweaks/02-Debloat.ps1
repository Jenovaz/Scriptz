<#
Debloat tweaks: built-in apps you can remove, plus Copilot and Widgets.
Field meanings are listed at the top of 01-Privacy.ps1.

Apps are built from the table below, one toggle each. StoreId lets Revert reinstall the app
from the Microsoft Store with winget; apps without one must be reinstalled by hand.
#>

$apps = @(
    # Package name                           Display name             StoreId          Recommended
    ,@('Microsoft.BingNews',                  'Microsoft News',        '9WZDNCRFHVFW',  $true)
    ,@('Microsoft.BingWeather',               'Weather',               '9WZDNCRFJ3Q2',  $false)
    ,@('Microsoft.GetHelp',                   'Get Help',              '9PKDZBMV1H3T',  $true)
    ,@('Microsoft.Getstarted',                'Tips',                  $null,           $true)
    ,@('Microsoft.MicrosoftSolitaireCollection', 'Solitaire Collection', '9WZDNCRFHWD2', $true)
    ,@('Microsoft.WindowsFeedbackHub',        'Feedback Hub',          '9NBLGGH4R32N',  $true)
    ,@('Clipchamp.Clipchamp',                 'Clipchamp',             '9P1J8S7CCWWT',  $true)
    ,@('Microsoft.PowerAutomateDesktop',      'Power Automate',        '9NFTCH6J7FHV',  $true)
    ,@('Microsoft.MicrosoftOfficeHub',        'Microsoft 365 (Office) hub', $null,     $true)
    ,@('Microsoft.549981C3F5F10',             'Cortana',               '9NFFX4SZZ23L',  $true)
    ,@('Microsoft.Todos',                     'Microsoft To Do',       '9NBLGGH5R558',  $false)
    ,@('Microsoft.WindowsMaps',               'Maps',                  '9WZDNCRDTBVB',  $false)
    ,@('Microsoft.ZuneVideo',                 'Films & TV',            '9WZDNCRFJ3P2',  $false)
)

foreach ($app in $apps) {
    $action = @{ Type = 'Appx'; Package = $app[0] }
    if ($app[2]) { $action.StoreId = $app[2] }
    $undo = if ($app[2]) { 'Turning it back off reinstalls it from the Store.' } else { 'Reinstall from the Microsoft Store if you want it back.' }
    @{
        Id = "debloat.app.$($app[0])"; Name = "Remove $($app[1])"; Category = 'Debloat'
        Risk = 'Safe'; Recommended = $app[3]; Reboot = $false; Source = 'TopDeck'
        Description = "Uninstalls $($app[1]) for every user on this PC. $undo"
        Actions = @($action)
    }
}

@{
    Id = 'debloat.copilot'; Name = 'Turn off Copilot'; Category = 'Debloat'
    Risk = 'Safe'; Recommended = $true; Reboot = $true; Source = 'TopDeck'
    Description = 'Removes the Copilot app and taskbar button, and blocks it via policy so updates do not bring it back.'
    Actions = @(
        @{ Type = 'Registry'; Path = 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'; Name = 'TurnOffWindowsCopilot'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'; Name = 'TurnOffWindowsCopilot'; Kind = 'DWord'; Value = 1; Default = 'Delete' }
        @{ Type = 'Registry'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ShowCopilotButton'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
        @{ Type = 'Appx'; Package = 'Microsoft.Copilot'; StoreId = '9NHT9RB2F4HD' }
    )
}

@{
    Id = 'debloat.widgets'; Name = 'Turn off Widgets'; Category = 'Debloat'
    Risk = 'Safe'; Recommended = $true; Reboot = $true; Source = 'TopDeck'
    Description = 'Removes the Widgets news panel from the taskbar and stops it running in the background.'
    Actions = @(
        @{ Type = 'Registry'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh'; Name = 'AllowNewsAndInterests'; Kind = 'DWord'; Value = 0; Default = 'Delete' }
    )
}
