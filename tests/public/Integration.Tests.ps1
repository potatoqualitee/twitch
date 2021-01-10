Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
Describe "Integration Tests" -Tag "IntegrationTests" {
    Context "Get-TvFollower" {
        It "gets 50 followers" {
            (Get-TvFollower).Count | Should -Be 50
        }
    }
}