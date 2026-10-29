# Explorer.ps1 - File Explorer and taskbar preferences. Personal-preference
# tweaks, all plain registry values, all reversed by Undo.ps1.

function Invoke-ExplorerSettings {
    Write-Log -Message '--- Explorer & taskbar ---'

    $advanced = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

    # Show file extensions (HideFileExt 0 = extensions visible).
    Set-Reg -Path $advanced -Name 'HideFileExt' -Value 0 -Type DWord
    # Show hidden files (Hidden 1 = show). A common developer preference;
    # protected operating-system files stay hidden either way.
    Set-Reg -Path $advanced -Name 'Hidden' -Value 1 -Type DWord
    # File Explorer opens to This PC instead of Home/Quick access.
    Set-Reg -Path $advanced -Name 'LaunchTo' -Value 1 -Type DWord

    # Dark mode for apps and system UI.
    $personalize = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    Set-Reg -Path $personalize -Name 'AppsUseLightTheme' -Value 0 -Type DWord
    Set-Reg -Path $personalize -Name 'SystemUsesLightTheme' -Value 0 -Type DWord

    # Taskbar: search collapses to an icon (1), Widgets button off,
    # consumer Chat/Teams icon off.
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 1 -Type DWord
    Set-Reg -Path $advanced -Name 'TaskbarDa' -Value 0 -Type DWord
    Set-Reg -Path $advanced -Name 'TaskbarMn' -Value 0 -Type DWord

    # Long path support (260-character limit lifted for aware apps).
    Set-Reg -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1 -Type DWord

    Write-Log -Message 'Explorer & taskbar done. Explorer restarts itself; if the taskbar does not update, sign out and back in.' -Level OK
}
