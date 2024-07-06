<#
.SYNOPSIS
    Tests the credentials of a local user on a specified or local computer.

.DESCRIPTION
    The Test-LocalUserCredential function validates the credentials of a local user account on a specified
    computer using the System.DirectoryServices.AccountManagement.PrincipalContext class. It checks whether
    the provided username and password are valid for the local machine context.

.PARAMETER Computer
    Specifies the name of the computer against which the credentials will be tested. If not specified,
    the function tests credentials on the local computer (represented by $env:COMPUTERNAME).

    Type: string
    Position: 0
    Mandatory: False
    ValueFromPipeline: False
    ValueFromPipelineByPropertyName: False
    Accept wildcard characters: False

.EXAMPLE
    Test-LocalUserCredential -Computer "Server01" -username "LocalUser" -password "P@ssw0rd!"
    Tests if the credentials (username: LocalUser, password: P@ssw0rd!) are valid for the local user on Server01.

.EXAMPLE
    Test-LocalUserCredential -Computer "Server01"
    Prompts for username and password input to test local credentials on Server01.

.NOTES
    - This function uses the System.DirectoryServices.AccountManagement.PrincipalContext class to validate credentials.
    - If the credentials are valid, the function returns $true; otherwise, it returns $false.
    - The function throws an error if there are issues during the credential validation process.
#>
Function Test-LocalUserCredential {
    PARAM ($Computer = $env:COMPUTERNAME)

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $computer)
    $obj.ValidateCredentials($username, $password)
}