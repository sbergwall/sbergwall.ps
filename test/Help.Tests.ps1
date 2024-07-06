Set-StrictMode -Version Latest

BeforeDiscovery {
    $moduleName = 'sbergwall.ps'
    $modulePath = Join-Path $PSScriptRoot '..\sbergwall.ps\sbergwall.ps.psm1'
    Import-Module -Name $modulePath -ErrorAction Stop -Force
    $exportedFunctions = Get-Command -CommandType Cmdlet, Function -Module $moduleName
}

Describe 'Testing module help' -Tag 'Help' -ForEach @{ exportedFunctions = $exportedFunctions; moduleName = $moduleName } {
    Context '<_.CommandType> <_.Name>' -ForEach $exportedFunctions {
        BeforeAll {
            $help = $_ | Get-Help
        }

        It 'Help is found' {
            $help.Name | Should -Be $_.Name
            $help.Category | Should -Be $_.CommandType
            $help.ModuleName | Should -Be $moduleName
        }

        It 'Synopsis is defined' {
            $help.Synopsis | Should -Not -BeNullOrEmpty
            # Syntax is used as synopsis when none is defined in help.
            $help.Synopsis | Should -Not -Match "^\s*$($_.Name)((\s+\[+?-\w+)|$)"
        }

        It 'Description is defined' -Skip:($_.Name -match '^Should-') {
            # Property is missing if undefined
            $help.description | Should -Not -BeNullOrEmpty
        }

        It 'Has at least one example' {
            $help.Examples | Should -Not -BeNullOrEmpty
            $help.Examples.example | Where-Object { -not $_.Code.Trim() } | ForEach-Object { $_.title.Trim('- ') } | Should -Be @() -Because 'no examples should be empty'
        }
    }
}