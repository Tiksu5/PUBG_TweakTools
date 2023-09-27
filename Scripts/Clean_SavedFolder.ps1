# v0.1
# Settareiden puhistus. Säilyttää kansio rakenteen ja user configin (GameUserSettings.ini)
# Tyhjentää Saved folderin ja sen subfolderit.

function Clean-SavedFolder {
    # Testaa path
    if (-not (Test-Path -Path $global:SavedFolderPath -PathType Container)) {
        [System.Windows.Forms.MessageBox]::Show("Polkua ei löydy: $global:SavedFolderPath") 
        return
    }

    $Files = Get-ChildItem -Path $global:SavedFolderPath -File -Recurse

    foreach ($File in $Files) {
        if ($File.FullName -ne $global:GameUserSettingsPath) {
           # Write-Host "Poistettu: $($File.FullName)"
            Remove-Item -Path $File.FullName -Force
        }      
    }
    $Label5.Text = "Done"
    $Label5.BackColor = [System.Drawing.Color]::Green
}
