function ConvertFrom-HtmlTable {
    <#
    .SYNOPSIS
    Attempts to scrape table from webpage.
    .DESCRIPTION
    Scrapes a given numbered table for the provided Web 
    Request response from the Invoke-WebRequest cmdlet.
    .EXAMPLE
    PS > $w = iwr 'https://www.w3schools.com/html/html_tables.asp'
    
    # Return the first table on a page
    PS > $w | ConvertFrom-HtmlTable | ft
    
    Company                      Contact          Country
    -------                      -------          -------
    Alfreds Futterkiste          Maria Anders     Germany
    Centro comercial Moctezuma   Francisco Chang  Mexico
    Ernst Handel                 Roland Mendel    Austria
    Island Trading               Helen Bennett    UK
    Laughing Bacchus Winecellars Yoshi Tannamuri  Canada
    Magazzini Alimentari Riuniti Giovanni Rovelli Italy

    # Again, using a different method requiring only the raw HTML
    PS > $w.RawContent | ConvertFrom-HtmlTable | ft

    Company                      Contact          Country
    -------                      -------          -------
    Alfreds Futterkiste          Maria Anders     Germany
    Centro comercial Moctezuma   Francisco Chang  Mexico
    Ernst Handel                 Roland Mendel    Austria
    Island Trading               Helen Bennett    UK
    Laughing Bacchus Winecellars Yoshi Tannamuri  Canada
    Magazzini Alimentari Riuniti Giovanni Rovelli Italy

    # Again, with the TableIndex parameter to get the 2nd table
    PS > $w | ConvertFrom-HtmlTable -TableIndex 1 | ft

    Tag        Description
    ---        -----------
    <table>    Defines a table
    <th>       Defines a header cell in a table
    <tr>       Defines a row in a table
    <td>       Defines a cell in a table
    <caption>  Defines a table caption
    <colgroup> Specifies a group of one or more columns in a table for formatting
    <col>      Specifies column properties for each column within a <colgroup> element
    <thead>    Groups the header content in a table
    <tbody>    Groups the body content in a table
    <tfoot>    Groups the footer content in a table

    .NOTES
    From https://www.leeholmes.com/blog/2015/01/05/extracting-tables-from-powershells-invoke-webrequest/
    #>
    [CmdletBinding()]
    [Alias('ConvertFrom-Html')]
    param(

    # The result of Invoke-WebRequest
        [Parameter(
            Mandatory,
            Position=0,
            ValueFromPipeline,
            ParameterSetName='byRequest'
        )]
        [Microsoft.PowerShell.Commands.HtmlWebResponseObject]
        $WebRequest,

        # Raw HTML text with at least 1 pair of <table> tags
        [Parameter(
            Mandatory,
            Position=0,
            ValueFromPipeline,
            ParameterSetName='byHtml'
        )]
        [string]
        $Html,

        # Choose a table found on the page. First table is default.
        [Parameter(Position=1)]
        [uint16]
        $TableIndex = 0,

        # Force using the first row as column headers
        [switch]
        $FirstRowHeaders
    )

    ## Extract the tables out of the web request
    if ($PsCmdlet.ParameterSetName -eq 'byRequest') {
    
        $tables = @($WebRequest.ParsedHtml.getElementsByTagName("TABLE"))
    
    } elseif ($PsCmdlet.ParameterSetName -eq 'byHtml') {
    
        $objHTML = New-Object -Com "HTMLFile"
        $objHTML.IHTMLDocument2_write($Html)
        $tables = $objHTML.getElementsByTagName("TABLE")
    
    }

    $table = $tables[$TableIndex]
    $titles = @()
    $rows = @($table.Rows)

    ## Go through all of the rows in the table
    $rc = 0
    foreach($row in $rows) {
        
        $cells = @($row.Cells)
        Write-Debug "Inspect `$cells ?"
        ## If we've found a table header, remember its titles
        # If the set contains no TH tag, assume the first row has the headers
        if(
            $cells[0].tagName -eq "TH" -or
            ($rc -eq 0 -and $FirstRowHeaders.IsPresent)
        ) {
            $titles = @($cells | ForEach-Object { ("" + $_.InnerText).Trim() })
            $rc++
            continue
        }

        ## If we haven't found any table headers, make up names "P1", "P2", etc.
        if(-not $titles) {
            $titles = @(1..($cells.Count + 2) | ForEach-Object { "P$_" })
        }

        ## Now go through the cells in the the row. For each, try to find the
        ## title that represents that column and create a hashtable mapping those
        ## titles to content
        $resultObject = [Ordered] @{}
        for($counter = 0; $counter -lt $cells.Count; $counter++) {
            $title = $titles[$counter]
            if(-not $title) {
                $rc++
                continue
            }
            $resultObject[$title] = ("" + $cells[$counter].InnerText).Trim()
        }

        ## And finally cast that hashtable to a PSCustomObject
        [PSCustomObject] $resultObject
        $rc++

    }

}#END: function ConvertFrom-HtmlTable
