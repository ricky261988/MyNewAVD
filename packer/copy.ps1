Write-Host "Setting Up Download URL for Notepad++...." -ForegroundColor DarkMagenta
$notepadppUrl = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.6/npp.8.7.6.Installer.x64.exe'

Write-Host "Setting Up Destination Path for Notepad++..." -ForegroundColor DarkMagenta
$destination = 'c:\notepadpp_installer.exe'

Write-Host "Downloading Notepad++....." -ForegroundColor DarkMagenta
Invoke-WebRequest -Uri $notepadppUrl -OutFile $destination

Write-Host "Installing Notepad++....." -ForegroundColor DarkMagenta
Start-Process -FilePath 'c:\notepadpp_installer.exe' -ArgumentList '/S' '/ALLUSERS' -Wait

Write-Host "Notepad Installation Done!!!!"