# Changelog

All notable changes to the Win11 MinMax Toolkit.

## [1.0.0] - 2026-10-29

First release — the script companion to the
[Windows 11 Min-Max Guide](https://marksong0917.github.io/win11-optimization-guide/).

### Added
- `MinMax.ps1` entry point: administrator + Windows 11 build checks,
  mandatory System Restore point before any change (refuses to run if
  creation fails), numbered menu, `-All` and `-Undo` switches, and a
  timestamped log file for every run.
- `modules/Debloat.ps1` — removes 16 preinstalled consumer apps (stubs,
  bundled games, trial apps) for the current user; skips anything absent.
- `modules/Privacy.ps1` — telemetry to Basic, advertising ID off, activity
  history off, inking/typing collection off, suggested content and Windows
  consumer features off, feedback prompts off.
- `modules/Performance.ps1` — Game Mode on, Game DVR off, animation trimmed
  with font smoothing kept, mouse pointer precision off, Ultimate
  Performance power plan on desktops only (laptops are left on Balanced).
- `modules/Explorer.ps1` — file extensions and hidden files shown, Explorer
  opens to This PC, dark mode, taskbar search as icon, Widgets and Chat
  icons off, long path support on.
- `modules/Undo.ps1` — per-module and full revert of every registry change
  to Windows defaults, with an honest note that removed Store apps are
  reinstalled from the Microsoft Store.

### Safety rules baked in from day one
- Never touches Windows Update, Defender, Bluetooth, network services,
  or Memory Integrity.
- No downloaded code, no third-party tools, no activation or ISO links.
