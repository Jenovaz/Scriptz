# Zomboid Mod Enabler

One checklist to switch on Project Zomboid multiplayer mods, instead of filling in three settings screens by hand.

## Why mods "don't load"

A Zomboid server needs **three** lists in its settings file (`%USERPROFILE%\Zomboid\Server\<server name>.ini`):

| Line | What it does | In-game screen |
|---|---|---|
| `WorkshopItems=` | Steam Workshop numbers. Tells Steam what to **download**. | Steam Workshop |
| `Mods=` | Mod IDs from each mod's `mod.info`. Tells the game what to **switch on**. | Mods |
| `Map=` | Map folders for map mods, with `Muldraugh, KY` last. | Map |

Adding a mod on the Steam Workshop screen only fills in the first one. If the mod isn't also ticked on the Mods screen, it downloads but never loads. This tool fills in all three.

## Run it

1. Subscribe to the mods on Steam so they download.
2. Close the game's **Edit Settings** screen (press Cancel), so the game doesn't overwrite what you save here.
3. Double-click `Run-ZomboidModEnabler.cmd`. It doesn't need admin rights.
4. Pick your server, tick the mods you want, check the right-hand panel, and press **Save**.
5. Start (or restart) the server.

It uses Windows PowerShell 5.1, which comes with Windows 10 and 11.

## What you see

- **On this server**: Workshop items already in the server's list. Mods start ticked if they're already on. Mods in items you added but never switched on also start ticked, because that's the usual missing step.
- **"N mods inside"**: some Workshop items contain several versions of one mod (Lite/Full, or different options). Tick only the one you want. If you already have one of them on, the others stay unticked.
- **Not downloaded yet**: in the list but not on this PC. These stay in the list so Steam downloads them. Subscribe, then press **Rescan**.
- **Other downloaded Zomboid mods**: everything else Steam has downloaded. Tick one to add it to the server.
- **Add Workshop items**: paste Workshop links or numbers. Collection links don't work; add the items inside the collection.
- **Check before saving**: flags mods that need another mod that isn't ticked (red), duplicate entries, and Build 41-only mods.
- **Will be written**: the exact three lines that Save will write.

## What Save does

- Copies the old settings file to `Zomboid\Server\ModEnablerBackups\` first. To undo, copy that backup back over the `.ini`.
- Rewrites only the `WorkshopItems=`, `Mods=` and `Map=` lines. Everything else in the file stays as it is.
- Removes duplicate Workshop entries.
- Orders `Mods=` so a mod's requirements load before it.
- Keeps map mods in their current order, adds new ones, and keeps `Muldraugh, KY` last.

## The `\` before mod IDs

Early Build 42 multiplayer wrote mod IDs as `Mods=\ModA;\ModB`, but later builds reportedly don't need the backslash. The tick box copies whatever your file already uses. If your `Mods=` line is empty, it starts unticked. If mods still don't load after saving, flip that box and save again.

## Command line

```
ZomboidModEnabler.ps1 -List                     # print what would be written, change nothing
ZomboidModEnabler.ps1 -Apply                    # write the default choices without the window
ZomboidModEnabler.ps1 -Server "Chaakuh Bruh"    # open a particular server
ZomboidModEnabler.ps1 -Add "2875848298 3790089095"
ZomboidModEnabler.ps1 -WorkshopDir "D:\SteamLibrary\steamapps\workshop\content\108600"
ZomboidModEnabler.ps1 -Build 41                 # hosting Build 41
```

Steam library folders are found automatically, including ones on other drives. Use `-WorkshopDir` only if that fails.
