function ConvertTo-DokuWikiTable {
    <#
    .SYNOPSIS
        Converts PowerShell objects to DokuWiki table format.

    .DESCRIPTION
        The ConvertTo-DokuWikiTable function takes PowerShell objects and converts them into
        DokuWiki formatted table syntax. It can automatically generate headers from object
        properties and supports pipeline input.

    .PARAMETER Content
        The PowerShell objects to convert to DokuWiki table format.
        This parameter accepts pipeline input.

    .PARAMETER NoHeader
        Switch parameter to suppress header generation in the output table.
        If specified, the table will not include property names as headers.

    .EXAMPLE
        Get-Process | Select-Object Name, ID, CPU | ConvertTo-DokuWikiTable

        Converts process information into a DokuWiki table with headers:
        ^Name^ID^CPU^
        |explorer|1234|12.5|
        |chrome|5678|45.2|

    .EXAMPLE
        $data | ConvertTo-DokuWikiTable -NoHeader

        Converts data to DokuWiki table format without headers:
        |Value1|Value2|Value3|
        |Data1|Data2|Data3|

    .OUTPUTS
        [String] DokuWiki formatted table as a string
    #>

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