# Debloat.ps1 - removes a conservative list of preinstalled consumer apps
# for the current user. Nothing here touches system components, the Store,
# Windows Update, Defender, or anything a Windows feature depends on.
# Anything not installed is skipped quietly. Removed apps can be reinstalled
# from the Microsoft Store at any time.

function Invoke-Debloat {
    Write-Log -Message '--- Debloat: removing preinstalled consumer apps (current user) ---'

    # Package-name patterns matched against Get-AppxPackage -Name.
    # Consumer stubs, bundled games and trial apps only.
    $patterns = @(
        '*Clipchamp*'                             # Clipchamp video editor stub
        'Microsoft.MicrosoftSolitaireCollection'  # Solitaire & casual games
        'Microsoft.BingNews'                      # News stub
        'Microsoft.BingWeather'                   # Weather stub
        'Microsoft.GetHelp'                       # Get Help stub
        'Microsoft.Getstarted'                    # Tips stub
        'Microsoft.People'                        # People (contacts hub)
        'Microsoft.Todos'                         # Microsoft To Do stub
        'Microsoft.WindowsFeedbackHub'            # Feedback Hub
        'Microsoft.MicrosoftOfficeHub'            # Office hub stub
        'Microsoft.SkypeApp'                      # Consumer Skype stub
        '*CandyCrush*'                            # Candy Crush games
        '*BubbleWitch*'                           # Bubble Witch games
        '*SpotifyMusic*'                          # Spotify stub
        '*TikTok*'                                # TikTok stub
        '*Disney*'                                # Disney+ stub
    )

    $removed = 0
    foreach ($pattern in $patterns) {
        $packages = Get-AppxPackage -Name $pattern -ErrorAction SilentlyContinue
        if (-not $packages) {
            Write-Log -Message "Not present, skipped: $pattern"
            continue
        }
        foreach ($pkg in $packages) {
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
                Write-Log -Message "Removed: $($pkg.Name)" -Level OK
                $removed++
            }
            catch {
                Write-Log -Message "Could not remove $($pkg.Name): $($_.Exception.Message)" -Level Warn
            }
        }
    }
    Write-Log -Message "Debloat done. Removed $removed package(s). Reinstall any of them from the Microsoft Store." -Level OK
    Write-Log -Message 'Note: removal is for the current user. Provisioned copies can still appear for NEW user accounts - that is deliberate (removing provisioned packages is where debloat tools start breaking Windows).' -Level Warn
}
