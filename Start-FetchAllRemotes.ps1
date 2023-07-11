function Start-FetchAllRemotes {
  <#
  .SYNOPSIS
  Update local index base don remote's current state.
  #>
  [Cmdletbinding()]
  [Alias('fall','Fetch-AllRemotes')]
  param(
    [string]$ModulePath = (Get-Location).Path
  )

  Push-Location

  Set-Location $ModulePath

  $dirs = Get-ChildItem -Directory
  foreach ($dir in $dirs) {
    Set-Location $dir.FullName
    Write-Host ('-' * 35) -ForegroundColor 'Cyan'
    Write-Host "$($dir.Name) " -NoNewline
    $dotGit = Get-Item ./.git/ -ea 0 -Force
    if ($dotGit) {
        git fetch
        Write-Host 'OK' -ForegroundColor 'Green'
    } else {
        Write-Host 'Not linked to any remote repo' -f 'Green'
    }
    Set-Location ..
  }

  Pop-Location

}
