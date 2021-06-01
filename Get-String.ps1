<#
.Synopsis
   Search contents of PSD1 files for module property 
   configuration settings. 
.DESCRIPTION
   Searches given directory recursively for PSD1 files, 
   replaces a matched, captured regex pattern with 
   a given string. Allows a user to propegate a
   change across a set of PowerShell Modules. 
.INPUTS
   This command has no pipeline input. 
.OUTPUTS
   Output from this cmdlet are objects containing information about the match(es). 
.NOTES
   This cmdlet pairs with the Set-String cmdlet. 
#>
function Get-String
{
    [CmdletBinding()]
    [OutputType([PsCustomObject])]
    Param
    (
        # Define the folder path
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNull()]
        [Alias("ExportFolder","Path")] 
        [string]
        $Directory,

        # Define the types of files to affect
        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $FileTypes,

        # Pattern to match [regex]
        [Parameter(Mandatory=$true,
                   Position=2)]
        [String]
        $Pattern
    )

    Begin
    {
    }
    Process
    {
        # Prep the extention strings for comparison
        $FileTypes = $FileTypes | foreach -Process {
            $_ -replace '\.'
        }
        
        # Start with given folder path and recurse all ps1, psd1, psm1 files
        $RecursedFiles = Get-ChildItem -Path $Directory -File -Recurse |
            where{$FileTypes -contains ($_.Extension -replace '\.')}

        $MatchedLines = $RecursedFiles | Select-String -Pattern $Pattern 
    }
    End
    {
        Write-Output $MatchedLines
    }
}

