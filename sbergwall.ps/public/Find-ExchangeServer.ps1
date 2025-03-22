function Find-ExchangeServer {
    <#
.SYNOPSIS
Finds and lists Exchange servers in the Active Directory.

.DESCRIPTION
The Find-ExchangeServer function searches the Active Directory for Exchange servers and lists their details, including name, DNS hostname, version, and roles.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
Find-ExchangeServer

This example searches the Active Directory for Exchange servers and lists their details.

.NOTES
- The function uses the DirectoryServices.DirectorySearcher class to search the Active Directory for objects of the category 'msExchExchangeServer'.
- It retrieves the necessary properties such as 'msExchCurrentServerRoles', 'networkAddress', and 'serialNumber'.
- The function converts the server roles from a bitmask to a human-readable list using the ConvertToExchangeRole helper function.
- The results are returned as custom objects with properties: Name, DnsHostName, Version, and Roles.
#>


    [CmdletBinding()]
    param ()

    Function ConvertToExchangeRole {
        Param(
            [Parameter(Position = 0)]
            [int]$roles
        )
        $roleNumber = @{
            2  = 'MBX'
            4  = 'CAS'
            16 = 'UM'
            32 = 'HUB'
            64 = 'EDGE'
        }
        $roleList = New-Object -TypeName Collections.ArrayList
        foreach ($key in ($roleNumber).Keys) {
            if ($key -band $roles) {
                [void]$roleList.Add($roleNumber.$key)
            }
        }
        Write-Output $roleList
    }

    $rootDse = [ADSI]'LDAP://RootDSE'
    $cfgCtx = $rootDse.Properties['configurationNamingContext'].Value
    $searcher = New-Object DirectoryServices.DirectorySearcher
    $searcher.SearchRoot = [ADSI]('LDAP://' + $cfgCtx)
    $searcher.Filter = '(objectCategory=msExchExchangeServer)'
    $searcher.PageSize = 100  # Reduce load by retrieving 500 objects at a time

    # Load only necessary properties
    $searcher.PropertiesToLoad.Add('msExchCurrentServerRoles') > $null
    $searcher.PropertiesToLoad.Add('networkAddress') > $null
    $searcher.PropertiesToLoad.Add('serialNumber') > $null

    # Perform paged search
    $results = $searcher.FindAll()

    foreach ($result in $results) {
        $entry = $result.GetDirectoryEntry()
        $roles = ConvertToExchangeRole -roles $entry.Properties['msExchCurrentServerRoles'].Value
        $fqdn = ($entry.Properties['networkAddress'].Value | Where-Object { $_ -like 'ncacn_ip_tcp:*' }).Split(':')[1]

        [PSCustomObject]@{
            Name        = $entry.Name[0]
            DnsHostName = $fqdn
            Version     = $entry.Properties['serialNumber'].Value
            Roles       = $roles
        }
    }
}
