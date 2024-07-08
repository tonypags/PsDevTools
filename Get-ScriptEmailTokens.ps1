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
            ParameterSetName='byFile',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position=0
        )]
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]
        $File,

        # Raw content of the script file
        [Parameter(ParameterSetName='byContent')]
        [Parameter(ValueFromPipeline)]
        [System.String]
        $String,



        # Drill down into any called functions for emails defined deep in the codebase
        [Parameter()]
        [switch]
        $Recurse

    )#END: param

    begin {
        $ptnEmailAddress = '^.+@[^\.].*\.[a-z]{2,}$' # https://regexlib.com/REDetails.aspx?regexp_id=174
        $rgxIgnoreTheseSources = '^Microsoft\.'
    }

    process {

        foreach ($item in $File) {

            $hashObject = [ordered]@{
                Filename = $item.Name
                EmailFound = $false
                Addresses = [System.Collections.Generic.List[System.Object]]@()
                MaxDepth = 0
                Path = $item.FullName
                TaskHost = $env:COMPUTERNAME
            }
            $fileContent = Get-Content $item.FullName -Raw
            
            # Tokenize the file content
            ([System.Management.Automation.PSParser]::Tokenize(
                $fileContent, [ref]$null)
            ).Where(
                {$_.Type -in ('Command','String')}
            ).ForEach({
                if ($_.Type -eq 'String') {

                    # Do the thing here
                    # Do the thing here
                    # Do the thing here
                    # Do the thing here
                    # Do the thing here
                    # Do the thing here
                    # Do the thing here
                    $_ | Where-Object Content -match $ptnEmailAddress

                } elseif ($_.Type -eq 'Command') {

                    # find the function definition
                    # find the function definition
                    # find the function definition
                    # find the function definition
                    # find the function definition
                    # find the function definition
                    $function = $_.Content
                    $source = (Get-Command $function).Source
                    if ($source -notmatch $rgxIgnoreTheseSources) {
                        $thisDefinition = (Get-Command $function).Definition
                        # $thisTOKENIZED = [System.Management.Automation.PSParser]::Tokenize($definition, [ref]$null)
                        # $thisTOKENIZED | Where-Object Type -eq 'String' | Where-Object Content -match $ptnEmailAddress | Format-Table

                        # call myself
                        # call myself
                        # call myself
                        # call myself
                        # call myself
                        # call myself
                        Get-ScriptEmailTokens -String $thisDefinition -Recurse
                    }

                } else {
                    Write-Error "Unhandled Type: $($_.Type)"
                }
            })


        }#END: foreach ($item in $Param1)

    }#END process

    end {

    }#END: end

}#END: function Get-ScriptEmailTokens
