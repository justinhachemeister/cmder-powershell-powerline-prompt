# Use this file to run your own startup commands

#######################################
#         PowerShell Aliases
# Sometimes Powershell can't run commands unless they're wrapped in a function
#######################################
Set-Alias -name ".." -value "cd.."
function explorerHere() {
    Start-Process -FilePath explorer.exe -argumentlist .
}
Set-Alias -name "e." -value "explorerHere"
function listNpmGlobalModules() {
    npm ls -g --depth=0
}
Set-Alias -name "npmls" -value "listNpmGlobalModules"
function goToCode() {
    D:
    cd D:\Amr\SourceCode
}
Set-Alias -name "c" -value "goToCode"
function chocoUpgrade() {
    choco upgrade all
}
Set-Alias -name "update" -value "chocoUpgrade"
Set-Alias ls Get-ChildItem-Color -option AllScope -Force
function gitStatus($Path) {
    if (Test-Path -Path (Join-Path (Get-Item -Path ".\" -Verbose).FullName '.git') ) {
        git status 
    }
    else {
        write-host "there's no Git repo here!"
    }
}
Set-Alias -name "status" -value "gitStatus"
######### PowerShell Aliases ##########

#######################################
#              SSH Agent
#######################################
Start-SshAgent

############## SSH Agent ##############

#######################################
#         Prompt Customization
#######################################
<#
.SYNTAX
    <PrePrompt><CMDER DEFAULT>
    λ <PostPrompt> <repl input>
.EXAMPLE
    <PrePrompt>N:\Documents\src\cmder [master]
    λ <PostPrompt> |
#>

[ScriptBlock]$PrePrompt = {

}

function Import-GitModule($Loaded){
    if($Loaded) { return }
    $GitModule = Get-Module -Name Posh-Git -ListAvailable
    if($GitModule | Select-Object version | Where-Object version -le ([version]"0.6.1.20160330")){
        Import-Module Posh-Git > $null
    }
    if(-not ($GitModule) ) {
        Write-Warning "Missing git support, install posh-git with 'Install-Module posh-git' and restart cmder."
    }
    # Make sure we only run once by alawys returning true
    return $true
}

$isGitLoaded = $false
$branchSymbol = ""
$arrowSymbol = ""

$defaultForeColor = "White"
$defaultBackColor = "Black"
$pathForeColor = "White"
$pathBackColor = "DarkBlue"
$gitCleanForeColor = "White"
$gitCleanBackColor = "Green"
$gitDirtyForeColor = "Black"
$gitDirtyBackColor = "Yellow"

function Write-GitPrompt() {
    $status = Get-GitStatus
    
    if ($status) {

        # assume git folder is clean
        $gitBackColor = $gitCleanBackColor
        $gitForeColor = $gitCleanForeColor
        if ($status.HasWorking -Or $status.HasIndex) {
            # but if it's dirty, change the back color 
            $gitBackColor = $gitDirtyBackColor
            $gitForeColor = $gitDirtyForeColor
        }

        # Close path prompt 
        Write-Host $arrowSymbol -NoNewLine -BackgroundColor $gitBackColor -ForegroundColor $pathBackColor

        # Set background color 
        $Host.UI.RawUI.BackgroundColor = $gitBackColor
        # Set foreground color 
        $Host.UI.RawUI.ForegroundColor = $gitForeColor 

        # Write branch symbol 
        Write-Host " " $branchSymbol " " $status.Branch " " -NoNewLine 

        <# Git status info 
        HasWorking   : False
        Branch       : master
        AheadBy      : 0
        Working      : {}
        Upstream     : origin/master
        StashCount   : 0
        Index        : {}
        HasIndex     : False
        BehindBy     : 0
        HasUntracked : False
        GitDir       : D:\amr\SourceCode\DevDiary\.git
        #>

        # close git prompt 
        Write-Host $arrowSymbol -NoNewLine -BackgroundColor $defaultBackColor -ForegroundColor $gitBackColor

        # Restore colors
        $Host.UI.RawUI.BackgroundColor = $defaultBackColor
        $Host.UI.RawUI.ForegroundColor = $defaultForeColor

<#
        $branchStatusText            = $null
        $branchStatusBackgroundColor = $s.BranchBackgroundColor
        $branchStatusForegroundColor = $s.BranchForegroundColor

        if (!$status.Upstream) {
            $branchStatusText            = $s.BranchUntrackedSymbol
        } elseif ($status.UpstreamGone -eq $true) {
            # Upstream branch is gone
            $branchStatusText            = $s.BranchGoneStatusSymbol
            $branchStatusBackgroundColor = $s.BranchGoneStatusBackgroundColor
            $branchStatusForegroundColor = $s.BranchGoneStatusForegroundColor
        } elseif ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0) {
            # We are aligned with remote
            $branchStatusText            = $s.BranchIdenticalStatusToSymbol
            $branchStatusBackgroundColor = $s.BranchIdenticalStatusToBackgroundColor
            $branchStatusForegroundColor = $s.BranchIdenticalStatusToForegroundColor
        } elseif ($status.BehindBy -ge 1 -and $status.AheadBy -ge 1) {
            # We are both behind and ahead of remote
            if ($s.BranchBehindAndAheadDisplay -eq "Full") {
                $branchStatusText        = ("{0}{1} {2}{3}" -f $s.BranchBehindStatusSymbol, $status.BehindBy, $s.BranchAheadStatusSymbol, $status.AheadBy)
            } elseif ($s.BranchBehindAndAheadDisplay -eq "Compact") {
                $branchStatusText        = ("{0}{1}{2}" -f $status.BehindBy, $s.BranchBehindAndAheadStatusSymbol, $status.AheadBy)
            } else {
                $branchStatusText        = $s.BranchBehindAndAheadStatusSymbol
            }
            $branchStatusBackgroundColor = $s.BranchBehindAndAheadStatusBackgroundColor
            $branchStatusForegroundColor = $s.BranchBehindAndAheadStatusForegroundColor
        } elseif ($status.BehindBy -ge 1) {
            # We are behind remote
            if ($s.BranchBehindAndAheadDisplay -eq "Full" -Or $s.BranchBehindAndAheadDisplay -eq "Compact") {
                $branchStatusText        = ("{0}{1}" -f $s.BranchBehindStatusSymbol, $status.BehindBy)
            } else {
                $branchStatusText        = $s.BranchBehindStatusSymbol
            }
            $branchStatusBackgroundColor = $s.BranchBehindStatusBackgroundColor
            $branchStatusForegroundColor = $s.BranchBehindStatusForegroundColor
        } elseif ($status.AheadBy -ge 1) {
            # We are ahead of remote
            if ($s.BranchBehindAndAheadDisplay -eq "Full" -Or $s.BranchBehindAndAheadDisplay -eq "Compact") {
                $branchStatusText        = ("{0}{1}" -f $s.BranchAheadStatusSymbol, $status.AheadBy)
            } else {
                $branchStatusText        = $s.BranchAheadStatusSymbol
            }
            $branchStatusBackgroundColor = $s.BranchAheadStatusBackgroundColor
            $branchStatusForegroundColor = $s.BranchAheadStatusForegroundColor
        } else {
            # This condition should not be possible but defaulting the variables to be safe
            $branchStatusText            = "?"
        }

        Write-Prompt (Format-BranchName($status.Branch)) -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor

        if ($branchStatusText) {
            Write-Prompt  (" {0}" -f $branchStatusText) -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
        }

        if($s.EnableFileStatus -and $status.HasIndex) {
            Write-Prompt $s.BeforeIndexText -BackgroundColor $s.BeforeIndexBackgroundColor -ForegroundColor $s.BeforeIndexForegroundColor

            if($s.ShowStatusWhenZero -or $status.Index.Added) {
                Write-Prompt (" $($s.FileAddedText)$($status.Index.Added.Count)") -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Index.Modified) {
                Write-Prompt (" $($s.FileModifiedText)$($status.Index.Modified.Count)") -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Index.Deleted) {
                Write-Prompt (" $($s.FileRemovedText)$($status.Index.Deleted.Count)") -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }

            if ($status.Index.Unmerged) {
                Write-Prompt (" $($s.FileConflictedText)$($status.Index.Unmerged.Count)") -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }

            if($status.HasWorking) {
                Write-Prompt $s.DelimText -BackgroundColor $s.DelimBackgroundColor -ForegroundColor $s.DelimForegroundColor
            }
        }

        if($s.EnableFileStatus -and $status.HasWorking) {
            if($s.ShowStatusWhenZero -or $status.Working.Added) {
                Write-Prompt (" $($s.FileAddedText)$($status.Working.Added.Count)") -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Working.Modified) {
                Write-Prompt (" $($s.FileModifiedText)$($status.Working.Modified.Count)") -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Working.Deleted) {
                Write-Prompt (" $($s.FileRemovedText)$($status.Working.Deleted.Count)") -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }

            if ($status.Working.Unmerged) {
                Write-Prompt (" $($s.FileConflictedText)$($status.Working.Unmerged.Count)") -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }
        }

        if ($status.HasWorking) {
            # We have un-staged files in the working tree
            $localStatusSymbol          = $s.LocalWorkingStatusSymbol
            $localStatusBackgroundColor = $s.LocalWorkingStatusBackgroundColor
            $localStatusForegroundColor = $s.LocalWorkingStatusForegroundColor
        } elseif ($status.HasIndex) {
            # We have staged but uncommited files
            $localStatusSymbol          = $s.LocalStagedStatusSymbol
            $localStatusBackgroundColor = $s.LocalStagedStatusBackgroundColor
            $localStatusForegroundColor = $s.LocalStagedStatusForegroundColor
        } else {
            # No uncommited changes
            $localStatusSymbol          = $s.LocalDefaultStatusSymbol
            $localStatusBackgroundColor = $s.LocalDefaultStatusBackgroundColor
            $localStatusForegroundColor = $s.LocalDefaultStatusForegroundColor
        }

        if ($localStatusSymbol) {
            Write-Prompt (" {0}" -f $localStatusSymbol) -BackgroundColor $localStatusBackgroundColor -ForegroundColor $localStatusForegroundColor
        }

        if ($s.EnableStashStatus -and ($status.StashCount -gt 0)) {
             Write-Prompt $s.BeforeStashText -BackgroundColor $s.BeforeStashBackgroundColor -ForegroundColor $s.BeforeStashForegroundColor
             Write-Prompt $status.StashCount -BackgroundColor $s.StashBackgroundColor -ForegroundColor $s.StashForegroundColor
             Write-Prompt $s.AfterStashText -BackgroundColor $s.AfterStashBackgroundColor -ForegroundColor $s.AfterStashForegroundColor
        }

        Write-Prompt $s.AfterText -BackgroundColor $s.AfterBackgroundColor -ForegroundColor $s.AfterForegroundColor

        if ($WindowTitleSupported -and $s.EnableWindowTitle) {
            if( -not $Global:PreviousWindowTitle ) {
                $Global:PreviousWindowTitle = $Host.UI.RawUI.WindowTitle
            }
            $repoName = Split-Path -Leaf (Split-Path $status.GitDir)
            $prefix = if ($s.EnableWindowTitle -is [string]) { $s.EnableWindowTitle } else { '' }
            $Host.UI.RawUI.WindowTitle = "$script:adminHeader$prefix$repoName [$($status.Branch)]"
        }
    } elseif ( $Global:PreviousWindowTitle ) {
        $Host.UI.RawUI.WindowTitle = $Global:PreviousWindowTitle
    }
    else {
        Write-Host $arrowSymbol -NoNewLine -ForegroundColor DarkBlue
        #>
    }
}

function getGitStatus($Path) {
    if (Test-Path -Path (Join-Path $Path '.git') ) {
        $isGitLoaded = Import-GitModule $isGitLoaded
        Write-GitPrompt
        return
    }
    else {
        Write-Host $arrowSymbol -NoNewLine -ForegroundColor $pathBackColor
    }
    $SplitPath = split-path $path
    if ($SplitPath) {
        getGitStatus($SplitPath)
    }
}

# Replace the cmder prompt entirely with this.
[ScriptBlock]$CmderPrompt = {

    Microsoft.PowerShell.Utility\Write-Host "`n" $pwd.ProviderPath " " -NoNewLine -BackgroundColor $pathBackColor -ForegroundColor $pathForeColor 
    
    getGitStatus($pwd.ProviderPath)
}


[ScriptBlock]$PostPrompt = {
}

## <Continue to add your own>

