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
            $script:pagination[$Name] = $null
        }

        if ($Next) {
            $cursor = $script:pagination[$Name]
        }

        $results = Invoke-TvRequest -Path "$Path&first=$MaxResults&after=$cursor" -Raw


        $script:pagination[$Name] = $results.pagination.cursor
        $data = $results | Get-Member -Name data

        if ($data) {
            if ($results.data) {
                $results.data | ConvertFrom-RestResponse
            }
        } else {
            $results | ConvertFrom-RestResponse
        }
    }
}