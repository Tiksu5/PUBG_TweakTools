#
#

# set-asennuspolku
function Set-ProgramPath {
    param([string]$NewPath)
    $global:ProgramPath = $NewPath
    $MoviesTestPath = $global:ProgramPath + "\TslGame\Content\Movies"
    if (Test-Path -Path $MoviesTestPath) {
        $global:MoviesFolderPath = $global:ProgramPath + "\TslGame\Content\Movies"
        $global:ExcludedFolderPath = $global:ProgramPath + "\TslGame\Content\Movies\AtoZ"
        $global:MoviesPathFound = $true
    } else {
        $global:DeleteMoviesDoneLabel.Text = "Leffakansiota ei löydy"
        $global:DeleteMoviesDoneLabel.BackColor = [System.Drawing.Color]::Yellow
        $global:MoviesPathFound = $false
        write-host "Movies folder 404"
    }
}

# get-asennuspolku
function Find-PubgPath {
    $Program = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
               Where-Object { $_.DisplayName -eq $global:ProgramName } |
               Select-Object -First 1
        
    # set-asennuspolku
    if ($Program) {
        Set-ProgramPath -NewPath $Program.InstallLocation
        $global:MainPathLabel.Text = "Asennuspolku löydetty: $global:ProgramPath"
        $global:MainPathLabel.BackColor = [System.Drawing.Color]::Green
        $global:ChangePathTextBox.Text = "$global:ProgramPath"
        $global:ProgramPathFound = $true
        $global:Config.Main.PubgPath = "$global:ProgramPath"
        $global:Config | Out-IniFile -Force "Config.ini"
    } else {
        $global:MainPathLabel.Text = "Asennuspolkua ei löytyny. Syötä polku käsin"
        $global:MainPathLabel.BackColor = [System.Drawing.Color]::Red
        $global:ChangePathTextBox.Text = "*****\SteamLibrary\steamapps\common\PUBG"
        $global:ProgramPathFound = $false
    }
}
# Testataan löytyykö polku configista ja onko se oikea
function Get-ProgramPath {
    if ([string]::IsNullOrEmpty($global:Config.Main.PubgPath)) {
        Find-PubgPath
    } else { 
        $EngineTestPath = $global:Config.Main.PubgPath + "\Engine"
        $TslGameTestPath = $global:Config.Main.PubgPath + "\TslGame"
        if ((Test-Path -Path $EngineTestPath) -and (Test-Path -Path $TslGameTestPath)) {
            $global:ProgramPath = $global:Config.Main.PubgPath
            $global:MainPathLabel.Text = "Asennuspolku löydetty: $global:ProgramPath"
            $global:MainPathLabel.BackColor = [System.Drawing.Color]::Green
            $global:ChangePathTextBox.Text = "$global:ProgramPath"
            $global:ProgramPathFound = $true
            # Testataan löytyykö leffakansio
            $MoviesTestPath = $global:ProgramPath + "\TslGame\Content\Movies"
            if (Test-Path -Path $MoviesTestPath) {
                $global:MoviesFolderPath = $global:ProgramPath + "\TslGame\Content\Movies"
                $global:ExcludedFolderPath = $global:ProgramPath + "\TslGame\Content\Movies\AtoZ"
                $global:MoviesPathFound = $true
            } else {
                $global:DeleteMoviesDoneLabel.Text = "Leffakansiota ei löydy"
                $global:DeleteMoviesDoneLabel.BackColor = [System.Drawing.Color]::Yellow
                $global:MoviesPathFound = $false
                write-host "Movies folder 404"
            }
        } else { 
            Find-PubgPath
        }    
    }
}
