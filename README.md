# powershell-utils

## Preinstall
```powershell
mkdir (Split-Path -Path $profile -Parent) -errorAction SilentlyContinue 
echo "" >> $profile 
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
Get-InstalledModule -Name PSReadLine -AllVersions | Uninstall-Module
powershell -NoProfile -Command "Uninstall-Module PSReadLine"
powershell -NoProfile -NonInteractive -Command "Uninstall-Module PSReadLine"
pwsh -NoProfile -Command "Uninstall-Module PSReadLine"
pwsh -NoProfile -NonInteractive -Command "Uninstall-Module PSReadLine"
Install-Module -Name PowerShellGet -Force
Install-Module PSReadLine -Force -SkipPublisherCheck -AllowPrerelease
Import-Module PSReadLine
Install-PackageProvider -Name NuGet -Force
Install-Module PowerShellGet  -Scope AllUsers -Force -SkipPublisherCheck
Install-Module Pansies -AllowClobber
Install-Module PSProfiler
Import-Module PSProfiler
```

## Install 
```powershell
function updateProfile() {
    $newProfileContent = $(Invoke-WebRequest https://raw.githubusercontent.com/barnuri/powershell-utils/main/profile.ps1).Content
    '' -match '' | out-null # reset regex result
    $profileContent = $($(Get-Content $PROFILE).Split([Environment]::NewLine) -join "`n")
    $profileContent -match '(\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# Profile By BarNuri \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#[.\s\S]*\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# END Profile By BarNuri \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#)' | out-null
    if($Matches.Count -gt 1) {
        $profileContent = $profileContent.Replace($Matches[1], $newProfileContent)
        echo $profileContent > $profile
    } else {
        mkdir -p (Split-Path -Path $profile -Parent) -errorAction SilentlyContinue
        echo "" >> $profile 
        Add-Content $profile $newProfileContent
    }
    '' -match '' | out-null # reset regex result
}
updateProfile
```

## Update
```powershell
updateProfile
```
