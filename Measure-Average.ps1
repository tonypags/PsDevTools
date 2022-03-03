function Measure-Average {

    [CmdletBinding()]

    param(
        # Array of numbers to average
        [Parameter(Mandatory)]
        [System.Object[]]
        $Data,

        # Array of numbers to average
        [Parameter()]
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
            $Modes = ($sortedByCount | Where-Object Count -eq $maxCount).Name
            $Modes

            # $modevalue = @()
            # $i=0
            # foreach ($group in $sortedByCount) {

            #     if ($group.count -ge $i) {
                
            #         $i = $group.count
            #         $modevalue += $group.Name
                
            #     } else {
            #         break
            #     }

            # }
            # $modevalue

        }

        Default {
            Write-Error "Unhandled Average: $($Average)"
            return
        }
    }

}#END: function Measure-Average
