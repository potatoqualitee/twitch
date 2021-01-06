function Show-TvViewerCount {
    <#
    .SYNOPSIS
        Connects to a Twitch

    .DESCRIPTION
        Connects to a Twitch

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ClientId,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("Secret")]
        [string]$Token,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Channel = "potatoqualitee"
    )
    begin {
        function Update-ViewCount {
            $viewcount = (Get-TvStream).viewer_count
            if (-not $viewcount) {
                $viewcount = 0
            }

            # THANKS VEXX!
            [System.Drawing.Bitmap]$image = [System.Drawing.Bitmap]::New(16, 16)
            $null = $image.SetResolution(96, 96)
            [System.Drawing.Graphics]$surface = [System.Drawing.Graphics]::FromImage($image)

            $configcolor = (Get-TvSystemTheme).Color
            $color = [System.Drawing.Color]::$configcolor
            $brush = [System.Drawing.SolidBrush]::New($color)

            if ([int]$viewcount -gt 99) {
                $weight = "Regular"
                $fontsize = 8.5
            } else {
                $fontsize = 12
                $weight = "Bold"
            }
            $fontfamily = Get-TvConfigValue -Name DefaultFont
            $font = [System.Drawing.Font]::New($fontfamily, $fontsize, $weight, "Pixel")
            $surface.DrawString($viewcount, $font, $brush, 0, 0)
            $surface.Flush()

            $new = New-Object System.IO.MemoryStream
            $null = $image.Save($new, "png")

            $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
            $bitmap.BeginInit()
            $bitmap.StreamSource = $new
            $bitmap.EndInit()
            $bitmap.Freeze()

            $image = [System.Drawing.Bitmap][System.Drawing.Image]::FromStream($bitmap.StreamSource)
            [System.Drawing.Icon]::FromHandle($image.GetHicon())
        }
    }
    process {
        if ($PSVersionTable.PSEdition -eq "Core") {
            throw "Not supported in PowerShell Core"
        }

        Write-Output "Please wait one moment while we perform the initial population of data"
        Write-Output "
  _____                       _____ _          _ _
 |  __ \                     / ____| |        | | |
 | |__) |____      _____ _ __ (___ | |__   ___| | |
 |  ___/ _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |
 | |  | (_) \ V  V /  __/ |  ____) | | | |  __/ | |
 |_|   \___/ \_/\_/ \___|_| |_____/|_| |_|\___|_|_|

"
        # Create notifyicon, and right-click -> Exit menu
        $script:notifyicon = New-Object System.Windows.Forms.NotifyIcon
        $script:notifyicon.Icon = Update-ViewCount
        $script:notifyicon.Visible = $true

        $menuitem = New-Object System.Windows.Forms.MenuItem
        $menuitem.Text = "Exit"

        $contextmenu = New-Object System.Windows.Forms.ContextMenu
        $script:notifyicon.ContextMenu = $contextmenu
        $script:notifyicon.contextMenu.MenuItems.AddRange($menuitem)

        # When Exit is clicked, close everything and kill the PowerShell process
        $menuitem.add_Click( {
                $script:notifyicon.Visible = $false
                $window.Close()
                $script:notifyicon.dispose()
                Stop-Process $pid
            })

        # THANK YOU MRMARKWEST @mrmarkwest!!
        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 10000
        $timer.add_Tick( { $script:notifyicon.Icon = Update-ViewCount })
        $timer.Start()

        # Make PowerShell Disappear
        $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
        $asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
        $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

        # Force garbage collection just to start slightly lower RAM usage.
        [System.GC]::Collect()

        # Create an application context for it to all run within.
        # This helps with responsiveness, especially when clicking Exit.
        $appContext = New-Object System.Windows.Forms.ApplicationContext
        [void][System.Windows.Forms.Application]::Run($appContext)
    }
}