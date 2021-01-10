Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
Describe "Integration Tests" -Tag "IntegrationTests" {
    Context "tvclient" {
        It "Get-TvFollower gets 50 followers" {
            (Get-TvFollower).Count | Should -Be 50
        }
        It "Get-TvSubscriber should contain potatoqualitee" {
            (Get-TvSubscriber).UserName | Should -Contain potatoqualitee
        }
        It "Show-TvAlert should probably return nothing" {
            Show-TvAlert -UserName MrMarkWest -Type Follow | Should -BeNullOrEmpty
        }

    }
}