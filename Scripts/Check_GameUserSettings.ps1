# v0.1
# Todo: Tee funktio(t?) toistuville checkeille

# Haetaan Arvot Configista
function GetValues-GameUserSettings {

    # Testaa Path
    if (-not (Test-Path -Path $global:GameUserSettingsPath -PathType Leaf)) {
        [System.Windows.Forms.MessageBox]::Show("Polkua ei löydy: $global:GameUserSettingsPath") 
        return
    }

    $FileContent = Get-Content -Path $global:GameUserSettingsPath -Raw
    $KeywordsMultipleMatch = @("MouseVerticalSensitivityMultiplierAdjusted=", "ColorBlindType=")

    <## TARVII JONKU ERI CHECKIN. KÄYTTÖÖN VASTA "UPLOAD SETTINGS TO CLOUD" VAIHEES
    "bUseVsync=", "bIsEnabledHrtfRemoteWeaponSound=", "bUseInGameSmoothedFrameRate=", "bMotionBlur=", "bSharpen=",
    "InputModeCrouch=", "InputModeProne=", "InputModeWalk=", "bToggleSprint=", "InputModeHoldRotation=", "InputModeHoldBreath=",
    "InputModeHoldAngled=", "InputModePeek=", "InputModeMap=", "InputModeADS=", "InputModeAim="
    #>
    
    
    # get-Arvot keywordeille, joille loytyy useampi match configista.
    $FileContent -split "`r`n" | ForEach-Object {
        $Line = $_.Trim()
    
        if ($Line -match 'MouseVerticalSensitivityMultiplierAdjusted=(\d+\.\d+)') {
            $Value = $Matches[1]
            $global:KeywordValues["MouseVerticalSensitivityMultiplierAdjusted="] = $Value
        }
        if ($Line -match 'ColorBlindType=(\d+)') {
            $Value = $Matches[1]
            $global:KeywordValues["ColorBlindType="] = $Value
        }
    }
    
    foreach ($Keyword in $global:Keywords) {
        if ($Keyword -notin $KeywordsMultipleMatch) {
            $Value = $FileContent | Select-String -Pattern "$Keyword([\d\.]+)" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
            $global:KeywordValues[$Keyword] = $Value
        }
   
            # Check Desimaalit
            if ($Keyword -in $global:KeywordsDecimalsToCheck) {
                if ($Value -notlike "*.000000") {
                    $Value = "WARNING: $Value"
                    $global:FailingKeywords += $Keyword
                    $global:CheckDecimalsLabel.Text = "Desimaalit: NOT OK"
                    $global:CheckDecimalsLabel.BackColor = [System.Drawing.Color]::Red
                 } else { 
                    $global:CheckDecimalsLabel.Text = "Desimaalit: OK"
                    $global:CheckDecimalsLabel.BackColor = [System.Drawing.Color]::Green
            }
        }
    }

      $ScopeCheckFail = $false
        # Check Scope senssit
    if ([double]$global:KeywordValues['"Scope6X",Sensitivity='] -lt 7.000000){
            $global:FailingKeywords += '"Scope6X",Sensitivity='
            $ScopeCheckFail = $true
            }

    if ([double]$global:KeywordValues['"Scope8X",Sensitivity='] -lt 13.000000){
            $global:FailingKeywords += '"Scope8X",Sensitivity='
            $ScopeCheckFail = $true
            }

    if ([double]$global:KeywordValues['"Scope15X",Sensitivity='] -lt 22.000000){
            $global:FailingKeywords += '"Scope15X",Sensitivity='
            $ScopeCheckFail = $true
            }

            if ($ScopeCheckFail) {
                $global:CheckScopeSensLabel.Text = "Scope: NOT OK"
                $global:CheckScopeSensLabel.BackColor = [System.Drawing.Color]::Red
            } else {
                $global:CheckScopeSensLabel.Text = "Scope: OK"
                $global:CheckScopeSensLabel.BackColor = [System.Drawing.Color]::Green
        }
   
    
    <# Debug
        foreach ($Keyword in $global:Keywords) {
        Write-Host "$Keyword$($global:KeywordValues[$Keyword])"
        Write-Host "-----------------"
        }
    # Debug#>
}

