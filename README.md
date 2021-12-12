# powershell-utils

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
