# Win11 MinMax Toolkit

**Minimal bloat, maximum performance — the safe way. Every tweak is reversible, and a restore point comes first.**

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Windows 11](https://img.shields.io/badge/Windows-11-0078D4.svg)

The script companion to the **[Windows 11 Min-Max Guide](https://marksong0917.github.io/win11-optimization-guide/)** — the guide explains the *why* step by step; this toolkit applies the safe, scriptable parts in a few minutes.

## Why

Most "debloat" scripts are a leap of faith: hundreds of changes, no log, no undo, and a real chance of breaking Windows Update, the Store, or security features. This toolkit takes the opposite approach — the min-max way from the guide:

- **Few, known changes.** Five modules, every tweak listed below and in the source.
- **Restore point first.** The script creates a System Restore point before touching anything — and *refuses to run* if that fails.
- **Reversible by design.** `Undo` restores every registry change to Windows defaults.
- **Logged.** Everything it does is printed and written to a timestamped log file next to the script.

## Safety first — what it never touches

- **Windows Update** — never disabled, delayed, or blocked.
- **Windows Defender & firewall** — never touched.
- **Bluetooth and network services** — never touched.
- **Memory Integrity (Core Isolation)** — *not* in these scripts at all. The guide treats it as an optional, manual, single-machine trade-off; on modern hardware the recommendation is to keep it **on**.
- **No nuking.** No component removal, no service disabling sprees, no hosts-file telemetry blocking, no registry "cleaners", no third-party tools downloaded or executed.

Power plan rule, straight from the guide: **Ultimate Performance is enabled on desktops only.** The script checks for a battery; laptops get a printed note to stay on Balanced and *no change is made*.

## Quick start

1. Download this repo (Code → Download ZIP) and extract it anywhere.
2. If Windows blocked the files: right-click the ZIP → Properties → **Unblock** before extracting (or run `Unblock-File .\MinMax.ps1` and the same for `modules\*.ps1`).
3. Open **PowerShell as Administrator** in the extracted folder.
4. Allow scripts for this session only, then run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\MinMax.ps1
```

5. Not sure yet? Preview the whole plan first — this changes nothing and needs no admin rights:

```powershell
.\MinMax.ps1 -DryRun  # print every change it would make, then exit
```

6. Pick from the menu (it asks before applying each module) — or run it all at once:

```powershell
.\MinMax.ps1 -All     # apply modules 1-4 non-interactively
.\MinMax.ps1 -Undo    # revert everything to Windows defaults
```

A normal run looks like this:

```text
==============================================
  Win11 MinMax Toolkit v1.0.0
  Min-max, but safe: reversible tweaks only.
==============================================
[13:02:11] [OK] Administrator check passed.
[13:02:11] [OK] Windows 11 check passed.
[13:02:12] [OK] Restore point created.
Choose: 2
Apply Privacy now? Type Y to continue: Y
[13:02:20] [INFO] Set HKCU:\...\AdvertisingInfo\Enabled = 0 (DWord)
...
```

Restart when it finishes. Requirements: Windows 11 (build 22000+), PowerShell 5.1+ (built into Windows 11), administrator rights.

## Modules

| Module | What it does |
|---|---|
| `Debloat.ps1` | Removes 16 preinstalled consumer apps for the current user: Clipchamp, Solitaire Collection, Bing News, Bing Weather, Get Help, Tips, People, To Do, Feedback Hub, Office Hub, Skype (consumer), the Candy Crush and Bubble Witch games, and the Spotify, TikTok and Disney+ stubs. Anything not installed is skipped. All reinstallable from the Microsoft Store. |
| `Privacy.ps1` | Telemetry to Basic (policy), advertising ID off, activity history off, inking/typing data collection off, suggested content & Windows consumer features off (Start/Settings suggestions, silent app installs), feedback prompts off. |
| `Performance.ps1` | Game Mode on, Game DVR background recording off; visual effects trimmed (window/taskbar animation off) with font smoothing (ClearType) kept on; mouse pointer precision off; Ultimate Performance power plan on desktops only. |
| `Explorer.ps1` | Show file extensions, show hidden files, Explorer opens to This PC, dark mode (apps + system), taskbar search as icon, Widgets button off, Chat/Teams taskbar icon off, long path support on. |
| `Undo.ps1` | Reverts every registry change above to Windows defaults; prints the honest note about removed apps (reinstall from the Store). |

## Undo

Two layers of "take it back":

1. **The restore point** created at the start of every run (Start → "Create a restore point" → System Restore) — the full-system safety net.
2. **`MinMax.ps1` → menu 5 (Undo menu)**, or `.\MinMax.ps1 -Undo` — restores each registry value to its Windows default, per module or all at once.

One honest limit: Undo does **not** reinstall removed Store apps. They are all free in the Microsoft Store; search the name and reinstall the ones you want back.

## FAQ

**Is this safe for my only PC?**
It is built to be: restore point first (or it refuses to run), a short list of well-known registry toggles, a log of every change, and a full Undo. It is still *your* machine — read the module source; it is short and commented on purpose.

**Why not remove more? Xbox apps, Paint, the Store itself?**
Because that is where systems break. The list is deliberately conservative: consumer stubs, bundled games and trial apps. Anything Windows or your apps might actually use stays.

**Does it speed up games?**
It removes background noise (DVR recording, consumer app clutter, animation overhead) and enables Game Mode. It will not work miracles — the guide's bigger wins are a clean install, sane startup apps, and XMP/EXPO, which are manual steps in the guide.

**Will Windows Update undo the tweaks?**
Feature updates sometimes reset user preferences. Re-running the toolkit is safe (it takes a fresh restore point each time); Undo still works afterwards.

**I created a new user account and the bloat apps are back. Why?**
Debloat removes apps for the *current* user only. Windows keeps "provisioned" copies that install for each new account. Removing provisioned packages is exactly where aggressive debloat tools start breaking Windows, so this toolkit deliberately does not do it — just run it once under the new account.

## What this is not

- Not a "debloat nuker" — no component stripping, no service massacre.
- Not an activator — **no activation tools, no MAS commands or links, no LTSC download links.** Use a licence you own; the guide says the same.
- Not a driver updater, registry cleaner, or security disabler — the guide explicitly warns against all three.

## Companion guide

Full reasoning, the clean-install path, browser setup, BIOS/XMP, and the final checklist:
**[Windows 11 Min-Max Guide](https://marksong0917.github.io/win11-optimization-guide/)**

## Credits

By **Ze (Mark) Song** — [portfolio](https://marksong0917.github.io/) · [Windows 11 Min-Max Guide](https://marksong0917.github.io/win11-optimization-guide/)

## License

[MIT](LICENSE) — use it, share it, keep the safety rules.
