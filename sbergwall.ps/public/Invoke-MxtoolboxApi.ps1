function Invoke-MxtoolboxApi {
    <#
.SYNOPSIS
    Invoke Mxtoolbox API.
.DESCRIPTION
    The MxToolBox API is a RESTful Web Service allowing MxToolbox customers to query the status of their monitors and run lookups.
.EXAMPLE
    Invoke-MxtoolboxApi -ApiKey 'YourAPIKey' -Type dns -Domain google.com
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('blacklist', 'smtp', 'mx', 'a', 'spf', 'txt', 'ptr', 'cname', 'whois', 'arin', 'soa', 'tcp', 'http', 'https', 'ping', 'trace', 'dns')]
        [Alias('Command', 'LookupType', 'Lookup')]
        [String]$Type,

        [Parameter(Mandatory = $true)]
        [Alias('DomainName', 'Argument')]
        [String]$Domain,

        [Parameter(Mandatory = $true)]
        [String]$ApiKey
    )
    process {
        $uri = "https://api.mxtoolbox.com/api/v1/Lookup/$type/?argument=$Domain&Authorization=$apikey"
        try {
            Invoke-RestMethod -Method Get -Uri $uri -ErrorAction Stop
        }
        catch {
            Write-Error $psitem
        }
    }
}