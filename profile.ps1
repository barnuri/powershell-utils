################# Profile By BarNuri #################
# author : ✡ BarNuri ✡
# git: https://github.com/barnuri/powershell-utils
# symbols - https://coolsymbol.com/
# PSReadLine -  https://docs.microsoft.com/en-us/powershell/module/psreadline/set-psreadlinekeyhandler?view=powershell-7.2

function syncPowershellUtils() {
    mkdir -p (Split-Path -Path $profile -Parent) -errorAction SilentlyContinue
    echo $null >> $profile
    $newProfileContent = $(Invoke-WebRequest https://raw.githubusercontent.com/barnuri/powershell-utils/main/profile.ps1 -Headers @{"Cache-Control"="no-cache"}).Content
    '' -match '' | out-null # reset regex result
    $profileContent = $($($(cat $profile) ?? "").Split([Environment]::NewLine) -join "`n")
    $profileContent -match '(\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# Profile By BarNuri \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#[.\s\S]*\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# END Profile By BarNuri \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#)' | out-null
    if($Matches.Count -gt 1) {
        $profileContent = $profileContent.Replace($Matches[1], $newProfileContent)
        echo $profileContent.TrimEnd() > $profile
    } else {
        echo $null >> $profile 
        Add-Content $profile $newProfileContent.Trim()
    }
    '' -match '' | out-null # reset regex result
}

function prompt {
    $host.ui.RawUI.WindowTitle = "Current Folder: $pwd"
    $CmdPromptUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    Write-host ($(if ($IsAdmin) { '[Admin]' } else { '' })) -BackgroundColor DarkBlue -ForegroundColor White -NoNewline
    Write-Host " $($CmdPromptUser.Name.split("\")[1]) " -BackgroundColor DarkBlue -ForegroundColor White -NoNewline
    Write-Host " $pwd" -NoNewline

    ## Git Status
    if (Test-Path -Path ".git") {
        $status=$(git --no-optional-locks status --short --show-stash  --ahead-behind --branch)
        $lines=$status.Split([Environment]::NewLine)
        
        $firstLine, $statusLines = $lines
        $statusLines += ""

        $firstLine -match '## (.+)' | out-null
        $isRemoteBranch = $Matches[1].Split(".").Count -gt 1
        $branch=$Matches[1].Split(".")[0]
        '' -match '' | out-null # reset regex result

        $firstLine -match '\[(?:.*)?(?:behind (\d)+)\]' | out-null
        $behind=$($Matches[1] ?? 0)
        '' -match '' | out-null # reset regex result

        $firstLine -match '\[(?:ahead (\d)+).*\]' | out-null 
        $ahead=$($Matches[1] ?? 0)
        '' -match '' | out-null # reset regex result

        Write-Host " ["  -NoNewLine -ForeGroundColor Yellow
        Write-Host "$branch" -NoNewLine -ForeGroundColor Cyan

        $deleted=$($statusLines | where{$_.StartsWith(" D ")}).Count
        $modify=$($statusLines | where{$_.StartsWith(" M ")}).Count
        $new=$($statusLines | where{$_.StartsWith("?? ")}).Count
        if ($behind -eq 0 -and $ahead -eq 0 -and $new -eq 0 -and $modify -eq 0 -and $deleted -eq 0) {
            if($isRemoteBranch) {
                Write-Host " =" -ForeGroundColor Cyan -NoNewLine
            }
            else {
                Write-Host " ☁ ↑" -ForeGroundColor yellow -NoNewLine
            }
        }
        else {
            Write-Host " ↓$behind " -ForeGroundColor Red -NoNewLine 
            Write-Host "↑$ahead " -ForeGroundColor Cyan -NoNewLine 
            if ($new -ne 0 -or $modify -ne 0 -or $deleted -ne 0) {  
                Write-Host "+$new " -ForeGroundColor Green -NoNewLine 
                Write-Host "±$modify " -ForeGroundColor Cyan -NoNewLine 
                Write-Host "-$deleted" -ForeGroundColor Red -NoNewLine 
            }
        }

        Write-Host "]"  -NoNewLine -ForeGroundColor Yellow
  }
  return " > "
}

Import-Module PSReadLine
Set-PSReadLineOption -Colors @{ InlinePrediction = '#9CA3AF'}
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -PredictionSource HistoryAndPlugin 
Set-PSReadlineOption -PredictionViewStyle InlineView
(Get-PSReadLineOption).ShowToolTips = $True
(Get-PSReadLineOption).HistoryNoDuplicates = $True
Set-PSReadlineKeyHandler -Key Ctrl+Spacebar -Function MenuComplete
Set-PSReadlineKeyHandler -Key Tab -Function AcceptNextSuggestionWord

# use code-insiders as code command
if (-Not $(Get-Command code -errorAction SilentlyContinue))
{
    if (Get-Command code-insiders -errorAction SilentlyContinue)
    {
        Set-Alias code code-insiders
    }
}

# k8s
Set-Alias k kubectl
Set-Alias k8s kubectl
Set-Alias ll dir

function kconfFunc { kubectl config view --raw --flatten --minify }
Set-Alias kconf kconfFunc 

function kallFunc($appName='') { kubectl get deploy,svc,ingress,pod $appName }
Set-Alias kall kallFunc

function klogFunc($search) { kubectl logs --tail=100000 -f -l $search }
Set-Alias klog klogFunc
Set-Alias klogs klogFunc

# ssh
function sshKeyFunc { cat $home\.ssh\id_rsa.pub }
Set-Alias sshkey sshKeyFunc

# python
function Python3venv() { python -m virtualenv venv }
Set-Alias p3venv Python3venv

function Python2venv() { python2 -m virtualenv venv }
Set-Alias p2venv Python3venv

function PipInstall() { python -m pip install --upgrade pip; pip install --upgrade -r REQUIREMENTS }
Set-Alias pipi PipInstall

function PipPackage() { python -m pip install --upgrade pip; pip install . }
Set-Alias pipp PipPackage

# git 
function Remove-MergedBranches { git branch --merged | ForEach-Object { $_.Trim() } | Where-Object {$_ -NotMatch "^\*"} | Where-Object {-not ( $_ -Like "*master" )} | ForEach-Object { git branch -d $_ }  }
Set-Alias gitrmb Remove-MergedBranches

function getAllBranches() { git branch -a -l --format "%(refname:short)" | ForEach-Object { $_.Split("/")[-1] } | Where-Object { $_ -ne "HEAD" } }

function gitCleanLocalBranches() { git fetch --all --prune ; git tag -l | ForEach-Object {git tag $_.Trim() -d} ; git branch -l --format "%(refname:short)" | ForEach-Object {  git  branch  $_.Trim()  -D } }

function gitResetHard() { git reset --hard }
Set-Alias gitReset gitResetHard

function gitCleanIgnoreFiles() { git clean -dfx }
Set-Alias gitCleanIgnore gitCleanIgnoreFiles

Class BranchesNames : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $BranchesNames = $(getAllBranches)
        return [String[]] $BranchesNames
    }
}

function gitMergeTo([ValidateSet([BranchesNames])] $targetBranchName='integration') {
    $currentBranch = $(git branch --show-current)
    git fetch --all;
    git checkout $targetBranchName;
    git pull ;
    git merge -X ignore-all-space --no-ff $currentBranch ;
    git push ;
    git checkout $currentBranch ;
}
Set-Alias gitmt gitMergeTo

function gitMoveToBranch([ValidateSet([BranchesNames])] $branchName='master') { git checkout $branchName; git pull }
Set-Alias gitc gitMoveToBranch

function gitCreateBranch($branchName) { git checkout -b $branchName; }
Set-Alias gitnb gitCreateBranch 

function gitMerge([ValidateSet([BranchesNames])] $branchName='master') { git fetch --all; git pull ; git merge -X ignore-all-space --no-ff origin/$branchName }
Set-Alias gitm gitMerge

function gitDiff([ValidateSet([BranchesNames])] $branchName='master') { git diff $branchName...$(git branch --show-current) --name-status }

function gitCheckoutFile([ValidateSet([BranchesNames])] $branchName) { git checkout $branchName -- $args }

function gitCheckoutFileFromMaster() { git checkout master -- $args }

# general
function HistoryFile() { (Get-PSReadlineOption).HistorySavePath }
Set-Alias hfile HistoryFile

function openHostsFile() { code C:\Windows\System32\drivers\etc\hosts }
Set-Alias hostsFile openHostsFile
Set-Alias hostFile openHostsFile
Set-Alias hostService "C:\Program Files (x86)\Acrylic DNS Proxy\AcrylicUI.exe"
Set-Alias hostsService "C:\Program Files (x86)\Acrylic DNS Proxy\AcrylicUI.exe"

function openProfile() { code $profile }
Set-Alias profile openProfile

function whichFunc($search) { $res=$(Get-Command $search -errorAction SilentlyContinue); if($res.Source) { echo $res.Source } else { echo $res } }
Set-Alias which whichFunc

function screenClose() { (Add-Type '[DllImport(\"user32.dll\")]^public static extern int PostMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::PostMessage(-1,0x0112,0xF170,2) }

################# END Profile By BarNuri #################
