function Disable-TvNotificationCount {
    <#
HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings

NOC_GLOBAL_SETTING_BADGE_ENABLED  DWORD

HKCU\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\$microsoft.quiethoursprofile.unrestricted$windows.data.notifications.quiethoursprofile\Current


Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\$microsoft.quiethoursprofile.unrestricted$windows.data.notifications.quiethoursprofile\Current

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
                Write-Warning DOINGIT
                $null = New-ItemProperty $path -Name $name -Value 0 -PropertyType DWORD -ErrorAction Stop
            }
            [pscustomobject]@{
                ActionCenterNotificationBadge = "Disabled"
            }
        }
    }
}