function Connect-SfbServer {
    <#
.SYNOPSIS
Connects to a Skype for Business (SfB) server pool and imports the session.

.DESCRIPTION
The Connect-SfbServer function establishes a PowerShell session to a specified Skype for Business server pool and imports the session into the global scope. This allows you to run Skype for Business cmdlets remotely.

.PARAMETER PoolFqdn
Specifies the fully qualified domain name (FQDN) of the Skype for Business server pool to connect to. This parameter is mandatory and can accept pipeline input.

.PARAMETER Credential
Specifies the credentials to use for the connection. If not provided, the function will use the current user's credentials. This parameter is optional.

.EXAMPLE
Connect-SfbServer -PoolFqdn "sfbpool.contoso.com" -Credential (Get-Credential)

This example connects to the Skype for Business server pool "sfbpool.contoso.com" using the credentials provided by the user.

.EXAMPLE
"sfbpool1.contoso.com", "sfbpool2.contoso.com" | Connect-SfbServer -Credential (Get-Credential)

This example connects to multiple Skype for Business server pools ("sfbpool1.contoso.com" and "sfbpool2.contoso.com") using the credentials provided by the user.

.NOTES
- The function uses the New-PSSession cmdlet to create a remote session to the specified Skype for Business server pool.
- The Import-PSSession cmdlet is used to import the session into the global scope, allowing you to run Skype for Business cmdlets remotely.
#>
    param (
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$PoolFqdn,

        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    process {
        foreach ($p in $PoolFqdn) {
            try {
                Write-Verbose "Creating a PSSession to $p"
                $global:SfbSession = New-PSSession -ConnectionUri "https://$p/ocsPowershell" -Credential $Credential -ErrorAction Stop
                Write-Verbose 'Importing PSSession'
                Import-Module (Import-PSSession $global:SfbSession -DisableNameChecking) -Global
            }
            catch {
                Write-Error $PSItem.Exception.Message
            }
        }
    }
}