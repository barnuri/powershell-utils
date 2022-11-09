Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
mkdir (Split-Path -Path $profile -Parent) -errorAction SilentlyContinue 
echo $null >> $profile

$parentDir = $(Split-Path $profile)
$profileTools = Join-Path -Path $parentDir -ChildPath "profileTools.psm1"
function profileTools() {
    echo $profileTools
}

function syncPowershellUtils() {
    mkdir -p (Split-Path -Path $profile -Parent) -errorAction SilentlyContinue
    $newProfileContent = $(curl https://raw.githubusercontent.com/barnuri/powershell-utils/master/profileTools.psm1 -H "Cache-Control: no-cache, no-store, must-revalidate"-H "Pragma: no-cache")
    echo $newProfileContent > $profileTools
    $installString = "### load profileTools.psm1"
    $importModuleExists = Select-String -Quiet -Pattern $installString -Path $profile
    if (-not $importModuleExists)
    {
        echo $installString >> $profile
        echo "Import-Module $profileTools -Force" >> $profile
    }
    Import-Module $profileTools -Force
}

syncPowershellUtils
