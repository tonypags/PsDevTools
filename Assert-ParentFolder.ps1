function Assert-ParentFolder {
    <#
    .EXAMPLE
    Assert-ParentFolder -Parent C:\temp\parent
    Creates a new folder if one doesn't already exist.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [Alias('Path','Folder')]
        [string]
        $Parent,

        [switch]
        $Force,

        [switch]
        $PassThru
    )
    
    begin {
        $itemProps = @{}
        $itemProps.ItemType = 'Directory'
    }
    
    process {

        if (Test-Path $Parent) {
            Write-Verbose "Folder already exists"
        } else {
            if ($Force.IsPresent) {$itemProps.Force = $true}
            $itemProps.Path = $Parent
            New-Item @itemProps | Out-Null
        }

        if ($PassThru) {Get-Item $Parent}
        
    }
    
}#END: function Assert-ParentFolder
