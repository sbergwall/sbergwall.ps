<#
.SYNOPSIS
    Updates installed PowerShell modules to their latest available versions.

.DESCRIPTION
    The Update-Modules function retrieves all installed PowerShell modules and updates them to their latest available versions. It can handle both prerelease and production versions of the modules.

.PARAMETER AllowPrerelease
    Allows updating to prerelease versions of the modules if available.
    Type: SwitchParameter
    Position: Named
    Mandatory: No
    Accepts pipeline input: No
    Accepts wildcard characters: No

.PARAMETER Name
    Specifies the name of the module to update. The default is '*' which updates all modules.
    Type: String
    Position: Named
    Mandatory: No
    Default value: '*'
    Accepts pipeline input: No
    Accepts wildcard characters: No

.PARAMETER WhatIf
    Shows what would happen if the command runs. The command is not actually executed.
    Type: SwitchParameter
    Position: Named
    Mandatory: No
    Accepts pipeline input: No
    Accepts wildcard characters: No

.EXAMPLE
    Update-Modules
    This command updates all installed modules to their latest production versions.

.EXAMPLE
    Update-Modules -AllowPrerelease
    This command updates all installed modules to their latest prerelease versions if available.

.EXAMPLE
    Update-Modules -Name 'ModuleName'
    This command updates the specified module 'ModuleName' to its latest version.

.EXAMPLE
    Update-Modules -WhatIf
    This command shows what would happen if the modules were updated, but does not actually perform the update.

.LINK
    https://powershellisfun.com/2022/07/11/updating-your-powershell-modules-to-the-latest-version-plus-cleaning-up-older-versions/

.NOTES
    The function requires the PowerShellGet module to be installed.
    Ensure you have the necessary permissions to update and uninstall modules.

#>
function Update-Modules {
    param (
        [switch]$AllowPrerelease,
        [string]$Name = '*',
        [switch]$WhatIf
    )

    # Get all installed modules
    Write-Host ('Retrieving all installed modules ...') -ForegroundColor Green
    $CurrentModules = Get-InstalledModule -Name $Name -ErrorAction SilentlyContinue | Select-Object Name, Version | Sort-Object Name

    if (-not $CurrentModules) {
        Write-Host ('No modules found.') -ForegroundColor Gray
        return
    }
    else {
        $ModulesCount = $CurrentModules.Name.Count
        $DigitsLength = $ModulesCount.ToString().Length
        Write-Host ('{0} modules found.' -f $ModulesCount) -ForegroundColor Gray
    }

    # Show status of AllowPrerelease Switch
    ''
    if ($AllowPrerelease) {
        Write-Host ('Updating installed modules to the latest PreRelease version ...') -ForegroundColor Green
    }
    else {
        Write-Host ('Updating installed modules to the latest Production version ...') -ForegroundColor Green
    }

    # Loop through the installed modules and update them if a newer version is available
    $i = 0
    foreach ($Module in $CurrentModules) {
        $i++
        $Counter = ("[{0,$DigitsLength}/{1,$DigitsLength}]" -f $i, $ModulesCount)
        $CounterLength = $Counter.Length
        Write-Host ('{0} Checking for updated version of module {1} ...' -f $Counter, $Module.Name) -ForegroundColor Green
        try {
            $latest = Find-Module $Module.Name -ErrorAction Stop
            if ([version]$Module.Version -lt [version]$latest.version) {
                Update-Module -Name $Module.Name -AllowPrerelease:$AllowPrerelease -AcceptLicense -Scope:AllUsers -Force:$True -ErrorAction Stop -WhatIf:$WhatIf.IsPresent
            }
        }
        catch {
            Write-Host ("{0$CounterLength} Error updating module {1}!" -f ' ', $Module.Name) -ForegroundColor Red
        }

        # Retrieve newest version number and remove old(er) version(s) if any
        $AllVersions = Get-InstalledModule -Name $Module.Name -AllVersions | Sort-Object PublishedDate -Descending
        $MostRecentVersion = $AllVersions[0].Version
        if ($AllVersions.Count -gt 1 ) {
            Foreach ($Version in $AllVersions) {
                if ($Version.Version -ne $MostRecentVersion) {
                    try {
                        Write-Host ("{0,$CounterLength} Uninstalling previous version {1} of module {2} ..." -f ' ', $Version.Version, $Module.Name) -ForegroundColor Gray
                        Uninstall-Module -Name $Module.Name -RequiredVersion $Version.Version -Force:$True -ErrorAction Stop -AllowPrerelease -WhatIf:$WhatIf.IsPresent
                    }
                    catch {
                        Write-Warning ("{0,$CounterLength} Error uninstalling previous version {1} of module {2}!" -f ' ', $Version.Version, $Module.Name)
                    }
                }
            }
        }
    }

    # Get the new module versions for comparing them to to previous one if updated
    $NewModules = Get-InstalledModule -Name $Name | Select-Object Name, Version | Sort-Object Name
    if ($NewModules) {
        ''
        Write-Host ('List of updated modules:') -ForegroundColor Green
        $NoUpdatesFound = $true
        foreach ($Module in $NewModules) {
            $CurrentVersion = $CurrentModules | Where-Object Name -EQ $Module.Name
            if ($CurrentVersion.Version -notlike $Module.Version) {
                $NoUpdatesFound = $false
                Write-Host ('- Updated module {0} from version {1} to {2}' -f $Module.Name, $CurrentVersion.Version, $Module.Version) -ForegroundColor Green
            }
        }

        if ($NoUpdatesFound) {
            Write-Host ('No modules were updated.') -ForegroundColor Gray
        }
    }
}
