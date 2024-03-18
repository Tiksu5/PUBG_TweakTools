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
    Write-Host "---------------"
    Write-Host "PUBG tapettu"
    
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

# HMääritetään tapettava prosessi muistin käytön mukaan.
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
function Loop-Check {
    while ($script:loopCount -le 5) {
        Write-Host "TslGame.exe duplicate process check $($script:loopCount)/5"
        Start-Sleep -Seconds 10
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
    $script:minMemoryUsage = $null
    $script:targetPID = $null
    $script:instanceCount = 0
    $script:loopCount = 1
    # Tarkistetaan löytyykö prosessi jo, jos ei niin käynnistetään.
    if (-not (Get-Process -Name "TslGame" -ErrorAction SilentlyContinue)) {
        Start-Process "steam://rungameid/578080"
        Write-Host "---------------"
        Write-Host "Käynnistetään PUBG"
        Start-Sleep -Seconds 20
        Write-Host "---------------"
        Loop-Check
    } else {
        Check-Duplicate
        Kill-Duplicate
    }
}

       









