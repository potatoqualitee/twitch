function Get-AdminCommand {
    [CmdletBinding()]
    param()
    process {
        $file = Get-TvConfigValue -Name AdminCommandFile
        Get-Content -Path $file | ConvertFrom-Json | ConvertTo-HashTable
    }
}