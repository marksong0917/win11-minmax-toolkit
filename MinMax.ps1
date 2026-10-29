<#
.SYNOPSIS
    Win11 MinMax Toolkit - the script companion to the Windows 11 Min-Max
    Guide (https://marksong0917.github.io/win11-optimization-guide/).

.DESCRIPTION
    Min-max, but safe. Every tweak is registry/policy based and reversible,
    and this script creates a System Restore point BEFORE changing anything
    and refuses to continue if that fails. It never touches Windows Update,
    Windows Defender, Bluetooth, network services, or Memory Integrity.

    Run with no switches for a menu, -All to apply modules 1-4
    non-interactively, or -Undo to revert everything to Windows defaults.

.EXAMPLE
    .\MinMax.ps1
    Interactive menu.

.EXAMPLE
    .\MinMax.ps1 -All
    Applies Debloat, Privacy, Performance and Explorer & taskbar.

.EXAMPLE
    .\MinMax.ps1 -Undo
    Reverts all registry tweaks to Windows defaults.

.NOTES
    Author: Ze (Mark) Song - https://marksong0917.github.io/
    Requires: Windows 11, PowerShell 5.1+, Administrator rights.
    License: MIT.
#>
param(
    [switch]$All,
    [switch]$Undo,
    [switch]$DryRun
)

$toolkitRoot = $PSScriptRoot
foreach ($module in @('Common.ps1', 'Debloat.ps1', 'Privacy.ps1', 'Performance.ps1', 'Explorer.ps1', 'Undo.ps1')) {
    . (Join-Path -Path (Join-Path -Path $toolkitRoot -ChildPath 'modules') -ChildPath $module)
}

# --- Dry run: print the plan, change nothing -----------------------------
# No admin rights or restore point needed - this mode only reads and prints.
if ($DryRun) {
    Write-Host ''
    Write-Host 'Win11 MinMax Toolkit - DRY RUN (nothing will be changed)'
    Write-Host ''
    Write-Host '  Debloat      Remove up to 16 preinstalled consumer apps (current user):'
    Write-Host '               Clipchamp, Solitaire, Bing News/Weather, Get Help, Tips, People,'
    Write-Host '               To Do, Feedback Hub, Office Hub, Skype, Candy Crush, Bubble Witch,'
    Write-Host '               Spotify, TikTok and Disney+ stubs. Missing apps are skipped.'
    Write-Host '  Privacy      Telemetry to Basic, advertising ID off, activity history off,'
    Write-Host '               inking/typing collection off, suggestions and consumer features off,'
    Write-Host '               feedback prompts off. (25 registry values)'
    Write-Host '  Performance  Game Mode on, Game DVR off, animation trimmed (ClearType kept),'
    Write-Host '               mouse precision off, Ultimate Performance on desktops only.'
    Write-Host '  Explorer     Extensions and hidden files shown, This PC start, dark mode,'
    Write-Host '               search icon, Widgets/Chat buttons off, long paths on.'
    Write-Host '  Undo         Every registry change above returns to its Windows default.'
    Write-Host ''
    Write-Host 'Run .\MinMax.ps1 without -DryRun to apply changes (a restore point is created first).'
    return
}

$logFile = Initialize-MinMaxLog -LogDirectory $toolkitRoot

Write-Host ''
Write-Host '=============================================='
Write-Host '  Win11 MinMax Toolkit v1.0.0'
Write-Host '  Min-max, but safe: reversible tweaks only.'
Write-Host '=============================================='
Write-Log -Message "Log file: $logFile"

# --- Safety checks -------------------------------------------------------
if (-not (Test-IsAdmin)) {
    Write-Log -Message 'Not running as Administrator. Right-click PowerShell, choose "Run as administrator", and run the script again. Nothing was changed.' -Level Error
    exit 1
}
Write-Log -Message 'Administrator check passed.' -Level OK

if (-not (Test-IsWindows11)) {
    Write-Log -Message 'This toolkit targets Windows 11 (build 22000+). Your build is older or could not be read. Nothing was changed.' -Level Error
    exit 1
}
Write-Log -Message 'Windows 11 check passed.' -Level OK

# --- Restore point first, or nothing happens -----------------------------
Write-Log -Message 'Creating a System Restore point before making any change...'
try {
    Enable-ComputerRestore -Drive "$env:SystemDrive\"
    Checkpoint-Computer -Description 'Win11 MinMax Toolkit - before changes' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
    Write-Log -Message 'Restore point created.' -Level OK
}
catch {
    Write-Log -Message "Restore point creation FAILED: $($_.Exception.Message)" -Level Error
    Write-Log -Message 'The toolkit refuses to change anything without a restore point. A common cause: Windows limits restore point creation to one per 24 hours - wait and run again tomorrow, or create one manually (Start > "Create a restore point"). Nothing was changed.' -Level Error
    exit 1
}

# --- Non-interactive modes ----------------------------------------------
if ($Undo) {
    Undo-All
    Write-Log -Message 'Done (Undo mode).'
    exit 0
}
if ($All) {
    Write-Log -Message 'Applying all modules: Debloat, Privacy, Performance, Explorer & taskbar.'
    Invoke-Debloat
    Invoke-Privacy
    Invoke-Performance
    Invoke-ExplorerSettings
    Write-Log -Message 'All modules applied. Restart the PC to finish.' -Level OK
    exit 0
}

$appliedAny = $false
function Confirm-Apply {
    param([Parameter(Mandatory = $true)][string]$Name)
    $answer = Read-Host -Prompt "Apply $Name now? Type Y to continue"
    return ($answer -eq 'Y' -or $answer -eq 'y')
}

# --- Menu -----------------------------------------------------------------
while ($true) {
    Write-Host ''
    Write-Host 'Win11 MinMax Toolkit'
    Write-Host '  1  Debloat             (remove preinstalled consumer apps)'
    Write-Host '  2  Privacy             (telemetry, ads, suggestions off)'
    Write-Host '  3  Performance         (game mode, effects, mouse, power plan)'
    Write-Host '  4  Explorer & taskbar  (extensions, dark mode, long paths)'
    Write-Host '  5  Undo menu           (revert to Windows defaults)'
    Write-Host '  0  Exit'
    $choice = Read-Host -Prompt 'Choose'
    switch ($choice) {
        '1' { if (Confirm-Apply -Name 'Debloat') { Invoke-Debloat; $appliedAny = $true } }
        '2' { if (Confirm-Apply -Name 'Privacy') { Invoke-Privacy; $appliedAny = $true } }
        '3' { if (Confirm-Apply -Name 'Performance') { Invoke-Performance; $appliedAny = $true } }
        '4' { if (Confirm-Apply -Name 'Explorer & taskbar') { Invoke-ExplorerSettings; $appliedAny = $true } }
        '5' { if (Confirm-Apply -Name 'Undo (revert to Windows defaults)') { Invoke-UndoMenu; $appliedAny = $true } }
        '0' {
            if ($appliedAny) {
                Write-Log -Message 'Exiting. Changes were applied this session - restart the PC to finish.' -Level OK
            } else {
                Write-Log -Message 'Exiting. Nothing was changed this session.'
            }
            return
        }
        default { Write-Log -Message "Unknown choice: $choice" -Level Warn }
    }
}
