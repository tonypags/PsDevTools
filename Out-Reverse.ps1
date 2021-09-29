function Out-Reverse {
    <#
    .SYNOPSIS
    Reverses the order of an array
    
    .DESCRIPTION
    Reverses the order of an array
    
    .PARAMETER InputObject
    Ordered array of multiple objects or values
    
    .EXAMPLE
    @('one','two','three') | Out-Reverse

    three
    two
    one
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )

    begin {
        $OutputObject = New-Object System.Collections.ArrayList
    }

    process {

        foreach ($obj in $InputObject) {
            [void]$OutputObject.Add($obj)
        }

    }

    end {

        $OutputObject.Reverse()
        $OutputObject

    }

}#END: function Out-Reverse {}
