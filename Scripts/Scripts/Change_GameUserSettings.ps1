#
# Todo: Textbox formating, Korjaa save (atm korvaa kaiken datan configista eikä pelkkiä arvoja)

# Tulosta arvot, ilmota virheistä, muuta arvot jnejne. työnalla
function ChangeValues-GameUserSettings {
    $ColumnWidth = 400
    $LabelX = 20
    $TextBoxX = 20
    $ControlHeight = 10
    $Spacing = 10

    # Asetusikkuna
    $ChangeForm = New-Object Windows.Forms.Form -Property @{
        Text = "Modify Game User Settings"
        Size = New-Object Drawing.Size(800, 1000)
    }

    # Tehää boxeja X määrä
    # Rajattu kriittisiin pelissä bugaviin arvoihin for now. Myöhemmin full customisation.
    $TextBoxes1 = @()
    $LabelXCounter = 0

    for ($i = 0; $i -lt $global:Keywords.Count; $i++) {
    $Keyword = $global:Keywords[$i]
    
        if ($Keyword -in $global:KeywordsDecimalsToCheck -or $Keyword -in $global:KeywordsScopesToCheck) {
            $Label1 = New-Object Windows.Forms.Label -Property @{
                Text = $Keyword
                Location = [System.Drawing.Point]::new($LabelX, 20 + $i * ($ControlHeight + $Spacing))
                Size = New-Object Drawing.Size(250, 20)
            }
        
            $ChangeForm.Controls.Add($Label1)

            $TextBox1 = New-Object Windows.Forms.TextBox -Property @{
                Location = [System.Drawing.Point]::new($TextBoxX, 40 + $i * ($ControlHeight + $Spacing))
                Size = New-Object Drawing.Size(150, 20)
            }
            $TextBox1.Text = $global:KeywordValues[$global:Keywords[$i]]
            if ($Keyword -in $global:FailingKeywords -or ('"' + $Keyword + '"') -in $global:FailingKeywords) {
                $TextBox1.BackColor = [System.Drawing.Color]::Red
            } elseif ($Keyword -in $global:KeywordsNotFound -or ('"' + $Keyword + '"') -in $global:KewywordsNotFound) {
                $TextBox1.BackColor = [System.Drawing.Color]::Yellow
                $TextBox1.Text = "Ei löydy"
            } else {
                $TextBox1.BackColor = [System.Drawing.Color]::Green
            }

            $ChangeForm.Controls.Add($TextBox1)
        }
        # Array Boxeille
        $TextBoxes1 += $TextBox1

        $LabelXCounter++



        # Yritetää mahuttaa Boxit Formiin
        if ($LabelXCounter -ge ($ChangeForm.Width / $ColumnWidth)) {
            $LabelXCounter = 0
            $LabelX = 20
            $TextBoxX = 20
        } else {
            $LabelX += $ColumnWidth
            $TextBoxX += $ColumnWidth
        }
    }

    # Save
    $SaveButton = New-Object Windows.Forms.Button -Property @{
        Text = "Apply"
        Location = New-Object Drawing.Point(680, 50)
        Size = New-Object Drawing.Size(80, 20)
    }
   <# $SaveButton.Add_Click({ 
        for ($i = 0; $i -lt $global:Keywords.Count; $i++) {
            $Keyword = $global:Keywords[$i]
            if ($Keyword -in $global:KeywordsDecimalsToCheck -or $Keyword -in $global:KeywordsScopesToCheck) {
                $ModifiedValue = $TextBoxes1[$i].Text
                
        # Debug
            Write-Host "---------"
            Write-Host "Keyword: $Keyword"
            Write-Host "Modified Value: $ModifiedValue"           
            Write-Host "Path: $global:GameUserSettingsPath"         
            Write-Host "Value: $Keyword $ModifiedValue"
            Write-Host "---------"
        # Debug 
            
            Set-Content -Path $global:GameUserSettingsPath -Value "$Keyword=$ModifiedValue" -Force
            }
        }

    })
    #>
    $ChangeForm.Controls.Add($SaveButton)

    # Cancel
    $CancelButton = New-Object Windows.Forms.Button -Property @{
        Text = "Cancel"
        Location = New-Object Drawing.Point(680, 90)
        Size = New-Object Drawing.Size(80, 20)
    }
    $CancelButton.Add_Click({ 
        $ChangeForm.Close() 
    })
        
    $ChangeForm.Controls.Add($CancelButton)

    $ChangeForm.ShowDialog()
}