#
#


 #### START ELEVATE TO ADMIN #####
param(
    [Parameter(Mandatory=$false)]
    [switch]$shouldAssumeToBeElevated,

    [Parameter(Mandatory=$false)]
    [String]$workingDirOverride
)

# If parameter is not set, we are propably in non-admin execution. We set it to the current working directory so that
#  the working directory of the elevated execution of this script is the current working directory
if(-not($PSBoundParameters.ContainsKey('workingDirOverride')))
{
    $workingDirOverride = (Get-Location).Path
}

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# If we are in a non-admin execution. Execute this script as admin
if ((Test-Admin) -eq $false)  {
    if ($shouldAssumeToBeElevated) {
        Write-Output "Elevating did not work :("

    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-ep RemoteSigned -noprofile -file "{0}" -shouldAssumeToBeElevated -workingDirOverride "{1}"' -f ($myinvocation.MyCommand.Definition, "$workingDirOverride"))
    }
    break
}

Set-Location "$workingDirOverride"
 #### END ELEVATE TO ADMIN #####


# Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName WindowsFormsIntegration
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'


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
$global:DefaultSoundsLocation = Join-Path -Path $global:ScriptDirectory -ChildPath "Sounds"
$global:ToolTip = New-Object System.Windows.Forms.ToolTip
$global:BootTimer = $null
$ConsolePtr = [Console.Window]::GetConsoleWindow()
$global:DefaultBackColor = [System.Drawing.Color]::White
$global:ExcludedFolders = @( $global:ReplayFolderPath, $global:ObserverFolderPath, $global:CrashesFolderPath )
$global:ExcludedFoldersAtStart = @( $global:ReplayFolderPath, $global:ObserverFolderPath, $global:CrashesFolderPath )
$global:Keywords = @( "sg.ResolutionQuality=", "ScreenScale=", "InGameCustomFrameRateLimit=", "MasterSoundVolume=", "EffectSoundVolume=",
                        "EmoteSoundVolume=", "UISoundVolume=", "BGMSoundVolume=", "PlaygroundBGMSoundVolume=", "PlaygroundWebSoundVolume=",
                        "FpsCameraFov=", "Gamma=", '"Baltic_Main", ', '"Desert_Main", ', '"Savage_Main", ', '"DihorOtok_Main", ',
                        '"Summerland_Main", ', '"Chimera_Main", ', '"Tiger_Main", ', '"Kiki_Main", ', '"Heaven_Main", ', '"Neon_Main", ', '"Normal",Sensitivity=',
                        '"Targeting",Sensitivity=', '"Scoping",Sensitivity=', '"ScopingMagnified",Sensitivity=', '"Scope2X",Sensitivity=',
                        '"Scope3X",Sensitivity=', '"Scope4X",Sensitivity=', '"Scope6X",Sensitivity=', '"Scope8X",Sensitivity=', '"Scope15X",Sensitivity=',
                        "MouseVerticalSensitivityMultiplierAdjusted=", "ResolutionSizeX=", "ResolutionSizeY=", "FullscreenMode=", "ColorBlindType=",
                        "sg.ViewDistanceQuality=", "sg.AntiAliasingQuality=", "sg.ShadowQuality=", "sg.PostProcessQuality=", "sg.TextureQuality=",
                        "sg.EffectsQuality=", "sg.FoliageQuality=", "bUseVsync=", "bIsEnabledHrtfRemoteWeaponSound=", "bUseInGameSmoothedFrameRate=",
                        "bMotionBlur=", "bSharpen=", "InputModeCrouch=", "InputModeProne=", "InputModeWalk=", "bToggleSprint=", "InputModeHoldRotation=", 
                        "InputModeHoldBreath=", "InputModeHoldAngled=", "InputModePeek=", "InputModeMap=", "InputModeADS=", "InputModeAim=", "bIsUsingPerScopeMouseSensitivity=" )
# Configin desimaalit, jotka bugaa
$global:KeywordsDecimalsToCheck = @("sg.ResolutionQuality=", "ScreenScale=", "InGameCustomFrameRateLimit=", "MasterSoundVolume=", "EffectSoundVolume=",
                                    "EmoteSoundVolume=", "UISoundVolume=", "BGMSoundVolume=", "PlaygroundBGMSoundVolume=", "PlaygroundWebSoundVolume=",
                                    "FpsCameraFov=", "Gamma=", '"Baltic_Main", ', '"Desert_Main", ', '"Savage_Main", ', '"DihorOtok_Main", ',
                                    '"Summerland_Main", ', '"Chimera_Main", ', '"Tiger_Main", ', '"Kiki_Main", ', '"Heaven_Main", ', '"Neon_Main", ')
<# SCOPE SENSSIT FIXATTU PATCHIS 28.2
Scope senssit jotka bugaa
$global:KeywordsScopesToCheck = @('"Scope6X",Sensitivity=', '"Scope8X",Sensitivity=', '"Scope15X",Sensitivity=', '"ScopingMagnified",Sensitivity=')
#>

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
. "$PSScriptRoot\Scripts\Find_Path.ps1"
. "$PSScriptRoot\Scripts\Delete_Movies.ps1"
. "$PSScriptRoot\Scripts\Clean_SavedFolder.ps1"
. "$PSScriptRoot\Scripts\Check_GameUserSettings.ps1"
. "$PSScriptRoot\Scripts\Change_GameUserSettings.ps1"
. "$PSScriptRoot\Scripts\Confirm_Dialog.ps1"
. "$PSScriptRoot\Scripts\Change_LogoPack.ps1"
. "$PSScriptRoot\Scripts\Kill_Pubg.ps1"
. "$PSScriptRoot\Scripts\Boot_Timer.ps1"

# Functions
function Set-ProgramPath {
    param([string]$NewPath)
    $global:ProgramPath = $NewPath
    if (Test-Path -Path $global:ProgramPath\TslGame\Content\Movies) {
        $global:MoviesFolderPath = "$global:ProgramPath\TslGame\Content\Movies"
        $global:ExcludedFolderPath = "$global:ProgramPath\TslGame\Content\Movies\AtoZ"
    }
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
# Hide Console
 [Console.Window]::ShowWindow($ConsolePtr, 0)

# Form
$MainForm = New-Object Windows.Forms.Form -Property @{
    Text = "Tiksu Tweak Tools v0.21"
    Size = New-Object Drawing.Size(600, 600)
    StartPosition = "CenterScreen"
    BackColor = $global:DefaultBackColor
}

$MenuStrip = New-Object System.Windows.Forms.MenuStrip
$MainForm.Controls.Add($MenuStrip)

# File menu
$FileMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$FileMenuItem.Text = "&File"

 # ShowConsole menu nappi
$ShowConsoleMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$ShowConsoleMenuItem.Text = "&Show Console"
$ShowConsoleMenuItem.Add_Click({
    [Console.Window]::ShowWindow($ConsolePtr, 4)
})

# Exit menu nappi
$ExitMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$ExitMenuItem.Text = "&Exit"
$ExitMenuItem.Add_Click({
    $MainForm.Close()
})

$FileMenuItem.DropDownItems.AddRange(@($ShowConsoleMenuItem, $ExitMenuItem))
$MenuStrip.Items.Add($FileMenuItem) | Out-Null

# Path_Label
$global:MainPathLabel = CreateLabel -text "Asennuspolku:" -locx 20 -locy 25 -sizex 320 -sizey 25
$MainForm.Controls.Add($global:MainPathLabel)

# Path Change Textbox
$global:ChangePathTextBox = CreateTextBox -locx 20 -locy 50 -sizex 250 -sizey 20
$MainForm.Controls.Add($global:ChangePathTextBox)

# ChangePathButton Muuta polku
$ChangePathButton = CreateButton -text "Muuta Polku" -locx 270 -locy 50 -sizex 75 -sizey 20
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
$DeleteMoviesLabel = CreateLabel -text "Poista videot, jotta peli käynnistyy nopeampaa." -locx 20 -locy 80 -sizex 250 -sizey 20
$MainForm.Controls.Add($DeleteMoviesLabel)

# Poista Videot done text
$global:DeleteMoviesDoneLabel = CreateLabel -text "" -locx 100 -locy 100 -sizex 130 -sizey 20
$MainForm.Controls.Add($global:DeleteMoviesDoneLabel)

# Poista Videot Button
$DeleteMoviesButton = CreateButton -text "Poista leffat" -locx 20 -locy 100 -sizex 80 -sizey 20

$DeleteMoviesButton.Add_Click({
    Delete-Movies
    })
$MainForm.Controls.Add($DeleteMoviesButton)

# Poista Saved kansio text
$DeleteSavedFolderLabel = CreateLabel -text "Säästää GameUserSettings.inin ja poistaa muun sisällön Saved kansiosta ja sen alikansioista" -locx 20 -locy 130 -sizex 300 -sizey 30
$MainForm.Controls.Add($DeleteSavedFolderLabel)

# Keep Replays checkbox
$global:KeepReplaysCheckBox = CreateCheckBox -text "Säästä Replat" -locx 10 -locy 160 -sizex 150 -sizey 20
$global:KeepReplaysCheckBox.Checked = $false
$global:KeepReplaysCheckBox.add_CheckedChanged({
    if ($global:KeepReplaysCheckBox.Checked) {
        $global:ExcludedFolders += $global:ReplayFolderPath
    } else {
        $global:ExcludedFolders = $global:ExcludedFolders -ne $global:ReplayFolderPath
    }
})
$MainForm.Controls.Add($global:KeepReplaysCheckBox)

# Keep Observerpack checkbox
$global:KeepObserverCheckBox = CreateCheckBox -text "Säästä Observerpaketti" -locx 10 -locy 180 -sizex 150 -sizey 20
$global:KeepObserverCheckBox.Checked = $false
$global:KeepObserverCheckBox.add_CheckedChanged({
    if ($global:KeepObserverCheckBox.Checked) {
        $global:ExcludedFolders += $global:ObserverFolderPath
    } else {
        $global:ExcludedFolders = $global:ExcludedFolders -ne $global:ObserverFolderPath
    }
})
$MainForm.Controls.Add($global:KeepObserverCheckBox)

# Keep Crashes checkbox
$global:KeepCrashesCheckBox = CreateCheckBox -text "Säästä Crash reportit" -locx 160 -locy 160 -sizex 150 -sizey 20
$global:KeepCrashesCheckBox.Checked = $false
$global:KeepCrashesCheckBox.add_CheckedChanged({
    if ($global:KeepCrashesCheckBox.Checked) {
        $global:ExcludedFolders += $global:CrashesFolderPath
    } else {
        $global:ExcludedFolders = $global:ExcludedFolders -ne $global:CrashesFolderPath
    }
})
$MainForm.Controls.Add($global:KeepCrashesCheckBox)

# Poista Saved kansio done text
$global:DeleteSavedFolderDoneLabel = CreateLabel -text "" -locx 100 -locy 200 -sizex 130 -sizey 20
$MainForm.Controls.Add($global:DeleteSavedFolderDoneLabel)

# Delete Saved kansio button
$DeleteSavedFolderButton = CreateButton -text "Poista Saved-kansio" -locx 20 -locy 200 -sizex 80 -sizey 20
$DeleteSavedFolderButton.Add_Click({
    Clean-SavedFolder
})
$MainForm.Controls.Add($DeleteSavedFolderButton)

# Hae config arvot text (GameUserSettings.ini)
$GetConfigValuesLabel = CreateLabel -text "Hakee GameUserSettings.inistä desimaali arvot, jotka voi bugaa/aiheuttaa stutteria enginessä" -locx 20 -locy 230 -sizex 350 -sizey 30
$MainForm.Controls.Add($GetConfigValuesLabel)

# Desimaalicheck text
$global:CheckDecimalsLabel = CreateLabel -text "Desimaalit: " -locx 100 -locy 260 -sizex 110 -sizey 20
$MainForm.Controls.Add($global:CheckDecimalsLabel)

<# SCOPE SENSSIT FIXATTU PATCHIS 28.2
Scopecheck text
$global:CheckScopeSensLabel = CreateLabel -text "Scopet: " -locx 100 -locy 270 -sizex 110 -sizey 20
$MainForm.Controls.Add($global:CheckScopeSensLabel)
#>

# 
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
$ChangeConfigValuesButton = CreateButton -text "Katso arvot" -locx 20 -locy 280 -sizex 80 -sizey 20
$ChangeConfigValuesButton.Add_Click({
    ChangeValues-GameUserSettings
})
$MainForm.Controls.Add($ChangeConfigValuesButton)

# Logopaketti Text
$ObserverPackLabel = CreateLabel -text "Vaihda Logopaketti" -locx 415 -locy 490 -sizex 150 -sizey 20
$MainForm.Controls.Add($ObserverPackLabel)

# Test löytyykö Logopakettien kansio, tekee jos ei löydy
if (-not (Test-Path -Path $DefaultSavedObserverPackLocation -PathType Container)) {
    New-Item -Path $DefaultSavedObserverPackLocation -ItemType Directory
}

# Logopaketti dropdown
$global:ObserverPackSelect = CreateDropDownMenu -locx 415 -locy 510 -sizex 150 -sizey 20

# Haetaan valmiit logopaketit dropdownin valinnoiksi
$global:SelectionFolders = Get-ChildItem -Path $global:DefaultSavedObserverPackLocation -Directory | Select-Object -ExpandProperty Name
$global:ObserverPackSelect.Items.AddRange($global:SelectionFolders)
$global:ObserverPackSelect.Items.Add("Default") | Out-Null
$global:ObserverPackSelect.SelectedItem = "Default"
$MainForm.Controls.Add($global:ObserverPackSelect)

# Logopaketti vaihto button
$ChangeObserverPackButton = CreateButton -text "Vaihda" -locx 410 -locy 530 -sizex 80 -sizey 20
$ChangeObserverPackButton.Add_Click({
    $global:ObserverPackSelectedItem = $global:ObserverPackSelect.SelectedItem
    Change-LogoPack
})
$MainForm.Controls.Add($ChangeObserverPackButton)
<# # Disabled work in progress
 Logopaketti new button
 $CreateObserverPackButton = CreateButton -text "Luo Uusi" -locx 490 -locy 530 -sizex 80 -sizey 20
 $CreateObserverPackButton.Add_Click({
     Create-LogoPackForm
})
$MainForm.Controls.Add($CreateObserverPackButton)
#>

# Launch Settings Label
$LaunchSettingsLabel = CreateLabel -text "Käynnistys asetukset" -locx 360 -locy 50 -sizex 300 -sizey 15
$MainForm.Controls.Add($LaunchSettingsLabel)

# Poista leffat checkbox startille
$global:DeleteMoviesAtStartCheckBox = CreateCheckBox -text "Poista Leffat" -locx 360 -locy 110 -sizex 130 -sizey 20
$global:DeleteMoviesAtStartCheckBox.Checked = $true
$MainForm.Controls.Add($global:DeleteMoviesAtStartCheckBox)

# Tyhjennä saved folder checkbox startille
$global:DeleteSavedAtStartCheckBox = CreateCheckBox -text "Tyhjennä Saved Folder" -locx 360 -locy 130 -sizex 170 -sizey 20
$global:DeleteSavedAtStartCheckBox.Checked = $true
# Lisävalintojen Visibility
$global:DeleteSavedAtStartCheckBox.Add_CheckStateChanged({
    $global:KeepReplaysAtStartCheckBox.Enabled = $global:DeleteSavedAtStartCheckBox.Checked
    $global:KeepObserverAtStartCheckBox.Enabled = $global:DeleteSavedAtStartCheckBox.Checked
    $global:KeepCrashesAtStartCheckBox.Enabled = $global:DeleteSavedAtStartCheckBox.Checked
    $global:KeepReplaysAtStartCheckBox.Visible = $global:DeleteSavedAtStartCheckBox.Checked
    $global:KeepObserverAtStartCheckBox.Visible = $global:DeleteSavedAtStartCheckBox.Checked
    $global:KeepCrashesAtStartCheckBox.Visible = $global:DeleteSavedAtStartCheckBox.Checked
})
$MainForm.Controls.Add($global:DeleteSavedAtStartCheckBox)

# Keep Replays checkbox startille
$global:KeepReplaysAtStartCheckBox = CreateCheckBox -text "Säästä Replat" -locx 380 -locy 150 -sizex 170 -sizey 20
$global:KeepReplaysAtStartCheckBox.Checked = $true
$global:KeepReplaysAtStartCheckBox.add_CheckedChanged({
    if ($global:KeepReplaysAtStartCheckBox.Checked) {
        $global:ExcludedFoldersAtStart += $global:ReplayFolderPath
    } else {
        $global:ExcludedFoldersAtStart = $global:ExcludedFoldersAtStart -ne $global:ReplayFolderPath
    }
})
$MainForm.Controls.Add($global:KeepReplaysAtStartCheckBox)

# Keep Observerpack checkbox startille
$global:KeepObserverAtStartCheckBox = CreateCheckBox -text "Säästä Observerpaketti" -locx 380 -locy 170 -sizex 170 -sizey 20
$global:KeepObserverAtStartCheckBox.Checked = $true
$global:KeepObserverAtStartCheckBox.add_CheckedChanged({
    if ($global:KeepObserverAtStartCheckBox.Checked) {
        $global:ExcludedFoldersAtStart += $global:ObserverFolderPath
    } else {
        $global:ExcludedFoldersAtStart = $global:ExcludedFoldersAtStart -ne $global:ObserverFolderPath
    }
})
$MainForm.Controls.Add($global:KeepObserverAtStartCheckBox)

# Keep Crashes checkbox
$global:KeepCrashesAtStartCheckBox = CreateCheckBox -text "Säästä Crash reportit" -locx 380 -locy 190 -sizex 170 -sizey 20
$global:KeepCrashesAtStartCheckBox.Checked = $true
$global:KeepCrashesAtStartCheckBox.add_CheckedChanged({
    if ($global:KeepCrashesAtStartCheckBox.Checked) {
        $global:ExcludedFoldersAtStart += $global:CrashesFolderPath
    } else {
        $global:ExcludedFoldersAtStart = $global:ExcludedFoldersAtStart -ne $global:CrashesFolderPath
    }
})
$MainForm.Controls.Add($global:KeepCrashesAtStartCheckBox)

# Muistutus boottia peli 3-4h crashin varalta
$global:BootReminderCheckBox = CreateCheckBox -text "Muistutus Boottaa peli" -locx 360 -locy 65 -sizex 135 -sizey 20
$global:BootReminderCheckBox.Checked = $true
$global:BootReminderCheckBox.Add_CheckStateChanged({
    $global:BootReminderSelect.Enabled = $global:BootReminderCheckBox.Checked
    $global:BootReminderSelect.Visible = $global:BootReminderCheckBox.Checked
    $global:BootReminderLabel.Enabled = $global:BootReminderCheckBox.Checked
    $global:BootReminderLabel.Visible = $global:BootReminderCheckBox.Checked
    $global:BootReminderTimeLeftLabel.Enabled = $global:BootReminderCheckBox.Checked
    $global:BootReminderTimeLeftLabel.Visible = $global:BootReminderCheckBox.Checked
})
$MainForm.Controls.Add($global:BootReminderCheckBox)

# Boot timer dropdown
$global:BootReminderSelect = CreateDropDownMenu -locx 360 -locy 85 -sizex 30 -sizey 20
1..4 | ForEach-Object { $global:BootReminderSelect.Items.Add($_) } | Out-Null
$global:BootReminderSelect.SelectedItem = 3
$MainForm.Controls.Add($global:BootReminderSelect)

# Boot timer label
$BootReminderLabel = CreateLabel -text "Tuntia" -locx 390 -locy 89 -sizex 40 -sizey 15
$MainForm.Controls.Add($BootReminderLabel)

# Boot timer time left label
$global:BootReminderTimeLeftLabel = CreateLabel -text "Time left: $global:CountDown" -locx 430 -locy 89 -sizex 150 -sizey 15
$MainForm.Controls.Add($global:BootReminderTimeLeftLabel)


#Launch PUBG button
$LaunchButton = CreateButton -text "Start" -locx 340 -locy 25 -sizex 80 -sizey 20
$LaunchButton.Add_Click({
    if ($global:DeleteMoviesAtStartCheckBox.Checked) {
        Delete-Movies -SkipConfirmation $true
        Start-Sleep -Seconds 1
    }
    if ($global:DeleteSavedAtStartCheckBox.Checked) {
        Clean-SavedFolder -SkipConfirmation $true
        Start-Sleep -Seconds 1
    }
    if ($global:BootReminderCheckBox.Checked) {        
        Boot-Timer
        Start-Sleep -Seconds 1
    }
    Start-PUBG
})
$MainForm.Controls.Add($LaunchButton)

#Kill PUBG button
$KillButton = CreateButton -text "Kill" -locx 420 -locy 25 -sizex 80 -sizey 20
$KillButton.Add_Click({
    Kill-PUBG
    # Suljetaan timer, jos semmonen löytyy
    if ($global:BootTimer -ne $null) {
        $global:BootTimer.Stop()
        $global:BootTimer.Dispose()
        $global:BootReminderTimeLeftLabel.Text = "Time left:"
    }
})
$MainForm.Controls.Add($KillButton)

#Restart PUBG button 
$RestartButton = CreateButton -text "Restart" -locx 500 -locy 25 -sizex 80 -sizey 20
$RestartButton.Add_Click({
    Kill-PUBG
    Start-Sleep -Seconds 1
    if ($global:DeleteMoviesAtStartCheckBox.Checked) {
        Delete-Movies -SkipConfirmation $true
        Start-Sleep -Seconds 1
    }
    if ($global:DeleteSavedAtStartCheckBox.Checked) {
        Clean-SavedFolder -SkipConfirmation $true
        Start-Sleep -Seconds 1
    }
    if ($global:BootReminderCheckBox.Checked) {        
        Boot-Timer
        Start-Sleep -Seconds 1
    }
    Start-PUBG
})
$MainForm.Controls.Add($RestartButton)





$MainForm.ShowDialog()

$MainForm.Dispose()

