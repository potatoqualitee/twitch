function Get-UserCommand {
    [CmdletBinding()]
    param()
    process {
        $file = Get-TvConfigValue -Name UserCommandFile
        Get-Content -Path $file | ConvertFrom-Json | ConvertTo-HashTable
    }
}