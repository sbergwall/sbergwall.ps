<#
.SYNOPSIS
    Tests the existence of an Active Directory group.

.DESCRIPTION
    The Test-ADGroup function verifies whether an Active Directory group exists by attempting to retrieve it using
    the provided Identity parameter. It returns $true if the group exists and $false otherwise.

.PARAMETER Identity
    Specifies the identity of the Active Directory group to test.

    Type: object
    Position: 0
    Mandatory: True
    ValueFromPipeline: True
    ValueFromPipelineByPropertyName: True
    Accept wildcard characters: True

.PARAMETER Server
    Specifies the Active Directory server to connect to for the operation. If not specified, the default behavior
    of connecting to any available domain controller is used.

    Type: string
    Position: named
    Mandatory: False
    Accept wildcard characters: False

.EXAMPLE
    Test-ADGroup -Identity "GroupName"
    Tests if the Active Directory group named "GroupName" exists.

.EXAMPLE
    "GroupName" | Test-ADGroup
    Tests if the Active Directory group named "GroupName" exists using pipeline input.

.NOTES
    - This function uses the Get-ADGroup cmdlet to retrieve information about the Active Directory group.
    - If the group exists, the function returns $true; otherwise, it returns $false.
    - If the group cannot be found or there is an error during the retrieval process, an error is thrown.
#>

function Test-ADGroup {
    [CmdletBinding(ConfirmImpact = 'None')]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Identity,

        # Param3 help description
        [String]$Server
    )

    Begin {
    }
    Process {
        try {
            $ADParams = $PSBoundParameters
            Get-adgroup @ADParams -erroraction Stop
            $true
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            $false
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    End {
    }
}