<#
.SYNOPSIS
    Waits for Active Directory object replication to complete on specified domain controllers.

.DESCRIPTION
    The Wait-ADObjectReplication function waits for an Active Directory object to replicate across all specified
    domain controllers. It checks the existence of the object based on either its identity or an LDAP filter.

.PARAMETER Identity
    Specifies the identity of the Active Directory object to wait for. This can be provided directly as a string.

    Type: string
    ParameterSetName: Identity
    Mandatory: True
    ValueFromPipeline: False
    ValueFromPipelineByPropertyName: False
    Accept wildcard characters: False

.PARAMETER LDAPFilter
    Specifies an LDAP filter to identify the Active Directory object to wait for.

    Type: string
    ParameterSetName: LDAPFilter
    Mandatory: True
    ValueFromPipeline: False
    ValueFromPipelineByPropertyName: False
    Accept wildcard characters: False

.PARAMETER Server
    Specifies the domain controllers to check for object replication. If not specified, all domain controllers in
    the current domain are queried.

    Type: string[]
    Mandatory: False
    ValueFromPipeline: False
    ValueFromPipelineByPropertyName: False
    Accept wildcard characters: False

.PARAMETER Timeout
    Specifies the timeout period for waiting for object replication. Default is 30 seconds.

    Type: TimeSpan
    Mandatory: False
    Default value: '00:00:30'
    ValueFromPipeline: False
    ValueFromPipelineByPropertyName: False
    Accept wildcard characters: False

.EXAMPLE
    Wait-ADObjectReplication -Identity "CN=User1,OU=Users,DC=contoso,DC=com" -Server "DC1", "DC2"
    Waits for the Active Directory object with identity "CN=User1,OU=Users,DC=contoso,DC=com" to replicate across
    domain controllers DC1 and DC2.

.EXAMPLE
    Wait-ADObjectReplication -LDAPFilter "(samaccountname=User1)" -Timeout 60
    Waits for the Active Directory object matching the LDAP filter "(samaccountname=User1)" to replicate across
    all domain controllers in the current domain with a 60-second timeout.

.NOTES
    - This function uses Get-ADObject cmdlet to check the existence of the Active Directory object.
    - It checks each specified domain controller until the object is found or the timeout period is reached.
    - If the object is not found within the specified timeout, the function throws a TimeoutException.
#>

function Wait-ADObjectReplication {
    [CmdletBinding(DefaultParameterSetName = 'Identity')]

    param (
        [Parameter(Mandatory = $True,
            ParameterSetName = 'Identity')]
        [ValidateNotNullOrEmpty()]
        [string]$Identity,

        [Parameter(Mandatory = $True,
            ParameterSetName = 'LDAPFilter')]
        [ValidateNotNullOrEmpty()]
        [String]$LDAPFilter,

        [string[]]$Server,

        [ValidateNotNullOrEmpty()]
        [TimeSpan]$Timeout = '00:00:30'
    )

    begin {
        Write-Verbose -Message "Starting: $($MyInvocation.Mycommand)"

        If (!($PSBoundParameters.ContainsKey('Server'))) {
            try {
                Write-Verbose -Message 'Finding All Domain Controllers'
                $Server = Get-ADDomainController -Filter { Name -like '*' } -ErrorAction Stop
                $NumberofDCs = ($Server | Measure-Object).count

                Write-Verbose -Message "Number of Domain Controllers Found: $NumberofDCs"
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($psitem)
            }
        }
    } # Begin

    process {
        foreach ($DC in $Server) {
            $GetADObjectSplatting = @(
                Identity = If ($null -ne $Identity) { $Identity }
                LDAPFilter = If ($null -ne $LDAPFilter) { $LDAPFilter }
                Server = $DC
                ErrorAction = 'Stop'
            )

            # wait for the object to replicate
            Write-Verbose "Checking $DC"

            $object = $Null
            while ($Null -ne $object) {

                # check if we've timed out
                $left = New-TimeSpan $(Get-Date) $stop
                if ($left.TotalSeconds -lt 0) {
                    # timeout
                    throw [System.TimeoutException]'Object propagation has timed out.'
                }

                try {
                    # wait a bit and check again
                    Start-Sleep -Milliseconds 250
                    $object = Get-ADObject @GetADObjectSplatting
                }
                catch {
                    $PSCmdlet.WriteError($psitem)
                }
            }
        }
    } # process
}