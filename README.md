# powershell-utils

## Preinstall
### Download Last Powershell Version:

https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows

### Then open pwsh with **Administrator** and run this
```powershell
mkdir (Split-Path -Path $profile -Parent) -errorAction SilentlyContinue 
echo $null >> $profile
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
Install-Module -Name PowerShellGet -Force
Install-PackageProvider -Name NuGet -Force
Install-Module PowerShellGet  -Scope AllUsers -Force -SkipPublisherCheck
Install-Module Pansies -AllowClobber
Install-Module PSReadLine -Force -SkipPublisherCheck -AllowPrerelease
```

## Install 
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$(Invoke-WebRequest https://raw.githubusercontent.com/barnuri/powershell-utils/master/profile.ps1 -Headers @{"Cache-Control"="no-cache"}).Content | iex
syncPowershellUtils
```

## Probelms with PSReadLine Installation
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Get-InstalledModule -Name PSReadLine -AllVersions | Uninstall-Module
powershell -NoProfile -Command "Uninstall-Module PSReadLine"
powershell -NoProfile -NonInteractive -Command "Uninstall-Module PSReadLine"
pwsh -NoProfile -Command "Uninstall-Module PSReadLine"
pwsh -NoProfile -NonInteractive -Command "Uninstall-Module PSReadLine"
Install-Module PSReadLine -Force -SkipPublisherCheck -AllowPrerelease
```


## Update
```powershell
syncPowershellUtils
```

## deps
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$(Invoke-WebRequest https://raw.githubusercontent.com/barnuri/powershell-utils/master/installCommonDeps.ps1 -Headers @{"Cache-Control"="no-cache"}).Content | iex
```
