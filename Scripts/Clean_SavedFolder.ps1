#
# Settareiden puhistus

# Tyhjentää Saved folderin ja sen subfolderit. Säilyttää kansio rakenteen ja user configin (GameUserSettings.ini)
function Clean-SavedFolder {
    # Testaa path
    if (-not (Test-Path -Path $global:SavedFolderPath -PathType Container)) {
        $global:DeleteSavedFolderDoneLabel.Text = "Polkua ei löydy"
        $global:DeleteSavedFolderDoneLabel.BackColor = [System.Drawing.Color]::Red 
        return
    }
    # get items + ignore user config
    $Files = Get-ChildItem -Path $global:SavedFolderPath -File -Recurse
    $Files = $Files | Where-Object { $_.FullName -ne $global:GameUserSettingsPath }
    # Check ennen poistoa
    if ($Files.Count -eq 0) {
        $global:DeleteSavedFolderDoneLabel.Text = "Ei poistettavia filuja"
        $global:DeleteSavedFolderDoneLabel.BackColor = [System.Drawing.Color]::Green
        return
    }
    # Varmistetaan poisto käyttäjältä
    $confirmationResult = Confirm-Dialog
    if ($confirmationResult -eq [Windows.Forms.DialogResult]::Yes) {
        foreach ($File in $Files) {
            Remove-Item -Path $File.FullName -Force   
        } 
        $global:DeleteSavedFolderDoneLabel.Text = "Saved kansio siivottu!"
        $global:DeleteSavedFolderDoneLabel.BackColor = [System.Drawing.Color]::Green
    } else {
        $global:DeleteSavedFolderDoneLabel.Text = "Poisto keskeytetty"
        $global:DeleteSavedFolderDoneLabel.BackColor = [System.Drawing.Color]::Yellow
    }
}
