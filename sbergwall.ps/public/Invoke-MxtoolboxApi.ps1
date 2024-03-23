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

        [Parameter(Mandatory = $true, ValueFromPipeline = $true,  ParameterSetName = "Lookup", HelpMessage = "The Domain you want to look up.")]
        [Alias('DomainName', 'Argument')]
        [String]$Domain,

        [Parameter(ParameterSetName = "Lookup")]
        [int]$Port,

        [Parameter(Mandatory = $true, ParameterSetName = "Lookup", HelpMessage = "Please enter your MXToolBox API key. This key can be found by navigating to 'https://mxtoolbox.com/user/api' in a web browser")]
        [Parameter(Mandatory = $true, ParameterSetName = "Usage", HelpMessage = "Please enter your MXToolBox API key. This key can be found by navigating to 'https://mxtoolbox.com/user/api' in a web browser")]
        [String]$ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = "Usage")]
        [switch]$Usage
    )
    process {
        If ($usage) {
            $uri = "https://api.mxtoolbox.com/api/v1/Usage?Authorization=$apikey"
        }
        else {
            If ($port) {
                $domain = $domain + "&port=$port"
            }
            $uri = "https://api.mxtoolbox.com/api/v1/Lookup/$type/?argument=$Domain&Authorization=$apikey"
        }

        try {
            Write-Verbose "Uri: $uri"
            Invoke-RestMethod -Method Get -Uri $uri -ErrorAction Stop
        }
        catch {
            Write-Error $psitem
        }
    }
}