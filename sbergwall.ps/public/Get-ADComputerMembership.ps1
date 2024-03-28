function Get-ADComputerMembership {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [String[]]$Identity
    )

    begin {}

    process {
        foreach ($i in $Identity) {
            try {
                Write-Output "=== $i ==="
                Get-ADComputer -Identity $i -Properties memberof -ErrorAction Stop | Select-Object -ExpandProperty Memberof
            }
            catch {
                <#Do this if a terminating exception happens#>
                $psitem.Exception.Message
            }
        }
    }

    end {}
}
