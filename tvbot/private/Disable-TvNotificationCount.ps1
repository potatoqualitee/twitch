function Disable-TvNotificationCount {
    <#
    Never could get this to work. Think some registry key needs to be "notified"

#>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    process {
        if ($PSVersionTable.PSEdition -eq "Core") {
            Write-Warning "Not supported in PowerShell Core"
        } else {
            # Create empty soundfile to disable notification alert for PowerShell 5.1
            $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings'
            $name = 'NOC_GLOBAL_SETTING_BADGE_ENABLED'
            if ((Get-ItemProperty -Path $path | Select-Object -ExpandProperty $name -ErrorAction SilentlyContinue) -ne "") {
                $null = New-ItemProperty $path -Name $name -Value 0 -PropertyType DWORD -ErrorAction Stop
            }
            [pscustomobject]@{
                ActionCenterNotificationBadge = "Disabled"
            }
        }
    }
}