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

}#END: function Test-Port
