function Get-ScriptEmailTokens {
    <#
    .SYNOPSIS
    Tokenizes a script file and return email address values found.
    .EXAMPLE
    dir *.ps1 | Get-ScriptEmailTokens
    
    Gets the email tokens from the given file
    .EXAMPLE
    dir *.ps1 | Get-ScriptEmailTokens -Recurse

    Gets the email tokens from any functions called within the file
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
                Search-EmailTokens -Recurse:($Recurse.IsPresent) -MaxDepth $MaxDepth -Tokens $tokens

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
    $rgxIgnoreTheseSources = '^Microsoft\.|^Microsoft\.'
    $rgxIgnoreTheseHelpUris = 'microsoft\.com'

    foreach ($token in $Tokens) {
        if ($token.Type -eq 'String') {

            if ($token.Content -match $ptnEmailAddress) { $token.Content }

        } elseif ($token.Type -eq 'Command') {
            
            if ($Recurse.IsPresent) {

                $function = Try {Get-Command $token.Content -ea Stop} Catch {
                    if ($_.Exception.Message -like '*is not recognized as the name of a cmdlet*') {continue}
                    Write-Error $_
                }
                
                if ($function.Source -notmatch $rgxIgnoreTheseSources -and $function.HelpUri -notmatch $rgxIgnoreTheseHelpUris) {

                    $tokens = [System.Management.Automation.PSParser]::Tokenize($function.Definition,  [ref]$null) | Limit-TokenTypes
                    Search-EmailTokens -Recurse -MaxDepth $MaxDepth -CurrentDepth ($CurrentDepth + 1) -Tokens $tokens
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
        $limitToTypes = ('Command','String')
    }

    process {
        @($Tokens).Where({ $_.Type -in $limitToTypes })
    }

}#END: function Limit-TokenTypes
