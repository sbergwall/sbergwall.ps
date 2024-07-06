function ConvertTo-DokuWikiTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        $Content,
        [switch]$NoHeader
    )

    BEGIN {
        $RowArray = New-Object System.Collections.ArrayList
    }

    PROCESS {
        If ($NoHeader) {
            $HeaderGenerated = $true
        }

        # This ForEach needed if the content wasn't piped in
        $Content | ForEach-Object {
            # First row enclosed by ||, all other rows by |
            If (!$HeaderGenerated) {
                $_.PSObject.Properties |
                    ForEach-Object -Begin { $Header = '' } `
                        -Process { $Header += "^$($_.Name)" } `
                        -End { $Header += '^' }
                    $RowArray.Add($Header) | Out-Null
                    $HeaderGenerated = $true
                }
                $_.PSObject.Properties |
                    ForEach-Object -Begin { $Row = '' } `
                        -Process { $Row += "|$($_.Value)" } `
                        -End { $Row += '|' }
                    $RowArray.Add($Row) | Out-Null
                }
            }

            END {
                $RowArray | Out-String
            }
        }