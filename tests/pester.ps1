param (
    $Show = "None"
)

Write-Host "Starting Tests" -ForegroundColor Green


Write-Host -Message "Importing Module"
Import-Module "$PSScriptRoot\..\tvclient\tvclient.psd1"
Import-Module "$PSScriptRoot\..\tvbot\tvbot.psd1"
Set-TvConfig -ClientId $env:clientid -Token $env:token

$totalFailed = 0
$totalRun = 0

$testresults = @()

Write-Host -Message "Proceeding with individual tests"
foreach ($file in (Get-ChildItem $PSScriptRoot -Recurse -File -Filter "*.Tests.ps1")) {
    Write-Host -Message "Executing $($file.Name)"
    $results = Invoke-Pester -Script $file.FullName -PassThru
    foreach ($result in $results) {
        $totalRun += $result.TotalCount
        $totalFailed += $result.FailedCount
        $result.TestResult | Where-Object { -not $_.Passed } | ForEach-Object {
            $name = $_.Name
            $testresults += [pscustomobject]@{
                Describe = $_.Describe
                Context  = $_.Context
                Name     = "It $name"
                Result   = $_.Result
                Message  = $_.FailureMessage
            }
        }
    }
}

$testresults | Sort-Object Describe, Context, Name, Result, Message | Format-List

if ($totalFailed -eq 0) { Write-Host -Message "All $totalRun tests executed without failure" }
else { Write-Host -Message "$totalFailed tests out of $totalRun tests failed" }

if ($totalFailed -gt 0) {
    throw "$totalFailed / $totalRun tests failed"
}