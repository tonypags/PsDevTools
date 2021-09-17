function ConvertFrom-Html {
    <#
    .SYNOPSIS
    Attempts to scrape table from webpage.
    .DESCRIPTION
    Scrapes a given numbered table for the provided Web 
    Request response from the Invoke-WebRequest cmdlet.
    .PARAMETER WebRequest
    HtmlWebResponseObject returned from Invoke-WebRequest cmdlet. 
    .PARAMETER Html
    Raw HTML string from the webpage.
    .PARAMETER TableIndex
    Index number of the table on the page, in order. First table is default.
    .EXAMPLE
    PS > $w = iwr 'https://www.w3schools.com/html/html_tables.asp'
    
    # Return the first table on a page
    PS > $w | ConvertFrom-Html | ft
    
    Company                      Contact          Country
    -------                      -------          -------
    Alfreds Futterkiste          Maria Anders     Germany
    Centro comercial Moctezuma   Francisco Chang  Mexico
    Ernst Handel                 Roland Mendel    Austria
    Island Trading               Helen Bennett    UK
    Laughing Bacchus Winecellars Yoshi Tannamuri  Canada
    Magazzini Alimentari Riuniti Giovanni Rovelli Italy

    # Again, using a different method requiring only the raw HTML
    PS > $w.RawContent | ConvertFrom-html | ft

    Company                      Contact          Country
    -------                      -------          -------
    Alfreds Futterkiste          Maria Anders     Germany
    Centro comercial Moctezuma   Francisco Chang  Mexico
    Ernst Handel                 Roland Mendel    Austria
    Island Trading               Helen Bennett    UK
    Laughing Bacchus Winecellars Yoshi Tannamuri  Canada
    Magazzini Alimentari Riuniti Giovanni Rovelli Italy

    # Again, with the TableIndex parameter to get the 2nd table
    PS > $w | ConvertFrom-Html -TableIndex 1 | ft

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
    param(
        [Parameter(
            Mandatory,
            Position=0,
            ValueFromPipeline,
            ParameterSetName='byRequest'
        )]
        [Microsoft.PowerShell.Commands.HtmlWebResponseObject]
        $WebRequest,

        [Parameter(
            Mandatory,
            Position=0,
            ValueFromPipeline,
            ParameterSetName='byHtml'
        )]
        [string]
        $Html,

        [Parameter(Position=1)]
        [uint16]
        $TableIndex = 0
    )

    ## Extract the tables out of the web request
    if ($PsCmdlet.ParameterSetName -eq 'byRequest') {
    
        $tables = @($WebRequest.ParsedHtml.getElementsByTagName("TABLE"))
    
    } elseif ($PsCmdlet.ParameterSetName -eq 'byHtml') {
    
        $objHTML = New-Object -Com "HTMLFile"
        $objHTML.IHTMLDocument2_write($Html)
        $tables = $objHTML.getElementsByTagName("TABLE")
    
    }

    $table = $tables[$TableNumber]
    $titles = @()
    $rows = @($table.Rows)

    ## Go through all of the rows in the table
    foreach($row in $rows) {
        
        $cells = @($row.Cells)
        ## If we've found a table header, remember its titles
        if($cells[0].tagName -eq "TH") {
            $titles = @($cells | % { ("" + $_.InnerText).Trim() })
            continue
        }

        ## If we haven't found any table headers, make up names "P1", "P2", etc.
        if(-not $titles) {
            $titles = @(1..($cells.Count + 2) | % { "P$_" })
        }

        ## Now go through the cells in the the row. For each, try to find the
        ## title that represents that column and create a hashtable mapping those
        ## titles to content
        $resultObject = [Ordered] @{}
        for($counter = 0; $counter -lt $cells.Count; $counter++) {
            $title = $titles[$counter]
            if(-not $title) { continue }
            $resultObject[$title] = ("" + $cells[$counter].InnerText).Trim()
        }

        ## And finally cast that hashtable to a PSCustomObject
        [PSCustomObject] $resultObject

    }

}#END: function ConvertFrom-Html
