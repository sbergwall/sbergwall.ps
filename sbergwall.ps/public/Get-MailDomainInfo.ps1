# https://raw.githubusercontent.com/HarmVeenstra/Powershellisfun/refs/heads/main/Retrieve%20Email%20DNS%20Records/Get-MailDomainInfo.ps1
#Requires -Modules DnsClientX

function Get-MailDomainInfo {
    <#
    .SYNOPSIS
        Retrieves email-related DNS records for a specified domain.

    .DESCRIPTION
        The Get-MailDomainInfo function performs DNS lookups to gather various email-related records for a domain,
        including Autodiscover, DMARC, MX, and SPF records. It uses the DnsClientX module for DNS resolution.

    .PARAMETER domain
        The domain name to query. Defaults to 'google.com' if not specified.

    .PARAMETER dnsProvider
        The DNS provider to use for queries. Defaults to 'CloudFlare'.

    .EXAMPLE
        Get-MailDomainInfo -domain "microsoft.com"
        Retrieves email DNS records for microsoft.com using the default CloudFlare DNS provider.

    .EXAMPLE
        Get-MailDomainInfo -domain "github.com" -dnsProvider "Google"
        Retrieves email DNS records for github.com using Google's DNS provider.

    .NOTES
        Requires the DnsClientX module to be installed.
        Author: Simon Bergwall
        Version: 1.0

    .LINK
        https://github.com/sbergwall/sbergwall.ps

    .OUTPUTS
        PSCustomObject containing formatted DNS record information
    #>

    param (
        $Domain = 'google.com',
        $DnsProvider = 'CloudFlare'
    )



    $autodiscoverA = (Resolve-Dns -Name "autodiscover.$($domain)" -Type A -DnsProvider $dnsProvider -ErrorAction SilentlyContinue).Data
    $dmarc = (Resolve-Dns -Name "_dmarc.$($domain)" -Type TXT -DnsProvider $dnsProvider -ErrorAction SilentlyContinue ).Data
    $mx = (Resolve-Dns -Name $domain -Type MX -DnsProvider $dnsProvider -ErrorAction SilentlyContinue).Data
    $spf = (Resolve-Dns -Name $domain -Type TXT -DnsProvider $dnsProvider -ErrorAction SilentlyContinue).data | Where-Object { $_ -like 'v=spf*' }

    [PSCustomObject]@{
        'Domain Name'             = $domain
        'Autodiscover IP-Address' = $autodiscoverA
        'DMARC Record'            = "$($dmarc)"
        'MX Record(s)'            = $mx -join ', '
        'SPF Record'              = "$($spf)"
    }
}
