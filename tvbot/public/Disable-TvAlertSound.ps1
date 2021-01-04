function Disable-TvAlertSound {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    process {
        if ($PSVersionTable.PSEdition -ne "Core") {
            # Create empty soundfile to disable notification alert for PowerShell 5.1
            $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
            $name = 'SoundFile'
            if ((Get-ItemProperty -Path $path | Select-Object -ExpandProperty $name -ErrorAction SilentlyContinue) -ne "") {
                $null = New-ItemProperty -Path $path -Name $name
            }
        } else {
            Write-Warning "Not supported in PowerShell Core, setting anyway"
        }
        if ($PSCmdlet.ShouldProcess("Executing Set-TvConfig -Sound Disabled")) {
            Set-TvConfig -Sound Disabled
        }
    }
}