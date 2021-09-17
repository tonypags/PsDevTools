
function Get-CacheDir {

    $CacheDir = if ($PsScriptRoot) {
        Join-Path $PsScriptRoot "cache"
    } else {
        $module = $env:PSModulePath -split ';' |
        Where-Object {$_ -like '*users*'} | 
        Select-Object -First 1
        Join-Path $module "PsClickToRunTools\cache"
    }
    $CacheDir

}#END: function Get-CacheDir

function Get-CachedXmlPath {
    $CacheDir = Get-CacheDir
    $CachedXmlPath =  Join-Path $CacheDir "c2r-channels.xml"
    $CachedXmlPath
}

function Save-TableAsXmlInCache {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [pscustomobject]
        $Table
    )

    $CacheDir = Get-CacheDir
    if ( -not (Test-Path $CacheDir)) {
        New-Item $CacheDir -ItemType Directory -Force
    }

    $CachedXmlPath = Get-CachedXmlPath
    $Table | Export-CliXml -Path $CachedXmlPath

}#END: function Save-TableAsXmlInCache


function Test-TableXmlInCache {

    $CachedXmlPath = Get-CachedXmlPath
    if (Test-Path $CachedXmlPath) {
        $true
    } else {
        $false
    }

}#END: function Test-TableXmlInCache

function Get-TableXmlInCacheItem {

    $CachedXmlPath = Get-CachedXmlPath
    if (Test-TableXmlInCache) {
        Get-Item $CachedXmlPath
    } else {
        throw "Cache file not found!"
    }

}#END: function Get-TableXmlInCacheItem


function Import-TableXmlInCache {

    $CachedXmlPath = Get-CachedXmlPath
    if (Test-TableXmlInCache) {
        Import-CliXml -Path $CachedXmlPath
    } else {
        throw "Cache file not found!"
    }

}#END: function Import-TableXmlInCache
