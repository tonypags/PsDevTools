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

        # list items should start/end on a new line and each item should end on a new line
        $stageTwo = $stageOne -replace
            '<\/?[o|u]l>',"`n" -replace
            '<li>'            -replace
            '<\/li>',"`n"

            # All other tags get replaced by nothing, unless a switch is present
        $stageThree = if ($ReplaceTagsWithLineBreaks.IsPresent) {
            $stageTwo -replace '<[^>]+?>',"`n"
        } else {
            $stageTwo -replace '<[^>]+?>'
        }
        
        $stageThree.Trim()
    }

    end {}

}#END: function Remove-HTMLTags {}
