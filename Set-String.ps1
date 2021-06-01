<#
.Synopsis
   Edit PSD1 files for continuity across a project, team, or firm.
.DESCRIPTION
   Searches given directory recursively for PSD1 files, 
   replaces a matched, captured regex pattern with 
   a given string. Allows a user to propegate a
   change across a set of PowerShell Modules. 
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   This cmdlet pairs with Get-String. 
#>
function Set-String
{
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='Low')]
    Param
    (
        # Object created by the Get-Psd1String cmdlet. 
        [Parameter(ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,
        
        # Regex string to target for replace
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]
        $Pattern,
        
        # Literal string to replace
        [Parameter(Mandatory=$true,Position=0)]
        [String]
        $Replace
    )

    Begin
    {
        # User will want confirmation
        $VerifyResult = @()
        # We will record the line prior to and after change,
        #  along with path info, etc. 
    }
    Process
    {
        if ($pscmdlet.ShouldProcess(
                # Target
                "$(
                Write-Host "Line $($InputObject.LineNumber) in File: " -ForegroundColor DarkCyan -NoNewline
                Write-Host "$($InputObject.Path -replace '.*\\')" -ForegroundColor DarkCyan
                )"
                , 
                # Operation
                "$(
                Write-Host 'Set-Content From: ' -NoNewline
                Write-Host "$((($InputObject.Line) -imatch ($InputObject.Pattern)) | %{$Matches.Get_Item(1)})" -ForegroundColor White -BackgroundColor Blue
                Write-Host "$($InputObject.Line)" -f DarkGray

                Write-Host "$($InputObject.Line -replace ($InputObject.Pattern), $Replace)" -ForegroundColor White
                Write-Host 'Set-Content To: ' -NoNewline
                Write-Host "$Replace `n" -ForegroundColor White -BackgroundColor Blue
                )"
            )
        )
        {            
            # Verify we are operating on the pipline, not a parameter array
            if($InputObject.count -eq 1){
                # Grab the full content and the line to change. 
                $strInput = Get-Content ($InputObject.Path)

                if($strInput.count -gt 1){
                    # Slip in the new line
                    $strInput[(($InputObject.LineNumber) -1)] =
                        $InputObject.Line -replace $Pattern, $Replace
                    $strOutput = $strInput
                }else{
                    # Just replace the single line from the file
                    $strOutput = $InputObject.Line -replace $Pattern, $Replace
                }

                # Overwrite the file with the new content. 
                Set-Content -Path ($InputObject.Path) -Value $strOutput -Force            
            }else{
                Invoke-PopupWarningOK -MessageBody "The Set-Psd1String Cmdlet only takes pipeline (object)input!"
            }
            ### END OF PROCESS, NOTHING ELSE BELOW ###
        }
    }
    End
    {
        # Output results object assebled during process

    }
}
# Better idea! cycle thru each file, so we're not setting content on 1 file 4 times in a row. 
#  This would mean I skip the process block and do all logic in the End block. 
#  ...effectively losing the paired cmdlet stuff, some of it anyway. 

