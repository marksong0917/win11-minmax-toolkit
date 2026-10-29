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
    [switch]$Undo
)

$toolkitRoot = $PSScriptRoot
foreach ($module in @('Common.ps1', 'Debloat.ps1', 'Privacy.ps1', 'Performance.ps1', 'Explorer.ps1', 'Undo.ps1')) {
    . (Join-Path -Path (Join-Path -Path $toolkitRoot -ChildPath 'modules') -ChildPath $module)
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
    Invoke-Debloat
    Invoke-Privacy
    Invoke-Performance
    Invoke-ExplorerSettings
    Write-Log -Message 'All modules applied. Restart the PC to finish.' -Level OK
    exit 0
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
        '1' { Invoke-Debloat }
        '2' { Invoke-Privacy }
        '3' { Invoke-Performance }
        '4' { Invoke-ExplorerSettings }
        '5' { Invoke-UndoMenu }
        '0' {
            Write-Log -Message 'Exiting. Restart the PC if you applied changes.'
            return
        }
        default { Write-Log -Message "Unknown choice: $choice" -Level Warn }
    }
}
