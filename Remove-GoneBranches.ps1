function Remove-GoneBranches {
  <#
  .SYNOPSIS
  Delete any local branches which are tracking origins that have been deleted.
  #>
  [Cmdletbinding()]
  [Alias('gone','Delete-GoneBranches')]
  param(
    [string]$RepoPath = (Get-Location).Path,
    [switch]$Force
  )

  Push-Location

  Set-Location $RepoPath

  git fetch --prune

  $gone = git branch -av | select-string '\[gone\]'

  foreach ($item in $gone) {

    $B = ($item.line -split '\s+')[1]

    if ($Force.IsPresent) {
      git branch -D $B
    } else {
      git branch -d $B
    }

  }

  Pop-Location

}
