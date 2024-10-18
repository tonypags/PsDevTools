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

    begin {
        $cachedSearches = @{} # commandName = emailAddresses
        $Results = [System.Collections.Generic.List[System.Object]]@()
    }

    process {

        foreach ($item in $Path) {

            $fileObj = Get-Item $item
            if ($Results.Path -contains $fileObj.FullName) {continue}

            $hashObject = [ordered]@{
                Filename = $fileObj.Name
                EmailFound = $false
                Addresses = [System.Collections.Generic.List[System.Object]]@()
                Path = $fileObj.FullName
                TaskHost = $env:COMPUTERNAME
            }
            $fileContent = Get-Content $fileObj.FullName -Raw

            # Tokenize the SCRIPT file content
            $tokens = [System.Management.Automation.PSParser]::Tokenize($fileContent, [ref]$null) | Limit-TokenTypes

            # Run the tokens through the helper function
            foreach ($token in $tokens) {

                # if the token was already run, add it from the cache
                if ($cachedSearches.Keys -contains $token) {

                    # add token search result from existing cache
                    $theseEmails = $cachedSearches.$token

                } else {
                    # else, run this token and add any results to the cache
                    $theseEmails = Search-EmailTokens -Recurse:($Recurse.IsPresent) -MaxDepth $MaxDepth -Tokens $tokens -hashedCommands $cachedSearches -Commands $Commands
                    if ($theseEmails) {$cachedSearches.$token = $theseEmails}
                }
            }

            foreach ($address in $theseEmails) {
                # Output any newly found email addresses
                if ($hashObject.Addresses -notcontains $address) {$hashObject.Addresses.Add($address)}

            }

            if ($hashObject.Addresses) {
                $hashObject.EmailFound = $true
                $hashObject.Addresses = $hashObject.Addresses | Sort-Object
            }

            $Results.Add([PsCustomObject]$hashObject)

        }#END: foreach ($item in $Path)

    }#END process

}#END: function Get-ScriptEmailTokens

function Search-EmailTokens {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.PSToken[]]
        $Tokens,

        # Maintained list of previously discovered tokens to avoid re-scanning a given command; commandName = emailAddresses[]
        [Parameter(Mandatory)]
        [AllowNull()]
        [hashtable]
        $hashedCommands,

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
    $ptnXmlCredential = '\\.+\.xml$' # cred file names contain a username@domain.tld pattern
    $ptnEmailBody1 = 'Please inform .+?@nfl.com of the status' # Emails listed in body text are not being sent any reports
    $ptnEwsQuery1 = '\.folders[\.\w]+?\([''"][\.\w-]+?@nfl\.com[''"]\)\.?' # getting mailbox data uses email as parameter

    # $Searches = [System.Collections.Generic.List[System.Object]]@()
    $ignoreSomeCommands = -not [string]::IsNullOrEmpty($Commands)

    foreach ($token in $Tokens) {
        if ($token.Type -eq 'String') {

            ###NOTE: This won't work since we are matching the token "Content", not the full line of code.
            # We need to reference the full line of code in some way. Another property? It only has line number, maybe we can call up the token tree, so to speak.
            if ($token.Content -match $ptnEwsQuery1) {continue} # ews queries do contain emails
            # We need to reference the full line of code in some way.
            # We need to reference the full line of code in some way.
            # We need to reference the full line of code in some way.
            # We need to reference the full line of code in some way.

            # I think it would be easier to ignore any string that is not just an email address and only an email address.
            if ($token.Content -match $ptnEmailBody1) {continue} # Emails listed in body text are not being sent any reports
            # I think it would be easier to ignore any string that is not just an email address and only an email address.
            # I think it would be easier to ignore any string that is not just an email address and only an email address.
            # I think it would be easier to ignore any string that is not just an email address and only an email address.
            # I think it would be easier to ignore any string that is not just an email address and only an email address.
            
            # Only match on email strings used to send reports or other notices
            if ($token.Content -match $ptnXmlCredential) {continue} # cred files do contain email-like strings
            if ($token.Content -match $ptnEmailAddress) {$token.Content} # then look for email pattern

        } elseif ($token.Type -eq 'Command') {

            # Discard commands if given a list; include select commands
            if ($ignoreSomeCommands -and $token.Content -notin $Commands) {continue}

            if ($Recurse.IsPresent) {

                $function = Try {Get-Command $token.Content -ea Stop} Catch {
                    if ($_.Exception.Message -like '*is not recognized as the name of a cmdlet*') {
                        # What about Private functions? Those will behave just like a missing function
                        # What about Private functions? Those will behave just like a missing function
                        # What about Private functions? Those will behave just like a missing function
                        # What about Private functions? Those will behave just like a missing function
                        continue
                    }
                    Write-Error $_
                }

                $tokens = [System.Management.Automation.PSParser]::Tokenize($function.Definition, [ref]$null) | Limit-TokenTypes
                if ($tokens) {
                    $newDepth = $CurrentDepth + 1
                    Write-Verbose " Recursion Depth: $('0:000' -f $newDepth) | Module / Function: [$($function.Source) / $($function.Name)]" -Verbose
                    Search-EmailTokens -Recurse -MaxDepth $MaxDepth -CurrentDepth $newDepth -Tokens $tokens -hashedCommands $hashedCommands
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
