#
#

# Kyllä/Ei Confirm
function Confirm-Dialog { 
    $ConfirmForm = New-Object Windows.Forms.Form -Property @{
    Text = "Confirm Delete"
    Size = New-Object Drawing.Size(300, 120)
    StartPosition = "CenterScreen"
    }

    $Confirmlabel = New-Object Windows.Forms.Label -Property @{
        Text = "Poistetaanko varmasti?"
        Location = New-Object Drawing.Point(10, 10)
        AutoSize = $true
    }

    $yesButton = New-Object Windows.Forms.Button -Property @{
        Text = "Kyllä"
        Location = New-Object Drawing.Point(30, 50)
        DialogResult = [Windows.Forms.DialogResult]::Yes
    }

    $noButton = New-Object Windows.Forms.Button -Property @{
        Text = "Ei"
        Location = New-Object Drawing.Point(120, 50)
        DialogResult = [Windows.Forms.DialogResult]::No
    }


    $ConfirmForm.Controls.Add($Confirmlabel)
    $ConfirmForm.Controls.Add($yesButton)
    $ConfirmForm.Controls.Add($noButton)

    $result = $ConfirmForm.ShowDialog()

    $ConfirmForm.Dispose()

    return $result
}
