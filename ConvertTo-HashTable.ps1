function ConvertTo-HashTable {
    <#
    .SYNOPSIS
    Converts text file content like a PSD1 file into a hashtable.
    .DESCRIPTION
    Convert raw text contained in a PSD1 file and
    creates a hashtable object on the pipeline, after
    running a basic verification routine on the logic in the file.
    .PARAMETER Path
    A file containing the hash table, ex: PSD1 file
    .PARAMETER HashTableContent
    The hashtable represented as a string (or array)
    .PARAMETER Force
    Does not check the loic before executing the code contained in the PSD1 file.
    .EXAMPLE
    $hash = ConvertTo-HashTable -HashTableContent (Get-Content $filepath)
    .EXAMPLE
    $hash = Get-Content $filepath | ConvertTo-HashTable
    .EXAMPLE
    $hash = ConvertTo-HashTable -Path ./filename.psd1
    #>
    [CmdletBinding(DefaultParameterSetName='byContent')]
    param (

        # The file containing the hash table, ex: PSD1 file
        [Parameter(ParameterSetName='byPath')]
        [ValidateScript({Test-Path $_})]
        [string]
        $Path,

        # The hashtable represented as a string (array)
        [Parameter(ValueFromPipeline,ParameterSetName='byContent')]
        [string[]]
        $HashTableContent,

        # Does not check the loic before executing the code contained in the PSD1 file.
        [Parameter()]
        [switch]
        $Force

    )
    
    begin {
        
        $Content = New-Object -TypeName System.Collections.ArrayList

        [string[]]$allowedCommands = @(
            'New-TimeSpan'
        )
        [string[]]$allowedVariables = @()
        [bool]$allowEnvVariables = $false
    
    }
    
    process {

        if ($PSCmdlet.ParameterSetName -eq 'byContent') {

            foreach ($line in $HashTableContent) {
                [void]($Content.Add($line))
            }
            
        } elseif ($PSCmdlet.ParameterSetName -eq 'byPath') {

            Try {
                Write-Verbose "Content being parsed from config file: [$($Path)]."
                $Content = Get-Content -Path $Path -ErrorAction Stop
            } Catch {
                throw "Unable to parse file content: $($Error[0].Exception.Message)"
            }

        }

    }
    
    end {

        $rawContent = @($Content).Where({$_ -notmatch '^#'})
        $strContent = $rawContent -join "`n"

        # Define a hashtable for all tasks (KEY=pathToParentFolder, VALUE=retentionInDays)
        Try {
            $scriptBlock = [scriptblock]::Create($strContent)
            if ($Force) {} else {
                $scriptBlock.CheckRestrictedLanguage(
                    $allowedCommands, $allowedVariables, $allowEnvVariables
                )
            }
            & $scriptBlock
        } Catch {
            Write-Warning ($Error[0].Exception.Message)
            throw "Unable to execute parsed text as a scriptblock!"
        }

    }

}#END: function ConvertTo-HashTable {}
