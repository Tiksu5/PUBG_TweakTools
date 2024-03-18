#
#

# Boot reminder to prevent 3-4h crash
function Boot-Timer {
    # Tarkistetaan onko peli päällä ennenku resetataan timer
    if (-not (Get-Process -Name "TslGame" -ErrorAction SilentlyContinue)) {
        # Suljetaan timer, jos semmonen löytyy
        if ($global:BootTimer -ne $null) {
            $global:BootTimer.Stop()
            $global:BootTimer.Dispose()
        }
        # Make timer
        $global:BootTimer = New-Object System.Windows.Forms.Timer
        $global:BootTimerSelectedItem = $global:BootReminderSelect.SelectedItem
        $global:BootTimer.Interval = 60000 # 1 minuutti
        $global:CountDown = $($global:BootTimerSelectedItem * 60 - 1) # Minuuteiksi
     #   $global:hours = [math]::Floor($global:CountDown / 3600) # Tunneiksi
     #   $global:minutes = [math]::Floor(($global:CountDown % 3600) / 60) # Minuuteiksi

        # Kun timer loppuu, sammuta se ja play restart sound.
        $global:BootTimer.add_Tick({
            # Tarkistetaan onko peli vielä päällä. Jos ei nii sammutetaa Timer.
            if (-not (Get-Process -Name "TslGame" -ErrorAction SilentlyContinue)) {
                $global:BootTimer.Stop()
                $global:BootTimer.Dispose()
                $global:BootReminderTimeLeftLabel.Text = "Time left:"
                return
            }
     #       $global:BootReminderTimeLeftLabel.Text = "Time left: $($hours)h $($minutes)m"
            $global:BootReminderTimeLeftLabel.Text = "Time left: $($global:CountDown)min"
            $global:BootReminderTimeLeftLabel.BackColor = [System.Drawing.Color]::White
            if ($global:CountDown -le 0) {
                $global:BootTimer.Stop()
                $global:BootTimer.Dispose()
                $RestartSoundFilePath = Join-Path $global:DefaultSoundsLocation "Restart.mp3"
                $MediaPlayer = [Windows.Media.Playback.MediaPlayer, Windows.Media, ContentType = WindowsRuntime]::New()
                $MediaPlayer.Source = [Windows.Media.Core.MediaSource]::CreateFromUri($RestartSoundFilePath)
                $MediaPlayer.Play()
                $global:BootReminderTimeLeftLabel.Text = "Time to Restart"
                $global:BootReminderTimeLeftLabel.BackColor = [System.Drawing.Color]::Red
            } else {
            $global:CountDown -= 1
            }
        })
        $global:BootTimer.Start()
            $global:BootReminderTimeLeftLabel.Text = "Time left: $($global:BootTimerSelectedItem * 60)min"
            Write-Host "Timer started. Interval: $($global:BootTimer.Interval) milliseconds"
    }
}
