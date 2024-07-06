<#
    .SYNOPSIS
    Run Exchange cmdlets in your Powershell session

    .DESCRIPTION
    Connecting your Powershell session to one of your Exchange On-premise servers so you can run Exchange cmdlets.

    .PARAMETER ComputerName
    One of your Exchange server on-prem

    .PARAMETER Credential
    If you want to specify another set of credentials then your existing ones

    .EXAMPLE
    Connect-Exchange -ComputerName "EXCHANGE01"

    .NOTES
    Copy of Paul Cunningham Connect-Exchange cmdlet, https://practical365.com/exchange-server/powershell-function-to-connect-to-exchange-on-premises/ made for learning more about PowerShell
#>
Function Connect-ExchangeServer {

    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-WSMan -ComputerName $_ })]
        [System.String]$ComputerName,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential
    )

    BEGIN {
        Write-Verbose "Starting: $($MyInvocation.MyCommand) "
        Write-Verbose "PSVersion: $($PSVersionTable.psversion) "
        Write-Verbose "OS: $((Get-CimInstance -ClassName Win32_OperatingSystem -Verbose:$false).Caption)"
    }

    PROCESS {

        #$Credentials = Get-Credential -Message "Enter your Exchange admin credentials"

        try {
            If ($PSBoundParameters.ContainsKey('Credential')) {
                $ExOPSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ComputerName/PowerShell/ -Authentication Kerberos -ErrorAction Stop -Credential $Credential
                Import-PSSession $ExOPSession -ErrorAction Stop | Out-Null
            } # end If statement
            else {
                $ExOPSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ComputerName/PowerShell/ -Authentication Kerberos -ErrorAction Stop
                Import-PSSession $ExOPSession -ErrorAction Stop | Out-Null
            } # end Else statement
        }
        catch {
            Write-Error -Message $_
        }
    }
    END {}
}