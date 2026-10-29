# Undo.ps1 - reverses every registry change the toolkit makes, back to
# Windows defaults. Two honest limits:
#   * Removed Appx packages are NOT reinstalled by Undo - reinstall them
#     from the Microsoft Store (they are all free Store apps).
#   * The restore point MinMax.ps1 creates before running remains the
#     full-system safety net on top of this Undo.

function Undo-Privacy {
    Write-Log -Message '--- Undo: Privacy ---'

    # Policy values: deleting them returns Windows to its default behaviour.
    Remove-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry'
    Remove-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'EnableActivityFeed'
    Remove-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'PublishUserActivities'
    Remove-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'UploadUserActivities'
    Remove-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableWindowsConsumerFeatures'
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableTailoredExperiencesWithDiagnosticData'

    # Advertising ID back on (Windows default).
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 1 -Type DWord

    # Inking/typing personalisation back to defaults.
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Microsoft\Personalization\Settings' -Name 'AcceptedPrivacyPolicy'
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' -Name 'RestrictImplicitInkCollection'
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' -Name 'RestrictImplicitTextCollection'
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore' -Name 'HarvestContacts'

    # Suggested content / consumer features back to defaults (values removed).
    $cdm = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    foreach ($name in @(
        'ContentDeliveryAllowed', 'FeatureManagementEnabled', 'OemPreInstalledAppsEnabled',
        'PreInstalledAppsEnabled', 'PreInstalledAppsEverEnabled', 'SilentInstalledAppsEnabled',
        'SoftLandingEnabled', 'SubscribedContent-338387Enabled', 'SubscribedContent-338388Enabled',
        'SubscribedContent-338389Enabled', 'SubscribedContent-353694Enabled',
        'SubscribedContent-353696Enabled', 'SystemPaneSuggestionsEnabled')) {
        Remove-RegValue -Path $cdm -Name $name
    }

    # Feedback prompts back to default.
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' -Name 'NumberOfSIUFInPeriod'

    Write-Log -Message 'Privacy reverted to Windows defaults.' -Level OK
}

function Undo-Performance {
    Write-Log -Message '--- Undo: Performance ---'

    # Game Mode / Game DVR back to defaults.
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Microsoft\GameBar' -Name 'AutoGameModeEnabled'
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Microsoft\GameBar' -Name 'AllowAutoGameMode'
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 1 -Type DWord
    Remove-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' -Name 'AllowGameDVR'

    # Visual effects back to "let Windows choose" (values removed).
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting'
    Remove-RegValue -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name 'MinAnimate'
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations'
    # FontSmoothing is left as-is: ClearType on is the Windows default too.

    # Mouse pointer precision back on (Windows defaults: 1 / 6 / 10).
    Set-Reg -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed' -Value '1' -Type String
    Set-Reg -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1' -Value '6' -Type String
    Set-Reg -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2' -Value '10' -Type String

    # Power plan: if this toolkit switched a desktop to Ultimate
    # Performance, switch back to Balanced (the Windows default plan).
    $balancedGuid = '381b4222-f694-41f0-9685-ff5bb260df2e'
    if (Get-HasBattery) {
        Write-Log -Message 'Laptop: the toolkit never changed your power plan; nothing to revert.'
    }
    else {
        powercfg.exe /setactive $balancedGuid | Out-Null
        Write-Log -Message 'Power plan set back to Balanced (Windows default).'
    }

    Write-Log -Message 'Performance reverted to Windows defaults.' -Level OK
}

function Undo-ExplorerSettings {
    Write-Log -Message '--- Undo: Explorer & taskbar ---'

    $advanced = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

    # Defaults: extensions hidden (1), hidden files hidden (2),
    # Explorer opens to Home/Quick access (value removed = default).
    Set-Reg -Path $advanced -Name 'HideFileExt' -Value 1 -Type DWord
    Set-Reg -Path $advanced -Name 'Hidden' -Value 2 -Type DWord
    Remove-RegValue -Path $advanced -Name 'LaunchTo'

    # Light theme back on (Windows default).
    $personalize = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    Set-Reg -Path $personalize -Name 'AppsUseLightTheme' -Value 1 -Type DWord
    Set-Reg -Path $personalize -Name 'SystemUsesLightTheme' -Value 1 -Type DWord

    # Taskbar: search box, Widgets and Chat back to defaults (values removed).
    Remove-RegValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode'
    Remove-RegValue -Path $advanced -Name 'TaskbarDa'
    Remove-RegValue -Path $advanced -Name 'TaskbarMn'

    # Long paths back to the Windows default (off).
    Set-Reg -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 0 -Type DWord

    Write-Log -Message 'Explorer & taskbar reverted to Windows defaults.' -Level OK
}

function Undo-Debloat {
    Write-Log -Message '--- Undo: Debloat ---'
    Write-Log -Message 'Removed apps are not reinstalled automatically. Every app on the debloat list is a free Microsoft Store app - reinstall any of them from the Store (search the app name, Install).' -Level Warn
    Write-Log -Message 'Nothing else to do here: debloat only ever removed Store packages for the current user.' -Level OK
}

function Undo-All {
    Undo-Privacy
    Undo-Performance
    Undo-ExplorerSettings
    Undo-Debloat
    Write-Log -Message 'Undo complete. Restart to make sure every default is back in effect.' -Level OK
}

function Invoke-UndoMenu {
    while ($true) {
        Write-Host ''
        Write-Host 'Undo - revert to Windows defaults'
        Write-Host '  1  Privacy'
        Write-Host '  2  Performance'
        Write-Host '  3  Explorer & taskbar'
        Write-Host '  4  Debloat (shows reinstall note)'
        Write-Host '  5  Everything (1-4)'
        Write-Host '  0  Back'
        $choice = Read-Host -Prompt 'Choose'
        switch ($choice) {
            '1' { Undo-Privacy }
            '2' { Undo-Performance }
            '3' { Undo-ExplorerSettings }
            '4' { Undo-Debloat }
            '5' { Undo-All }
            '0' { return }
            default { Write-Log -Message "Unknown choice: $choice" -Level Warn }
        }
    }
}
