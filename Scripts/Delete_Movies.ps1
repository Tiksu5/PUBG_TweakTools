#
#


$script:ItemsInMoviesFolder = "null"
$script:MoviesFound = $false

# Tarkistetaan että path on oikein ja tiedostot löytyy
function Check-Movies {
        param (
        [bool]$SkipConfirmation = $false
    )
    # If SkipConfirmation is true, skip label update
    if ($SkipConfirmation) {
        # Testaa Path > Get Item > Check Item
        if (-not (Test-Path -Path $global:MoviesFolderPath -PathType Container)) {
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
            return  
        }
    } else {
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
}

# Poistaa Kaikki muut leffat/kansiot paitsi "AtoZ" Kansiota tai sen sisältöä
function Delete-Movies {
        param (
        [bool]$SkipConfirmation = $false
    )
    #Check onko peli päällä ja skip delete jos on
    if (Get-Process -Name "TslGame" -ErrorAction SilentlyContinue) {
        return
    }
    # If SkipConfirmation is true, skip user confirmation & label update
    if ($SkipConfirmation) {
        # Check ennen poistoa
        Check-Movies -SkipConfirmation $true

        # Delete jos leffat löydetty
        if ($script:MoviesFound) {
            foreach ($Item in $script:ItemsInMoviesFolder) {
                if (-not $Item.FullName.StartsWith($global:ExcludedFolderPath)) {
                    Remove-Item -Path $Item.FullName -Force -Recurse
                }
            }
        }
    } else {
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
}
