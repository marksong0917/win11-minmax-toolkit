# Performance.ps1 - four things only, exactly as the guide prescribes:
#   1. Game Mode on, Game DVR (background recording) off
#   2. Visual effects trimmed, font smoothing (ClearType) kept on
#   3. Mouse pointer precision (Enhance pointer precision) off
#   4. Power plan: Ultimate Performance on DESKTOPS only. Laptops are left
#      on Balanced - Ultimate Performance buys heat and fan noise there,
#      not speed. If a battery is detected, nothing is changed.
# Memory Integrity / Core Isolation is NOT touched by this toolkit.

function Invoke-Performance {
    Write-Log -Message '--- Performance ---'

    # 1. Game Mode on + Game DVR off
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\GameBar' -Name 'AutoGameModeEnabled' -Value 1 -Type DWord
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Value 1 -Type DWord
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0 -Type DWord
    Set-Reg -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' -Name 'AllowGameDVR' -Value 0 -Type DWord

    # 2. Visual effects: custom profile (3) so individual choices apply.
    #    Window/taskbar animation off; font smoothing explicitly kept on.
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Value 3 -Type DWord
    Set-Reg -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name 'MinAnimate' -Value '0' -Type String
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -Value 0 -Type DWord
    Set-Reg -Path 'HKCU:\Control Panel\Desktop' -Name 'FontSmoothing' -Value '2' -Type String
    Set-Reg -Path 'HKCU:\Control Panel\Desktop' -Name 'FontSmoothingType' -Value 2 -Type DWord

    # 3. Mouse: pointer precision (acceleration) off - 1:1 movement.
    Set-Reg -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed' -Value '0' -Type String
    Set-Reg -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1' -Value '0' -Type String
    Set-Reg -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2' -Value '0' -Type String

    # 4. Power plan - desktops only.
    $ultimateGuid = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
    if (Get-HasBattery) {
        Write-Log -Message 'Battery detected (laptop): power plan left unchanged. Stay on Balanced - see Section 4 of the guide.' -Level Warn
    }
    else {
        Write-Log -Message 'No battery detected (desktop): enabling Ultimate Performance plan.'
        $planList = powercfg.exe /list | Out-String
        if ($planList -notmatch 'Ultimate Performance') {
            powercfg.exe /duplicatescheme $ultimateGuid | Out-Null
        }
        powercfg.exe /setactive $ultimateGuid | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Log -Message 'Ultimate Performance plan is now active.' -Level OK
        }
        else {
            Write-Log -Message 'powercfg could not activate the plan; set it manually in Settings > System > Power.' -Level Warn
        }
    }

    Write-Log -Message 'Performance done.' -Level OK
}
