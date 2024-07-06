<#
.SYNOPSIS
    Retrieves the last logon date and the domain controller that recorded the logon for specified Active Directory users.

.DESCRIPTION
    The Get-ADUserLastLogon function queries all domain controllers in the Active Directory domain to determine the most recent logon date and the domain controller that recorded this logon for specified users. It supports retrieving this information for one or multiple users, specified either directly by SAM account names, or indirectly via an LDAP filter.

.PARAMETER SamAccountName
    Specifies the SAM account name(s) of the user(s) whose last logon information is to be retrieved. This parameter accepts pipeline input.
    Type: Object[]
    Aliases: Identity
    Position: 0
    Required: No
    Accepts pipeline input: True (ByValue, ByPropertyName)
    Accepts wildcard characters: No

.PARAMETER Property
    Specifies additional properties of the user(s) to retrieve. This parameter accepts a single string or an array of strings.
    Type: String[]
    Position: 1
    Required: No
    Accepts pipeline input: No
    Accepts wildcard characters: No

.PARAMETER Filter
    Specifies an LDAP filter to retrieve users based on criteria. If no SamAccountName is specified, the function will retrieve all user accounts in the domain that match the filter.
    Type: String
    Position: 2
    Required: No
    Accepts pipeline input: No
    Accepts wildcard characters: No

.EXAMPLE
    Get-ADUserLastLogon -SamAccountName jdoe
    This command retrieves the last logon date and the domain controller that recorded the logon for the user with the SAM account name jdoe.

.EXAMPLE
    Get-ADUserLastLogon -SamAccountName jdoe, asmith
    This command retrieves the last logon date and the domain controller that recorded the logon for the users with the SAM account names jdoe and asmith.

.EXAMPLE
    Get-ADUserLastLogon -Filter "Department -eq 'Sales'"
    This command retrieves the last logon date and the domain controller that recorded the logon for all users in the Sales department.

.EXAMPLE
    Get-ADUserLastLogon -SamAccountName jdoe -Property mail, title
    This command retrieves the last logon date, the domain controller that recorded the logon, and the mail and title properties for the user with the SAM account name jdoe.

.NOTES
    The function requires the Active Directory PowerShell module.
    Ensure you have the necessary permissions to query Active Directory and access domain controllers.
#>

function Get-ADUserLastLogon {
    param
    (
        # Take a samaccountname property
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Identity')]
        [Object[]]$SamAccountName,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter( { @('mail') })]
        [String[]]$Property,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String]$Filter
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"

        Write-Verbose -Message '[BEGIN  ] Finding All Domain Controllers'
        $ADDomainControllers = Get-ADDomainController -Filter { Name -like '*' }
        $NumberofDCs = ($ADDomainControllers | Measure-Object).count

        If ($NumberofDCs -eq 0) { throw 'No AD Domain Controllers could be found.' }
        Write-Verbose -Message "[BEGIN  ] Number of Domain Controllers Found: $NumberofDCs"

        If (-not($PSBoundParameters.ContainsKey('SamAccountName'))) {
            try {
                Write-Verbose '[BEGIN  ] No SamAccountName was specified, getting all AD user accounts in domain'
                $adSplat = @{ErrorAction = 'Stop' }
                If (-not($null -eq $Filter)) { $adSplat.Filter = $filter }
                If (-not($null -eq $Property)) { $adSplat.Property = $filter }

                $SamAccountName = Get-ADUser @adSplat
            }
            catch {
                $PSCmdlet.WriteError($psitem)
            }
        }
    } # Begin

    process {
        foreach ($user in $SamAccountName ) {
            try {
                switch ($user) {
                    { $user -is [string] } {
                        $Splatting = @{
                            Identity    = $user
                            ErrorAction = 'Stop'

                        }
                        If (-not($null -eq $Property)) { $Splatting.Properties = $Property }

                        $user = Get-ADUser @Splatting
                    }

                    { $user -is [Microsoft.ActiveDirectory.Management.ADUser] } {
                        If ($PSBoundParameters.ContainsKey('Property')) { $user = Get-ADUser -Identity $user -Properties $Property }
                    }
                    default { throw 'Unknown type was used.' }

                } # Switch
            }
            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
                # Catch if AD user cannot be found and go to next user in loop
                $PSCmdlet.WriteError($psitem)
                continue
            }

            catch {
                $PSCmdlet.WriteError($psitem)
            }

            $lastlogon = 0

            foreach ($ADDomainController in $ADDomainControllers) {
                $DCHostname = $ADDomainController.HostName
                Write-Verbose -Message "[Process] Checking on Domain Controller: $DCHostname"
                try {
                    $paramGetADUser = @{
                        Identity    = $user
                        Server      = $DCHostname
                        ErrorAction = 'Stop'
                        Properties  = 'lastLogon'
                    }

                    $ADUser = Get-ADUser @paramGetADUser
                } #Try
                Catch {
                    Write-Warning "Error on:$DCHostname. Message: $psitem"
                }

                Write-Verbose -Message "[Process]`t Converting To DateTime"
                $ADUserlastLogon = [DateTime]::FromFileTime($ADUser.lastLogon)

                Write-Verbose -Message "[Process]`t LastLogon Date: $ADUserlastLogon"
                if ($ADUserLastLogon -gt $lastLogon) {
                    $lastLogon = $ADUserlastLogon
                    $OwningDC = $DCHostname
                } # If Logon is GT
            } #ForEach DC

            $User | Add-Member -MemberType NoteProperty -Name LastLogonExtended -Value $lastlogon -Force
            $User | Add-Member -MemberType NoteProperty -Name LastLogonExtendedDC -Value $OwningDC -Force
            $user
        } # foreach $user
    } # Process
}
