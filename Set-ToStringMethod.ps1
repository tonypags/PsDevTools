function Set-ToStringMethod {
    <#
    .SYNOPSIS
    Changes the ToString() function ran on an object.
    .DESCRIPTION
    Changes the function ran on a
    pscustomobject when calling the ToString() method.
    The variable
    .EXAMPLE
    $ScriptBlock = {
        $g=$this.general
        $b=$g.'Overall bit rate'
        $d=$g.Duration
        $z=$g.'File size'
        $f=$g.Format
        "$f $z $b $d"
    }
    (dir ~/Movies/*.mp4)[0] | Get-MediaInfo -ov info
    $info.tostring()
    #System.Collections.ArrayList
    Set-ToStringMethod $info $ScriptBlock
    $info.tostring()
    #MPEG-4 253 MiB 12.0 Mb/s 2 min 56 s
    #>
    [CmdletBinding()]
    param (
        
        [Parameter(Mandatory,Position=0)]
        [ValidateNotNull()]
        [psobject]
        $InputObject,

        # Use the variable $this to refer to the InputObject
        [Parameter(Mandatory,Position=1)]
        [scriptblock]
        $ScriptBlock

    )
    
    begin {

    }
    
    process {

        $memProps = @{
            Force = $true
            MemberType = 'ScriptMethod'
            Name = 'ToString'
            InputObject = $InputObject
            Value = $ScriptBlock
        }

        Add-Member @memProps

    }
    
    end {

    }

}#END: function Set-ToStringMethod {}
