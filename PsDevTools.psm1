$Functions = Get-ChildItem $PSScriptRoot\*.ps1
Foreach ($File in $Functions) {
    . $File.FullName
}
Remove-Variable -Name 'Functions','File' -Force -ea 0
Export-ModuleMember -Function * -Alias * -Variable *
