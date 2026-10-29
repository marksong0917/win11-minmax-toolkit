# Privacy.ps1 - the "recommended settings" class of privacy toggles, the
# same conservative set the guide applies with O&O ShutUp10++ (green items
# only). Every value here is a normal registry toggle and is fully reversed
# by Undo.ps1.

function Invoke-Privacy {
    Write-Log -Message '--- Privacy: telemetry, ads, suggestions and feedback off ---'

    # Telemetry: basic level (policy). 1 = Basic. This is the lowest level
    # Windows offers outside of enterprise "Security" mode; diagnostics are
    # reduced, not faked or blocked by hosts-file tricks.
    Set-Reg -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 1 -Type DWord

    # Advertising ID: apps can no longer use it to personalise ads.
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0 -Type DWord

    # Activity history / Timeline: stop recording and uploading activity.
    Set-Reg -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'EnableActivityFeed' -Value 0 -Type DWord
    Set-Reg -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'PublishUserActivities' -Value 0 -Type DWord
    Set-Reg -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'UploadUserActivities' -Value 0 -Type DWord

    # Inking & typing personalisation: stop sending ink/typed samples and
    # stop building a personal dictionary from typing.
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\Personalization\Settings' -Name 'AcceptedPrivacyPolicy' -Value 0 -Type DWord
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' -Name 'RestrictImplicitInkCollection' -Value 1 -Type DWord
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' -Name 'RestrictImplicitTextCollection' -Value 1 -Type DWord
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore' -Name 'HarvestContacts' -Value 0 -Type DWord

    # Suggested content, consumer features and silent app installs:
    # no app suggestions in Start/Settings, no promoted apps quietly
    # installed, no "suggested content" in the Settings app.
    $cdm = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    Set-Reg -Path $cdm -Name 'ContentDeliveryAllowed' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'FeatureManagementEnabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'OemPreInstalledAppsEnabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'PreInstalledAppsEnabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'PreInstalledAppsEverEnabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'SilentInstalledAppsEnabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'SoftLandingEnabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'SubscribedContent-338387Enabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'SubscribedContent-338388Enabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'SubscribedContent-338389Enabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'SubscribedContent-353694Enabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'SubscribedContent-353696Enabled' -Value 0 -Type DWord
    Set-Reg -Path $cdm -Name 'SystemPaneSuggestionsEnabled' -Value 0 -Type DWord

    # Same promise at policy level (also stops Windows consumer features
    # such as promoted third-party apps for every user on the machine).
    Set-Reg -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableWindowsConsumerFeatures' -Value 1 -Type DWord
    Set-Reg -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableTailoredExperiencesWithDiagnosticData' -Value 1 -Type DWord

    # Feedback prompts: Windows stops asking for feedback (SIUF).
    Set-Reg -Path 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' -Name 'NumberOfSIUFInPeriod' -Value 0 -Type DWord

    Write-Log -Message 'Privacy done. Sign out or restart for every toggle to take effect.' -Level OK
}
