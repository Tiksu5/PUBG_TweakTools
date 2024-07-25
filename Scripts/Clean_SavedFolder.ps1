#
# Settareiden puhistus

# Tyhjentää Saved folderin ja sen subfolderit. Säilyttää kansio rakenteen ja user configin (GameUserSettings.ini)

function Clean-SavedFolder {
    param (
    [bool]$SkipConfirmation = $false
    )
    #Tarkistetaan onko peli päällä ja skipataan delete jos on.
    if (Get-Process -Name "TslGame" -ErrorAction SilentlyContinue) {
        Write-Host Peli on päällä, skipataan Saved kansion tyhjennys
        return
    }
    # If SkipConfirmation is true, skip user confirmation & label update
    if ($SkipConfirmation) {
        # Testaa path
        if (-not (Test-Path -Path $global:SavedFolderPath -PathType Container)) {
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
            # Ignore User Config Backupit etc.
            if ($Item.FullName -like $global:WindowsNoEditorFolderPath + "\GameUserSettings*") {
                continue
            }
            # Säästetään Engine.ini jos se on asetettu read-only
            if ($Item.FullName -eq $global:WindowsNoEditorFolderPath + "\Engine.ini" -and ($Item.Attributes -band [System.IO.FileAttributes]::ReadOnly)) {
                continue
            }
            # Säästetään Replat jos valittu launch settareista
            if ($global:KeepReplaysAtStartCheckBox.Checked -and $Item.FullName -like "$global:ReplayFolderPath*")) {
                continue
             }
             # Säästetään Logo pack jos valittu launch settareista
            if ($global:KeepObserverAtStartCheckBox.Checked-and $Item.FullName -like "$global:ObserverFolderPath*")) {
                continue
            }
            # Säästetään Crash reportit jos valittu launch settareista
            if ($global:KeepCrashesAtStartCheckBox.Checked-and $Item.FullName -like "$global:CrashesFolderPath*")) {
                continue
            }
            # Ignore muut valitut kansiot
            if (-not $Item.PSIsContainer) {
                foreach ($ExcludedFolderAtStart in $global:ExcludedFoldersAtStart) {
                    if ($Item.FullName -like "$ExcludedFolderAtStart*") {
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
            return
        }
        foreach ($Item in $ItemsToDelete) {
            Remove-Item -Path $Item.FullName -Force
        }
        # Poistaa tyhjät kansiot Replay kansiosta
        $ReplaySubFolders = Get-ChildItem -Path $global:ReplayFolderPath -Directory
        foreach ($ReplaySubFolder in $ReplaySubFolders) {
            $FilesInReplaySubFolder = Get-ChildItem -Path $ReplaySubFolder.FullName -File
            if (-not $FilesInReplaySubFolder) {
                Remove-Item -Path $ReplaySubFolder.FullName -Force -Recurse
            }
        }
        # Poistaa tyhjät kansiot Crashes kansiosta
        $CrashesSubFolders = Get-ChildItem -Path $global:CrashesFolderPath -Directory
        foreach ($CrashesSubFolder in $CrashesSubFolders) {
            $FilesInCrashesSubFolder = Get-ChildItem -Path $CrashesSubFolder.FullName -File
            if (-not $FilesInCrashesSubFolder) {
                Remove-Item -Path $CrashesSubFolder.FullName -Force -Recurse
            }
        }

    } else {
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
            # Ignore User Config Backupit etc.
            if ($Item.FullName -like $global:WindowsNoEditorFolderPath + "\GameUserSettings*") {
                continue
            }
            # Säästetään Engine.ini jos se on asetettu read-only
            if ($Item.FullName -eq $global:WindowsNoEditorFolderPath + "\Engine.ini" -and ($Item.Attributes -band [System.IO.FileAttributes]::ReadOnly)) {
                continue
            }
            # Säästetään Crash reportit jos valittu main settareista
            if ($global:KeepReplaysCheckBox.Checked -and $Item.FullName -like "$global:ReplayFolderPath*")) {
                continue
             }
             # Säästetään Crash reportit jos valittu main settareista
            if ($global:KeepObserverCheckBox.Checked-and $Item.FullName -like "$global:ObserverFolderPath*")) {
                continue
            }
            # Säästetään Crash reportit jos valittu main settareista
            if ($global:KeepCrashesCheckBox.Checked-and $Item.FullName -like "$global:CrashesFolderPath*")) {
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
            $global:DeleteSavedFolderDoneLabel.BackColor = [System.Drawing.Color]::Green
            return
        }
        # user confirm poistolle
        $confirmationResult = Confirm-Dialog
        if ($confirmationResult -eq [Windows.Forms.DialogResult]::Yes) {
            foreach ($Item in $ItemsToDelete) {
                Remove-Item -Path $Item.FullName -Force
            }
            # Poistaa tyhjät kansiot Replay kansiosta
            $ReplaySubFolders = Get-ChildItem -Path $global:ReplayFolderPath -Directory
            foreach ($ReplaySubFolder in $ReplaySubFolders) {
                $FilesInReplaySubFolder = Get-ChildItem -Path $ReplaySubFolder.FullName -File
                if (-not $FilesInReplaySubFolder) {
                    Remove-Item -Path $ReplaySubFolder.FullName -Force -Recurse
                }
            }
            # Poistaa tyhjät kansiot Crashes kansiosta
            $CrashesSubFolders = Get-ChildItem -Path $global:CrashesFolderPath -Directory
            foreach ($CrashesSubFolder in $CrashesSubFolders) {
                $FilesInCrashesSubFolder = Get-ChildItem -Path $CrashesSubFolder.FullName -File
                if (-not $FilesInCrashesSubFolder) {
                    Remove-Item -Path $CrashesSubFolder.FullName -Force -Recurse
                }
            }
            $global:DeleteSavedFolderDoneLabel.Text = "Saved kansio siivottu!"
            $global:DeleteSavedFolderDoneLabel.BackColor = [System.Drawing.Color]::Green
        } else {
            $global:DeleteSavedFolderDoneLabel.Text = "Poisto keskeytetty"
            $global:DeleteSavedFolderDoneLabel.BackColor = [System.Drawing.Color]::Yellow
        }
    }
}

