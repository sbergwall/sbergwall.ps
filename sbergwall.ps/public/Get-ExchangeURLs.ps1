function Get-ExchangeURLs {
    <#
.SYNOPSIS
Retrieves the URLs for various Exchange services on specified Client Access servers.

.DESCRIPTION
The Get-ExchangeURLs function retrieves the internal and external URLs for various Exchange services such as Outlook Anywhere, Outlook Web App (OWA), Exchange Control Panel (ECP), Offline Address Book (OAB), Exchange Web Services (EWS), MAPI, and ActiveSync on specified Client Access servers.

.PARAMETER Server
Specifies the names of the Exchange servers to retrieve URLs from. This parameter is mandatory and can accept pipeline input.

.EXAMPLE
Get-ExchangeURLs -Server "EXCH01"

This example retrieves the URLs for various Exchange services on the server "EXCH01".

.EXAMPLE
"EXCH01", "EXCH02" | Get-ExchangeURLs

This example retrieves the URLs for various Exchange services on the servers "EXCH01" and "EXCH02" using pipeline input.

.NOTES
- The function checks if the specified server is a Client Access server using the Get-ExchangeServer cmdlet.
- It retrieves the URLs for various Exchange services using cmdlets such as Get-OutlookAnywhere, Get-OWAVirtualDirectory, Get-ECPVirtualDirectory, Get-OABVirtualDirectory, Get-WebServicesVirtualDirectory, Get-MAPIVirtualDirectory, and Get-ActiveSyncVirtualDirectory.
- The results are returned as custom objects with properties for each service's internal and external URLs.
- If a server is not a Client Access server, a warning message is displayed.

.LINK
https://docs.microsoft.com/en-us/powershell/module/exchange/get-exchangeserver
https://docs.microsoft.com/en-us/powershell/module/exchange/get-outlookanywhere
https://docs.microsoft.com/en-us/powershell/module/exchange/get-owavirtualdirectory
https://docs.microsoft.com/en-us/powershell/module/exchange/get-ecpvirtualdirectory
https://docs.microsoft.com/en-us/powershell/module/exchange/get-oabvirtualdirectory
https://docs.microsoft.com/en-us/powershell/module/exchange/get-webservicesvirtualdirectory
https://docs.microsoft.com/en-us/powershell/module/exchange/get-mapivirtualdirectory
https://docs.microsoft.com/en-us/powershell/module/exchange/get-activesyncvirtualdirectory
#>

    [CmdletBinding()]
    param (
        # Mailbox Server Name
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Server
    )
    process {
        foreach ($i in $server) {
            if ((Get-ExchangeServer $i -ErrorAction SilentlyContinue).IsClientAccessServer) {

                $OA = Get-OutlookAnywhere -Server $i -AdPropertiesOnly | Select-Object InternalHostName, ExternalHostName
                $OWA = Get-OWAVirtualDirectory -Server $i -AdPropertiesOnly | Select-Object InternalURL, ExternalURL
                $ECP = Get-ECPVirtualDirectory -Server $i -AdPropertiesOnly | Select-Object InternalURL, ExternalURL
                $OAB = Get-OABVirtualDirectory -Server $i -AdPropertiesOnly | Select-Object InternalURL, ExternalURL
                $EWS = Get-WebServicesVirtualDirectory -Server $i -AdPropertiesOnly | Select-Object InternalURL, ExternalURL
                $MAPI = Get-MAPIVirtualDirectory -Server $i -AdPropertiesOnly | Select-Object InternalURL, ExternalURL
                $EAS = Get-ActiveSyncVirtualDirectory -Server $i -AdPropertiesOnly | Select-Object InternalURL, ExternalURL
                $AutoD = Get-ClientAccessServer $i | Select-Object AutoDiscoverServiceInternalUri

                [PSCustomObject]@{
                    Server                                      = $i
                    OutlookAnywhereInternalHostName             = $OA.InternalHostName
                    OutlookAnywhereExternalHostName             = $oa.ExternalHostName
                    OWAVirtualDirectoryInternalHostName         = $OWA.InternalURL
                    OWAVirtualDirectoryExternalURL              = $owa.ExternalURL
                    ECPVirtualDirectoryInternalHostName         = $ECP.InternalURL
                    ECPVirtualDirectoryExternalURL              = $ecp.ExternalURL
                    OABVirtualDirectoryInternalHostName         = $OAB.InternalURL
                    OABVirtualDirectoryExternalURL              = $oab.ExternalURL
                    WebServicesVirtualDirectoryInternalHostName = $EWS.InternalURL
                    WebServicesVirtualDirectoryExternalURL      = $ews.ExternalURL
                    MAPIVirtualDirectoryInternalHostName        = $MAPI.InternalURL
                    MAPIVirtualDirectoryExternalURL             = $Mapi.ExternalURL
                    ActiveSyncVirtualDirectoryInternalHostName  = $EAS.InternalURL
                    ActiveSyncVirtualDirectoryExternalURL       = $eas.ExternalURL
                    AutoDiscoverServiceInternalUri              = $AutoD.AutoDiscoverServiceInternalUri
                }

            }
            else {
                Write-Warning -Message "$i is not a Client Access server."
            }
        }
    }
}