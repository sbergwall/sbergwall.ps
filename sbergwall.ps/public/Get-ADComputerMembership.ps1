<#
.SYNOPSIS
    Retrieves the group membership of specified Active Directory computers.

.DESCRIPTION
    The Get-ADComputerMembership function retrieves the group membership information for specified Active Directory computers. It takes a list of computer identities and outputs the groups that each computer belongs to.

.PARAMETER Identity
    Specifies the SAM account name(s) or distinguished name(s) of the computer(s) whose group membership information is to be retrieved.
    Type: String[]
    Position: Named
    Mandatory: Yes
    Accepts pipeline input: No
    Accepts wildcard characters: No

.EXAMPLE
    Get-ADComputerMembership -Identity "Comp01"
    This command retrieves the group membership information for the computer with the identity "Comp01".

.EXAMPLE
    Get-ADComputerMembership -Identity "Comp01", "Comp02"
    This command retrieves the group membership information for the computers with the identities "Comp01" and "Comp02".

.NOTES
    The function requires the Active Directory PowerShell module.
    Ensure you have the necessary permissions to query Active Directory.
#>
function Get-ADComputerMembership {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String[]]$Identity
    )

    process {
        foreach ($i in $Identity) {
            try {
                Write-Output "=== $i ==="
                Get-ADComputer -Identity $i -Properties memberof -ErrorAction Stop | Select-Object -ExpandProperty Memberof
            }
            catch {
                $psitem.Exception.Message
            }
        }
    }
}
