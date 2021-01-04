function Enable-TvAlertSound {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    process {
        if ($PSVersionTable.PSEdition -ne "Core") {
            # Remove empty soundfile property to enable notification alert for PowerShell 5.1
            $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe\'
            $name = 'SoundFile'
            if ((Get-ItemProperty -Path $path | Select-Object -ExpandProperty $name -ErrorAction SilentlyContinue) -eq "") {
                $null = Remove-ItemProperty -Path $path -Name SoundFile
            }
        } else {
            Write-Warning "Not supported in PowerShell Core, setting anyway"
        }
        # no idea why whatif doesn't work for this
        if ($PSCmdlet.ShouldProcess("Executing Set-TvConfig -Sound Enabled")) {
            Set-TvConfig -Sound Enabled
        }
    }
}