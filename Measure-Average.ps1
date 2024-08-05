function Measure-Average {
    <#
    .SYNOPSIS
    Calculates the average of an array of numbers
    .DESCRIPTION
    Allows the user to choose average mean, median,
    or mode and returns the numerical result.
    .EXAMPLE
    Measure-Average @(1,3,44,3,14,6,100)
    24.4285714285714

    Returns the average (mean)
    .EXAMPLE
    Measure-Average @(1,3,44,3,14,6,100) Median
    6
    
    Returns the median
    .EXAMPLE
    Measure-Average @(1,3,44,3,14,6,100) Mode
    3

    Returns the most common item (mode)
    .EXAMPLE
    Measure-Average @(1,3,44,3,14,6,100,6) Mode
    3
    6

    Returns the most common items (modes)
    #>

    [CmdletBinding()]

    param(
        # Array of numbers to average (allow null elements, we remove them in logic)
        [Parameter(Mandatory,Position=0)]
        [AllowNull()]
        [System.Object[]]
        $Data,

        # Array of numbers to average
        [Parameter(Position=1)]
        [ValidateNotNull()]
        [ValidateSet('Mean','Median','Mode')]
        [Alias('Method')]
        [string]
        $Average = 'Mean'
    )

    # Ensure no null values are passed
    $count1 = ($Data | Measure-Object).Count
    $Data = $Data | Where-Object {$null -ne $_}
    $count2 = ($Data | Measure-Object).Count
    $diffC = $count1 - $count2
    if ($count2) {
        if ($diffC) {Write-Warning "[Measure-Average] Filtered out $($diffC) null data point(s)"}
    } else {
        Write-Error 'No values passed to function!'
        return
    }

    switch ($Average) {

        'Mean'   {
            ($Data | Measure-Object -Average).Average
        }

        'Median' {

            $Data = $Data | Sort-Object
            if ($Data.count % 2) {
                #odd
                $middleItemIndex = [math]::Ceiling($Data.count/2) - 1
                $Data[$middleItemIndex]
            } else {
                #even
                $twoMiddleItems = $Data[$Data.Count/2], $Data[$Data.count/2-1]
                ($twoMiddleItems | Measure-Object -Average).average
            }            
        }

        'Mode'   {

            $sortedByCount = $Data | Group-Object | Sort-Object -Descending Count
            $maxCount = $sortedByCount[0].Count

            # Return multiple values is desired when found
            $Modes = ($sortedByCount | Where-Object Count -eq $maxCount).Name
            $Modes
        }

        Default {
            Write-Error "Unhandled Average: $($Average)"
            return
        }
    }

}#END: function Measure-Average
