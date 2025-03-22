Function ConvertFrom-Sid {
    <#
.SYNOPSIS
Converts a Security Identifier (SID) to a user account name.

.DESCRIPTION
The ConvertFrom-Sid function takes a Security Identifier (SID) as input and converts it to the corresponding user account name.

.PARAMETER SID
Specifies the Security Identifier (SID) to convert. This parameter is mandatory.

.EXAMPLE
ConvertFrom-Sid -SID "S-1-5-21-3457937927-2839227994-823803824-1129"

This example converts the specified SID to the corresponding user account name.

.EXAMPLE
$sid = "S-1-5-21-3457937927-2839227994-823803824-1129"
ConvertFrom-Sid -SID $sid

This example stores the SID in a variable and then converts it to the corresponding user account name.

.NOTES
- The function uses the .NET Framework class System.Security.Principal.SecurityIdentifier to translate the SID to a user account name.
- The Translate method of the SecurityIdentifier class is used to perform the conversion.
- The function returns the converted user account name as a string.

.LINK
https://docs.microsoft.com/en-us/dotnet/api/system.security.principal.securityidentifier?view=net-5.0
#>

    param (
        [Parameter(Mandatory = $true)]
        $SID
    )

    # Give SID as input to .NET Framework Class
    $SID2 = New-Object System.Security.Principal.SecurityIdentifier($SID)

    # Use Translate to find user from sid
    $objUser = $SID2.Translate([System.Security.Principal.NTAccount])

    # Print the converted SID to username value
    $objUser.Value
}
