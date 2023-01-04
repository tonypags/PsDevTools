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
    .EXAMPLE
    PS C:\> $email.Body.text | Remove-HTMLTags -ReplaceTagsWithLineBreaks
    #>
    param(
        [Parameter(
            Position=0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('string')]
        [string]
        $Html,

        # Replace all tags with line breaks, instead of just removing the tags
        [Parameter()]
        [switch]
        $ReplaceTagsWithLineBreaks

    )
    
    begin {}

    process {

        $stageOne = (
            $Html -replace 
                '\s\s+',' ' -replace
                '<br>',"`n" -replace
                '\\n',"`n" -replace
                '&#160'," " -replace
                '&nbsp;'," "
        )


        $stageTwo = if ($ReplaceTagsWithLineBreaks.IsPresent) {
            $stageOne -replace '<[^>]+?>',"`n"
        } else {
            $stageOne -replace '<[^>]+?>'
        }
        
        $stageTwo.Trim()
    }

    end {}

}#END: function Remove-HTMLTags {}
