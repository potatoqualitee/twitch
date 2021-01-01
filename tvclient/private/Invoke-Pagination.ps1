function Invoke-Pagination {
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$Path,
        [switch]$Next,
        [int]$MaxResults
    )
    process {
        if (-not $script:pagination[$Name]) {
            $script:pagination[$Name] = New-Object -TypeName System.Collections.ArrayList
        }

        if ($Next) {
            $cursor = $script:pagination[$Name]
        }

        $results = Invoke-TvRequest -Path "$Path&first=$MaxResults&after=$cursor" -Raw

        if ($Next) {
            $script:pagination[$Name] = $results.pagination.cursor
        }

        $results.data | ConvertFrom-RestResponse
    }
}