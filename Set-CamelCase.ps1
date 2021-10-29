function Set-CamelCase {
    <#
    .SYNOPSIS
    Converts a string to camelCase

    .DESCRIPTION
    Converts a string to camelCase

    .PARAMETER String
    The string to convert to camelCase

    .PARAMETER SkipToLower
    If a capital letter doesn't follow a space, it will remain capital.

    .EXAMPLE
    Set-CamelCase -String 'make this camel case'
    makeThisCamelCase

    .EXAMPLE
    Set-CamelCase -String 'camelCase'
    camelCase

    .EXAMPLE
    Set-CamelCase -String 'uppercase'
    Uppercase

    .EXAMPLE
    'A very Long stRing of words IN miXed case' | Set-CamelCase
    aVeryLongStringOfWordsInMixedCase
    
    .EXAMPLE
    'A very Long stRing of words IN miXed case' | Set-CamelCase -SkipToLower
    aVeryLongStRingOfWordsINMiXedCase
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$String,
        [switch]$SkipToLower
    )

    if ($String.Trim() -match '\s') {

        # Join the words but make the first letter of each word
        #  after a space capital (camelCase)
        $followsSpace = $false
        [char[]]$char = @()
        foreach ( $letter in ($String.ToCharArray()) ) {

            if ($followsSpace -and $letter.ToString() -notmatch '\s') {

                [char[]]$char += $letter.ToString().ToUpper() -as [char]
                $followsSpace = $false

            } elseif ($letter.ToString() -notmatch '\s') {

                [char[]]$char += if ($SkipToLower.IsPresent) {
                    $letter
                } else {
                    $letter.ToString().ToLower() -as [char]
                }
                $followsSpace = $false

            } elseif ($letter.ToString() -match '\s') {

                $followsSpace = $true

            } else {

                Write-Error "Unhandled case in loop-conditional."

            }

        }

        $char -join ''

    } else {
        
        # Respect existing camelCase entries
        if ($String -cmatch '\p{Lu}') {

            # In this case we have no spaces and at least 1 capital
            $String
            # no changes to input

        } else {

            # Title case any lowercase, no-space strings
            (Get-Culture).TextInfo.ToTitleCase($string)
        
        }

    }
    
}#END: function Set-CamelCase
