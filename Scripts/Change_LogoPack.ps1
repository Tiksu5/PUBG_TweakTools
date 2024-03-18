#
#

# Change LogoPack
function Change-LogoPack {
    # Check että observer folder löytyy/luo se jos puuttuu
    if (-not (Test-Path -Path $global:ObserverFolderPath -PathType Container)) {
        New-Item -ItemType Directory -Path $global:ObserverFolderPath -Force
        return
    }
    # Tyhjennä observer kansio
    $script:ItemsInObserverFolder = Get-ChildItem -Path $global:ObserverFolderPath -Force -Recurse
    foreach ($Item in $script:ItemsInObserverFolder) {
        $ItemsInsideDirectory = Get-ChildItem -Path $Item.FullName -File -Recurse
        foreach ($ItemInsideDirectory in $ItemsInsideDirectory) {
            Remove-Item -Path $ItemInsideDirectory.FullName -Force -Recurse
        }
    }
    # Kopioi uus paketti tilalle
    if ($global:ObserverPackSelectedItem -ne "Default") {
        $script:FilesInSelectedObserverPack = Get-ChildItem -Path $global:ObserverPackSelectedItem -Force -Recurse
        foreach ($File in $script:FilesInSelectedObserverPack) {
            $FilesInsideDirectory = Get-ChildItem -Path $File.FullName
            foreach ($FileInsideDirectory in $FilesInsideDirectory) {
                Copy-Item -Path $FileInsideDirectory.FullName -Destination $global:ObserverFolderPath -Force -Recurse 
            }
        }
    }
}


# ObserverPackForm
function Create-LogoPackForm {
    # Form
    $CreateLogoPackForm  = New-Object Windows.Forms.Form -Property @{
        Text = "Create LogoPack"
        Size = New-Object Drawing.Size(800, 1000)
        StartPosition = "CenterScreen"
    }
    # Labels
    $TeamCountLabel = New-Object System.Windows.Forms.Label -Property @{
        Text = "Number of Teams:"
        Location = New-Object System.Drawing.Point(20, 20)
    }
    $CreateLogoPackForm.Controls.Add($TeamCountLabel)

    # Tiimi määrä valitsin
    $NumericUpDownTeamCount = New-Object System.Windows.Forms.NumericUpDown -Property @{
        Location = New-Object System.Drawing.Point(150, 20)
        Size = New-Object System.Drawing.Size(40, 20)
    }
    $CreateLogoPackForm.Controls.Add($NumericUpDownTeamCount)

    # Buttons
    $GenerateTeamsButton = New-Object System.Windows.Forms.Button -Property @{
        Text = "Select"
        Location = New-Object System.Drawing.Point(200, 15)
    }
    $GenerateTeamsButton.Add_Click({
        $TeamCount = [int]$NumericUpDownTeamCount.Value
        Generate-TeamInputFields $TeamCount
        })
    $CreateLogoPackForm.Controls.Add($GenerateTeamsButton)

    $CreateLogoPackForm.ShowDialog()
}

# ObserverPack Form
function Generate-TeamInputFields($TeamCount) {
    $CreateLogoPackForm.Controls | Where-Object { $_.Name -like "team*" } | ForEach-Object {
        $CreateLogoPackForm.Controls.Remove($_)
        $_.Dispose()    
    }

    $teamsPerColumn = 8
    $columnIndex = 0

    # Tee input fieldit
    for ($i = 1; $i -le $TeamCount; $i++) {
        # Laskuri tiimeille
        $ColumnIndex = [math]::floor(($i - 1) / $TeamsPerColumn)

        # Labels
        $TeamNameLabelLocation = New-Object System.Drawing.Point
        $TeamNameLabelLocation.X = 20 + $ColumnIndex * 250
        $TeamNameLabelLocation.Y = 60 + (($i - 1) % $TeamsPerColumn) * 110
        $TeamNameLabel = New-Object System.Windows.Forms.Label -Property @{
            Text = "Team $i Name"
            Location = $TeamNameLabelLocation
            Size = New-Object Drawing.Size(120, 20)
        }
        $CreateLogoPackForm.Controls.Add($TeamNameLabel)

        $TeamShortNameLabelLocation = New-Object System.Drawing.Point
        $TeamShortNameLabelLocation.X = 20 + $ColumnIndex * 250
        $TeamShortNameLabelLocation.Y = 90 + (($i - 1) % $TeamsPerColumn) * 110
        $TeamShortNameLabel = New-Object System.Windows.Forms.Label -Property @{
            Text = "Team $i Short Name"
            Location = $TeamShortNameLabelLocation
            Size = New-Object Drawing.Size(120, 20)
        }
        $CreateLogoPackForm.Controls.Add($TeamShortNameLabel)

        $TeamLogoLabelLocation = New-Object System.Drawing.Point
        $TeamLogoLabelLocation.X = 20 + $ColumnIndex * 250
        $TeamLogoLabelLocation.Y = 120 + (($i - 1) % $TeamsPerColumn) * 110
        $TeamLogoLabel = New-Object System.Windows.Forms.Label -Property @{
            Text = "Team $i Logo"
            Location = $TeamLogoLabelLocation
            Size = New-Object Drawing.Size(120, 20)
        }
        $CreateLogoPackForm.Controls.Add($TeamLogoLabel)

        # Textboxes
        $TeamNameTextBoxLocation = New-Object System.Drawing.Point
        $TeamNameTextBoxLocation.X = 140 + $ColumnIndex * 250
        $TeamNameTextBoxLocation.Y = 60 + (($i - 1) % $TeamsPerColumn) * 110
        $TeamNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Location = $TeamNameTextBoxLocation
        }
        $CreateLogoPackForm.Controls.Add($TeamNameTextBox)

        $TeamShortNameTextBoxLocation = New-Object System.Drawing.Point
        $TeamShortNameTextBoxLocation.X = 140 + $ColumnIndex * 250
        $TeamShortNameTextBoxLocation.Y = 90 + (($i - 1) % $TeamsPerColumn) * 110
        $TeamShortNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Location = $TeamShortNameTextBoxLocation
        }
        $CreateLogoPackForm.Controls.Add($TeamShortNameTextBox)

        # PictureBox previewille
        $PreviewPictureBoxLocation = New-Object System.Drawing.Point
        $PreviewPictureBoxLocation.X = 250 + $ColumnIndex * 250
        $PreviewPictureBoxLocation.Y = 40 + (($i - 1) % $TeamsPerColumn) * 110
        $script:PreviewPictureBox = New-Object System.Windows.Forms.PictureBox -Property @{
            Size = New-Object System.Drawing.Size(100, 100)
            Location = $PreviewPictureBoxLocation
            SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
            BorderStyle = 'FixedSingle'
            Image = $null
        }
        $CreateLogoPackForm.Controls.Add($script:PreviewPictureBox)

        # Nappi Logon valinnalle
        $BrowseLogoButtonLocation = New-Object System.Drawing.Point
        $BrowseLogoButtonLocation.X = 140 + $ColumnIndex * 250
        $BrowseLogoButtonLocation.Y = 120 + (($i - 1) % $TeamsPerColumn) * 110
        $BrowseLogoButton = New-Object System.Windows.Forms.Button -Property @{
            Text = "Hae Logo"
            Location = $BrowseLogoButtonLocation
            Size = New-Object Drawing.Size(65, 20)
        }

        $BrowseLogoButton.Add_Click({
            $PictureBoxToUpdate = $script:PreviewPictureBox
            $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
            $FileDialog.Filter = "Image Files (*.jpg; *.png; *.bmp)|*.jpg;*.png;*.bmp"
    
            if ($FileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                # Call the function to update the image with the selected file
                Update-PictureBoxImage -ImagePath $FileDialog.FileName
            }
        })
        $CreateLogoPackForm.Controls.Add($BrowseLogoButton)

        # submit button
        $SubmitButton = New-Object System.Windows.Forms.Button -Property @{
            Text = "Tallenna"
            Location = New-Object System.Drawing.Point(280, 15)
        }
        $SubmitButton.Add_Click({
            #
            #
            #
            $CreateLogoPackForm.Close()
        })
        $CreateLogoPackForm.Controls.Add($SubmitButton)                 
    }
}


function Update-PictureBoxImage {
    param(
        [string]$ImagePath
    )

    if (Test-Path $ImagePath) {
        # Access the Image property of the PictureBox directly
        $script:PreviewPictureBox.Image = [System.Drawing.Image]::FromFile($ImagePath)
    } else {
        Write-Host "Image not found at $ImagePath"
    }
}