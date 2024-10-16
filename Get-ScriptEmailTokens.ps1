function Get-ScriptEmailTokens {
    <#
    .SYNOPSIS
    Tokenizes a script file and return email address values found.
    .EXAMPLE
    dir *.ps1 | Get-ScriptEmailTokens

    Gets the email tokens from the given files in the path
    .EXAMPLE
    dir *.ps1 | Get-ScriptEmailTokens -Commands New-Thingy,Add-Thingy -Recurse

    Gets the email tokens from either functions New-Thingy or Add-Thingy called within the files in the path
    .EXAMPLE
    dir *.ps1 | Get-ScriptEmailTokens -Recurse

    Gets the email tokens from any functions called within the files in the path
    #>
    [CmdletBinding()]
    param(

        # Object of the script file
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position=0
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,

        # Used to limit nested scanning to a given set of command/function names, by default no limits
        [Parameter()]
        [string[]]
        $Commands,

        # Drill down into any called functions for emails defined deep in the codebase
        [Parameter()]
        [switch]
        $Recurse,

        # How deep to drill down into nested functions [0=no recusion; -1=no maximum]
        [Parameter()]
        [ValidateRange(-1,99)]
        [int]
        $MaxDepth=-1

    )#END: param

    process {

        foreach ($item in $Path) {

            $fileObj = Get-Item $item

            $hashObject = [ordered]@{
                Filename = $fileObj.Name
                EmailFound = $false
                Addresses = [System.Collections.Generic.List[System.Object]]@()
                Path = $fileObj.FullName
                TaskHost = $env:COMPUTERNAME
            }
            $fileContent = Get-Content $fileObj.FullName -Raw

            # Run the tokens through the helper function
            @(
                # Tokenize the file content
                $tokens = [System.Management.Automation.PSParser]::Tokenize($fileContent, [ref]$null) | Limit-TokenTypes

                if ($tokens) {
                    Search-EmailTokens -Recurse:($Recurse.IsPresent) -MaxDepth $MaxDepth -Tokens $tokens -Commands $Commands
                }

            ).Foreach({

                # Output any newly found email addresses
                if ($hashObject.Addresses -notcontains $_) {$hashObject.Addresses.Add($_)}

            })

            if ($hashObject.Addresses) {
                $hashObject.EmailFound = $true
                $hashObject.Addresses = $hashObject.Addresses | Sort-Object
            }

            [PsCustomObject]$hashObject

        }#END: foreach ($item in $Path)

    }#END process

}#END: function Get-ScriptEmailTokens

function Search-EmailTokens {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.PSToken[]]
        $Tokens,

        # Used to limit nested scanning to a given set of command/function names, by default no limits
        [Parameter()]
        [string[]]
        $Commands,

        # Drill down into any called functions for emails defined deep in the codebase
        [Parameter()]
        [switch]
        $Recurse,

        # How deep to drill down into nested functions [0=no recusion; -1=no maximum]
        [Parameter()]
        [ValidateRange(-1,99)]
        [int]
        $MaxDepth=-1,

        [Parameter()]
        [int]
        $CurrentDepth=0
    )

    if ($MaxDepth -eq -1) {<# NO MAX DEPTH #>} elseif ($CurrentDepth -gt $MaxDepth) {return}

    $ptnEmailAddress = '^.+@[^\.].*\.[a-z]{2,}$' # https://regexlib.com/REDetails.aspx?regexp_id=174
    $rgxIgnoreTheseSources = '^Az\.|^VMWare\.|^Microsoft\.|PnP\.PowerShell'
    $rgxIgnoreTheseHelpUris = 'microsoft\.com'

    foreach ($token in $Tokens) {
        if ($token.Type -eq 'String') {

            if ($token.Content -match $ptnEmailAddress) { $token.Content }

        } elseif ($token.Type -eq 'Command') {

            # Discard commands if given a list
            if (-not [string]::IsNullOrEmpty($Commands)) {
                # include select commands
                if ($token.Content -notin $Commands) {continue}
            }

            if ($Recurse.IsPresent) {

                $function = Try {Get-Command $token.Content -ea Stop} Catch {
                    if ($_.Exception.Message -like '*is not recognized as the name of a cmdlet*') {continue}
                    Write-Error $_
                }

                if (
                    $function.Source -notmatch $rgxIgnoreTheseSources -and
                    $function.Name -notmatch '\.exe$' -and
                    $function.HelpUri -notmatch $rgxIgnoreTheseHelpUris
                ) {

                    $tokens = [System.Management.Automation.PSParser]::Tokenize($function.Definition, [ref]$null) | Limit-TokenTypes
                    if ($tokens) {
                        $newDepth = $CurrentDepth + 1
                        Write-Verbose " Recursion Depth: $('0:000' -f $CurrentDepth) | Module / Function: [$($function.Source) / $($function.Name)]" -Verbose
                        Search-EmailTokens -Recurse -MaxDepth $MaxDepth -CurrentDepth $newDepth -Tokens $tokens
                    }
                }
            }

        } else {
            Write-Error "Unhandled Type: $($token.Type)"
        }
    }

}#END: function Search-EmailTokens

function Limit-TokenTypes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [System.Management.Automation.PSToken[]]
        $Tokens
    )

    begin {
        $limitToTypes = Get-TokenTypes
    }

    process {
        @($Tokens).Where({ $_.Type -in $limitToTypes })
    }

}#END: function Limit-TokenTypes

function Get-TokenTypes {
    @('Command','String')
}#END: function Get-TokenTypes
