function Test-IsGuid {
    param (
        # The string to test
        [Parameter(Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [string]
        $Guid
    )
    
    Process {
        foreach ($id in $Guid) {
            if ($null -eq ($id -as [guid]).gettype()) {
                New-Object -TypeName psobject -Property @{
                    String = $id
                    IsGuid = $false
                    Guid = $null
                }
            } else {
                New-Object -TypeName psobject -Property @{
                    String = $id
                    IsGuid = $true
                    Guid = $id -as [guid]
                }
            }
        }
    }
}
