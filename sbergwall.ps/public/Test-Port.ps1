<#
    .SYNOPSIS
        Tests the accessibility of a specified TCP port on a given hostname or IP address.

    .DESCRIPTION
        The Test-Port function checks whether a specified TCP port is accessible on a given hostname or IP address.
        It resolves the hostname to an IP address and attempts to establish a TCP connection to the specified port.
        If the port is accessible, it outputs a message indicating that the port is operational. If not accessible,
        it outputs a message indicating that the port is closed.

    .PARAMETER hostname
        Specifies the hostname or IP address of the target system where the port accessibility will be tested.

        Type: string
        Position: 0
        Mandatory: True
        Accept pipeline input: True (ByValue, ByPropertyName)
        Accept wildcard characters: No

    .PARAMETER port
        Specifies the TCP port number to test for accessibility on the target system.

        Type: int
        Position: 1
        Mandatory: True
        Accept pipeline input: False
        Accept wildcard characters: No

    .EXAMPLE
        Test-Port -hostname "example.com" -port 80
        Tests port 80 on the hostname "example.com" to check if it is accessible.

    .EXAMPLE
        "192.168.1.1", 3389 | Test-Port
        Tests port 3389 on the IP address "192.168.1.1" to check if it is accessible.

    .NOTES
        - This function uses .NET methods to resolve hostnames to IP addresses and to establish TCP connections.
        - It does not handle UDP ports or other network protocols.
        - Ensure that the target system allows inbound traffic on the specified port for accurate testing results.
    #>
function Test-Port {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Hostname,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateRange(0, 65535)]
        [int]$Port
    )

    # Function logic remains unchanged from the original code
    try {
        $ip = [System.Net.Dns]::GetHostAddresses($Hostname) | Select-Object -ExpandProperty IPAddressToString
        if ($ip.GetType().Name -eq 'Object[]') {
            $ip = $ip[0]
        }
    }
    catch {
        Write-Warning "Possibly $Hostname is an incorrect hostname or IP address."
        return
    }

    $t = New-Object Net.Sockets.TcpClient
    try {
        $t.Connect($ip, $Port)
    }
    catch {}

    if ($t.Connected) {
        $t.Close()
        Write-Output "Port $Port on $ip is operational."
    }
    else {
        Write-Output "Port $Port on $ip is closed. Check firewall settings or network connectivity."
    }
}
