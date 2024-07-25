#
#
#
#
#
#
#
#
# v0.3# Lisätty config filu user settingseille, pari nappia lisää, lisätty valinta kerralla disabloia kaikki launch settarit.
####### Lisätty PsIni moduuli .ini tiedostojen lukemista ja muokkaamista varten.
#############################################################################################################################

 #### START ELEVATE TO ADMIN #####
param(
    [Parameter(Mandatory=$false)]
    [switch]$shouldAssumeToBeElevated,

    [Parameter(Mandatory=$false)]
    [String]$workingDirOverride
)

# If parameter is not set, we are propably in non-admin execution. We set it to the current working directory so that
# the working directory of the elevated execution of this script is the current working directory
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

 # .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

# Hide Console
$ConsolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($ConsolePtr, 0) | out-null

# Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName WindowsFormsIntegration
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore

# Modules
Import-Module $PSScriptRoot\Modules\PsIni\3.1.3\PsIni.psm1

# Variables
$global:ProgramName = "PUBG: BATTLEGROUNDS"
$global:GameUserSettingsPath = "$env:LOCALAPPDATA\TslGame\Saved\Config\WindowsNoEditor\GameUserSettings.ini"
$global:CrashesFolderPath = "$env:LOCALAPPDATA\TslGame\Saved\Crashes"
$global:ReplayFolderPath = "$env:LOCALAPPDATA\TslGame\Saved\Demos"
$global:ObserverFolderPath = "$env:LOCALAPPDATA\TslGame\Saved\Observer"
$global:SavedFolderPath = "$env:LOCALAPPDATA\TslGame\Saved"
$global:WindowsNoEditorFolderPath = "$env:LOCALAPPDATA\TslGame\Saved\Config\WindowsNoEditor"
$global:CasterGamingFolderPath = "$env:LOCALAPPDATA\TslGame\Saved\Observer.gaming"
$global:CasterObserverFolderPath = "$env:LOCALAPPDATA\TslGame\Saved\Observer.casting"
$global:ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$global:ConfigPath = "$PSScriptRoot\Config.ini"
$global:DefaultSavedObserverPackLocation = Join-Path -Path $global:ScriptDirectory -ChildPath "ObserverPacks"
$global:DefaultSoundsLocation = Join-Path -Path $global:ScriptDirectory -ChildPath "Sounds"
$global:ToolTip = New-Object System.Windows.Forms.ToolTip
$global:BootTimer = $null
$global:DefaultBackColor = [System.Drawing.Color]::White
$global:ExcludedFolders = @( $global:ReplayFolderPath, $global:ObserverFolderPath, $global:CrashesFolderPath, $global:CasterObserverFolderPath, $global:CasterGamingFolderPath )
$global:ExcludedFoldersAtStart = @( $global:ReplayFolderPath, $global:ObserverFolderPath, $global:CrashesFolderPath, $global:CasterObserverFolderPath, $global:CasterGamingFolderPath )
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
. "$PSScriptRoot\Scripts\Get_Config.ps1"

# Get Config arvot
Get-Config

# Functions
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

[System.Windows.Forms.Application]::EnableVisualStyles();

# Form
$MainForm = New-Object Windows.Forms.Form -Property @{
    Text = "Tiksu Tweak Tools v0.3"
    Size = New-Object Drawing.Size(600, 600)
    StartPosition = "CenterScreen"
    BackColor = $global:DefaultBackColor
}

$MenuStrip = New-Object System.Windows.Forms.MenuStrip
$MainForm.Controls.Add($MenuStrip)

# File menu
$FileMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$FileMenuItem.Text = "&File"

 # HideConsole menu nappi
$HideConsoleMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$HideConsoleMenuItem.Text = "Hide Console"
if ($global:cfgMainHideConsole -is [bool]) { 
    $HideConsoleMenuItem.Checked = $global:cfgMainHideConsole
} else { 
    $HideConsoleMenuItem.Checked = $true
}
if ($HideConsoleMenuItem.Checked) {
    [Console.Window]::ShowWindow($ConsolePtr, 0) | Out-Null
} else {
    [Console.Window]::ShowWindow($ConsolePtr, 4) | Out-Null
}

$HideConsoleMenuItem.Add_Click({
    if ($HideConsoleMenuItem.Checked) {
        [Console.Window]::ShowWindow($ConsolePtr, 4) 
        $HideConsoleMenuItem.Checked = $false
    } else {
        [Console.Window]::ShowWindow($ConsolePtr, 0) 
        $HideConsoleMenuItem.Checked = $true
    }
    $global:cfgMainHideConsole = $HideConsoleMenuItem.Checked
    $global:Config.Main.HideConsole = $global:cfgMainHideConsole
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }
})

 # AutoSave menu nappi
$AutoSaveMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$AutoSaveMenuItem.Text = "Autosave"
if ($global:cfgMainRememberSettings -is [bool]) { 
    $AutoSaveMenuItem.Checked = $global:cfgMainRememberSettings
} else { 
    $AutoSaveMenuItem.Checked = $true
}

$AutoSaveMenuItem.Add_Click({
    if ($AutoSaveMenuItem.Checked) {
        $AutoSaveMenuItem.Checked = $false
    } else {
        $AutoSaveMenuItem.Checked = $true
    }
    $global:cfgMainRememberSettings = $AutoSaveMenuItem.Checked
    $global:Config.Main.RememberSettings = $global:cfgMainRememberSettings
    $global:Config | Out-IniFile -Force "Config.ini"   
})

# Exit menu nappi
$ExitMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$ExitMenuItem.Text = "&Exit"
$ExitMenuItem.Add_Click({
    $MainForm.Close()
})
$FileMenuItem.DropDownItems.AddRange(@($AutoSaveMenuItem, $HideConsoleMenuItem, $ExitMenuItem))
$MenuStrip.Items.Add($FileMenuItem) | Out-Null


$MainForm.Add_Shown({$MainForm.Activate()}) | Out-Null

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
    $EngineTestPath = $global:ChangePathTextBox.Text + "\Engine"
    $TslGameTestPath = $global:ChangePathTextBox.Text + "\TslGame"
    if ((Test-Path -Path $EngineTestPath) -and (Test-Path -Path $TslGameTestPath)) {
        Set-ProgramPath -NewPath $global:ChangePathTextBox.Text
        $global:MainPathLabel.Text = "Asennuspolku löydetty: $global:ProgramPath"
        $global:MainPathLabel.BackColor = [System.Drawing.Color]::Green
        $global:Config.Main.PubgPath = "$global:ProgramPath"
        $global:ProgramPathFound = $true
        
    } else {
        [System.Windows.Forms.MessageBox]::Show("$($global:ChangePathTextBox.Text) Ei ole PUBG asennus kansio") 
    }
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
if ($global:cfgMainKeepReplays -is [bool]) {
    $global:KeepReplaysCheckBox.Checked = $global:cfgMainKeepReplays
} else { 
    $global:KeepReplaysCheckBox.Checked = $false
}
$global:KeepReplaysCheckBox.add_CheckedChanged({ 
    if ($global:KeepReplaysCheckBox.Checked) {
        $global:ExcludedFolders += $global:ReplayFolderPath
    } else {
        $global:ExcludedFolders = $global:ExcludedFolders -ne $global:ReplayFolderPath
    }
    $global:cfgMainKeepReplays = $global:KeepReplaysCheckBox.Checked
    $global:Config.Main.KeepReplays = $global:cfgMainKeepReplays
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($global:KeepReplaysCheckBox)

# Keep Observerpack checkbox
$global:KeepObserverCheckBox = CreateCheckBox -text "Säästä Observerpaketti" -locx 10 -locy 180 -sizex 150 -sizey 20
if ($global:cfgMainKeepObserver -is [bool]) {
    $global:KeepObserverCheckBox.Checked = $global:cfgMainKeepObserver
} else { 
    $global:KeepObserverCheckBox.Checked = $false
}
$global:KeepObserverCheckBox.add_CheckedChanged({
    if ($global:KeepObserverCheckBox.Checked) {
        $global:ExcludedFolders += $global:ObserverFolderPath
    } else {
        $global:ExcludedFolders = $global:ExcludedFolders -ne $global:ObserverFolderPath
    }
    $global:cfgMainKeepObserver = $global:KeepObserverCheckBox.Checked
    $global:Config.Main.KeepObserver = $global:cfgMainKeepObserver
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($global:KeepObserverCheckBox)

# Keep Crashes checkbox
$global:KeepCrashesCheckBox = CreateCheckBox -text "Säästä Crash reportit" -locx 160 -locy 160 -sizex 150 -sizey 20
if ($global:cfgMainKeepCrash -is [bool]) {
    $global:KeepCrashesCheckBox.Checked = $global:cfgMainKeepCrash
} else { 
    $global:cfgMainKeepCrash.Checked = $false 
}
$global:KeepCrashesCheckBox.add_CheckedChanged({
    if ($global:KeepCrashesCheckBox.Checked) {
        $global:ExcludedFolders += $global:CrashesFolderPath
    } else {
        $global:ExcludedFolders = $global:ExcludedFolders -ne $global:CrashesFolderPath
        }
    $global:cfgMainKeepCrash = $global:KeepCrashesCheckBox.Checked
    $global:Config.Main.KeepCrash = $global:cfgMainKeepCrash
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
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
$GetConfigValuesLabel = CreateLabel -text "Hakee GameUserSettings.inistä desimaali arvot, jotka voi bugaa/aiheuttaa stutteria enginessä" -locx 20 -locy 230 -sizex 300 -sizey 30
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

# GetPath at start
Get-ProgramPath
if ($global:MoviesPathFound = $true) {
    Check-Movies
}
GetValues-GameUserSettings

# Muuta GameUserSettings.ini arvot button
$ChangeConfigValuesButton = CreateButton -text "Katso arvot" -locx 20 -locy 260 -sizex 80 -sizey 20
$ChangeConfigValuesButton.Add_Click({
    GetValues-GameUserSettings
    ChangeValues-GameUserSettings
})
$MainForm.Controls.Add($ChangeConfigValuesButton)

# Logopaketti Text
$ObserverPackLabel = CreateLabel -text "Vaihda Logopaketti" -locx 415 -locy 490 -sizex 150 -sizey 20
$MainForm.Controls.Add($ObserverPackLabel)

# Test löytyykö Logopakettien kansio, tekee jos ei löydy
if (-not (Test-Path -Path $DefaultSavedObserverPackLocation -PathType Container)) {
    New-Item -Path $DefaultSavedObserverPackLocation -ItemType Directory
    $global:cfgLaunchObserverPackSelect = "Default"
    $global:Config.Launch.ObserverPackSelect = $global:cfgLaunchObserverPackSelect
}

# Logopaketti dropdown
$global:ObserverPackSelect = CreateDropDownMenu -locx 415 -locy 510 -sizex 150 -sizey 20

# Haetaan valmiit logopaketit dropdownin valinnoiksi
$global:SelectionFolders = Get-ChildItem -Path $global:DefaultSavedObserverPackLocation -Directory | Select-Object -ExpandProperty Name
$global:ObserverPackSelect.Items.AddRange($global:SelectionFolders)
$global:ObserverPackSelect.Items.Add("Default") | Out-Null
$global:ObserverPackSelect.SelectedItem = $global:cfgLaunchObserverPackSelect
$global:ObserverPackSelect.add_SelectedIndexChanged({
    $global:cfgLaunchObserverPackSelect = $global:ObserverPackSelect.SelectedItem
    $global:Config.Launch.ObserverPackSelect = $global:cfgLaunchObserverPackSelect
    if ($global:AutoSaveMenuItem.Checked) {
       $global:Config | Out-IniFile -Force "Config.ini"
    }
})

$MainForm.Controls.Add($global:ObserverPackSelect)

# Logopaketti vaihto button
$ChangeObserverPackButton = CreateButton -text "Vaiha nyt" -locx 410 -locy 530 -sizex 80 -sizey 20
$ChangeObserverPackButton.Add_Click({
    Change-LogoPack{
    $global:cfgLaunchObserverPackSelect = $global:ObserverPackSelect.SelectedItem
    $global:Config.Launch.ObserverPackSelect = $global:cfgLaunchObserverPackSelect
    $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($ChangeObserverPackButton)

# logopaketin vaihto checkbox starttiin
$global:ChangeObserverPackAtStartCheckBox = CreateCheckBox -text "Vaiha logopaketti" -locx 360 -locy 110 -sizex 130 -sizey 20
if ($global:cfgLaunchChangeLogo -is [bool]) { 
    $global:ChangeObserverPackAtStartCheckBox.Checked = $global:cfgLaunchChangeLogo
} else { 
   $global:ChangeObserverPackAtStartCheckBox.Checked = $false
} 
$global:ChangeObserverPackAtStartCheckBox.add_CheckedChanged({
    $global:cfgLaunchChangeLogo = $global:ChangeObserverPackAtStartCheckBox.Checked 
    $global:Config.Launch.ChangeLogo = $global:cfgLaunchChangeLogo
    if ($global:AutoSaveMenuItem.Checked) {
       $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($global:ChangeObserverPackAtStartCheckBox)

<# # Disabled work in progress
 Logopaketti new button
 $CreateObserverPackButton = CreateButton -text "Luo Uusi" -locx 490 -locy 530 -sizex 80 -sizey 20
 $CreateObserverPackButton.Add_Click({
     Create-LogoPackForm
})
$MainForm.Controls.Add($CreateObserverPackButton)
#>

# Launch Settings Label
$LaunchSettingsLabel = CreateLabel -text "Do on Launch" -locx 360 -locy 50 -sizex 300 -sizey 15
$MainForm.Controls.Add($LaunchSettingsLabel)

# Launch Settings Checkbox
$global:EnableLaunchSettingsCheckBox = CreateCheckBox -text "Enable Launch Settings" -locx 360 -locy 70 -sizex 150 -sizey 20
if ($global:cfgLaunchEnableSettings -is [bool]) { 
    $global:EnableLaunchSettingsCheckBox.Checked = $global:cfgLaunchEnableSettings
} else { 
    $global:EnableLaunchSettingsCheckBox.Checked = $false
} 
$global:EnableLaunchSettingsCheckBox.add_CheckedChanged({
    $global:DeleteSavedAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:KillExtraProcessCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:BootReminderCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:KillDuplicateTslGameCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:KillPUBGLauncherCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:KillBELauncherCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:BootReminderSelect.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:BootReminderLabel.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:BootReminderTimeLeftLabel.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:KeepReplaysAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:KeepObserverAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:KeepCrashesAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:DeleteMoviesAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
    $global:ChangeObserverPackAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked

    $global:cfgLaunchEnableSettings = $global:EnableLaunchSettingsCheckBox.Checked 
    $global:Config.Launch.EnableSettings = $global:cfgLaunchEnableSettings
    if ($global:AutoSaveMenuItem.Checked) {
       $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($global:EnableLaunchSettingsCheckBox)


# Poista leffat checkbox startille
$global:DeleteMoviesAtStartCheckBox = CreateCheckBox -text "Poista Leffat" -locx 360 -locy 90 -sizex 130 -sizey 20
if ($global:cfgLaunchDeleteMovies -is [bool]) { 
    $global:DeleteMoviesAtStartCheckBox.Checked = $global:cfgLaunchDeleteMovies
} else { 
    $global:DeleteMoviesAtStartCheckBox.Checked = $false
} 
$global:DeleteMoviesAtStartCheckBox.add_CheckedChanged({
    $global:cfgLaunchDeleteMovies = $global:DeleteMoviesAtStartCheckBox.Checked 
    $global:Config.Launch.DeleteMovies = $global:cfgLaunchDeleteMovies
    if ($global:AutoSaveMenuItem.Checked) {
       $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($global:DeleteMoviesAtStartCheckBox)

# Tyhjennä saved folder checkbox startille
$global:DeleteSavedAtStartCheckBox = CreateCheckBox -text "Tyhjennä Saved Folder" -locx 360 -locy 130 -sizex 170 -sizey 20
if ($global:cfgLaunchDeleteMovies -is [bool]) { 
    $global:DeleteSavedAtStartCheckBox.Checked = $global:cfgLaunchDeleteSaved
} else { 
    $global:DeleteSavedAtStartCheckBox.Checked = $false
}

# Lisävalintojen Visibility
$global:DeleteSavedAtStartCheckBox.add_CheckedChanged({
    $global:KeepReplaysAtStartCheckBox.Enabled = $global:DeleteSavedAtStartCheckBox.Checked
    $global:KeepObserverAtStartCheckBox.Enabled = $global:DeleteSavedAtStartCheckBox.Checked
    $global:KeepCrashesAtStartCheckBox.Enabled = $global:DeleteSavedAtStartCheckBox.Checked
    $global:KeepReplaysAtStartCheckBox.Visible = $global:DeleteSavedAtStartCheckBox.Checked
    $global:KeepObserverAtStartCheckBox.Visible = $global:DeleteSavedAtStartCheckBox.Checked
    $global:KeepCrashesAtStartCheckBox.Visible = $global:DeleteSavedAtStartCheckBox.Checked
    # Siirretään alempia checkboxeja valinnan mukaan
    if ($global:DeleteSavedAtStartCheckBox.Checked) {
        $global:KillExtraProcessCheckBox.Location = New-Object System.Drawing.Point (360, 210)
        $global:KillDuplicateTslGameCheckBox.Location = New-Object System.Drawing.Point(380, 230)
        $global:KillPUBGLauncherCheckBox.Location = New-Object System.Drawing.Point(380, 250)
        $global:KillBELauncherCheckBox.Location = New-Object System.Drawing.Point(380, 270)
    } else {
        $global:KillExtraProcessCheckBox.Location = New-Object System.Drawing.Point(360, 150)
        $global:KillDuplicateTslGameCheckBox.Location = New-Object System.Drawing.Point(380, 170)
        $global:KillPUBGLauncherCheckBox.Location = New-Object System.Drawing.Point(380, 190)
        $global:KillBELauncherCheckBox.Location = New-Object System.Drawing.Point(380, 210)
    }
    $global:cfgLaunchDeleteSaved = $global:DeleteSavedAtStartCheckBox.Checked
    $global:Config.Launch.DeleteSaved = $global:cfgLaunchDeleteSaved
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }
})


$MainForm.Controls.Add($global:DeleteSavedAtStartCheckBox)

# Keep Replays checkbox startille
$global:KeepReplaysAtStartCheckBox = CreateCheckBox -text "Säästä Replat" -locx 380 -locy 150 -sizex 170 -sizey 20
if ($global:cfgLaunchKeepReplays -is [bool]) { 
    $global:KeepReplaysAtStartCheckBox.Checked = $global:cfgLaunchKeepReplays
} else { 
    $global:KeepReplaysAtStartCheckBox.Checked = $false
}
$global:KeepReplaysAtStartCheckBox.add_CheckedChanged({
    if ($global:KeepReplaysAtStartCheckBox.Checked) {
        $global:ExcludedFoldersAtStart += $global:ReplayFolderPath
    } else {
        $global:ExcludedFoldersAtStart = $global:ExcludedFoldersAtStart -ne $global:ReplayFolderPath
    }
    $global:cfgLaunchKeepReplays = $global:KeepReplaysAtStartCheckBox.Checked
    $global:Config.Launch.KeepReplays = $global:cfgLaunchKeepReplays
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($global:KeepReplaysAtStartCheckBox)

# Keep Observerpack checkbox startille
$global:KeepObserverAtStartCheckBox = CreateCheckBox -text "Säästä Logopaketti" -locx 380 -locy 170 -sizex 170 -sizey 20
if ($global:cfgLaunchKeepObserver -is [bool]) {
    $global:KeepObserverAtStartCheckBox.Checked = $global:cfgLaunchKeepObserver
} else {
    $global:KeepObserverAtStartCheckBox.Checked = $false
}
$global:KeepObserverAtStartCheckBox.add_CheckedChanged({
    if ($global:KeepObserverAtStartCheckBox.Checked) {
        $global:ExcludedFoldersAtStart += $global:ObserverFolderPath
    } else {
        $global:ExcludedFoldersAtStart = $global:ExcludedFoldersAtStart -ne $global:ObserverFolderPath
        }
    $global:cfgLaunchKeepObserver = $global:KeepObserverAtStartCheckBox.Checked
    $global:Config.Launch.KeepObserver = $global:cfgLaunchKeepObserver
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($global:KeepObserverAtStartCheckBox)

# Keep Crashes checkbox
$global:KeepCrashesAtStartCheckBox = CreateCheckBox -text "Säästä Crash reportit" -locx 380 -locy 190 -sizex 170 -sizey 20
if ($global:cfgLaunchKeepCrash -is [bool]) {
    $global:KeepCrashesAtStartCheckBox.Checked = $global:cfgLaunchKeepCrash
} else {
    $global:KeepCrashesAtStartCheckBox.Checked = $false
}
$global:KeepCrashesAtStartCheckBox.add_CheckedChanged({
    if ($global:KeepCrashesAtStartCheckBox.Checked) {
        $global:ExcludedFoldersAtStart += $global:CrashesFolderPath
    } else {
        $global:ExcludedFoldersAtStart = $global:ExcludedFoldersAtStart -ne $global:CrashesFolderPath
    }
    $global:cfgLaunchKeepCrash = $global:KeepCrashesAtStartCheckBox.Checked
    $global:Config.Launch.KeepCrash = $global:cfgLaunchKeepCrash
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }   
})
$MainForm.Controls.Add($global:KeepCrashesAtStartCheckBox)


# Muistutus boottia peli 3-4h crashin varalta
$global:BootReminderCheckBox = CreateCheckBox -text "Muistutus Boottaa peli" -locx 360 -locy 290 -sizex 135 -sizey 20
if ($global:cfgLaunchBootReminder -is [bool]) {
    $global:BootReminderCheckBox.Checked = $global:cfgLaunchBootReminder
} else {
$global:BootReminderCheckBox.Checked = $false
}
$global:BootReminderCheckBox.add_CheckedChanged({
    $global:BootReminderSelect.Enabled = $global:BootReminderCheckBox.Checked
    $global:BootReminderSelect.Visible = $global:BootReminderCheckBox.Checked
    $global:BootReminderLabel.Enabled = $global:BootReminderCheckBox.Checked
    $global:BootReminderLabel.Visible = $global:BootReminderCheckBox.Checked
    $global:BootReminderTimeLeftLabel.Enabled = $global:BootReminderCheckBox.Checked
    $global:BootReminderTimeLeftLabel.Visible = $global:BootReminderCheckBox.Checked
    $global:cfgLaunchBootReminder = $global:BootReminderCheckBox.Checked
    $global:Config.Launch.BootReminder = $global:cfgLaunchBootReminder
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }   
})
$MainForm.Controls.Add($global:BootReminderCheckBox)

# Boot timer dropdown
$global:BootReminderSelect = CreateDropDownMenu -locx 360 -locy 315 -sizex 30 -sizey 20
1..4 | ForEach-Object { $global:BootReminderSelect.Items.Add($_) } | Out-Null
$cfgLaunchBootTimerInt = [int]$global:cfgLaunchBootTimer
$global:BootReminderSelect.SelectedItem = $global:cfgLaunchBootTimerInt
$global:BootReminderSelect.add_SelectedIndexChanged({
    $global:cfgLaunchBootTimerInt = $global:BootReminderSelect.SelectedItem
    $global:cfgLaunchBootTimer = $global:cfgLaunchBootTimerInt.ToString()
    $global:Config.Launch.BootTimer = $global:cfgLaunchBootTimer
    if ($global:AutoSaveMenuItem.Checked) {
       $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($global:BootReminderSelect)

# Boot timer label
$BootReminderLabel = CreateLabel -text "Tuntia" -locx 390 -locy 319 -sizex 40 -sizey 15
$MainForm.Controls.Add($BootReminderLabel)

# Boot timer time left label
$global:BootReminderTimeLeftLabel = CreateLabel -text "Time left: $global:CountDown" -locx 430 -locy 319 -sizex 150 -sizey 15
$MainForm.Controls.Add($global:BootReminderTimeLeftLabel)

# Tapa extra prosessit checkbox startille
$global:KillExtraProcessCheckBox = CreateCheckBox -text "Tapa extra prosessit" -locx 360 -locy 210 -sizex 130 -sizey 20
if ($global:cfgLaunchKillProcess -is [bool]) {
    $global:KillExtraProcessCheckBox.Checked = $global:cfgLaunchKillProcess
} else {
$global:KillExtraProcessCheckBox.Checked = $false
}
# Lisävalintojen Visibility
$global:KillExtraProcessCheckBox.add_CheckedChanged({
    $global:KillDuplicateTslGameCheckBox.Enabled = $global:KillExtraProcessCheckBox.Checked
    $global:KillPUBGLauncherCheckBox.Enabled = $global:KillExtraProcessCheckBox.Checked
    $global:KillBELauncherCheckBox.Enabled = $global:KillExtraProcessCheckBox.Checked
    $global:KillDuplicateTslGameCheckBox.Visible = $global:KillExtraProcessCheckBox.Checked
    $global:KillPUBGLauncherCheckBox.Visible = $global:KillExtraProcessCheckBox.Checked
    $global:KillBELauncherCheckBox.Visible = $global:KillExtraProcessCheckBox.Checked
    $global:cfgLaunchKillProcess = $global:KillExtraProcessCheckBox.Checked
    $global:Config.Launch.KillProcess = $global:cfgLaunchKillProcess
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($global:KillExtraProcessCheckBox)

# Kill Duplicate TslGame.exe checkbox startille
$global:KillDuplicateTslGameCheckBox = CreateCheckBox -text "Tapa turha TslGame.exe" -locx 380 -locy 230 -sizex 170 -sizey 20
if ($global:cfgLaunchKillDuplicateTslGame -is [bool]) {
    $global:KillDuplicateTslGameCheckBox.Checked = $global:cfgLaunchKillDuplicateTslGame
} else {
$global:KillDuplicateTslGameCheckBox.Checked = $false
}
$global:KillDuplicateTslGameCheckBox.add_CheckedChanged({
    $global:cfgLaunchKillDuplicateTslGame = $global:KillDuplicateTslGameCheckBox.Checked
    $global:Config.Launch.KillDuplicateTslGame = $global:cfgLaunchKillDuplicateTslGame
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }
})

$MainForm.Controls.Add($global:KillDuplicateTslGameCheckBox)

# Kill ExecPubg.exe checkbox startille
$global:KillPUBGLauncherCheckBox = CreateCheckBox -text "Tapa ExecPubg.exe" -locx 380 -locy 250 -sizex 170 -sizey 20
if ($global:cfgLaunchKillPubgLauncher -is [bool]) {
    $global:KillPUBGLauncherCheckBox.Checked = $global:cfgLaunchKillPubgLauncher
} else {
$global:KillPUBGLauncherCheckBox.Checked = $false
}
$global:KillPUBGLauncherCheckBox.add_CheckedChanged({
    $global:cfgLaunchKillPubgLauncher = $global:KillPUBGLauncherCheckBox.Checked
    $global:Config.Launch.KillPubgLauncher = $global:cfgLaunchKillPubgLauncher
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    } 
})

$MainForm.Controls.Add($global:KillPUBGLauncherCheckBox)

# Kill TslGame_BE.exe checkbox
$global:KillBELauncherCheckBox = CreateCheckBox -text "Tapa TslGame_BE.exe" -locx 380 -locy 270 -sizex 170 -sizey 20
if ($global:cfgLaunchKillBELauncher -is [bool]) {
    $global:KillBELauncherCheckBox.Checked = $global:cfgLaunchKillBELauncher
} else {
$global:KillBELauncherCheckBox.Checked = $false
}
$global:KillBELauncherCheckBox.add_CheckedChanged({
    $global:cfgLaunchKillBELauncher = $global:KillBELauncherCheckBox.Checked
    $global:Config.Launch.KillBELauncher = $global:cfgLaunchKillBELauncher
    if ($global:AutoSaveMenuItem.Checked) {
        $global:Config | Out-IniFile -Force "Config.ini"
    }
}) 
$MainForm.Controls.Add($global:KillBELauncherCheckBox)

# Piilotetaa ja siirretään lisävalinnat
if (-not ($global:DeleteSavedAtStartCheckBox.Checked)) {
    $global:KillExtraProcessCheckBox.Location = New-Object System.Drawing.Point(360, 150)
    $global:KillDuplicateTslGameCheckBox.Location = New-Object System.Drawing.Point(380, 170)
    $global:KillPUBGLauncherCheckBox.Location = New-Object System.Drawing.Point(380, 190)
    $global:KillBELauncherCheckBox.Location = New-Object System.Drawing.Point(380, 210)
}

# Säädetään näkyvyydet tallenettujen settareiden mukaan
$global:KeepReplaysAtStartCheckBox.Enabled = $global:DeleteSavedAtStartCheckBox.Checked
$global:KeepObserverAtStartCheckBox.Enabled = $global:DeleteSavedAtStartCheckBox.Checked
$global:KeepCrashesAtStartCheckBox.Enabled = $global:DeleteSavedAtStartCheckBox.Checked
$global:KeepReplaysAtStartCheckBox.Visible = $global:DeleteSavedAtStartCheckBox.Checked
$global:KeepObserverAtStartCheckBox.Visible = $global:DeleteSavedAtStartCheckBox.Checked
$global:KeepCrashesAtStartCheckBox.Visible = $global:DeleteSavedAtStartCheckBox.Checked
$global:KillDuplicateTslGameCheckBox.Enabled = $global:KillExtraProcessCheckBox.Checked
$global:KillPUBGLauncherCheckBox.Enabled = $global:KillExtraProcessCheckBox.Checked
$global:KillBELauncherCheckBox.Enabled = $global:KillExtraProcessCheckBox.Checked
$global:KillDuplicateTslGameCheckBox.Visible = $global:KillExtraProcessCheckBox.Checked
$global:KillPUBGLauncherCheckBox.Visible = $global:KillExtraProcessCheckBox.Checked
$global:KillBELauncherCheckBox.Visible = $global:KillExtraProcessCheckBox.Checked
$global:BootReminderSelect.Enabled = $global:BootReminderCheckBox.Checked
$global:BootReminderSelect.Visible = $global:BootReminderCheckBox.Checked
$global:BootReminderLabel.Enabled = $global:BootReminderCheckBox.Checked
$global:BootReminderLabel.Visible = $global:BootReminderCheckBox.Checked
$global:BootReminderTimeLeftLabel.Enabled = $global:BootReminderCheckBox.Checked
$global:BootReminderTimeLeftLabel.Visible = $global:BootReminderCheckBox.Checked

$global:DeleteSavedAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:KillExtraProcessCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:BootReminderCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:KillDuplicateTslGameCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:KillPUBGLauncherCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:KillBELauncherCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:BootReminderSelect.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:BootReminderLabel.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:BootReminderTimeLeftLabel.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:KeepReplaysAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:KeepObserverAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:KeepCrashesAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:DeleteMoviesAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked
$global:ChangeObserverPackAtStartCheckBox.Enabled = $global:EnableLaunchSettingsCheckBox.Checked

# Launch PUBG button
$LaunchButton = CreateButton -text "Start" -locx 340 -locy 25 -sizex 80 -sizey 20
$LaunchButton.Add_Click({
    Start-PUBG
})
$MainForm.Controls.Add($LaunchButton)

# Kill PUBG button
$KillButton = CreateButton -text "Kill" -locx 420 -locy 25 -sizex 80 -sizey 20
$KillButton.Add_Click({
    Kill-PUBG
})
$MainForm.Controls.Add($KillButton)

# Restart PUBG button 
$RestartButton = CreateButton -text "Restart" -locx 500 -locy 25 -sizex 80 -sizey 20
$RestartButton.Add_Click({
    Restart-PUBG
})
$MainForm.Controls.Add($RestartButton)

# Save Settings button 
$SaveButton = CreateButton -text "Save Settings" -locx 415 -locy 465 -sizex 90 -sizey 20
$SaveButton.Add_Click({
    $global:Config | Out-IniFile -Force Config.ini
})
$MainForm.Controls.Add($SaveButton)


### Siirretty menu valikkoon
<# Remember Settings CheckBox (AutoSave)
$global:AutoSaveCheckBox = CreateCheckBox -text "Muista asetukset" -locx 415 -locy 430 -sizex 150 -sizey 20
if ($global:cfgMainRememberSettings -is [bool]) {
    $global:AutoSaveCheckBox.Checked = $global:cfgMainRememberSettings
} else {
    $global:AutoSaveCheckBox.Checked = $false
}
$global:AutoSaveCheckBox.Add_CheckedChanged({ 
    $global:cfgMainRememberSettings = $global:AutoSaveCheckBox.Checked
    $global:Config.Main.RememberSettings = $global:cfgMainRememberSettings
    if ($global:AutoSaveCheckBox.Checked){ 
        $global:Config | Out-IniFile -Force "Config.ini"
    }
})
$MainForm.Controls.Add($global:AutoSaveCheckBox)#>



$MainForm.ShowDialog()

$MainForm.Dispose()

