function Assert-ParentFolder {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [Alias('Path','Folder')]
        [string]
        $Parent,

        [switch]
        $Force
    )
    
    begin {
        $itemProps = @{}
        $itemProps.ItemType = 'File'
    }
    
    process {

        if (Test-Path $Parent) {
            Write-Verbose "Folder already exists"
        } else {
            if ($Force.IsPresent) {$itemProps.Force = $true}
            $itemProps.Force = $Parent
            New-Item @itemProps
        }
        
    }
    
    end {
        
    }

}#END: function Assert-ParentFolder
