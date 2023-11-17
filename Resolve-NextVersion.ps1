function Resolve-NextVersion {
    <#
    .EXAMPLE
    Resolve-NextVersion '0.1.0'
    0.1.1
    .EXAMPLE
    Resolve-NextVersion '0.1.0' -NewMajorVersion
    1.0.0
    .EXAMPLE
    Resolve-NextVersion '0.1.0' -NewMinorVersion
    0.2.0
    #>
    param(
        # Baseline Value
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [AllowNull()]
        [Alias('Version','FileVersion')]
        [version]
        $CurrentVersion,

        # Value to use for new files/packages
        [Parameter()]
        [version]
        $InitialVersion = '0.1.0',

        # Setting this will increment major and zero the rest
        [Parameter()]
        [switch]
        $NewMajorVersion,
        
        # Setting this will increment minor and zero the build
        [Parameter()]
        [switch]
        $NewMinorVersion
    )

    $v = $CurrentVersion # abbrieviation only
    $strVersion = "$($v.Major).$($v.Minor).$($v.Build)"

    # Calculate Next Version
    if ($strVersion -eq '..') {
        $InitialVersion
    } elseif ($NewMajorVersion.IsPresent) {
        $newMajor = ([version]$strVersion).Major + 1
        "$($newMajor).0.0" -as [version]
        
    } elseif ($NewMinorVersion.IsPresent) {
        $oldMajor = ([version]$strVersion).Major
        $newMinor = ([version]$strVersion).Minor + 1
        "$($oldMajor).$($newMinor).0" -as [version]
        
    } else {
        $oldMajor = ([version]$strVersion).Major
        $oldMinor = ([version]$strVersion).Minor
        $newBuild = ([version]$strVersion).Build + 1
        "$($oldMajor).$($oldMinor).$($newBuild)" -as [version]
    }

}#END: function Resolve-NextVersion
