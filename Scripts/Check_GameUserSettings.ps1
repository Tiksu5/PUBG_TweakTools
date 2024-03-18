#
#Haetaan settarit configista ja tarkistetaan tiedossa olevat bugiset arvot.

# Haetaan Arvot Configista
function GetValues-GameUserSettings {

    # Testaa Path
    if (-not (Test-Path -Path $global:GameUserSettingsPath -PathType Leaf)) {
        [System.Windows.Forms.MessageBox]::Show("Polkua ei löydy: $global:GameUserSettingsPath") 
        return
    }

    $FileContent = Get-Content -Path $global:GameUserSettingsPath -Raw
    
    #Hae keywordeille arvot ja ignore arvot riviltä joka alkaa "TslPersistantData"
    foreach ($Keyword in $global:Keywords) {
        $ConcatenatedContent = $FileContent -join "`n"
        $Pattern = "$Keyword([\w\.]+)"
        $Lines = $ConcatenatedContent -split "`n"
        $found = $false

        foreach ($Line in $Lines) {
            if ($Line -notmatch "TslPersistantData" -and $Line -match $Pattern) {
                $Value = $Line | Select-String -Pattern $Pattern | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
                $global:KeywordValues[$Keyword] = $Value
                $found = $true
                break  
            }
        }
        #talteen settarit joita ei löytyny configista
        if (-not $found) {
            $global:KeywordsNotFound += $Keyword
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
    <# SCOPE SENSSIT FIXATTU PATCHIS 28.2
    # Check Scope senssit
    $ScopeCheckFail = $false
    $UniversalScopeCheckFail = $false
    $PerScope = [double]$global:KeywordValues['"bIsUsingPerScopeMouseSensitivity="']

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
    if ([double]$global:KeywordValues['"ScopingMagnified",Sensitivity='] -lt 22.000000){
        $global:FailingKeywords += '"ScopingMagnified",Sensitivity='
        $UniversalScopeCheckFail = $true
    }

    if (($ScopeCheckFail -and $PerScope) -or ($UniversalScopeCheckFail -and -not $PerScope)){
        $global:CheckScopeSensLabel.Text = "Scope: NOT OK"
        $global:CheckScopeSensLabel.BackColor = [System.Drawing.Color]::Red
    } elseif ($ScopeCheckFail -and -not $PerScope){
        $global:CheckScopeSensLabel.Text = "Scope: OK"
        $global:CheckScopeSensLabel.BackColor = [System.Drawing.Color]::Yellow
        $global:ToolTip.SetToolTip($global:CheckScopeSensLabel, "Joku perscope sensseistä on liian pieni, mutta universal scope sens käytössä ja se on OK")
    } elseif ($UniversalScopeCheckFail -and $PerScope){
        $global:CheckScopeSensLabel.Text = "Scope: OK"
        $global:CheckScopeSensLabel.BackColor = [System.Drawing.Color]::Yellow
        $global:ToolTip.SetToolTip($global:CheckScopeSensLabel, "Universal scope senssi liian pieni, mutta per scope senssit käytössä ja on OK")
    } else {
        $global:CheckScopeSensLabel.Text = "Scope: OK"
        $global:CheckScopeSensLabel.BackColor = [System.Drawing.Color]::Green
    }
   #>

}

