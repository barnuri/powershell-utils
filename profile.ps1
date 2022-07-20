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
        $longStatus=$(git --no-optional-locks status)
        $status=$(git --no-optional-locks status --short --ahead-behind --branch)
        $lines=$status.Split([Environment]::NewLine)
        
        $firstLine, $statusLines = $lines
        $statusLines += ""

        $firstLine -match '## (.+)' | out-null
        $isRemoteBranch = $Matches[1].Split(".").Count -gt 1
        $branch=$Matches[1].Split(".")[0]
        '' -match '' | out-null # reset regex result

        $firstLine -match '\[(?:.*)?(?:behind (\d+))\]' | out-null
        $behind=$($Matches[1] ?? 0)
        '' -match '' | out-null # reset regex result

        $firstLine -match '\[(?:ahead (\d+)).*\]' | out-null 
        $ahead=$($Matches[1] ?? 0)
        '' -match '' | out-null # reset regex result

        Write-Host " ["  -NoNewLine -ForeGroundColor Yellow
        Write-Host "$branch" -NoNewLine -ForeGroundColor Cyan
        
        $dontHaveCommitedFiles = ($($longStatus.ToLower().Split([Environment]::NewLine) | where { $_.StartsWith("no changes added to commit") }).Count + $($longStatus.ToLower().Split([Environment]::NewLine) | where { $_.StartsWith("nothing added to commit") }).Count) -gt 0
        $statusLines = $statusLines | foreach { If ($dontHaveCommitedFiles) { $_.Trim() } Else { $_ } }

        $deleted=$($statusLines | where { $_.StartsWith("D ") }).Count
        $modify=$($statusLines | where { $_.StartsWith("M ") }).Count + $($statusLines | where { $_.StartsWith("T ") }).Count + $($statusLines | where { $_.StartsWith("R ") }).Count + $($statusLines | where { $_.StartsWith("C ") }).Count
        $new=$($statusLines | where { $_.StartsWith("A ") }).Count
        if($dontHaveCommitedFiles) {
            $new=$new+$($statusLines | where { $_.StartsWith("?? ") }).Count + $($statusLines | where { $_.StartsWith("? ") }).Count
        }
        $mergeConflicts=$($statusLines | where { $_.StartsWith("UU ") }).Count + $($statusLines | where { $_.StartsWith("U ") }).Count
        if(!($isRemoteBranch)) {
            Write-Host " ☁ ↑" -ForeGroundColor yellow -NoNewLine
        }
        if ($isRemoteBranch -and $behind -eq 0 -and $ahead -eq 0 -and $new -eq 0 -and $modify -eq 0 -and $deleted -eq 0 -and $mergeConflicts -eq 0) {
            Write-Host " =" -ForeGroundColor Cyan -NoNewLine
        }
        else {
            Write-Host " ↓$behind " -ForeGroundColor Red -NoNewLine 
            Write-Host "↑$ahead " -ForeGroundColor Cyan -NoNewLine 
            if ($new -ne 0 -or $modify -ne 0 -or $deleted -ne 0) {  
                Write-Host "+$new " -ForeGroundColor Green -NoNewLine 
                Write-Host "±$modify " -ForeGroundColor Cyan -NoNewLine 
                Write-Host "-$deleted" -ForeGroundColor Red -NoNewLine 
            }
            if ($mergeConflicts -ne 0) {
                Write-Host " !$mergeConflicts" -ForeGroundColor Magenta -NoNewLine 
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

Set-Alias ll dir

############# k8s
Set-Alias k kubectl
function kconf { kubectl config view --raw --flatten --minify }
function kall($appName='') { kubectl get deploy,svc,ingress,pod $appName }
function klog($search) { kubectl logs --tail=100000 -f -l $search }
function klogs($search) { klog $search }

############# ssh
function sshKeyFunc { cat $home\.ssh\id_rsa.pub }
Set-Alias sshkey sshKeyFunc

############# python
function p3venv() { python3 -m virtualenv venv }
function p2venv() { python2 -m virtualenv venv }

# pip install
function pipi() {
    python -m pip install --upgrade pip;
    pip install --upgrade -r REQUIREMENTS 
}

# pip install package
function pipp() {
    python -m pip install --upgrade pip;
    pip install . 
}

############# git 
function gitRemoveMergedBranches { git branch --merged | ForEach-Object { $_.Trim() } | Where-Object {$_ -NotMatch "^\*"} | Where-Object {-not ( $_ -Like "*master" )} | ForEach-Object { git branch -d $_ }  }
function getAllBranches() { git branch -a -l --format "%(refname:short)" | ForEach-Object { $_.Split("/")[-1] } | Where-Object { $_ -ne "HEAD" } }
function gitCleanLocalBranches() {
    git fetch --all --prune ;
    git branch -l --format "%(refname:short)" | ForEach-Object {  git  branch  $_.Trim()  -D }
}
function gitCleanIgnoreFiles() { git clean -dfx }

Class BranchesNames : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $BranchesNames = $(getAllBranches)
        return [String[]] $BranchesNames
    }
}

function gitMergeTo([ValidateSet([BranchesNames])] $targetBranchName='integration') {
    $currentBranch = $(git branch --show-current)
    git checkout $targetBranchName;
    git pull ;
    git merge -X ignore-all-space --no-ff $currentBranch ;
    git push ;
    git checkout $currentBranch ;
}
Set-Alias gitmt gitMergeTo

function gitc([ValidateSet([BranchesNames])] $branchName='master') {
    git checkout $branchName;
    git pull 
}
# git new branch
function gitnb($branchName) { git checkout -b $branchName; }

# git merge
function gitm([ValidateSet([BranchesNames])] $branchName='master') {
     git fetch origin $branchName;
     git pull ;
     git merge -X ignore-all-space --no-ff origin/$branchName
}

function gitDiff([ValidateSet([BranchesNames])] $branchName='master') {
    git fetch origin $branchName;
    git diff origin/$branchName...$(git branch --show-current) --name-status
}
function gitCheckoutFile([ValidateSet([BranchesNames])] $branchName) {
    git fetch origin $branchName;
    git checkout origin/$branchName -- $args
}
function gitCheckoutFileFromMaster() {
    git fetch origin master;
    git checkout origin/master -- $args
}

# git commit & push
function gitCommitAndPush() {
    $msg = "$args"
    if ($msg -eq "") {
        $msg = "commit"
    }
    git add .;
    git commit -am "$args";
    git pull;
    git push;
}
Set-Alias gitp gitCommitAndPush

function gitEmptyCommit() {
    git commit --allow-empty -m "empty commit - trigger status checks";
    git pull;
    git push;
}

# general
function HistoryFile() { (Get-PSReadlineOption).HistorySavePath }
Set-Alias hfile HistoryFile

function hostsFile() { echo "C:\Windows\System32\drivers\etc\hosts" }
function hostFile() { hostsFile }
function profile() { echo $profile }
function which($search) { $res=$(Get-Command $search -errorAction SilentlyContinue); if($res.Source) { echo $res.Source } else { echo $res } }
function screenClose() { (Add-Type '[DllImport(\"user32.dll\")]^public static extern int PostMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::PostMessage(-1,0x0112,0xF170,2) }
################# END Profile By BarNuri #################
