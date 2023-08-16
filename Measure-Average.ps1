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
        # Array of numbers to average
        [Parameter(Mandatory,Position=0)]
        [System.Object[]]
        $Data,

        # Array of numbers to average
        [Parameter(Position=1)]
        [ValidateNotNull()]
        [ValidateSet('Mean','Median','Mode')]
        [string]
        $Average = 'Mean'
    )

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
