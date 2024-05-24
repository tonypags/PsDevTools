function Convert-CurlyQuotesToStraightQuotes {
    [CmdletBinding()]
    [Alias('curly')]
    param(

        # String line(s) of text with or without curly quotes
        [Parameter(
            ValueFromPipeline,
            HelpMessage='line(s) of text with or without curly quotes',
            Position=0
        )]
        [ValidateNotNull()]
        [string[]]
        $String

    )#END: param

    begin {

        $fancySingleQuotes = "[\u2019\u2018]"
        $fancyDoubleQuotes = "[\u201C\u201D]|&quot;"

    }#END: begin

    process {

        foreach ($item in $String) {

            $item -replace $fancySingleQuotes,"'" -replace $fancyDoubleQuotes,'"'

        }#END: foreach ($item in $String)

    }#END process

}#END: function Convert-CurlyQuotesToStraightQuotes
