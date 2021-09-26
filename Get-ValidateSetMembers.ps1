function Get-ValidateSetMembers {
    <#
    .SYNOPSIS
    Get Allowed parameter values
    
    .DESCRIPTION
    Get Allowed parameter values from a given command name
    
    .PARAMETER CommandName
    Name of the command. Required
    
    .PARAMETER ParameterName
    Name(s) of the parameters to return (leave blank for all)
    
    .EXAMPLE
    Get-ValidateSetMembers 'Find-Package' -pn Includes,Type
    
    .EXAMPLE
    Get-ValidateSetMembers 'Find-Package'
    #>
    [CmdletBinding()]
    param (
        # Name of the command. Required
        [Parameter(Mandatory,Position=0)]
        [string]
        [Alias('cn')]
        $CommandName,

        # Name(s) of the parameters to return (leave blank for all)
        [Parameter(Position=1)]
        [AllowNull()]
        [string[]]
        [Alias('pn')]
        $ParameterName
    )
    
    [string[]]$CommonParameters = 
    [System.Management.Automation.PSCmdlet]::CommonParameters +
    [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

    if ($null -eq $ParameterName) {
        $ParameterName = (Get-Command $CommandName).Parameters.Keys |
            Where-Object {$CommonParameters -notcontains $_}
    }

    foreach ($param in $ParameterName) {

        $attrib = (
            Get-Command $CommandName
        ).Parameters.$param.Attributes
        
        if ($attrib.ValidValues) {
            [pscustomobject][ordered]@{
                CommandName = $CommandName
                ParameterName = $param
                ValidValues = $attrib.ValidValues
            }
        }

    }#END: foreach ($param in $ParameterName) {}

}#END: function Get-ValidateSetMembers {}
