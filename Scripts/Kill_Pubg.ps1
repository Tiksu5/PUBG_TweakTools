#
#

# Kill PUBG
function Kill-PUBG {
    Get-ExecutionPolicy
    $proc = @(
        "ExecPubg.exe",
        "TslGame.exe",
        "TslGame_BE.exe",
        "TslGame_UC.exe",
        "zksvc.exe",
        "BEService.exe",
        "ucldr_battlegrounds_gl.exe"
    )

    Write-Host "Tapetaan PUBG prosessit"
    Write-Host "---------------"

    foreach ($process in $proc) {
        $result = Invoke-Expression "taskkill /F /IM $process /T 2>&1"
        if ($result -match "SUCCESS") {
            Write-Host "Stopped process: $process"
        } else {
            Write-Host "Process not found or unable to terminate: $process"
        }
    }
    # Suljetaan timer, jos semmonen löytyy
    if ($global:BootTimer -ne $null) {
        $global:BootTimer.Stop()
        $global:BootTimer.Dispose()
        $global:BootReminderTimeLeftLabel.Text = "Time left:"
    }
    Write-Host "---------------"
    Write-Host "PUBG tapettu"
    Write-Host "---------------"
    
}

# Tapetaan PUBGin Launcheri
function Kill-PUBGLauncher {
    # Tapetaan PUBG Launcher jos käynnissä
    if (Get-Process -Name "ExecPubg.exe" -ErrorAction SilentlyContinue) {
        Write-Host "Tapetaan PUBG launcher"
        Write-Host "---------------"
        Stop-Process -Name "ExecPubg.exe" -Force
        Write-Host "Stopped process: ExecPubg.exe"
    } else {
        Write-Host "Process not found or unable to terminate: ExecPubg.exe"
        Write-Host "Suljetaan skripti"
        return
    }
}

# Tapetaan Battleyen Launcheri (BattleEye service pysyy päällä!)
function Kill-BELauncher {
    # Tapetaan BE Launcher jos käynnissä
    if (Get-Process -Name "TslGame_BE" -ErrorAction SilentlyContinue) {
        Write-Host "Tapetaan BattleEye launcher"
        Write-Host "---------------"
        Stop-Process -Name "TslGame_BE.exe" -Force
        Write-Host "Stopped process: TslGame_BE.exe"
    } else {
        Write-Host "Process not found or unable to terminate: TslGame_BE.exe"
        Write-Host "Suljetaan skripti"
        return
    }
}
    

# Tapetaan vähemmän muistia käyttävä TslGame.exe prosessi, joka mahdollisesti aiheuttaa stutteria. Ei vaikuta pelin toimintaan negatiivisesti
function Kill-Duplicate {
    if ($script:instanceCount -gt 1) {
        if ($script:targetPID) {
            Write-Host "Ylimääränen prosessi löydetty"
            Write-Host "Tapetaan prosessi PID: $script:targetPID"
            Stop-Process -Id $script:targetPID -Force
        } else {
            Write-Host "Ei löydy prosessia TslGame.exe"
            Write-Host "Suljetaan skripti"
        }
        return
    } else {
        Write-Host "Vain yksi TslGame.exe prosessi löydetty"
        Write-Host "Suljetaan skripti"
        return
    }
}

# Määritetään tapettava prosessi muistin käytön mukaan.
function Check-Duplicate {
    Get-Process -Name "TslGame" | ForEach-Object {
        $script:instanceCount++
        $processID = $_.Id
        $memoryUsage = $_.WorkingSet / 1MB  # Convert to MB

        if (-not $script:minMemoryUsage) {
            $script:minMemoryUsage = $memoryUsage
            $script:targetPID = $processID
        } else {
            if ($memoryUsage -lt $script:minMemoryUsage) {
                $script:minMemoryUsage = $memoryUsage
                $script:targetPID = $processID
            }
        }
    }
}

# Loop kunnes löytyy toinen TslGame prosessi
function Kill-DuplicateLoop {
    $script:minMemoryUsage = $null
    $script:targetPID = $null
    $script:instanceCount = 0
    $script:loopCount = 1
    while ($script:loopCount -le 10) {
        Write-Host "TslGame.exe duplicate process check $($script:loopCount)/5"
        Start-Sleep -Seconds 5
        $script:instanceCount = 0
        Check-Duplicate
        if ($script:instanceCount -gt 1) {
            Kill-Duplicate
            return
        } else {
            Write-Host "Ylimäärästä prosessia ei löytynyt vielä"
            Write-Host "---------------"
            $script:loopCount++
        }
    }
    Write-Host "Ylimäärästä prosessia ei löytyny 5 yrityksen jälkeen"
    Write-Host "Suljetaan skripti"
}

# Start PUBG
function Start-PUBG {
    # Tarkistetaan löytyykö prosessi jo, jos ei niin käynnistetään.
    if (-not (Get-Process -Name "TslGame" -ErrorAction SilentlyContinue)) {
        if ($global:EnableLaunchSettingsCheckBox.Checked) {
            if ($global:DeleteMoviesAtStartCheckBox.Checked) {
                Delete-Movies -SkipConfirmation $true
                Start-Sleep -Seconds 1
            }
            if ($global:DeleteSavedAtStartCheckBox.Checked) {
                Clean-SavedFolder -SkipConfirmation $true
                Start-Sleep -Seconds 1
            }
            if ($global:ChangeObserverPackAtStartCheckBox.Checked) {
                Change-LogoPack
                Start-Sleep -Seconds 1
            }
            if ($global:BootReminderCheckBox.Checked) {        
                Boot-Timer
                Start-Sleep -Seconds 1
            }
        }
        Start-Process "steam://rungameid/578080"
        Write-Host "---------------"
        Write-Host "Käynnistetään PUBG"
        Start-Sleep -Seconds 20
        Write-Host "---------------"
        if ($global:EnableLaunchSettingsCheckBox.Checked) {
            if ($global:killExtraProcessCheckBox.Checked) {
                if ($global:KillDuplicateTslGameCheckBox.Checked) {
                    Kill-DuplicateLoop
                    Start-Sleep -Seconds 1
                }
                if ($global:PUBGLauncherCheckBox.Checked) {
                    Kill-PUBGLauncher
                    Start-Sleep -Seconds 1
                }
                if ($global:BELauncherCheckBox.Checked) {
                    Kill-BELauncher
                }
            }
        }
    } else {
        if ($global:EnableLaunchSettingsCheckBox.Checked) {
            if ($global:killExtraProcessCheckBox.Checked) {
                if ($global:KillDuplicateTslGameCheckBox.Checked) {
                    Check-Duplicate
                    Kill-Duplicate
                    Start-Sleep -Seconds 1
                }
                if ($global:PUBGLauncherCheckBox.Checked) {
                    Kill-PUBGLauncher
                    Start-Sleep -Seconds 1
                }
                if ($global:BELauncherCheckBox.Checked) {
                    Kill-BELauncher
                }
            }
        }
    }
}

# Restart PUBG
function Restart-PUBG {
    # Tapetaan prosessit
    Kill-PUBG
    Start-Sleep -Seconds 1
    # Tarkistetaan joko prosessi tapettu.
    $script:restartCheckCount = 1
    while ($script:restartCheckCount -le 10) {
        Write-Host "TslGame.exe process check $($script:restartCheckCount)/10"
        Start-Sleep -Seconds 2
        if (-not (Get-Process -Name "TslGame" -ErrorAction SilentlyContinue)) {
            if ($global:EnableLaunchSettingsCheckBox.Checked) {
                if ($global:DeleteMoviesAtStartCheckBox.Checked) {
                    Delete-Movies -SkipConfirmation $true
                    Start-Sleep -Seconds 1
                }
                if ($global:DeleteSavedAtStartCheckBox.Checked) {
                    Clean-SavedFolder -SkipConfirmation $true
                    Start-Sleep -Seconds 1
                }
                if ($global:ChangeObserverPackAtStartCheckBox.Checked) {
                    Change-LogoPack
                    Start-Sleep -Seconds 1
                }
                if ($global:BootReminderCheckBox.Checked) {        
                    Boot-Timer
                    Start-Sleep -Seconds 1
                }
            }
            Start-Process "steam://rungameid/578080"
            Write-Host "---------------"
            Write-Host "Käynnistetään PUBG"
            Start-Sleep -Seconds 20
            Write-Host "---------------"
            if ($global:EnableLaunchSettingsCheckBox.Checked) {
                if ($global:killExtraProcessCheckBox.Checked) {
                    if ($global:KillDuplicateTslGameCheckBox.Checked) {
                        Kill-DuplicateLoop
                        Start-Sleep -Seconds 1
                    }
                    if ($global:PUBGLauncherCheckBox.Checked) {
                        Kill-PUBGLauncher
                        Start-Sleep -Seconds 1
                    }
                    if ($global:BELauncherCheckBox.Checked) {
                        Kill-BELauncher
                    }
                }
            }
            return
        } else {
            Write-Host "Prosessi vielä käynnissä"
            Write-Host "---------------"
            $script:restartCheckCount++
        }
        Write-Host "Prosessi vielä käynnissä 10 yrityksen jälkeen"
        Write-Host "Suljetaan skripti"
        Write-Host "---------------"
    }
}
