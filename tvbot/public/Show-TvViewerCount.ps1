function Show-TvViewerCount {
    <#
    .SYNOPSIS
        In Windows 10, creates a notify icon that shows how many users are currently watching a stream

    .DESCRIPTION
        In Windows 10, creates a notify icon that shows how many users are currently watching a stream

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .EXAMPLE
        PS> Show-TvViewerCount

        In Windows 10, creates a notify icon that shows how many users are currently watching a stream

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$UserName
    )
    begin {
        function Update-ViewCount {
            $viewcount = (Get-TvStream -UserName $UserName).ViewerCount
            if (-not $viewcount) {
                $viewcount = 0
            }

            # THANKS VEXX!
            [System.Drawing.Bitmap]$image = [System.Drawing.Bitmap]::New(16, 16)
            $null = $image.SetResolution(96, 96)
            [System.Drawing.Graphics]$surface = [System.Drawing.Graphics]::FromImage($image)

            $configcolor = Get-TvConfigValue -Name NotifyColor
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
        # Check if running in Core or in Windows Terminal ($env:WT_SESSION)
        if ($PSVersionTable.PSEdition -eq "Core" -or $env:WT_SESSION) {
            throw "This command is not supported by Core or Windows Terminal. Run Windows PowerShell 5.1."
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