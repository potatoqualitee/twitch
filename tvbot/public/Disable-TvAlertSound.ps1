function Disable-TvAlertSound {
    <#
    .SYNOPSIS
        Disables chat notification sounds

    .DESCRIPTION
        Disables chat notification sounds. Only supported on Windows 5.1.

    .PARAMETER WhatIf
        Shows what would happen if the command would run

    .PARAMETER Confirm
        Displays (or disables using -Confirm:$false) a confirmation prompt

    .EXAMPLE
        PS C:\> Disable-TvAlertSound

        Disables chat notification sounds

#>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    process {
        if ($PSVersionTable.PSEdition -eq "Core") {
            Write-Warning "Not supported in PowerShell Core, setting config anyway"
        } else {
            # Create empty soundfile to disable notification alert for PowerShell 5.1
            $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
            $name = 'SoundFile'
            if ((Get-ItemProperty -Path $path | Select-Object -ExpandProperty $name -ErrorAction SilentlyContinue) -ne "") {
                $null = New-ItemProperty -Path $path -Name $name
            }
        }

        if ($PSCmdlet.ShouldProcess("Executing Set-TvConfig -Sound Disabled")) {
            Set-TvConfig -Sound Disabled
        }
    }
}