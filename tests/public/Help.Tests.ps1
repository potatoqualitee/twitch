Import-Module tvbot, tvclient
$commands = Get-Command -Module tvbot, tvclient
foreach ($command in $commands) {
    $name = $command.Name
    $help = Get-Help $name

    Describe "Test help for $name" {
        It "gets Synopsis for $name" {
            $help.Synopsis | Should -Not -BeNullOrEmpty
        }

        It "gets Description for $name" {
            $help.Description | Should -Not -BeNullOrEmpty
        }

        It "gets Example from $name" {
            $help.Examples.Example.Code | Should -Not -BeNullOrEmpty
        }

        It "gets Example comment from $name" {
            $help.Examples.Example.Remarks.Text | Should -Not -BeNullOrEmpty
        }

        $params = $command.Parameters.Keys | Where-Object {
            $PSItem -notin [System.Management.Automation.PSCmdlet]::CommonParameters
        }

        foreach ($parameter in $params) {
            $paramhelp = $help.parameters.parameter | Where-Object Name -eq $parameter

            It "gets help for the $parameter parameter in $name" {
                $paramhelp.Description.Text | Should -Not -BeNullOrEmpty
            }
        }

        foreach ($helpname in $help.Parameters.Parameter.Name) {
            It "finds help definition $helpname in parameter list" {
                $helpname -in $params | Should -BeTrue
            }
        }
    }
}