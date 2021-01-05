function Enable-TvNotificationCount {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    process {
        if ($PSVersionTable.PSEdition -eq "Core") {
            Write-Warning "Not supported in PowerShell Core, setting anyway"
        } else {
            # Remove empty
            $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings'
            $name = 'NOC_GLOBAL_SETTING_BADGE_ENABLED'
            if ((Get-ItemProperty -Path $path | Select-Object -ExpandProperty $name -ErrorAction SilentlyContinue) -eq "") {
                $null = Remove-ItemProperty -Path $path -Name $name
            }

            [pscustomobject]@{
                ActionCenterNotificationBadge = "Enabled"
            }
        }
    }
}