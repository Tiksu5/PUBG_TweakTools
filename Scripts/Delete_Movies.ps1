# v0.1
# Poistaa Kaikki muut leffa kansiot paitsi AtoZ

function Delete-Movies {
    $MovieFolder = "$global:ProgramPath\TslGame\Content\Movies"
    $ExcludedFolder = "$global:ProgramPath\TslGame\Content\Movies\AtoZ"

    # Testaa Path
    if (-not (Test-Path -Path $MovieFolder -PathType Container)) {
        [System.Windows.Forms.MessageBox]::Show("Polkua ei löydy: $MovieFolder") 
        return
    }

    $AllFolders = Get-ChildItem -Path $MovieFolder -Directory -Recurse
    foreach ($Folder in $AllFolders) {
        if (-not $Folder.FullName.StartsWith($ExcludedFolder)) {
           # Write-Host "Poistettu: $($Folder.FullName)"
            Remove-Item -Path $Folder.FullName -Force -Recurse
        }
    }
    $Label3.Text = "Done"
    $Label3.BackColor = [System.Drawing.Color]::Green
}


