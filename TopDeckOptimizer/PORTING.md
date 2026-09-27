# Porting record

Stage 2 brought the registry tweaks from two MIT-licensed projects into Top Deck:

- **ZOICWARE** `src/RegTweaks.txt` (189 sections)
- **FR33THY Ultimate** `6 Windows/22 Control Panel Settings.ps1`, the "Optimize" block (196 sections). Only settings ZOICWARE does not already cover were taken; where both set the same value differently, ZOICWARE's value was kept.

Ultimate's matching "Default" block supplies Windows' own value for each setting. Undo uses it when a tweak was applied by something other than Top Deck, so there is no backup.

Result: 159 tweaks (124 Safe, 32 Moderate, 3 Advanced; 77 recommended).

## Bugs fixed while porting

| Source | Problem | Fix |
|---|---|---|
| ZOICWARE | `UserPreferencesMask` written as `hex(2)` (text). It is binary data; as text it corrupts the visual-effects setting. | Written as binary. |
| FR33THY Ultimate | Same `UserPreferencesMask` type error in its default-values block. | Default read as binary (`9E 1E 07 80 12 00 00 00`, the real Windows default). |
| ZOICWARE | Widgets policies `DisableWidgetsOnLockScreen` and `DisableWidgetsBoard` set to 0, which means "not disabled". | Set to 1. |
| FR33THY Ultimate | Key names containing `$` written as `?`, so the Focus Assist / Do Not Disturb tweaks wrote to keys Windows never reads. | Not ported (see below). |

## Not ported

| Section | Reason |
|---|---|
| ZOICWARE: Restore the classic context menu | duplicate of ui.classic-context-menu |
| ZOICWARE: Enable action center | only removes a policy; not a tweak |
| ZOICWARE: Show file name extensions | duplicate of ui.file-extensions |
| ZOICWARE: Disable menu show delay | duplicate of perf.menu-delay |
| ZOICWARE: Turn off enhance pointer precision | duplicate of gaming.mouse-accel |
| ZOICWARE: Disable hibernate | duplicate of perf.hibernation |
| ZOICWARE: Set system responsiveness to 10 | duplicate of gaming.network-throttling |
| ZOICWARE: Disable network throttling | duplicate of gaming.network-throttling |
| ZOICWARE: Turn on hardware accelerated GPU scheduling | duplicate of gaming.hags |
| ZOICWARE: Disable game bar | duplicate of gaming.game-dvr |
| ZOICWARE: Disable store my activity history on this device | duplicate of privacy.activity-history |
| ZOICWARE: Disable safe search | content filter preference, not an optimisation |
| ZOICWARE: Remove logons | deletes every program's startup entry (antivirus, audio, drivers) |
| ZOICWARE: Disable magnifier settings | only changes Magnifier options |
| ZOICWARE: Disable narrator settings | only changes Narrator options |
| ZOICWARE: Disable search web results | duplicate of privacy.bing-search |
| ZOICWARE: Disable do not disturb | timestamped CloudStore blobs Windows rewrites |
| ZOICWARE: Disable dynamic lock | Dynamic Lock is already off by default |
| ZOICWARE: Remove resume from taskbar | unclear target value |
| ZOICWARE: Disable small taskbar buttons | unclear target value |
| ZOICWARE: Disable USB error notifications | hides useful USB error warnings |
| ZOICWARE: Disable XBOX mode | unclear effect |
| ZOICWARE: Disable allow themes to change desktop icons | niche |
| ZOICWARE: Disable auto read/scan in Ease of Access Center | niche |
| ZOICWARE: Disable visual warning for Sound Sentry | niche |
| Ultimate: disable notify me when the clock changes | niche |
| Ultimate: disable display file size information in folder tips | niche |
| Ultimate: disable show pop-up description for folder and desktop items | niche |
| Ultimate: disable show preview handlers in preview pane | niche |
| Ultimate: disable show status bar | niche |
| Ultimate: mouse pointers scheme none | cursor scheme preference |
| Ultimate: disable allow other network users to control or disable the shared internet connection | niche |
| Ultimate: disable defragment and optimize your drives | turns off scheduled TRIM for SSDs |
| Ultimate: enable microphone | Windows default |
| Ultimate: disable sending required data | duplicate of privacy.telemetry |
| Ultimate: always hide most used list in start menu | conflicts with z32/z13 |
| Ultimate: remove security taskbar icon | hides the Windows Security tray icon |
| Ultimate: disable show key background | niche |
| Ultimate: disable pinned | new Start layout preferences |
| Ultimate: disable recent | new Start layout preferences |
| Ultimate: disable show recent and suggested files | new Start layout preferences |
| Ultimate: enable all | new Start layout preferences |
| Ultimate: disable show most used apps | new Start layout preferences |
| Ultimate: small start menu size | new Start layout preferences |
| Ultimate: disable hide your name and profile picture on start | new Start layout preferences |
| Ultimate: disable let windows manage my default printer | niche |
| Ultimate: disable focus assist | CloudStore blobs; key names broken in source |
| Ultimate: disable turn on do not disturb automatically | CloudStore blobs; key names broken in source |
| Ultimate: disable set priority notifications | CloudStore blobs |
| Ultimate: disable focus settings | CloudStore blobs |
| Ultimate: battery options optimize for video quality | niche |
| Ultimate: NEW START MENU | forces unreleased Start menu features |
| Ultimate: disable copilot & ai | duplicate |
| Ultimate: mouse fix (no accel with epp on) | mouse curve fix conflicts with acceleration off |
| Ultimate: disable windows platform binary table | duplicate of z138 |

Everything else in those two sources that is not a registry setting (services, scheduled tasks, driver installers, Defender, Windows Update) is planned for later stages.
