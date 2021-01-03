function Set-WindowStyle {
    # thanks https://www.reddit.com/r/PowerShell/comments/et0ml2/hide_a_minimized_application/
    [CmdletBinding()]
    param(
        [ValidateSet("Show", "Hide")]
        [string]$Style = "Show",
        [int]$Id = $PID,
        [System.Diagnostics.Process]$Process
    )
    $styles = @{
        Show = 5
        Hide = 0
    }
    if (-not $Process) {
        $Process = Get-Process -Id $PID
    }
    $handle = $Process.MainWindowHandle
    Write-Verbose ("Set Window Style {1} on handle {0} for Pid {2}" -f $handle, $Style, $Process.Id)
    $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $asyncwindow = Add-Type -MemberDefinition $windowcode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru

    $null = $asyncwindow::ShowWindowAsync($handle, $styles[$Style])
    # Restore if it's minimized
    if ($Style -eq "Show") {
        $null = $asyncwindow::ShowWindowAsync($handle, 10)
    }
}