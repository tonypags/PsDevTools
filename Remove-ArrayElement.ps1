function Remove-ArrayElement {
    <#
    .SYNOPSIS
    Removes an item from a list

    .DESCRIPTION
    Removes the given Value/Index from the given Array or collection of pipeline objects.
    
    .PARAMETER Array
    The collection being modified
    
    .PARAMETER Index
    The numeric position of the unwanted value, last element by default.
    Must be less than collection size.
    
    .PARAMETER Value
    Optionally enter the Value that exists in the collection.
    When entering an integer as the Value, you must specify the parameter name,
    otherwise it will be treated as the Index parameter's value.
    
    .EXAMPLE
    @('ready','set','go') | Remove-ArrayElement 0
    set
    go
    
    Trims the array's first value.

    .EXAMPLE
    @('10.0.0.11','10.0.0.12','1.1.1.1') | Remove-ArrayElement
    10.0.0.11
    10.0.0.12

    Trims the array's last value.

    .EXAMPLE
    @('10.0.0.11','10.0.0.12','10.0.0.13') | Remove-ArrayElement '10.0.0.13'
    10.0.0.11
    10.0.0.12

    Remove an old DNS server from the existing stack.

    .EXAMPLE
    @(10,20,30) | Remove-ArrayElement -Value 20
    10
    30

    Removes the given integer value. Integer values MUST be a named parameter,
    otherwise it will be the treated as the Nth index.
    #>
    [CmdletBinding(DefaultParameterSetName='byIndex')]
    param (
        # The collection being modified/appended to
        [Parameter(ValueFromPipeline,Position=1)]
        [ValidateNotNullOrEmpty()]
        [system.object[]]
        $Array,

        # The numeric position of the unwanted element, last [-1] by default.
        # Must be less than collection size.
        [Parameter(ParameterSetName='byIndex',Position=0)]
        [ValidateNotNull()]
        [int]
        $Index = -1,

        # Optionally enter the Value that exists in the collection.
        # When entering an integer as the Value, you must specify the parameter
        #  name, otherwise integers will be treated as the -Index parameter's value.
        [Parameter(ParameterSetName='byValue',Position=0,Mandatory)]
        [system.object]
        $Value
    )
    
    begin {
        $intArray = @()
    }
    
    process {
        foreach ($item in $Array) {
            $intArray += $item
        }
    }
    
    end {
        
        if ($PSCmdlet.ParameterSetName -eq 'byValue') {
            $Index = $intArray.IndexOf($Value)
        }
        
        $maxIndex = @($intArray).Count - 1

        if ($PSCmdlet.ParameterSetName -eq 'byIndex') {

            # Make sure that the Index isn't out of range
            if ( $Index -gt $maxIndex ) {

                Write-Error "Given index [$($Index)] is out of range [0..$($maxIndex)]."
                return
    
            }

        }

        if ($Index -eq -1 -or $Index -eq $maxIndex) {

            # The user didn't specify, or chose last position
            $intArray[0..($maxIndex - 1)]
            
        } elseif ($Index -eq 0) {

            # Top of the stack (like a push)
            $intArray[1..($maxIndex)]

        } else {

            # Somewhere in between, split collection in 2 at the given index
            $itemsAboveUnwanted = @($intArray)[0..($Index - 1)]
            $itemsBelowUnwanted = @($intArray)[($Index + 1)..($maxIndex)]
        
            # @($itemsAboveUnwanted) + ,$Element + @($itemsBelowUnwanted) # This was ading nulls in and affecting the total count of objects.
            $outArray = @()
            if (@($itemsAboveUnwanted)) { @($itemsAboveUnwanted) | ForEach-Object {$outArray += $_} }
            $outArray += ,$Element
            # (,$var) forces a single value if $var is an array
            if (@($itemsBelowUnwanted)) { @($itemsBelowUnwanted) | ForEach-Object {$outArray += $_} }
            $outArray
            
        }#END: if ($Index -eq -1 -or $Index -eq $maxIndex)

    }#END: end {}

}#END: function Remove-ArrayElement
