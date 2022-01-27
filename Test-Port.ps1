function Test-Port {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Alias('ComputerName')]
        $IPAddress,

        [Parameter(Mandatory)]
        [Alias('TcpPort')]
        $Port
    )

    $connection = New-Object System.Net.Sockets.TcpClient($IPAddress, $Port)

    if ($connection.Connected) {$true} else {$false}

    Write-Warning "PsDevTools\Test-Port is depreciated. Please use PsWinAdmin\Test-Port"

}#END: function Test-Port
