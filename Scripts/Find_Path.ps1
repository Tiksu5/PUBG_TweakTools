# v0.1
#

# get-asennuspolku
function Find-PUBGPath {
    $Program = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
               Where-Object { $_.DisplayName -eq $global:ProgramName } |
               Select-Object -First 1
        
        # set-asennuspolku
    if ($Program) {
        Set-ProgramPath -NewPath $Program.InstallLocation
        $global:MainPathLabel.Text = "Asennuspolku löydetty: $global:ProgramPath"
        $global:MainPathLabel.BackColor = [System.Drawing.Color]::Green
        $global:ChangePathTextBox.Text = "$global:ProgramPath"
        return
    } else {
        $global:MainPathLabel.Text = "Asennuspolkua ei löytyny. Syötä polku käsin"
        $global:MainPathLabel.BackColor = [System.Drawing.Color]::Red
        $global:ChangePathTextBox.Text = "*****\SteamLibrary\steamapps\common\PUBG"
    }
}
