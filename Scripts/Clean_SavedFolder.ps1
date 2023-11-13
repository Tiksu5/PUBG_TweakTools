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
    # get itemit
    $script:ItemsInSavedFolder = Get-ChildItem -Path $global:SavedFolderPath -Force -Recurse
    # array poistettaville
    $ItemsToDelete = @()
    foreach ($Item in $script:ItemsInSavedFolder) {
        $exclude = $false
        # Ignore User Config
        if ($Item.FullName -eq $global:GameUserSettingsPath) {
            continue
        }
        # Ignore muut valitut kansiot
        if (-not $Item.PSIsContainer) {
            foreach ($ExcludedFolder in $global:ExcludedFolders) {
                if ($Item.FullName -like "$ExcludedFolder*") {
                    $exclude = $true
                    break             
                }
            }
        }
        if (-not $exclude -and -not $Item.PSIsContainer) {
            $ItemsToDelete += $Item
        }
    }
    # Check onko poistettavaa
    if ($ItemsToDelete.Count -eq 0) {
        $global:DeleteSavedFolderDoneLabel.Text = "Ei poistettavia filuja"
        $global:DeleteSavedFolderDoneLabel.BackColor = [System.Drawing.Color]::Yellow
        return
    }
    # user confirm poistolle
    $confirmationResult = Confirm-Dialog
    if ($confirmationResult -eq [Windows.Forms.DialogResult]::Yes) {
        foreach ($Item in $ItemsToDelete) {
            Remove-Item -Path $Item.FullName -Force
        }
        $global:DeleteSavedFolderDoneLabel.Text = "Saved kansio siivottu!"
        $global:DeleteSavedFolderDoneLabel.BackColor = [System.Drawing.Color]::Green
    } else {
        $global:DeleteSavedFolderDoneLabel.Text = "Poisto keskeytetty"
        $global:DeleteSavedFolderDoneLabel.BackColor = [System.Drawing.Color]::Yellow
    }
}