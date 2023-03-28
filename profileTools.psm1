################# Profile By BarNuri #################
# author : ✡ BarNuri ✡
# git: https://github.com/barnuri/powershell-utils
# symbols - https://coolsymbol.com/
# PSReadLine -  https://docs.microsoft.com/en-us/powershell/module/psreadline/set-psreadlinekeyhandler?view=powershell-7.2

$parentDir = $(Split-Path $profile)
$profileTools = Join-Path -Path $parentDir -ChildPath "profileTools.psm1"
function profileTools() {
    echo $profileTools
}

function syncPowershellUtils() {
    mkdir -p (Split-Path -Path $profile -Parent) -errorAction SilentlyContinue
    $newProfileContent = $(Invoke-WebRequest https://raw.githubusercontent.com/barnuri/powershell-utils/master/profileTools.psm1?noCache=$((Get-Date).ToString())).Content
    echo $newProfileContent > $profileTools
    $installString = "### load profileTools.psm1"
    $importModuleExists = Select-String -Quiet -Pattern $installString -Path $profile
    if (-not $importModuleExists)
    {
        echo $installString >> $profile
        echo "`$SaveVerbosePreference = `$global:VerbosePreference;" >> $profile
        echo "`$global:VerbosePreference = 'SilentlyContinue';" >> $profile
        echo "Import-Module $profileTools -Force -DisableNameChecking" >> $profile
        echo "`$global:VerbosePreference = `$SaveVerbosePreference;" >> $profile
    }
    $SaveVerbosePreference = $global:VerbosePreference;
    $global:VerbosePreference = 'SilentlyContinue';
    Import-Module $profileTools -Force -DisableNameChecking
    $global:VerbosePreference = $SaveVerbosePreference;
}

function reloadProfile() {
    . $profile
    $SaveVerbosePreference = $global:VerbosePreference;
    $global:VerbosePreference = 'SilentlyContinue';
    Import-Module $profileTools -Force -DisableNameChecking
    $global:VerbosePreference = $SaveVerbosePreference;
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
        $longStatus=$(git status)
        $status=$(git status --short --ahead-behind --branch)
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
        $modify=$($statusLines | where { $_.StartsWith("M ") -OR $_.StartsWith("T ") -OR $_.StartsWith("R ") -OR $_.StartsWith("C ") }).Count
        $new=$($statusLines | where { $_.StartsWith("A ") }).Count
        if($dontHaveCommitedFiles) {
            $new=$new+$($statusLines | where { $_.StartsWith("?? ") }).Count + $($statusLines | where { $_.StartsWith("? ") }).Count
        }
        $mergeConflicts=$($statusLines | where { 
            $_.StartsWith("UU ") -OR 
            $_.StartsWith("U ") -OR 
            $_.StartsWith("AA ") -OR 
            $_.StartsWith("DD ") -OR 
            $_.StartsWith("AU ") -OR 
            $_.StartsWith("UD ") -OR 
            $_.StartsWith("UA ") -OR 
            $_.StartsWith("DU ")
        }).Count
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

# Class BranchesNames : System.Management.Automation.IValidateSetValuesGenerator {
#     [String[]] GetValidValues() {
#         $BranchesNames = $(getAllBranches)
#         return [String[]] $BranchesNames
#     }
# }

function gitMergeTo(
    #[ValidateSet([BranchesNames])]
     $targetBranchName='integration') {
    $currentBranch = $(git branch --show-current)
    git checkout $targetBranchName;
    git pull ;
    git merge -X ignore-all-space --no-ff $currentBranch ;
    git push ;
    git checkout $currentBranch ;
}
Set-Alias gitmt gitMergeTo

function gitc(
    #[ValidateSet([BranchesNames])]
     $branchName='master') {
    git checkout $branchName;
    git pull 
}
# git new branch
function gitnb($branchName) { git checkout -b $branchName; }

# git new branch from master
function gitnbm($branchName) {
    git fetch origin master ;
    git checkout origin/master ;
    gitnb $branchName
}

# git merge
function gitm(
    #[ValidateSet([BranchesNames])]
     $branchName='master') {
     git fetch origin $branchName;
     git pull ;
     git merge -X ignore-all-space --no-ff origin/$branchName
}

function gitDiff(
    #[ValidateSet([BranchesNames])]
     $branchName='master') {
    git fetch origin $branchName;
    git diff origin/$branchName...$(git branch --show-current) --name-status
}
function gitCheckoutFile(
    #[ValidateSet([BranchesNames])]
     $branchName) {
    git fetch origin $branchName;
    git checkout origin/$branchName -- $args
}
function gitCheckoutFileFromMaster() {
    git fetch origin master;
    git checkout origin/master -- $args
}
function gitCleanCommitsIntoOne() {
    $msg = "$args"
    $currentBranchName = $(git name-rev --name-only HEAD)
    if ($msg -eq "") {
        $msg = "$currentBranchName"
    }
    git fetch origin master;
    git reset $(git merge-base origin/master $(git branch --show-current));
    git add -A;
    git commit -m "$msg";
    git push -f;
}
# git commit & push
function gitCommitAndPush() {
    $msg = "$args"
    $currentBranchName = $(git name-rev --name-only HEAD)
    $IsRemoteBranch=[bool]$(git config branch.$($currentBranchName).merge)
    if ($msg -eq "") {
        $msg = "$currentBranchName"
    }
    if(!$IsRemoteBranch) {
        git push --set-upstream origin $currentBranchName
    }
    git add .;
    git commit -am $msg;
    git pull;
    git push;
    if(!$IsRemoteBranch) {
        Write-Host "$(gitOriginUrl)/pull/new/$currentBranchName" -ForeGroundColor Cyan 
    }
}
Set-Alias gitp gitCommitAndPush

function gitOriginUrl() {
    $repoUrl = $(git config --get remote.origin.url)
    if($repoUrl.StartsWith("git@")) {
        $repoUrl = $repoUrl.SubString(4)
    }
    $repoUrl = $repoUrl.Replace(":","/")
    if($repoUrl.EndsWith(".git")) {
        $repoUrl = $repoUrl.SubString(0, $repoUrl.Length - 4)
    }
    if(!$repoUrl.StartsWith("http")) {
        $repoUrl = "https://$repoUrl"
    }
    $repoUrl = $repoUrl.Trim("/")
    echo "$repoUrl"
}

function gitEmptyCommit($msg = "empty commit - trigger status checks") {
    git commit --allow-empty -m "$msg";
    git pull;
    git push;
}

function gitSpeedUp() {
    $env:GIT_ASK_YESNO="false" ;
    git fsck ;
    git repack -ad ;
    git gc --aggressive  --prune=now --force ;
    git status ;
}

# general
function HistoryFile() { (Get-PSReadlineOption).HistorySavePath }
Set-Alias hfile HistoryFile

function filesByGlob($glob) {
    Get-ChildItem -Filter $glob -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -ExpandProperty FullName
}

function updatePowershell() {
    iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
}

function hardLink($src, $dest) {
    try { del $dest 2>&1 | out-null } catch {}
    New-Item -ItemType SymbolicLink -Path $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($dest) -Target $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($src)
}

function hostsFile() { echo "C:\Windows\System32\drivers\etc\hosts" }
function hostFile() { hostsFile }
function profile() { echo $profile }
function which($search) { $res=$(Get-Command $search -errorAction SilentlyContinue); if($res.Source) { echo $res.Source } else { echo $res } }
function screenClose() { (Add-Type '[DllImport(\"user32.dll\")]^public static extern int PostMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::PostMessage(-1,0x0112,0xF170,2) }

function watch($command, $secsToSleep = 5) {
    while (1) {
        clear ;
        echo "$(Get-Date)" ;
        . $command ;
        sleep $secsToSleep ;
    }
}

function wslIp($DOCKER_DISTRO = "Ubuntu-20.04") {
    echo "$((wsl -d "$DOCKER_DISTRO" sh -c "hostname -I").Split(" ")[0] )"
}

function DockerService($DOCKER_DISTRO = "Ubuntu-20.04") {
  $DOCKER_DIR = "/mnt/wsl/shared-docker"
  $DOCKER_SOCK = "$DOCKER_DIR/docker.sock"
  wsl -d "$DOCKER_DISTRO" sh -c "[ -S '$DOCKER_SOCK' ]"
  if ($LASTEXITCODE) {
    wsl -d "$DOCKER_DISTRO" sh -c "mkdir -pm o=,ug=rwx $DOCKER_DIR ; chgrp docker $DOCKER_DIR"
    wsl -d "$DOCKER_DISTRO" sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
  }
}

function wslProxy($DOCKER_DISTRO = "Ubuntu-20.04") {
    $env:WSL_HOST = (wsl -d "$DOCKER_DISTRO" sh -c "hostname -I").Split(" ")[0] 
    $env:DOCKER_HOST = "tcp://$($env:WSL_HOST):2375"
    netsh interface portproxy add v4tov4 listenport=2375 connectport=2375 connectaddress=$env:WSL_HOST
}

function wslProxyPort($port, $DOCKER_DISTRO = "Ubuntu-20.04") {
    $WSL_HOST = (wsl -d "$DOCKER_DISTRO" sh -c "hostname -I").Split(" ")[0]
    netsh interface portproxy add v4tov4 listenport=$port connectport=$port connectaddress=$WSL_HOST
}

function wslProxyPortDelete($port) {
    netsh interface portproxy delete v4tov4 listenport=$port
}

function minikubeProxy($DOCKER_DISTRO = "Ubuntu-20.04") {
    $(wsl -d "$DOCKER_DISTRO" kubectl config view --raw --flatten --minify) > ~/.kube/config
}

Export-ModuleMember -Function * -Alias * -Variable * -Cmdlet *
################# END Profile By BarNuri #################

