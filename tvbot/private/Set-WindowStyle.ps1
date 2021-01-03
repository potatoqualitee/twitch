function Set-WindowStyle {
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
}