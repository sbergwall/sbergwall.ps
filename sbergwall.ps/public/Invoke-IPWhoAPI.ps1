function Invoke-IPWhoAPI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ParameterSetName = 'IPv4')]
        [ValidateScript({$_ -match '^(\d{1,3}\.){3}\d{1,3}$'})]
        $IPv4Address,

        [Parameter(Mandatory=$true, ParameterSetName = 'IPv6')]
        [ValidateScript({$_ -match '^(([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:)|(([0-9A-Fa-f]{1,4}:){1,6}|:):([0-9A-Fa-f]{1,4}|:){1,6}(([0-9]{1,3}\.){3}[0-9]{1,3}|[0-9A-Fa-f]{1,4})?)$'})]
        $IPv6Address
    )

    
    class DNSNameCache {
        [hashtable]$LookupTable

        DNSNameCache() {
            $this.LookupTable = @{}
        }

        [psobject] GetDNSName([string]$Identity) {
            if ($this.LookupTable.Contains($Identity)) {
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
