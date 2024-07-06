<#
.SYNOPSIS
    Retrieves SMTP log information from a specified directory or log file.

.DESCRIPTION
    The Get-SMTPLogInformation function reads SMTP log files either from a directory containing multiple log files
    or from a single log file. It parses the log files to extract SMTP-related information and outputs the parsed data
    as objects with predefined headers.

.PARAMETER LogPath
    Specifies the path to a directory containing SMTP log files (*.log). If provided, the function retrieves and parses
    all log files within the directory.

    Type: DirectoryInfo
    ParameterSetName: LogPath
    Position: 0
    Mandatory: True
    Default value: None
    Accept pipeline input: False
    Accept wildcard characters: No

.PARAMETER LogFile
    Specifies a single SMTP log file (.log). If provided, the function retrieves and parses the specified log file.

    Type: FileInfo
    ParameterSetName: LogFile
    Position: 0
    Mandatory: True
    Default value: None
    Accept pipeline input: False
    Accept wildcard characters: No

.EXAMPLE
    Get-SMTPLogInformation -LogPath 'C:\SMTPLogs'
    Retrieves and parses all SMTP log files (*.log) located in the 'C:\SMTPLogs' directory.

.EXAMPLE
    Get-SMTPLogInformation -LogFile 'C:\SMTPLogs\SMTPLogFile.log'
    Retrieves and parses the SMTP log file 'C:\SMTPLogs\SMTPLogFile.log'.

.NOTES
    - This function assumes that the SMTP log files are in a specific format that can be parsed using ConvertFrom-Csv.
    - The function skips the first 5 lines of each log file before parsing, assuming these are header or metadata lines.
    - Ensure that the log files conform to the expected format for accurate parsing and extraction of SMTP information.
.LINK
    # https://learn.microsoft.com/en-us/exchange/mail-flow/connectors/protocol-logging?view=exchserver-2019
#>

function Get-SMTPLogInformation {
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'LogPath')]
        [System.IO.DirectoryInfo]$LogPath,
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFile')]
        [System.IO.FileInfo]$LogFile
    )

    If ($LogPath) { $Logs = Get-Item "$LogPath/*.log" }
    If ($LogFile) { $logs = Get-Item $logfile }

    foreach ($log in $logs) {
        #Get-Content $log.FullName |
        [io.file]::ReadAllLines($log) |
            Select-Object -Skip 5 |
                ConvertFrom-Csv -Header 'date-time', 'connector-id', 'session-id', 'sequence-number', 'local-endpoint', 'remote-endpoint', 'event', 'data', 'context'
    }
}