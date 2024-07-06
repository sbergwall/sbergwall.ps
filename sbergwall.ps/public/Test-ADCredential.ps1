<#
.SYNOPSIS
    Validates Active Directory credentials.

.DESCRIPTION
    The Test-ADCredential function checks if the provided Active Directory credentials are valid by attempting to authenticate against the domain.

.PARAMETER Credential
    Specifies the Active Directory credentials to validate. This parameter accepts a PSCredential object.
    Type: PSCredential
    Position: 0
    Mandatory: Yes
    Accepts pipeline input: True (ByPropertyName)
    Accepts wildcard characters: No

.EXAMPLE
    $cred = Get-Credential
    Test-ADCredential -Credential $cred
    This command validates the Active Directory credentials provided by the Get-Credential cmdlet.

.EXAMPLE
    Test-ADCredential -Credential (Get-Credential)
    This command validates the Active Directory credentials provided by the Get-Credential cmdlet inline.

.NOTES
    The function requires the System.DirectoryServices.AccountManagement assembly.
    Ensure you have the necessary permissions to query Active Directory.

.OUTPUTS
    System.Boolean
    The function returns $true if the credentials are valid, and $false otherwise.
#>
function Test-ADCredential {
   [CmdletBinding()]

   [OutputType([bool])]

   Param (
      [Parameter(ValueFromPipelineByPropertyName = $true,
         Position = 0)]
      [ValidateNotNull()]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.PSCredential]
      [System.Management.Automation.Credential()]
      $Credential = [System.Management.Automation.PSCredential]::Empty
   )

   Begin {
   }

   Process {
      try {
         $UserName = $Credential.GetNetworkCredential().UserName
         $Password = $Credential.GetNetworkCredential().Password

         Add-Type -AssemblyName System.DirectoryServices.AccountManagement
         $ds = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
         $ds.ValidateCredentials($UserName, $Password)
      }
      catch {
         $PSCmdlet.ThrowTerminatingError($PSitem)
      }
   }

   End {
   }
}
