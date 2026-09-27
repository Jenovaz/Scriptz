# Jenovaz "Top Deck" OS Optimizer

Windows debloat and tuning with on/off switches, and **every switch can be undone**.

## Run it

1. Download or clone this folder.
2. Double-click `Run-TopDeck.cmd` and click **Yes** on the admin prompt.

It needs Windows 10 or 11. It uses Windows PowerShell 5.1, which is already built into Windows, so there is nothing to install.

## How it works

- Each switch shows what is **currently set on your PC**, not a guess.
- Flip the switches you want changed. Nothing happens until you press **Apply**.
- **Preview changes** lists every registry value, service and app that will be touched, with its current value and its new value.
- Before a tweak is applied for the first time, its original settings are saved to `%ProgramData%\TopDeckOptimizer\backups.json`. Turning the switch off puts those originals back.
- A Windows restore point is created before applying, unless you untick the box.
- 189 tweaks across 11 tabs: Privacy, App Permissions, Debloat, Performance, Gaming, Start & Taskbar, File Explorer, Desktop & Look, Accessibility & Input, System and Security. Use the **Search** box to find one across all tabs.
- **Recommended** switches on the tweaks marked safe for most PCs. **Save profile** and **Load profile** carry your choices to another PC.
- The **Tools** tab has one-off jobs: temp file cleanup, DISM and SFC repair, drive TRIM/defrag and DNS flush.
- Taskbar, Start and Explorer changes offer to restart File Explorer afterwards so they show straight away.
- Everything is logged to `%ProgramData%\TopDeckOptimizer\topdeck.log`.

Risk labels:

| Label | Meaning |
|---|---|
| Safe | No known downside for normal use. |
| Moderate | Has a trade-off (battery life, a feature you might use). Read the description first. |
| Advanced | Can break Windows features or updates. Only for people who know what they are turning off. |

## Things to know

- **Removed apps** can't come back from a backup. Turning the switch off reinstalls the app from the Microsoft Store where possible, otherwise the log tells you to reinstall it by hand.
- If you sign in as a standard user and type an admin password at the prompt, the "current user" settings apply to the admin account, not yours. Run it from an account that is itself an administrator.
- The **Security** tab turns Windows protections off (UAC, Core Isolation). Those are Advanced and never switched on by Recommended.
- `TopDeck.ps1 -Check` validates the tweak files and prints the state of every tweak without changing anything.

## Adding a tweak

Tweaks are data, not code. Add an entry to the matching file in `Tweaks\`; the fields are explained at the top of `Tweaks\01-Privacy.ps1`. Most tweaks are one or more registry values:

```powershell
@{
    Id = 'ui.example'; Name = 'What the switch says'; Category = 'Interface'
    Risk = 'Safe'; Recommended = $false; Reboot = $false; Source = 'TopDeck'
    Description = 'One plain-English line.'
    Actions = @(
        @{ Type = 'Registry'; Path = 'HKCU:\Some\Key'; Name = 'Value'; Kind = 'DWord'; Value = 0; Default = 1 }
    )
}
```

Action types:

| Type | Does | Fields |
|---|---|---|
| `Registry` | Sets a value, or deletes it with `Ensure = 'Absent'` | `Path`, `Name` (`''` = the key's default value), `Kind`, `Value`, optional `Default` |
| `RegistryKey` | Deletes a whole key; a full copy is saved first so undo rebuilds it | `Path`, `Ensure = 'Absent'` |
| `Service` | Changes a service's startup type | `Name`, `Startup` |
| `ScheduledTask` | Disables a scheduled task | `Path`, `Name` |
| `Appx` | Removes a built-in app | `Package`, optional `StoreId` |
| `Command` | Your own scripts | `Test`, `Apply`, `Revert`, `Describe`, optional `Backup` |

Add `Explorer = $true` to a tweak if File Explorer needs restarting to show it. After editing, run `TopDeck.ps1 -Check`, then the test below.

## Testing

`Tests\FakeRegistry.Tests.ps1` applies and undoes every registry tweak against an in-memory fake registry and checks each setting ends up exactly where it started. It runs on any computer with PowerShell 7, including Linux and Mac, and never touches your real registry:

```
pwsh -File Tests\FakeRegistry.Tests.ps1
```

## Layout

```
TopDeckOptimizer/
  Run-TopDeck.cmd          double-click launcher
  TopDeck.ps1              the window
  Core/Engine.psm1         test / backup / apply / revert logic
  Core/MainWindow.xaml     window layout
  Tweaks/*.ps1             tweak definitions, one file per category
  Tests/                   fake-registry test for every registry tweak
  PORTING.md               what was ported from ZOICWARE and Ultimate, bugs fixed, what was skipped and why
  Tools/Tools.ps1          one-off tools
  THIRD-PARTY-NOTICES.txt  credits and licences
```

## Credits

Built on ideas and code from [ZOICWARE](https://github.com/zoicware/ZOICWARE) and [FR33THY Ultimate](https://github.com/FR33THYFR33THY/Ultimate) (both MIT licensed), and features in the style of Wagnardsoft WTools. See `THIRD-PARTY-NOTICES.txt`.
