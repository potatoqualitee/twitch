Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\..\constants.ps1"


Describe "Integration Tests" -Tag "IntegrationTests" {
    Import-Module ./tvclient/tvclient.psd1
    Import-Module ./tvbot/tvbot.psd1
    Set-TvConfig -ClientId $env:clientid -Token $env:token

    Context "Get-TvFollower" {
        It "gets 50 followers" {
            (Get-TvFollower).Count | Should -Be 50
        }
    }
}