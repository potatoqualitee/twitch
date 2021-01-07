function Switch-WindowStyle {
    # thanks https://www.reddit.com/r/PowerShell/comments/et0ml2/hide_a_minimized_application/
    [CmdletBinding()]
    param(
        [System.Diagnostics.Process]$Process
    )
    process {
        if (-not $Process) {
            $Process = Get-Process -Id $PID
        }
        $handle = $Process.MainWindowHandle

        Write-Verbose "[$(Get-Date)] Getting window handle"
        while ($handle -eq 0) {
            Start-Sleep -Milliseconds 100
            Write-Verbose "[$(Get-Date)] Trying to get the handle again"
            $Process.Refresh()
            $handle = $Process.MainWindowHandle
        }
        try {
            $ae = [System.Windows.Automation.AutomationElement]::FromHandle($handle)
            $wp = $ae.GetCurrentPattern([System.Windows.Automation.WindowPatternIdentifiers]::Pattern)
            $state = $wp.Current.WindowVisualState
        } catch {
            Write-Verbose "[$(Get-Date)] Couldn't get handle, try again"
            return
        }

        If (-not $script:mindetect::IsWindowVisible($handle) -or $state -eq "Minimized") {
            # show and really show, even when minimized
            <#
            'FORCEMINIMIZE'   = 11
            'HIDE'            = 0
            'MAXIMIZE'        = 3
            'MINIMIZE'        = 6
            'RESTORE'         = 9
            'SHOW'            = 5
            'SHOWDEFAULT'     = 10
            'SHOWMAXIMIZED'   = 3
            'SHOWMINIMIZED'   = 2
            'SHOWMINNOACTIVE' = 7
            'SHOWNA'          = 8
            'SHOWNOACTIVATE'  = 4
            'SHOWNORMAL'      = 1
            #>
            Write-Verbose "[$(Get-Date)] Setting to show using restore cuz it's awesome"
            $null = $script:asyncwindow::ShowWindowAsync($handle, 9)
            Write-Verbose "[$(Get-Date)] Setting to foreground just to be sure"
            $null = $script:foreground::SetForegroundWindow($handle)
        } else {
            Write-Verbose "[$(Get-Date)] Setting to hide"
            $null = $script:asyncwindow::ShowWindowAsync($handle, 0)
        }
    }
}