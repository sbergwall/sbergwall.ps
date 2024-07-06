function Test-PrivateIP {
    <#
    .SYNOPSIS
        Determines if a given IP address is within the IPv4 private address space ranges.

    .DESCRIPTION
        The Test-PrivateIP function checks if the provided IP address string is within the private IPv4 address ranges (127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16). It returns $true if the IP address is private, and $false otherwise.

    .PARAMETER IP
        Specifies the IP address to test.
        Type: String
        Position: Named
        Mandatory: Yes
        Accepts pipeline input: Yes (ByValue)
        Accepts wildcard characters: No

    .EXAMPLE
        Test-PrivateIP -IP "172.16.1.2"
        This command returns $true because "172.16.1.2" is within the private IPv4 address range.

    .EXAMPLE
        '10.1.2.3' | Test-PrivateIP
        This command returns $true because "10.1.2.3" is within the private IPv4 address range.

    .EXAMPLE
        Test-PrivateIP -IP "8.8.8.8"
        This command returns $false because "8.8.8.8" is not within the private IPv4 address range.

    .NOTES
        The function uses regex to match the IP address against the known private IP ranges.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$IP
    )
    process {
        if ($IP -match '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.(1[6-9]|2[0-9]|3[0-1])\.)') {
            $true
        } else {
            $false
        }
    }
}
