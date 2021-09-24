function Remove-HTMLTags {
    <#
    .SYNOPSIS
    Short description
    .DESCRIPTION
    Long description
    .EXAMPLE
    PS C:\> Remove-HTMLTags $email.Body.text
    .EXAMPLE
    PS C:\> $email.Body.text | Remove-HTMLTags
    #>
    param(
        [Parameter(
            Position=0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]
        $Html
    )
    
    begin {}

    process {

        (
            $Html -replace 
                '\s\s+',' ' -replace
                '<br>',"`n" -replace
                '\\n',"`n" -replace
                '&#160'," " -replace
                '&nbsp;'," " -replace
                '<[^>]+?>'
        ).Trim()
        
    }

    end {}

}
