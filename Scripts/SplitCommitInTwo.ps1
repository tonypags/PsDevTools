# FROM https://hisham.hm/2019/02/12/splitting-a-git-commit-into-one-commit-per-file/
## Edited for PowerShell by Tony Pagliaro Sept 2022
#
# 1. Run an interactive rebase: git rebase -i <hash#>
# 2. Replace pick with "edit" for the commit you want to split.
# 3. During the edit phase, run this script.
#
## TESTED for actions in normal shell: M=??, A=OK, D=??, R=??
## TESTED for actions during git rebase: M=OK, A=??, D=??, R=??
#

$ErrorActionPreference = 'Stop'

$message="$(git log --pretty=format:'%s' -n1)"

if ((git status --porcelain --untracked-files=no|Measure-Object).Count -eq 0) {
    git reset --soft HEAD^
}

$filesInCommit = @(git status --porcelain --untracked-files=no)

foreach ($item in $filesInCommit) {

    $status = $item[0]
    $file = ($item -replace "^$($status)").Trim().Trim('"') # handle " chars
    Write-Host $status '|' $file

    if ($status -eq 'M') {
        git add $file
        git commit -n $file -m "$($file)`n$message`n"

    } elseif ($status -eq 'A') {
        git add $file
        git commit -n $file -m "Added $($file)`n$message`n"

    } elseif ($status -eq 'D') {
        git rm $file
        git commit -n $file -m "Removed $($file)`n$message`n"
        
    } elseif ($status -eq 'R') {

        Write-Warning "Rename status not yet supported!"
        Write-Host "Re-committing using original commit..."
        Write-Debug "Make sure the 2nd item isn't duplicate committed!!!" -debug
        # git commit -m "$message"
        
    } else {
        Write-Warning "Unknown status for file '$file'. Stop to debug?" -wa:inquire
    }
}

Write-Host "1 commit split into $(($filesInCommit|Measure-Object).Count) commits. Run ``git rebase --continue`` to proceed with rebase."
