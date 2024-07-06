<#
.SYNOPSIS
    Retrieves unique command names and their sources from a PowerShell script block or script file.

.DESCRIPTION
    The Get-ModuleDependency function parses a PowerShell script block or script file to identify unique command names
    and their corresponding source locations. It returns a list of command names and their sources, helping to identify
    dependencies within scripts or modules.

.PARAMETER FilePath
    Specifies the path to a PowerShell script file (.ps1). If provided, the function extracts the script block from
    the file and analyzes it for command dependencies. Cannot be used together with the ScriptBlock parameter.

    Type: FileInfo
    Position: 0
    Mandatory: False
    Default value: None
    Accept pipeline input: False
    Accept wildcard characters: No

.PARAMETER ScriptBlock
    Specifies a script block containing PowerShell script. If provided, the function analyzes the script block directly
    for command dependencies. Cannot be used together with the FilePath parameter.

    Type: ScriptBlock
    Position: 1
    Mandatory: False
    Default value: None
    Accept pipeline input: False
    Accept wildcard characters: No

.EXAMPLE
    Get-ModuleDependency -FilePath 'C:\Scripts\Script.ps1'
    Retrieves all unique command names and their sources from the script file 'C:\Scripts\Script.ps1'.

.NOTES
    This function analyzes the abstract syntax tree (AST) of PowerShell script code to identify command names.
    It may not capture dynamically invoked commands or commands invoked via variables or expressions.
#>

function Get-ModuleDependency {
    [CmdletBinding()]
    param (
        [ValidateScript({ if (-Not ($_ | Test-Path) ) { throw 'File or folder does not exist' }
                if (-Not ($_ | Test-Path -PathType Leaf) ) { throw 'The Path argument must be a file. Folder paths are not allowed.' }
                return $true })]
        [System.IO.FileInfo]$FilePath,

        [scriptblock]$scriptblock
    )

    If ($FilePath) { $scriptblock = Get-Command $FilePath | Select-Object -ExpandProperty ScriptBlock }

    $ast = $scriptblock.Ast

    $commands = $ast.FindAll( { $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true)
    $commandText = foreach ($command in $commands) {
        $command.CommandElements[0].Extent.Text
    }

    $commandText | Select-Object -Unique | Sort-Object | Select-Object @{
        Label      = 'CommandName'
        Expression = { $_ }
    },
    @{
        Label      = 'Source'
        Expression = {
            (Get-Command $_).Source
        }
    }
}