$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\src\$sut"

Describe "Get-SitesUsingCloudflare" {
    Context "When it produces output." {
        Mock -CommandName Get-SitesUsingCloudflare -MockWith {
            $list = [System.Collections.Generic.List[PSObject]]::new()
            $objects = [char[]](65..90) | ForEach-Object { [PSCustomObject]@{Name = "$_.com"} }

            [void] $list.Add($objects)
            return $list
        } -Verifiable

        $sites = Get-SitesUsingCloudflare -Name 'Test'

        It "Should return one or more PSCustomObjects." {
            $sites | Should BeOfType System.Management.Automation.PSCustomObject
            Assert-VerifiableMocks
        }
    }

    Context "When it produces no output." {
        Mock -CommandName Get-SitesUsingCloudflare -MockWith {} -Verifiable

        $sites = Get-SitesUsingCloudflare -Name 'Test'

        It "Should return null." {
            $sites | Should BeNullOrEmpty
            Assert-VerifiableMocks
        }
    }
}
