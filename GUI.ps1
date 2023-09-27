# v0.1

$global:ProgramName = "PUBG: BATTLEGROUNDS"
# function Set-ProgramPath päivittää ProgramPathin
$global:ProgramPath = "null"
$global:GameUserSettingsPath = "$env:LOCALAPPDATA\TslGame\Saved\Config\WindowsNoEditor\GameUserSettings.ini"
$global:SavedFolderPath = "$env:LOCALAPPDATA\TslGame\Saved"
$global:GameUserSettingsPath = "$env:LOCALAPPDATA\TslGame\Saved\Config\WindowsNoEditor\GameUserSettings.ini"
$global:Keywords = @( "sg.ResolutionQuality=", "ScreenScale=", "InGameCustomFrameRateLimit=", "MasterSoundVolume=", "EffectSoundVolume=",
                        "EmoteSoundVolume=", "UISoundVolume=", "BGMSoundVolume=", "PlaygroundBGMSoundVolume=", "PlaygroundWebSoundVolume=",
                        "FpsCameraFov=", "Gamma=", '"Baltic_Main", ', '"Desert_Main", ', '"Savage_Main", ', '"DihorOtok_Main", ',
                        '"Summerland_Main", ', '"Chimera_Main", ', '"Tiger_Main", ', '"Kiki_Main", ', '"Heaven_Main", ', '"Normal",Sensitivity=',
                        '"Targeting",Sensitivity=', '"Scoping",Sensitivity=', '"ScopingMagnified",Sensitivity=', '"Scope2X",Sensitivity=',
                        '"Scope3X",Sensitivity=', '"Scope4X",Sensitivity=', '"Scope6X",Sensitivity=', '"Scope8X",Sensitivity=', '"Scope15X",Sensitivity=',
                        "MouseVerticalSensitivityMultiplierAdjusted=", "ResolutionSizeX=", "ResolutionSizeY=", "FullscreenMode=", "ColorBlindType=",
                        "sg.ViewDistanceQuality=", "sg.AntiAliasingQuality=", "sg.ShadowQuality=", "sg.PostProcessQuality=", "sg.TextureQuality=",
                        "sg.EffectsQuality=", "sg.FoliageQuality=")

$global:KeywordsDecimalsToCheck = @("sg.ResolutionQuality=", "ScreenScale=", "InGameCustomFrameRateLimit=", "MasterSoundVolume=", "EffectSoundVolume=",
                                    "EmoteSoundVolume=", "UISoundVolume=", "BGMSoundVolume=", "PlaygroundBGMSoundVolume=", "PlaygroundWebSoundVolume=",
                                    "FpsCameraFov=", "Gamma=", '"Baltic_Main", ', '"Desert_Main", ', '"Savage_Main", ', '"DihorOtok_Main", ',
                                    '"Summerland_Main", ', '"Chimera_Main", ', '"Tiger_Main", ', '"Kiki_Main", ', '"Heaven_Main", ')

$global:KeywordsScopesToCheck = @('"Scope6X",Sensitivity=', '"Scope8X",Sensitivity=', '"Scope15X",Sensitivity=')
# Hashtable arvoille
$global:KeywordValues = @{}
# Array Configin settareille, jotka pielessä.
$global:FailingKeywords = @() 

        <# 
        Alias Test

        "sg.ResolutionQuality=" = "Resolution Quality"
        "ScreenScale=" = "Screen Scale"
        "FullscreenMode=" = "Display Mode"
        "ResolutionSizeX=" = "Resolution X"
        "ResolutionSizeY=" = "Resolution Y"
        "ColorBlindType=" = "Colorblind Mode"
        "InGameCustomFrameRateLimit=" = "FPS Limit"
        "FpsCameraFov=" = "Field of View"
        "sg.ViewDistanceQuality=" = "View Distance"
        "sg.AntiAliasingQuality=" = "Anti Aliasing"
        "sg.ShadowQuality=" = "Shadows"
        "sg.PostProcessQuality=" = "Post Processing"
        "sg.TextureQuality=" = "Textures"
        "sg.EffectsQuality=" = "Effects" 
        "sg.FoliageQuality=" = "Foliage"
        "MasterSoundVolume=" = "Master Volume"
        "EffectSoundVolume=" = "Effects Volume"
        "EmoteSoundVolume=" = "Emote Voume"
        "UISoundVolume=" = "UI Volume"
        "BGMSoundVolume=" = "BGM Volume"
        "PlaygroundBGMSoundVolume=" = "Training BGM Volume"
        "PlaygroundWebSoundVolume=" = "Training Web Volume"
        "Gamma=" = "Universal Brightness"
        '"Baltic_Main", ' = "Erangel Brightness"
        '"Desert_Main", ' = "Miramar Brightness"
        '"Savage_Main", ' = "Sanhok Brightness"
        '"DihorOtok_Main", ' = "Vikendi Brightness"
        '"Summerland_Main", ' = "Karakin Brightness" 
        '"Chimera_Main", ' = "Paramo Brightness"
        '"Tiger_Main", ' = "Taego Brightness"
        '"Kiki_Main", ' = "Deston Brightness"
        '"Heaven_Main", ' = "Haven Brightness" 
        '"Normal",Sensitivity=' = "Hipfire Sensitivity"
        '"Targeting",Sensitivity=' = "Aim Sensitivity"
        '"Scoping",Sensitivity=' = "ADS Sensitivity"
        '"ScopingMagnified",Sensitivity=' = "Universal Scope Sensitivity"
        '"Scope2X",Sensitivity=' = "2X Sensitivity"
        '"Scope3X",Sensitivity=' = "3X Sensitivity"
        '"Scope4X",Sensitivity=' = "4X Sensitivity"
        '"Scope6X",Sensitivity=' = "6X Sensitivity"
        '"Scope8X",Sensitivity=' = "8X Sensitivity"
        '"Scope15X",Sensitivity=' = "15X Sensitivity"
        "MouseVerticalSensitivityMultiplierAdjusted=" = "Vertical Multiplier"
        }
        #>


# Scripts
   . .\Scripts\Find_Path.ps1
   . .\Scripts\Delete_Movies.ps1
   . .\Scripts\Clean_SavedFolder.ps1
   . .\Scripts\Check_GameUserSettings.ps1
   . .\Scripts\Change_GameUserSettings.ps1

Add-Type -AssemblyName System.Windows.Forms

# Functions
   function Set-ProgramPath {
    param(
        [string]$NewPath
        )
    $Script:ProgramPath = $NewPath
}

# Form
$Form = New-Object Windows.Forms.Form -Property @{
Text = "Tiksu Tweak Tools v0.1"
Size = New-Object Drawing.Size(600, 600)
}

# Path_Label
$global:MainPathLabel = New-Object Windows.Forms.Label -Property @{
    Text = "Asennuspolku:"
    Location = New-Object Drawing.Point(20, 20)
    Size = New-Object Drawing.Size(400, 20)
    }
$Form.Controls.Add($global:MainPathLabel)

# Path Change Textbox
$TextBox1 = New-Object Windows.Forms.TextBox -Property @{
    Location = New-Object Drawing.Point(20, 40)
    Size = New-Object Drawing.Size(250, 20)
    }
$Form.Controls.Add($TextBox1)

# Button1 Muuta polku
$Button1 = New-Object Windows.Forms.Button -Property @{
    Text = "Muuta polku"
    Location = New-Object Drawing.Point(280, 40)
    Size = New-Object Drawing.Size(75, 20)
    }
$Button1.Add_Click({
      # Testaa Path
    if (-not (Test-Path -Path $TextBox1.Text -PathType Container)) {
        [System.Windows.Forms.MessageBox]::Show("Polkua ei löydy: $($TextBox1.Text) ") 
        return
        }
    Set-ProgramPath -NewPath $TextBox1.Text
    $global:MainPathLabel.Text = "Asennuspolku löydetty: $global:ProgramPath"
    $global:MainPathLabel.BackColor = [System.Drawing.Color]::Green
    })
$Form.Controls.Add($Button1)

# Label2 Poista Videot 
$Label2 = New-Object Windows.Forms.Label -Property @{
    Text = "Poista videot, jotta peli käynnistyy nopeampaa."
    Location = New-Object Drawing.Point(20, 70)
    Size = New-Object Drawing.Size(250, 20)
}
$Form.Controls.Add($Label2)

# Label3 Poista Videot Done
$Label3 = New-Object Windows.Forms.Label -Property @{
    Text = ""
    Location = New-Object Drawing.Point(100, 90)
    Size = New-Object Drawing.Size(50, 20)
}
$Form.Controls.Add($Label3)

# Button2 Poista Videot
$Button2 = New-Object Windows.Forms.Button -Property @{
    Text = "Poista Videot"
    Location = New-Object Drawing.Point(20, 90)
    Size = New-Object Drawing.Size(80, 20)
}
$Button2.Add_Click({
    Delete-Movies
    $Label3.Text = "OK"
    })
$Form.Controls.Add($Button2)

# Label4 Poista Saved kansio
$Label4 = New-Object Windows.Forms.Label -Property @{
    Text = "Säästää GameUserSettings.inin ja poistaa muun sisällön Saved kansiosta ja sen alikansioista"
    Location = New-Object Drawing.Point(20, 120)
    Size = New-Object Drawing.Size(350, 30)
}
$Form.Controls.Add($Label4)

# Label5 Poista Saved kansio Done
$Label5 = New-Object Windows.Forms.Label -Property @{
    Text = ""
    Location = New-Object Drawing.Point(100, 150)
    Size = New-Object Drawing.Size(50, 20)
}
$Form.Controls.Add($Label5)

# Button3 Poista Saved-kansion tiedostot, paitsi GameUserSettings.ini
$Button3 = New-Object Windows.Forms.Button -Property @{
    Text = "Poista Saved-kansio"
    Location = New-Object Drawing.Point(20, 150)
    Size = New-Object Drawing.Size(80, 20)
}
$Button3.Add_Click({
    Clean-SavedFolder
})
$Form.Controls.Add($Button3)

# Label6 Hae arvot
$Label6 = New-Object Windows.Forms.Label -Property @{
    Text = "Hakee GameUserSettings.inistä desimaali arvot, jotka voi bugaa/aiheuttaa stutteria enginessä"
    Location = New-Object Drawing.Point(20, 180)
    Size = New-Object Drawing.Size(350, 30)
}
$Form.Controls.Add($Label6)

# Label7 Desimaalicheck
$Label7 = New-Object Windows.Forms.Label -Property @{
    Text = "Desimaalit: "
    Location = New-Object Drawing.Point(100, 210)
    Size = New-Object Drawing.Size(110, 20)
}
$Form.Controls.Add($Label7)

# Label8 Scopecheck
$Label8 = New-Object Windows.Forms.Label -Property @{
    Text = "Scopet: "
    Location = New-Object Drawing.Point(100, 230)
    Size = New-Object Drawing.Size(110, 20)
}
$Form.Controls.Add($Label8)

# Button4 Hae GameUserSettings.ini arvot
$Button4 = New-Object Windows.Forms.Button -Property @{
    Text = "Hae Arvot"
    Location = New-Object Drawing.Point(20, 210)
    Size = New-Object Drawing.Size(80, 20)
}
$Button4.Add_Click({
    GetValues-GameUserSettings
})
$Form.Controls.Add($Button4)

# FindPath
Find-PUBGPath
GetValues-GameUserSettings

# Button5 Muuta GameUserSettings.ini arvot
$Button5 = New-Object Windows.Forms.Button -Property @{
    Text = "Muuta Arvot"
    Location = New-Object Drawing.Point(20, 230)
    Size = New-Object Drawing.Size(80, 20)
}
$Button5.Add_Click({
    ChangeValues-GameUserSettings
})
$Form.Controls.Add($Button5)



$Form.ShowDialog()

$Form.Dispose()

