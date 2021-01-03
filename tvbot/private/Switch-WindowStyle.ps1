function Switch-WindowStyle {
    # thanks https://www.reddit.com/r/PowerShell/comments/et0ml2/hide_a_minimized_application/
    [CmdletBinding()]
    param(
        [System.Diagnostics.Process]$Process
    )
    process {
        $styles = @{
            Show = 5
            Hide = 0
        }

        if (-not $Process) {
            $Process = Get-Process -Id $PID
        }
        $handle = $Process.MainWindowHandle

        Write-Verbose "Getting window handle"
        while ($handle -eq 0) {
            Start-Sleep -Milliseconds 100
            Write-Verbose "Trying to get the handle again"
            $Process.Refresh()
            $handle = $Process.MainWindowHandle
        }
        try {
            $ae = [System.Windows.Automation.AutomationElement]::FromHandle($handle)
            $wp = $ae.GetCurrentPattern([System.Windows.Automation.WindowPatternIdentifiers]::Pattern)
            $state = $wp.Current.WindowVisualState
        } catch {
            Write-Verbose "Couldn't get handle, try again"
            return
        }

        If (-not $script:mindetect::IsWindowVisible($handle) -or $state -eq "Minimized") {
            $null = $script:asyncwindow::ShowWindowAsync($handle, $styles["Show"])
            $null = $asyncwindow::ShowWindowAsync($handle, 10)
        } else {
            $null = $script:asyncwindow::ShowWindowAsync($handle, $styles["Hide"])
        }
    }
}