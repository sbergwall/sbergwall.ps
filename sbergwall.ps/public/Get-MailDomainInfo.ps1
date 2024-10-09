# https://raw.githubusercontent.com/HarmVeenstra/Powershellisfun/refs/heads/main/Retrieve%20Email%20DNS%20Records/Get-MailDomainInfo.ps1
#Requires -Modules DnsClientX

function Get-MailDomainInfo {
    param (
        $domain = 'google.com',
        $dnsProvider = 'CloudFlare'
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
