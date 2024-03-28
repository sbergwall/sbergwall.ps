function Invoke-IPWhoAPI {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_ -match '^(\d{1,3}\.){3}\d{1,3}$'})]
        $IPv4Address
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
}
