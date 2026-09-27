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
- **Recommended** switches on the tweaks marked safe for most PCs. **Save profile** and **Load profile** carry your choices to another PC.
- The **Tools** tab has one-off jobs: temp file cleanup, DISM and SFC repair, drive TRIM/defrag and DNS flush.
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

Action types: `Registry`, `Service`, `ScheduledTask`, `Appx` (remove an app), and `Command` (your own Test / Apply / Revert scripts). Run `TopDeck.ps1 -Check` after editing.

## Layout

```
TopDeckOptimizer/
  Run-TopDeck.cmd          double-click launcher
  TopDeck.ps1              the window
  Core/Engine.psm1         test / backup / apply / revert logic
  Core/MainWindow.xaml     window layout
  Tweaks/*.ps1             tweak definitions, one file per category
  Tools/Tools.ps1          one-off tools
  THIRD-PARTY-NOTICES.txt  credits and licences
```

## Credits

Built on ideas and code from [ZOICWARE](https://github.com/zoicware/ZOICWARE) and [FR33THY Ultimate](https://github.com/FR33THYFR33THY/Ultimate) (both MIT licensed), and features in the style of Wagnardsoft WTools. See `THIRD-PARTY-NOTICES.txt`.
