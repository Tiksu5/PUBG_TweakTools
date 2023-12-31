﻿#
#

# Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName WindowsFormsIntegration
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore

[System.Windows.Forms.Application]::EnableVisualStyles();

# Variables
$global:ProgramName = "PUBG: BATTLEGROUNDS"
$global:ProgramPath = "null"
$global:GameUserSettingsPath = "$env:LOCALAPPDATA\TslGame\Saved\Config\WindowsNoEditor\GameUserSettings.ini"
$global:CrashesFolderPath = "$env:LOCALAPPDATA\TslGame\Saved\Crashes"
$global:ReplayFolderPath = "$env:LOCALAPPDATA\TslGame\Saved\Demos"
$global:ObserverFolderPath = "$env:LOCALAPPDATA\TslGame\Saved\Observer"
$global:SavedFolderPath = "$env:LOCALAPPDATA\TslGame\Saved"
$global:ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$global:DefaultSavedObserverPackLocation = Join-Path -Path $global:ScriptDirectory -ChildPath "ObserverPacks"
$global:ToolTip = New-Object System.Windows.Forms.ToolTip
$global:ExcludedFolders = @( $global:ReplayFolderPath, $global:ObserverFolderPath )
$global:Keywords = @( "sg.ResolutionQuality=", "ScreenScale=", "InGameCustomFrameRateLimit=", "MasterSoundVolume=", "EffectSoundVolume=",
                        "EmoteSoundVolume=", "UISoundVolume=", "BGMSoundVolume=", "PlaygroundBGMSoundVolume=", "PlaygroundWebSoundVolume=",
                        "FpsCameraFov=", "Gamma=", '"Baltic_Main", ', '"Desert_Main", ', '"Savage_Main", ', '"DihorOtok_Main", ',
                        '"Summerland_Main", ', '"Chimera_Main", ', '"Tiger_Main", ', '"Kiki_Main", ', '"Heaven_Main", ', '"Normal",Sensitivity=',
                        '"Targeting",Sensitivity=', '"Scoping",Sensitivity=', '"ScopingMagnified",Sensitivity=', '"Scope2X",Sensitivity=',
                        '"Scope3X",Sensitivity=', '"Scope4X",Sensitivity=', '"Scope6X",Sensitivity=', '"Scope8X",Sensitivity=', '"Scope15X",Sensitivity=',
                        "MouseVerticalSensitivityMultiplierAdjusted=", "ResolutionSizeX=", "ResolutionSizeY=", "FullscreenMode=", "ColorBlindType=",
                        "sg.ViewDistanceQuality=", "sg.AntiAliasingQuality=", "sg.ShadowQuality=", "sg.PostProcessQuality=", "sg.TextureQuality=",
                        "sg.EffectsQuality=", "sg.FoliageQuality=", "bUseVsync=", "bIsEnabledHrtfRemoteWeaponSound=", "bUseInGameSmoothedFrameRate=",
                        "bMotionBlur=", "bSharpen=", "InputModeCrouch=", "InputModeProne=", "InputModeWalk=", "bToggleSprint=", "InputModeHoldRotation=", 
                        "InputModeHoldBreath=", "InputModeHoldAngled=", "InputModePeek=", "InputModeMap=", "InputModeADS=", "InputModeAim=", "bIsUsingPerScopeMouseSensitivity=")
# Configin desimaalit, jotka bugaa
$global:KeywordsDecimalsToCheck = @("sg.ResolutionQuality=", "ScreenScale=", "InGameCustomFrameRateLimit=", "MasterSoundVolume=", "EffectSoundVolume=",
                                    "EmoteSoundVolume=", "UISoundVolume=", "BGMSoundVolume=", "PlaygroundBGMSoundVolume=", "PlaygroundWebSoundVolume=",
                                    "FpsCameraFov=", "Gamma=", '"Baltic_Main", ', '"Desert_Main", ', '"Savage_Main", ', '"DihorOtok_Main", ',
                                    '"Summerland_Main", ', '"Chimera_Main", ', '"Tiger_Main", ', '"Kiki_Main", ', '"Heaven_Main", ')
# Scope senssit jotka bugaa
$global:KeywordsScopesToCheck = @('"Scope6X",Sensitivity=', '"Scope8X",Sensitivity=', '"Scope15X",Sensitivity=', '"ScopingMagnified",Sensitivity=')
# Hashtable arvoille
$global:KeywordValues = @{}
# Array Configin settareille, jotka pielessä.
$global:FailingKeywords = @() 
# Array keywordeille joita ei löydy configista
$global:KeywordsNotFound = @()
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
   . .\Scripts\Change_LogoPack.ps1

# Functions
function Set-ProgramPath {
    param([string]$NewPath)
    $global:ProgramPath = $NewPath
    $global:MoviesFolderPath = "$global:ProgramPath\TslGame\Content\Movies"
    $global:ExcludedFolderPath = "$global:ProgramPath\TslGame\Content\Movies\AtoZ"
}

function CreateLabel {
    param (
        [string]$text,
        [int]$locx,
        [int]$locy,
        [int]$sizex,
        [int]$sizey
    )

    $label = New-Object System.Windows.Forms.Label -Property @{
        Text = "$text"
        Location = New-Object Drawing.Point($locx, $locy)
        Size = New-Object Drawing.Size($sizex, $sizey)
    }

    return $label
}

function CreateButton {
    param (
        [string]$text,
        [int]$locx,
        [int]$locy,
        [int]$sizex,
        [int]$sizey
    )

    $button = New-Object System.Windows.Forms.Button -Property @{
        Text = "$text"
        Location = New-Object Drawing.Point($locx, $locy)
        Size = New-Object Drawing.Size($sizex, $sizey)
    }

    return $button
}

function CreateTextBox {
    param (
        [string]$text,
        [int]$locx,
        [int]$locy,
        [int]$sizex,
        [int]$sizey
    )

    $textbox = New-Object System.Windows.Forms.TextBox -Property @{
        Text = "$text"
        Location = New-Object Drawing.Point($locx, $locy)
        Size = New-Object Drawing.Size($sizex, $sizey)
    }

    return $textbox
}

function CreateCheckBox {
    param (
        [string]$text,
        [int]$locx,
        [int]$locy,
        [int]$sizex,
        [int]$sizey
    )

    $checkbox = New-Object System.Windows.Forms.CheckBox -Property @{
        Text = "$text"
        Location = New-Object Drawing.Point($locx, $locy)
        Size = New-Object System.Drawing.Point($sizex, $sizey)
    }

    return $checkbox
}

function CreateDropDownMenu {
    param (
        [int]$locx,
        [int]$locy,
        [int]$sizex,
        [int]$sizey
    )

    $dropdown = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = New-Object Drawing.Point($locx, $locy)
        Size = New-Object System.Drawing.Point($sizex, $sizey)
    }

    return $dropdown
}

# Form
$MainForm = New-Object Windows.Forms.Form -Property @{
    Text = "Tiksu Tweak Tools v0.1"
    Size = New-Object Drawing.Size(600, 600)
    StartPosition = "CenterScreen"
}

# Path_Label
$global:MainPathLabel = CreateLabel -text "Asennuspolku:" -locx 20 -locy 15 -sizex 335 -sizey 25
$MainForm.Controls.Add($global:MainPathLabel)

# Path Change Textbox
$global:ChangePathTextBox = CreateTextBox -locx 20 -locy 40 -sizex 250 -sizey 20
$MainForm.Controls.Add($global:ChangePathTextBox)

# ChangePathButton Muuta polku
$ChangePathButton = CreateButton -text "Muuta Polku" -locx 280 -locy 40 -sizex 75 -sizey 20
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
$DeleteMoviesLabel = CreateLabel -text "Poista videot, jotta peli käynnistyy nopeampaa." -locx 20 -locy 70 -sizex 250 -sizey 20
$MainForm.Controls.Add($DeleteMoviesLabel)

# Poista Videot done text
$global:DeleteMoviesDoneLabel = CreateLabel -text "" -locx 100 -locy 90 -sizex 130 -sizey 20
$MainForm.Controls.Add($global:DeleteMoviesDoneLabel)

# Poista Videot Button
$DeleteMoviesButton = CreateButton -text "Poista leffat" -locx 20 -locy 90 -sizex 80 -sizey 20

$DeleteMoviesButton.Add_Click({
    Delete-Movies
    })
$MainForm.Controls.Add($DeleteMoviesButton)

# Poista Saved kansio text
$DeleteSavedFolderLabel = CreateLabel -text "Säästää GameUserSettings.inin ja poistaa muun sisällön Saved kansiosta ja sen alikansioista" -locx 20 -locy 120 -sizex 350 -sizey 30
$MainForm.Controls.Add($DeleteSavedFolderLabel)

# Keep Replays checkbox
$global:KeepReplaysCheckBox = CreateCheckBox -text "Säästä Replat" -locx 10 -locy 150 -sizex 170 -sizey 20
$global:KeepReplaysCheckBox.Checked = $true
$global:KeepReplaysCheckBox.add_CheckedChanged({
    if ($global:KeepReplaysCheckBox.Checked) {
        $global:ExcludedFolders += $global:ReplayFolderPath
    } else {
        $global:ExcludedFolders = $global:ExcludedFolders -ne $global:ReplayFolderPath
    }
})
$MainForm.Controls.Add($global:KeepReplaysCheckBox)

# Observerpack checkbox
$global:KeepObserverCheckBox = CreateCheckBox -text "Säästä Observerpaketti" -locx 10 -locy 170 -sizex 170 -sizey 20
$global:KeepObserverCheckBox.Checked = $true
$global:KeepObserverCheckBox.add_CheckedChanged({
    if ($global:KeepObserverCheckBox.Checked) {
        $global:ExcludedFolders += $global:ObserverFolderPath
    } else {
        $global:ExcludedFolders = $global:ExcludedFolders -ne $global:ObserverFolderPath
    }
})
$MainForm.Controls.Add($global:KeepObserverCheckBox)

# Poista Saved kansio done text
$global:DeleteSavedFolderDoneLabel = CreateLabel -text "" -locx 100 -locy 190 -sizex 130 -sizey 20
$MainForm.Controls.Add($global:DeleteSavedFolderDoneLabel)

# Delete Saved kansio button
$DeleteSavedFolderButton = CreateButton -text "Poista Saved-kansio" -locx 20 -locy 190 -sizex 80 -sizey 20
$DeleteSavedFolderButton.Add_Click({
    Clean-SavedFolder
})
$MainForm.Controls.Add($DeleteSavedFolderButton)

# Hae config arvot text (GameUserSettings.ini)
$GetConfigValuesLabel = CreateLabel -text "Hakee GameUserSettings.inistä desimaali arvot, jotka voi bugaa/aiheuttaa stutteria enginessä" -locx 20 -locy 220 -sizex 350 -sizey 30
$MainForm.Controls.Add($GetConfigValuesLabel)

# Desimaalicheck text
$global:CheckDecimalsLabel = CreateLabel -text "Desimaalit: " -locx 100 -locy 250 -sizex 110 -sizey 20
$MainForm.Controls.Add($global:CheckDecimalsLabel)

# Scopecheck text
$global:CheckScopeSensLabel = CreateLabel -text "Scopet: " -locx 100 -locy 270 -sizex 110 -sizey 20
$MainForm.Controls.Add($global:CheckScopeSensLabel)

 <##Hae config arvot button (GameUserSettings.ini)
$GetConfigValuesButton = CreateButton -text "Hae Arvot" -locx 20 -locy 250 -sizex 80 -sizey 20
$GetConfigValuesButton.Add_Click({
    GetValues-GameUserSettings
})
$Form.Controls.Add($GetConfigValuesButton)
#>

# FindPath/GetValues @start
Find-PUBGPath
Check-Movies
GetValues-GameUserSettings

# Muuta GameUserSettings.ini arvot button
$ChangeConfigValuesButton = CreateButton -text "Muuta Arvot" -locx 20 -locy 270 -sizex 80 -sizey 20
$ChangeConfigValuesButton.Add_Click({
    ChangeValues-GameUserSettings
})
$MainForm.Controls.Add($ChangeConfigValuesButton)

# Logopaketti Text
$ObserverPackLabel = CreateLabel -text "Vaihda/Luo observerpaketti" -locx 420 -locy 70 -sizex 150 -sizey 20
$MainForm.Controls.Add($ObserverPackLabel)

# Test löytyykö Logopakettien kansio, tekee jos ei löydy
if (-not (Test-Path -Path $DefaultSavedObserverPackLocation -PathType Container)) {
    New-Item -Path $DefaultSavedObserverPackLocation -ItemType Directory
}

# Logopaketti dropdown
$ObserverPackSelect = CreateDropDownMenu -locx 420 -locy 90 -sizex 150 -sizey 20

# Haetaan valmiit logopaketit dropdownin valinnoiksi
$global:SelectionFolders = Get-ChildItem -Path $global:DefaultSavedObserverPackLocation -Directory | Select-Object -ExpandProperty Name
$global:ObserverPackSelect.Items.AddRange($global:SelectionFolders)
$DefaultOption = "Default"
$global:ObserverPackSelect.Items.Add($DefaultOption)
$global:ObserverPackSelect.SelectedItem = $DefaultOption
$MainForm.Controls.Add($global:ObserverPackSelect)

# Logopaketti vaihto button
$ChangeObserverPackButton = CreateButton -text "Vaihda" -locx 420 -locy 110 -sizex 80 -sizey 20
$ChangeObserverPackButton.Add_Click({
    $global:SelectedItem = $global:ObserverPackSelect.SelectedItem
    Change-LogoPack
})
$MainForm.Controls.Add($ChangeObserverPackButton)

# Logopaketti new button
$CreateObserverPackButton = CreateButton -text "Luo Uusi" -locx 500 -locy 110 -sizex 80 -sizey 20
$CreateObserverPackButton.Add_Click({
    Create-LogoPackForm
})
$MainForm.Controls.Add($CreateObserverPackButton)

$MainForm.ShowDialog()

$MainForm.Dispose()

