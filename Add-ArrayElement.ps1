function Add-ArrayElement {
    <#
    .SYNOPSIS
    Adds item to list
    
    .DESCRIPTION
    Adds the given Element to the given Array or collection of pipeline objects.
    Inserts the new Element into position specified either by Index or by Value.
    
    .PARAMETER Element
    Any single value, arrays will be treated as a single value
    
    .PARAMETER Array
    The collection being modified/appended to
    
    .PARAMETER Index
    The numeric position of the incoming element, last by default.
    Must be less than collection size.
    
    .PARAMETER Value
    Optionally enter the Value that exists in the collection. The element
    being added will come before the first occurrance of this value in the collection.
    When entering an integer as the Value, you must specify the parameter name,
    otherwise it will be treated as the Index parameter's value.
    
    .EXAMPLE
    @(10,30) | Add-ArrayElement 20 1
    10
    20
    30

    Add an element into the 2nd position of an array using the index parameter
    .EXAMPLE
    @('ready','go') | Add-ArrayElement 'set 'go'
    ready
    set
    go
    
    Add an element into the position above an existing element in the array, by value
    .EXAMPLE
    @('10.0.0.11','10.0.0.12') | Add-ArrayElement '1.1.1.1'
    10.0.0.11
    10.0.0.12
    1.1.1.1

    Append a public DNS server to the existing stack
    .EXAMPLE
    @('10.0.0.11','10.0.0.12') | Add-ArrayElement '10.0.0.13' 0
    10.0.0.13
    10.0.0.11
    10.0.0.12

    Prepend a new DNS server to the existing stack
    #>
    [CmdletBinding(DefaultParameterSetName='byIndex')]
    param (
        # Any single value, arrays will be treated as a single value
        [Parameter(Mandatory,Position=0)]
        [system.object]
        $Element,

        # The collection being modified/appended to
        [Parameter(ValueFromPipeline,Position=1)]
        [ValidateNotNullOrEmpty()]
        [system.object[]]
        $Array,

        # The numeric position of the incoming element, last by default.
        # Must be less than collection size.
        [Parameter(ParameterSetName='byIndex',Position=2)]
        [int]
        $Index = -1,

        # Optionally enter the Value that exists in the collection.
        # The element being added will come before the first
        #  occurrance of this value in the collection.
        # When entering an integer as the Value, you must specify the parameter
        #  name, otherwise it will be treated as the Index parameter's value.
        [Parameter(ParameterSetName='byValue',Position=2)]
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

        # Make sure that the Index isn't out of range
        # Then test other cases
        if ( $Index -gt $maxIndex ) {

            Write-Information "Appending value to end of Array. $(
            )The given Index [$($Index)] is out of range [0..$($maxIndex)]."

            # Simply append the value to the end of the input (like enqueue)
            $itemsAboveInsert = $intArray
            $itemsBelowInsert = $null

        } elseif ($Index -eq -1) {

            # The user didn't specify, or chose last position
            # Simply append the value to the end of the input (like enqueue)
            $itemsAboveInsert = $intArray
            $itemsBelowInsert = $null
            
        } elseif ($Index -eq 0) {

            # Top of the stack (like a push)
            $itemsAboveInsert = $null
            $itemsBelowInsert = $intArray

        } else {

            # Somewhere in between, split collection in 2 at the given index
            $itemsAboveInsert = @($intArray)[0..($Index -1)]
            $itemsBelowInsert = @($intArray)[($Index)..($maxIndex)]
        
        }
        
        # @($itemsAboveInsert) + ,$Element + @($itemsBelowInsert) # This was ading nulls in and affecting the total count of objects.
        $outArray = @()
        if (@($itemsAboveInsert)) { @($itemsAboveInsert) | ForEach-Object {$outArray += $_} }
        $outArray += ,$Element
        # (,$var) forces a single value if $var is an array
        if (@($itemsBelowInsert)) { @($itemsBelowInsert) | ForEach-Object {$outArray += $_} }
        $outArray

    }

}#END: function Add-ArrayElement