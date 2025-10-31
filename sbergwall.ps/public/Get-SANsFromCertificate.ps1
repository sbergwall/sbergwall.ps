<#
.SYNOPSIS
Retrieves Subject Alternative Names (SANs) from a given certificate.

.DESCRIPTION
The `Get-SANsFromCertificate` function extracts SANs from a provided certificate in PEM or Base64 format.

.PARAMETER BinaryCertificate
The certificate in PEM or Base64 format.

.EXAMPLE
Get-SANsFromCertificate -BinaryCertificate "<Base64EncodedCertificate>"

.EXAMPLE
$cert = Get-Content -Path "certificate.pem"
Get-SANsFromCertificate -BinaryCertificate $cert

.NOTES
Author: sbergwall
#>
function Get-SANsFromCertificate {
    param(
        [Parameter(Mandatory)]
        [string]$BinaryCertificate
    )

    try {
        # If certificate is in PEM format
        if ($BinaryCertificate -match 'BEGIN CERTIFICATE') {
            $clean = ($BinaryCertificate -split "`r?`n" | Where-Object { $_ -notmatch '-----' }) -join ''
            $bytes = [Convert]::FromBase64String($clean)
        }
        else {
            # Otherwise assume plain base64
            $bytes = [Convert]::FromBase64String($BinaryCertificate)
        }

        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(, $bytes)

        # Find the SAN extension (OID 2.5.29.17)
        $sanExt = $cert.Extensions | Where-Object { $_.Oid.Value -eq '2.5.29.17' }
        if ($sanExt) {
            # Pretty-print SANs
            return $sanExt.Format($true)
        }
        else {
            return $null
        }
    }
    catch {
        Write-Verbose "Failed to decode SANs: $($_.Exception.Message)"
        return $null
    }
}
