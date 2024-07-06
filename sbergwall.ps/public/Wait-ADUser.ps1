<#
.SYNOPSIS
    Waits for an Active Directory user to become available by checking if the user exists.

.DESCRIPTION
    The Wait-ADUser function waits for an Active Directory user to become available by repeatedly checking
    if the user exists. It retries a specified number of times with a waiting period between retries.

.PARAMETER Identity
    Specifies the identity of the Active Directory user to wait for. This can be provided directly as a string.

    Type: string
    ParameterSetName: None
    Mandatory: True
    ValueFromPipeline: True
    ValueFromPipelineByPropertyName: True
    Accept wildcard characters: False

.PARAMETER Server
    Specifies the domain controller to query for the user. If not specified, the default domain controller
    is used.

    Type: string
    ParameterSetName: None
    Mandatory: False
    ValueFromPipeline: False
    ValueFromPipelineByPropertyName: False
    Accept wildcard characters: False

.PARAMETER Wait
    Specifies the waiting period in seconds between each retry attempt to check for the user. Default is 3 seconds.

    Type: int
    ParameterSetName: None
    Mandatory: False
    Default value: 3
    ValueFromPipeline: False
    ValueFromPipelineByPropertyName: False
    Accept wildcard characters: False

.PARAMETER Retry
    Specifies the number of retry attempts to check for the user. Default is 5 retries.

    Type: int
    ParameterSetName: None
    Mandatory: False
    Default value: 5
    ValueFromPipeline: False
    ValueFromPipelineByPropertyName: False
    Accept wildcard characters: False

.EXAMPLE
Wait-ADUser -Identity "JohnDoe"
Wait for a specific user to become available on the default domain controller

.EXAMPLE
Wait-ADUser -Identity "JaneSmith" -Server "DC01"
Wait for a specific user on a specific domain controller

.EXAMPLE
Wait-ADUser -Identity "AliceBrown" -Retry 10 -Wait 5
Wait for a user with custom retry and wait parameters

.NOTES
    - This function uses Get-ADUser cmdlet to check if the Active Directory user exists.
    - It retries a specified number of times with a waiting period between retries until the user is found or the maximum retry attempts are reached.
    - If the user is not found within the specified retry attempts, the function throws a ADIdentityNotFoundException.
#>

function Wait-ADUser {
    [CmdletBinding(ConfirmImpact = 'None')]

    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Identity,

        [String]$Server,

        [int]$Wait = 3,

        [int]$Retry = 5
    )

    Begin {
    }
    Process {
        $i = 0
        $Continue = $false

        $ADParams = $PSBoundParameters
        $ADParams.Remove('Retry') | Out-Null
        $ADParams.Remove('Wait') | Out-Null
        Do {
            try {
                Get-ADUser @ADParams -errorAction stop | Out-Null
                $Continue = $true

            }
            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
                $i++
                Write-Verbose "Looking for $Identity. On Retry $i. Star sleeping $wait seconds"
                Start-Sleep -Seconds $Wait
                If ($i -eq $Retry) {
                    $Continue = $true
                }
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSitem)
                $Continue = $true
            }
        } while ($Continue -eq $false)
    }
    End {
    }
}