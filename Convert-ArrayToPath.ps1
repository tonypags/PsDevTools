function Convert-ArrayToPath {
    <#
    .SYNOPSIS
    Join-Path for three or more strings.
    .DESCRIPTION
    Creates a path string joining all items with the path separator.
    .EXAMPLE
    @('c:\','temp','temp.txt') | Convert-ArrayToPath
    #>
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline,
            Position=0
        )]
        [validatenotnull()]
        [string[]]
        $Array
    )
    
    begin {
        
        [string]$cmdString = "[IO.Path]::Combine({0})"
        [string]$arrParams = ''
    }
    
    process {
        
        foreach ($string in $Array) {
            
            if ([string]::IsNullOrWhiteSpace($arrParams)) {} else {
                $arrParams += ', '
            }
            $arrParams += "'$($string)'"
        }
    
    }

    end {

        Invoke-Expression ($cmdString -f $arrParams)
        
    }

}#END: function Convert-ArrayToPath {}
