<#
.SYNOPSIS
    Retrieves information about an IP address using the IPWho API.

.DESCRIPTION
    The Invoke-IPWhoAPI function queries the IPWho API to retrieve information about specified IPv4 or IPv6 addresses. It caches the results to avoid repeated queries for the same IP address.

.PARAMETER IPv4Address
    Specifies the IPv4 address to query. This parameter is mandatory when using the 'IPv4' parameter set.
    Type: String
    Position: Named
    Mandatory: Yes
    Parameter set: IPv4
    Accepts pipeline input: No
    Accepts wildcard characters: No

.PARAMETER IPv6Address
    Specifies the IPv6 address to query. This parameter is mandatory when using the 'IPv6' parameter set.
    Type: String
    Position: Named
    Mandatory: Yes
    Parameter set: IPv6
    Accepts pipeline input: No
    Accepts wildcard characters: No

.EXAMPLE
    Invoke-IPWhoAPI -IPv4Address "8.8.8.8"
    This command retrieves information about the IPv4 address "8.8.8.8" using the IPWho API.

.EXAMPLE
    Invoke-IPWhoAPI -IPv6Address "2001:4860:4860::8888"
    This command retrieves information about the IPv6 address "2001:4860:4860::8888" using the IPWho API.

.NOTES
    The function requires internet access to query the IPWho API.
    Ensure you have the necessary permissions and internet connectivity to query the IPWho API.
#>
function Invoke-IPWhoAPI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'IPv4')]
        [ValidateScript({ $_ -match '^(\d{1,3}\.){3}\d{1,3}$' })]
        $IPv4Address,

        [Parameter(Mandatory = $true, ParameterSetName = 'IPv6')]
        [ValidateScript({ $_ -match '^(([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:)|(([0-9A-Fa-f]{1,4}:){1,6}|:):([0-9A-Fa-f]{1,4}|:){1,6}(([0-9]{1,3}\.){3}[0-9]{1,3}|[0-9A-Fa-f]{1,4})?)$' })]
        $IPv6Address
    )

    class DNSNameCache {
        [hashtable]$LookupTable

        DNSNameCache() {
            $this.LookupTable = @{}
        }

        [psobject] GetDNSName([string]$Identity) {
            if ($this.LookupTable.Contains($Identity)) {
                Write-Verbose 'Dns name found in cache.'
                return $this.LookupTable[$Identity]
            }
            else {
                return ($this.LookupTable[$Identity] = (Invoke-RestMethod -Method get -Uri "http://ipwho.is/$($Identity)"))
            }
        }
    }

    # Start out with an empty cache, by creating an instance of our DNSNameCache class
    # We could as well have used
    #   New-Object -TypeName DNSNameCache
    $DNSNameCache = [DNSNameCache]::new()

    foreach ($line in $IPv4Address) {
        $DNSNameCache.GetDNSName($line)
    }
    foreach ($line in $IPv6Address) {
        $DNSNameCache.GetDNSName($line)
    }
}
