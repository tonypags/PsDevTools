function Compare-ArrayOrder {

    [CmdletBinding()]
    param (
        [system.object[]]
        $ReferenceArray,
        [system.object[]]
        $DifferenceArray    
    )

    $doesItMatch = $true

    if (
        $ReferenceArray.Count -ne
        $DifferenceArray.Count
    ) {
        Write-Warning "Arrays have different counts"
        $doesItMatch = $false
        break
    }

    for ($i = 0; $i -lt $ReferenceArray.Count; $i++) {
        
        if ($ReferenceArray[$i] -ne $DifferenceArray[$i]) {

            Write-Warning "item[$i] doesn't match: $(
                $ReferenceArray[$i]):$($DifferenceArray[$i]
            )"
            $doesItMatch = $false
            break
        }

    }

    $doesItMatch

}#END: function Compare-ArrayOrder
