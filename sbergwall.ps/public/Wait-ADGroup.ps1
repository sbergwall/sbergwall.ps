<#
.SYNOPSIS
    Waits for an Active Directory group to become available.

.DESCRIPTION
    The Wait-ADGroup function waits for a specified Active Directory group to become available. It retries
    checking the existence of the group at regular intervals until either the group is found or the maximum
    number of retry attempts is reached.

.PARAMETER Identity
    Specifies the identity of the Active Directory group to wait for. This can be provided directly as a
    string or through pipeline input.

    Type: string
    Position: 0
    Mandatory: True
    ValueFromPipeline: True
    ValueFromPipelineByPropertyName: True
    Accept wildcard characters: False

.PARAMETER Server
    Specifies the Active Directory server to query for the group. If not specified, the function uses the
    default domain controller.

    Type: string
    Position: 1
    Mandatory: False
    ValueFromPipeline: False
    ValueFromPipelineByPropertyName: False
    Accept wildcard characters: False

.PARAMETER Wait
    Specifies the number of seconds to wait between retry attempts when the group is not found. Default is 3 seconds.

    Type: int
    Position: Named
    Mandatory: False
    Default value: 3
    Accept pipeline input: False

.PARAMETER Retry
    Specifies the maximum number of retry attempts to find the group before aborting. Default is 5 attempts.

    Type: int
    Position: Named
    Mandatory: False
    Default value: 5
    Accept pipeline input: False

.EXAMPLE
    Wait-ADGroup -Identity "GroupName" -Wait 5 -Retry 10
    Waits for the Active Directory group "GroupName" with a 5-second interval between retries and up to 10 retry attempts.

.EXAMPLE
    "GroupName" | Wait-ADGroup -Wait 2
    Uses pipeline input to wait for the Active Directory group "GroupName" with a 2-second interval between retries.

.NOTES
    - This function uses Get-ADGroup to check the existence of the group.
    - It retries checking the group's existence until it is found or until the maximum number of retry attempts is reached.
    - If the group is not found within the specified number of retry attempts, the function terminates with a warning message.
#>

function Wait-ADGroup {
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
                Get-ADGroup @ADParams -errorAction stop
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