#Config

#
#

function Create-NewIni {
    $NewINIContent = [ordered] @{
        Main = [ordered] @{
            "PubgPath" = ""
            "HideConsole" = $true
            "RememberSettings" = $true
            "KeepReplays" = $false
            "KeepObserver" = $false
            "KeepCrash" = $false
        }
        Launch = [ordered] @{
            "DeleteMovies" = $true
            "DeleteSaved" = $true
            "KeepReplays" = $true
            "KeepObserver" = $true
            "KeepCrash" = $false
            "KillProcess" = $true
            "KillDuplicateTslGame" = $true
            "KillPubgLauncher" = $true
            "KillBELauncher" = $true
            "BootReminder" = $false
            "BootTimer" = "4"
            "ObserverPackSelect" = "Flags and numbers"
            "ChangeLogo" = "true"
            "EnableSettings"= "true"
            
        }
    }
        $NewINIContent | Out-IniFile "config.ini"
}



# Get Configs
function Get-Config {
    if (Test-Path -Path $global:ConfigPath) {
        $global:Config = Get-IniContent $global:ConfigPath
    } else {
        Create-NewIni
        $global:Config = Get-IniContent $global:ConfigPath
    }
    foreach ($SectionName in $global:Config.Keys) {
        $Section = $global:Config[$SectionName]
        foreach ($Key in $Section.Keys) {
            $VariableName = "global:cfg$SectionName$Key"
            $Value = $Section[$Key]
            switch ($value){
                "True" { $NewValue = $true }
                "False" { $NewValue = $false }
                default { $NewValue = $Value }
            }
            Set-Variable -Name $VariableName -Value $NewValue   
        }
    }




  <#$global:cfgPath = $global:Config.Main.PubgPath
    $global:cfgMainKeepConsole = [bool]::parse($global:Config.Main.HideConsole)
    $global:cfgMainKeepReplays = [bool]::parse($global:Config.Main.KeepReplays)
    $global:cfgMainKeepObserver = [bool]::parse($global:Config.Main.KeepObserver)
    $global:cfgMainKeepCrash = [bool]::parse($global:Config.Main.KeepCrash)
    $global:cfgAutoSave = [bool]::parse($global:Config.Main.RememberSettings)
    $global:cfgDeleteMovies = [bool]::parse($global:Config.Launch.DeleteMovies)
    $global:cfgCleanSaved = [bool]::parse($global:Config.Launch.CleanSaved)
    $global:cfgKeepReplay = [bool]::parse($global:Config.Launch.KeepReplays)
    $global:cfgKeepObserver = [bool]::parse($global:Config.Launch.KeepObserver)
    $global:cfgKeepCrash = [bool]::parse($global:Config.Launch.KeepCrash)
    $global:cfgKillProcess = [bool]::parse($global:Config.Launch.KillProcess)
    $global:cfgKillDuplicate = [bool]::parse($global:Config.Launch.KillDuplicateTslGame)
    $global:cfgKillPubgLauncher = [bool]::parse($global:Config.Launch.KillPubgLauncher)
    $global:cfgKillBELauncher = [bool]::parse($global:Config.Launch.KillBELauncher)
    $global:cfgBootReminder = [bool]::parse($global:Config.Launch.BootReminder)
    $global:cfgBootTimer = $global:Config.Launch.BootTimer
    $global:cfgObserverPackSelect = $global:Config.Launch.ObserverPackSelect#>
}


    
#$global:PUBGCfg = Get-IniContent $global:GameUserSettingsPath    


#function Get-PUBGCfg {
#    $global:PUBGCfgContent = Get-IniContent "$global:GameUserSettingsPath"
#}
