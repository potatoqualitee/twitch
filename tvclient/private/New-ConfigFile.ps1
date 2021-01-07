function New-ConfigFile {
    [CmdletBinding()]
    param()
    process {

        ######### Create directories
        $dir = Split-Path -Path $script:configfile

        if (-not (Test-Path -Path $dir)) {
            New-Item -ItemType Directory -Path $dir -ErrorAction SilentlyContinue
        }

        Write-Verbose "[$(Get-Date)] Writing config to $script:configfile"
        [PSCustomObject]@{
            ConfigFile     = $script:configfile.Replace("\\","\")
            ClientId       = $null
            Token          = $null
            DiscordWebhook = $null
        } | ConvertFrom-RestResponse | ConvertTo-Json | Set-Content -Path $script:configfile -Encoding Unicode
    }
}