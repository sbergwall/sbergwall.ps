function Find-ModuleUpdates {
    <#
    .SYNOPSIS
        Checks for available updates for installed PowerShell modules.

    .DESCRIPTION
        The Find-ModuleUpdates function checks the PowerShell Gallery for newer versions of
        installed modules. The function displays progress while checking modules and outputs a table
        of modules that have updates available.

    .PARAMETER NameFilter
        Specifies a filter for module names. Supports wildcard characters.
        Default value is '*' which checks all installed modules.

    .EXAMPLE
        Find-ModuleUpdates
        Checks all installed modules for available updates.

    .EXAMPLE
        Find-ModuleUpdates -NameFilter "Az*"
        Checks for updates only for installed modules whose names start with "Az".

    .EXAMPLE
        Find-ModuleUpdates -Verbose
        Checks all modules and displays detailed progress information.

    .LINK
        https://github.com/sbergwall/sbergwall.ps
        https://powershellisfun.com/2023/09/20/check-for-powershell-module-updates/

    .OUTPUTS
        Displays a table of modules with available updates, including:
        - Repository
        - Module name
        - Installed version
        - Latest version
        - Published date
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$NameFilter = '*'
    )

    # Retrieve all installed modules
    Write-Verbose 'Retrieving installed PowerShell modules'
    [array]$InstalledModules = Get-InstalledModule -Name $NameFilter -ErrorAction SilentlyContinue

    # Retrieve current versions of modules (63 at a time because of PSGallery limit)
    if ($InstalledModules.Count -eq 1) {
        $onlineversions = $null
        Write-Verbose ('Checking online versions for installed module {0}' -f $name)
        $currentversions = Find-Module -Name $CurrentModules.name
        $onlineversions = $onlineversions + $currentversions
    }

    if ($InstalledModules.Count -gt 1) {
        $startnumber = 0
        $endnumber = 62
        $onlineversions = $null
        while ($InstalledModules.Count -gt $onlineversions.Count) {
            Write-Verbose ('Checking online versions for installed modules [{0}..{1}/{2}]' -f $startnumber, $endnumber, $InstalledModules.Count)
            $currentversions = Find-Module -Name $InstalledModules.name[$startnumber..$endnumber]
            $startnumber = $startnumber + 63
            $endnumber = $endnumber + 63
            $onlineversions = $onlineversions + $currentversions
        }
    }
    if (-not $onlineversions) {
        Write-Warning 'No modules were found to check for updates, please check your NameFilter. Exiting...'
        return
    }

    # Loop through all modules and check for newer versions and add those to $total
    $number = 1
    Write-Verbose 'Checking for updated versions'
    $total = foreach ($module in $InstalledModules) {
        Write-Progress -Activity 'Checking modules' -Status ('Processing {0}' -f $module.name) -PercentComplete (($number / $InstalledModules.count) * 100)
        try {
            $PsgalleryModule = $onlineversions | Where-Object name -EQ $module.Name
            if ([version]$module.version -lt [version]$PsgalleryModule.version) {
                [PSCustomObject]@{
                    Repository          = $module.Repository
                    'Module name'       = $module.Name
                    'Installed version' = $module.Version
                    'Latest version'    = $PsgalleryModule.version
                    'Published on'      = $PsgalleryModule.PublishedDate
                }
            }
        }
        catch {
            Write-Warning ('Could not find module {0}' -f $module.Name)
        }
        $number++
    }

    # Output $total to display updates for installed modules if any
    if ($total.Count -gt 0) {
        Write-Information -MessageData ('Found {0} updated modules' -f $total.Count) -InformationAction Continue
        $total
    }
    else {
        Write-Information -MessageData 'No updated modules were found' -InformationAction Continue
    }
}