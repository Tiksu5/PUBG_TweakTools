#
#

# Tehdään shortcut
$SourceFileName = '"Gui.ps1"'
# $ShortcutPath = Join-Path -Path $env:USERPROFILE\Desktop -ChildPath "TTT.lnk"
$ShortcutPath = Join-Path -Path $PSScriptRoot -ChildPath "TTT.lnk"
$WScriptObj = New-Object -ComObject "WScript.Shell"
$Shortcut = $WScriptObj.CreateShortcut($ShortcutPath)
# Set the target path for the shortcut (including powershell.exe)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ep RemoteSigned -NoProfile -File $SourceFileName"
$shortcut.WorkingDirectory = $PSScriptRoot
$Shortcut.Save()