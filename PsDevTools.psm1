$Functions = Get-ChildItem $PSScriptRoot\*.ps1
Foreach ($File in $Functions) {
    . $File.FullName
}
Export-ModuleMember -Function * -Alias * -Variable *
