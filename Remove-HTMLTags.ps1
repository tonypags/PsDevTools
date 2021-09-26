function Remove-HTMLTags {
    <#
    .SYNOPSIS
    Converts HTML into a semi-readable text block.
    .DESCRIPTION
    Converts HTML into a semi-readable text block.
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

}#END: function Remove-HTMLTags {}
