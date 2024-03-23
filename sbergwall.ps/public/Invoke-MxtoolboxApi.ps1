function Invoke-MxtoolboxApi {
    <#
.SYNOPSIS
    Invoke Mxtoolbox API.
.DESCRIPTION
    The MxToolBox API is a RESTful Web Service allowing MxToolbox customers to query the status of their monitors and run lookups.
.EXAMPLE
    Invoke-MxtoolboxApi -ApiKey 'YourAPIKey' -Type dns -Domain google.com
#>

    [CmdletBinding(DefaultParameterSetName = 'Lookup')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The type of lookup you want, for example mx or spf", ParameterSetName = "Lookup")]
        [ValidateSet('blacklist', 'smtp', 'mx', 'a', 'spf', 'txt', 'ptr', 'cname', 'whois', 'arin', 'soa', 'tcp', 'http', 'https', 'ping', 'trace', 'dns')]
        [Alias('Command', 'LookupType', 'Lookup')]
        [String]$Type,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true,  ParameterSetName = "Lookup")]
        [Alias('DomainName', 'Argument')]
        [String]$Domain,

        [Parameter(Mandatory = $true, ParameterSetName = "Lookup")]
        [Parameter(Mandatory = $true, ParameterSetName = "Usage")]
        [String]$ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = "Usage")]
        [switch]$Usage
    )
    process {
        If ($usage) {
            $uri = "https://api.mxtoolbox.com/api/v1/Usage?Authorization=$apikey"
        }
        else {
            $uri = "https://api.mxtoolbox.com/api/v1/Lookup/$type/?argument=$Domain&Authorization=$apikey"
        }

        try {
            Invoke-RestMethod -Method Get -Uri $uri -ErrorAction Stop
        }
        catch {
            Write-Error $psitem
        }
    }
}