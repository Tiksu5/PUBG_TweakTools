# v0.1
# Todo: funktiot texteille ja boxeille

#
$global:ProgramName = "PUBG: BATTLEGROUNDS"
$global:ProgramPath = "null"
$global:GameUserSettingsPath = "$env:LOCALAPPDATA\TslGame\Saved\Config\WindowsNoEditor\GameUserSettings.ini"
$global:SavedFolderPath = "$env:LOCALAPPDATA\TslGame\Saved"
$global:Keywords = @( "sg.ResolutionQuality=", "ScreenScale=", "InGameCustomFrameRateLimit=", "MasterSoundVolume=", "EffectSoundVolume=",
                        "EmoteSoundVolume=", "UISoundVolume=", "BGMSoundVolume=", "PlaygroundBGMSoundVolume=", "PlaygroundWebSoundVolume=",
                        "FpsCameraFov=", "Gamma=", '"Baltic_Main", ', '"Desert_Main", ', '"Savage_Main", ', '"DihorOtok_Main", ',
                        '"Summerland_Main", ', '"Chimera_Main", ', '"Tiger_Main", ', '"Kiki_Main", ', '"Heaven_Main", ', '"Normal",Sensitivity=',
                        '"Targeting",Sensitivity=', '"Scoping",Sensitivity=', '"ScopingMagnified",Sensitivity=', '"Scope2X",Sensitivity=',
                        '"Scope3X",Sensitivity=', '"Scope4X",Sensitivity=', '"Scope6X",Sensitivity=', '"Scope8X",Sensitivity=', '"Scope15X",Sensitivity=',
                        "MouseVerticalSensitivityMultiplierAdjusted=", "ResolutionSizeX=", "ResolutionSizeY=", "FullscreenMode=", "ColorBlindType=",
                        "sg.ViewDistanceQuality=", "sg.AntiAliasingQuality=", "sg.ShadowQuality=", "sg.PostProcessQuality=", "sg.TextureQuality=",
                        "sg.EffectsQuality=", "sg.FoliageQuality=")
# Configin desimaalit, jotka bugaa
$global:KeywordsDecimalsToCheck = @("sg.ResolutionQuality=", "ScreenScale=", "InGameCustomFrameRateLimit=", "MasterSoundVolume=", "EffectSoundVolume=",
                                    "EmoteSoundVolume=", "UISoundVolume=", "BGMSoundVolume=", "PlaygroundBGMSoundVolume=", "PlaygroundWebSoundVolume=",
                                    "FpsCameraFov=", "Gamma=", '"Baltic_Main", ', '"Desert_Main", ', '"Savage_Main", ', '"DihorOtok_Main", ',
                                    '"Summerland_Main", ', '"Chimera_Main", ', '"Tiger_Main", ', '"Kiki_Main", ', '"Heaven_Main", ')
# Scope senssit jotka bugaa
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
   . .\Scripts\Confirm_Dialog.ps1

Add-Type -AssemblyName System.Windows.Forms

# Functions
   function Set-ProgramPath {
    param([string]$NewPath)
    $global:ProgramPath = $NewPath
    $global:MoviesFolderPath = "$global:ProgramPath\TslGame\Content\Movies"
    $global:ExcludedFolderPath = "$global:ProgramPath\TslGame\Content\Movies\AtoZ"
}

# Form
$MainForm = New-Object Windows.Forms.Form -Property @{
    Text = "Tiksu Tweak Tools v0.1"
    Size = New-Object Drawing.Size(600, 600)
    StartPosition = "CenterScreen"
}

# Path_Label
$global:MainPathLabel = New-Object Windows.Forms.Label -Property @{
    Text = "Asennuspolku:"
    Location = New-Object Drawing.Point(20, 20)
    Size = New-Object Drawing.Size(400, 20)
}
$MainForm.Controls.Add($global:MainPathLabel)

# Path Change Textbox
$global:ChangePathTextBox = New-Object Windows.Forms.TextBox -Property @{
    Location = New-Object Drawing.Point(20, 40)
    Size = New-Object Drawing.Size(250, 20)
}
$MainForm.Controls.Add($global:ChangePathTextBox)

# Button1 Muuta polku
$ChangePathButton = New-Object Windows.Forms.Button -Property @{
    Text = "Muuta polku"
    Location = New-Object Drawing.Point(280, 40)
    Size = New-Object Drawing.Size(75, 20)
}
$ChangePathButton.Add_Click({
    # Testaa Path
    if (-not (Test-Path -Path $global:ChangePathTextBox.Text -PathType Container)) {
        [System.Windows.Forms.MessageBox]::Show("Polkua ei löydy: $($global:ChangePathTextBox.Text) ") 
        return
    }
    Set-ProgramPath -NewPath $global:ChangePathTextBox.Text
    $global:MainPathLabel.Text = "Asennuspolku löydetty: $global:ProgramPath"
    $global:MainPathLabel.BackColor = [System.Drawing.Color]::Green
})
$MainForm.Controls.Add($ChangePathButton)

# Poista Videot text
$DeleteMoviesLabel = New-Object Windows.Forms.Label -Property @{
    Text = "Poista videot, jotta peli käynnistyy nopeampaa."
    Location = New-Object Drawing.Point(20, 70)
    Size = New-Object Drawing.Size(250, 20)
}
$MainForm.Controls.Add($DeleteMoviesLabel)

# Poista Videot done text
$global:DeleteMoviesDoneLabel = New-Object Windows.Forms.Label -Property @{
    Text = ""
    Location = New-Object Drawing.Point(100, 90)
    Size = New-Object Drawing.Size(130, 20)
}
$MainForm.Controls.Add($global:DeleteMoviesDoneLabel)

# Poista Videot Button
$DeleteMoviesButton = New-Object Windows.Forms.Button -Property @{
    Text = "Poista Videot"
    Location = New-Object Drawing.Point(20, 90)
    Size = New-Object Drawing.Size(80, 20)
}
$DeleteMoviesButton.Add_Click({
    Delete-Movies
    })
$MainForm.Controls.Add($DeleteMoviesButton)

# Poista Saved kansio text
$DeleteSavedFolderLabel = New-Object Windows.Forms.Label -Property @{
    Text = "Säästää GameUserSettings.inin ja poistaa muun sisällön Saved kansiosta ja sen alikansioista"
    Location = New-Object Drawing.Point(20, 120)
    Size = New-Object Drawing.Size(350, 30)
}
$MainForm.Controls.Add($DeleteSavedFolderLabel)

# Poista Saved kansio done text
$global:DeleteSavedFolderDoneLabel = New-Object Windows.Forms.Label -Property @{
    Text = ""
    Location = New-Object Drawing.Point(100, 150)
    Size = New-Object Drawing.Size(130, 20)
}
$MainForm.Controls.Add($global:DeleteSavedFolderDoneLabel)

# Delete Saved kansio button
$DeleteSavedFolderButton = New-Object Windows.Forms.Button -Property @{
    Text = "Poista Saved-kansio"
    Location = New-Object Drawing.Point(20, 150)
    Size = New-Object Drawing.Size(80, 20)
}
$DeleteSavedFolderButton.Add_Click({
    Clean-SavedFolder
})
$MainForm.Controls.Add($DeleteSavedFolderButton)

# Hae config arvot text (GameUserSettings.ini)
$GetConfigValuesLabel = New-Object Windows.Forms.Label -Property @{
    Text = "Hakee GameUserSettings.inistä desimaali arvot, jotka voi bugaa/aiheuttaa stutteria enginessä"
    Location = New-Object Drawing.Point(20, 180)
    Size = New-Object Drawing.Size(350, 30)
}
$MainForm.Controls.Add($GetConfigValuesLabel)

# Desimaalicheck text
$global:CheckDecimalsLabel = New-Object Windows.Forms.Label -Property @{
    Text = "Desimaalit: "
    Location = New-Object Drawing.Point(100, 210)
    Size = New-Object Drawing.Size(110, 20)
}
$MainForm.Controls.Add($global:CheckDecimalsLabel)

# Scopecheck text
$global:CheckScopeSensLabel = New-Object Windows.Forms.Label -Property @{
    Text = "Scopet: "
    Location = New-Object Drawing.Point(100, 230)
    Size = New-Object Drawing.Size(110, 20)
}
$MainForm.Controls.Add($global:CheckScopeSensLabel)

 <##Hae config arvot button (GameUserSettings.ini)
$GetConfigValuesButton = New-Object Windows.Forms.Button -Property @{
    Text = "Hae Arvot"
    Location = New-Object Drawing.Point(20, 210)
    Size = New-Object Drawing.Size(80, 20)
}
$GetConfigValuesButton.Add_Click({
    GetValues-GameUserSettings
})
$Form.Controls.Add($GetConfigValuesButton)
#>

# FindPath/GetValues @start
Find-PUBGPath
Check-Movies
GetValues-GameUserSettings

# Muuta GameUserSettings.ini arvot
$ChangeConfigValuesButton = New-Object Windows.Forms.Button -Property @{
    Text = "Muuta Arvot"
    Location = New-Object Drawing.Point(20, 230)
    Size = New-Object Drawing.Size(80, 20)
}
$ChangeConfigValuesButton.Add_Click({
    ChangeValues-GameUserSettings
})
$MainForm.Controls.Add($ChangeConfigValuesButton)

$MainForm.ShowDialog()

$MainForm.Dispose()

