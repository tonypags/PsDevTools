function Compare-ArrayOrder {

    [CmdletBinding()]
    param (
        [system.object[]]
        $ReferenceArray,
        [system.object[]]
        $DifferenceArray,
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
        $failedItems.Add([pscustomobject]@{
            index = -1
            ReferenceValue  = $ReferenceArray.Count
            DifferenceValue = [math]::Abs(($ReferenceArray.Count - $DifferenceArray.Count))
        })
    }

    for ($i = 0; $i -lt $ReferenceArray.Count; $i++) {
        
        if ($ReferenceArray[$i] -ne $DifferenceArray[$i]) {

            Write-Warning "item[$i] doesn't match: $(
                $ReferenceArray[$i]):$($DifferenceArray[$i]
            )"
            $doesItMatch = $false
            $failedItems.Add([pscustomobject]@{
                index = $i
                ReferenceValue  = $ReferenceArray[$i]
                DifferenceValue = $DifferenceArray[$i]
            })
        }

    }

    if ($Quiet) {
        $doesItMatch
    } else {
        $failedItems
    }

}#END: function Compare-ArrayOrder
