#
#


$script:ItemsInMoviesFolder = "null"
$script:MoviesFound = $false

# Tarkistetaan et path on oikein ja tiedostot löytyy
function Check-Movies {

    # Testaa Path > Get Item > Check Item
    if (-not (Test-Path -Path $global:MoviesFolderPath -PathType Container)) {
        $global:DeleteMoviesDoneLabel.Text = "Polkua ei löydy"
        $global:DeleteMoviesDoneLabel.BackColor = [System.Drawing.Color]::Red
        return
    }
    $script:ItemsInMoviesFolder = Get-ChildItem -Path $global:MoviesFolderPath -Force
    foreach ($Item in $script:ItemsInMoviesFolder) {
        if (-not $Item.FullName.StartsWith($global:ExcludedFolderPath)) {
            $script:MoviesFound = $true
            break
        }
    }
    if (-not $script:MoviesFound) {       
        $global:DeleteMoviesDoneLabel.Text = "Leffat on jo poistettu!"
        $global:DeleteMoviesDoneLabel.BackColor = [System.Drawing.Color]::Green
        return  
    }
    $global:DeleteMoviesDoneLabel.Text = "Leffoja löydetty"
    $global:DeleteMoviesDoneLabel.BackColor = [System.Drawing.Color]::Yellow
}


# Poistaa Kaikki muut leffat/kansiot paitsi "AtoZ" Kansiota tai sen sisältöä
function Delete-Movies {
    
    # Check ennen poistoa
    Check-Movies
    # Varmistetaan poisto käyttäjältä
    if ($script:MoviesFound) {
        $confirmationResult = Confirm-Dialog
        if ($confirmationResult -eq [Windows.Forms.DialogResult]::Yes) {
            foreach ($Item in $script:ItemsInMoviesFolder) {
                if (-not $Item.FullName.StartsWith($global:ExcludedFolderPath)) {
                    Remove-Item -Path $Item.FullName -Force -Recurse
                }
            }   
            $global:DeleteMoviesDoneLabel.Text = "Leffat poistettu!"
            $global:DeleteMoviesDoneLabel.BackColor = [System.Drawing.Color]::Green
            $script:MoviesFound = $false
        } else {
            $global:DeleteMoviesDoneLabel.Text = "Poisto keskeytetty"
            $global:DeleteMoviesDoneLabel.BackColor = [System.Drawing.Color]::Yellow
        }
    }
}



