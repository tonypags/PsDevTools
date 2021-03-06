function Compare-ArrayOrder {
    <#
    .SYNOPSIS
    Compare small arrays against each other, including order of elements.
    .NOTES
    For larger arrays, use this logic. 
    $diff = [Collections.Generic.HashSet[string]]$Collection1
    $diff.SymmetricExceptWith([Collections.Generic.HashSet[string]]$Collection2.BaseName)
    $diffArray = [string[]]$diff
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        [ValidateNotNullOrEmpty()]
        [system.object[]]
        $ReferenceArray,

        [Parameter(Mandatory,Position=1)]
        [ValidateNotNullOrEmpty()]
        [system.object[]]
        $DifferenceArray,
        
        [Parameter()]
        [switch]
        $Quiet
    )

    $doesItMatch = $true
    $failedItems = [system.collections.arraylist]@()

    if (
        $ReferenceArray.Count -ne
        $DifferenceArray.Count
    ) {
        Write-Warning "Arrays have different counts"
        $doesItMatch = $false
        [void]($failedItems.Add([pscustomobject]@{
            index = -1
            ReferenceValue  = $ReferenceArray.Count
            DifferenceValue = [math]::Abs(($ReferenceArray.Count - $DifferenceArray.Count))
        }))
    }

    for ($i = 0; $i -lt $ReferenceArray.Count; $i++) {
        
        if ($ReferenceArray[$i] -ne $DifferenceArray[$i]) {

            Write-Warning "item[$i] doesn't match: $(
                $ReferenceArray[$i]):$($DifferenceArray[$i]
            )"
            $doesItMatch = $false
            [void]($failedItems.Add([pscustomobject]@{
                index = $i
                ReferenceValue  = $ReferenceArray[$i]
                DifferenceValue = $DifferenceArray[$i]
            }))
        }

    }

    if ($Quiet) {
        $doesItMatch
    } else {
        $failedItems
    }

}#END: function Compare-ArrayOrder
