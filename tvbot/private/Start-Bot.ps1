function Start-Bot {
    <#
        .SYNOPSIS
            Starts the bot

        .DESCRIPTION
            There's a lot to unpack here! This command

            - Creates a notify icon that sits near the clock. This is used to control the bot
            - The notifyicon is then "painted" to the setting of BotIconColor
            - It also opens a new window to run the bot
            - Both the control powershell host process and the new window that actually runs the bot are automatically hidden
            - When the bot notifyicon is left-clicked, the bot window will be activated/appear if the bot is minimized or hidden. If the window is already visible, it will be hidden
            - If the notify is right-clicked, you'll be offered the option to quit or restart the bot (sometimes it just fails ¯\_(ツ)_/¯)

    #>
    # add all the GUI assemblies
    Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, UIAutomationClient

    # window show/hide helper
    $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $script:asyncwindow = Add-Type -MemberDefinition $windowcode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru

    # determine if bot window is minimized
    $mincode = '[DllImport("user32.dll")] public static extern bool IsWindowVisible(int hwnd);'
    $script:mindetect = Add-Type -MemberDefinition $mincode -Name Win32ShowMinimized -Namespace Win32Functions -PassThru

    ############################## repaint the bot icon ##############################

    # Create bitmapimage to enable streaming
    $boticon = Get-TvConfigValue -Name BotIcon
    $script:bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
    $bytes = [System.IO.File]::ReadAllBytes($boticon)
    $stream = New-Object System.IO.MemoryStream(,$Bytes)
    $bitmap.BeginInit()
    $bitmap.StreamSource = $stream
    $bitmap.EndInit()
    $bitmap.Freeze()

    # Setup reusable objects
    $colormap = New-Object System.Drawing.Imaging.ColorMap
    $attributes = New-Object System.Drawing.Imaging.ImageAttributes
    $rectangle = New-Object System.Drawing.Rectangle(0, 0, $bitmap.Width, $bitmap.Height)

    $color = Get-TvConfigValue -Name BotIconColor
    $img = [System.Drawing.Image]::FromStream($bitmap.StreamSource)
    $bmp = [System.Drawing.Bitmap]$img
    $colormap.OldColor = "#000000"
    $colormap.NewColor = $color
    $attributes.SetRemapTable($colormap)
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.DrawImage($bmp, $rectangle, 0, 0, $bitmap.Width, $bitmap.Height, "Pixel", $attributes)

    # Create empty canvas for the new image
    $newimage = New-Object System.Drawing.Bitmap(16, 16)
    $null = $newimage.SetResolution(96, 96)

    # Draw new image on the empty canvas
    $graph = [System.Drawing.Graphics]::FromImage($newimage)
    $graph.DrawImage($img, 0, 0, 16, 16)

    # Convert the bitmap into an icon
    $icon = [System.Drawing.Icon]::FromHandle($newimage.GetHicon())

    # Create NotificationIcon and set its default values
    $script:notifyicon = New-Object System.Windows.Forms.NotifyIcon
    $script:notifyicon.Icon = $icon
    $script:notifyicon.Visible = $true

    ############################## add support for clicks ##############################

    # Create right-click -> Exit menu
    $menuexit = New-Object System.Windows.Forms.MenuItem
    $menuexit.Text = "Exit"
    # Create right-click -> Restart bot
    $menurestart = New-Object System.Windows.Forms.MenuItem
    $menurestart.Text = "Restart bot"

    $contextmenu = New-Object System.Windows.Forms.ContextMenu
    $script:notifyicon.ContextMenu = $contextmenu
    $script:notifyicon.contextMenu.MenuItems.AddRange($menurestart)
    $script:notifyicon.contextMenu.MenuItems.AddRange($menuexit)

    # Show/Hide bot window on left-click
    $script:notifyicon.add_Click( {
            if ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
                $null = Switch-WindowStyle -Process $script:newprocess
            }
        })

    # When Exit is clicked, close everything and kill the PowerShell process
    $menuexit.add_Click( {
            $script:notifyicon.Visible = $false
            $script:notifyicon.dispose()
            Stop-Process $script:newprocess.Id
            Stop-Process $pid
        })

    # When Restart is clicked, close everything and kill the PowerShell process
    $menurestart.add_Click( {
            Stop-Process $script:newprocess.Id
            $script:newprocess = Start-Process -FilePath powershell -ArgumentList "-NoLogo -NoProfile -Command Start-TvBot -NoTrayIcon -PrimaryPid $PID @script:startboundparams" -PassThru
            Start-Sleep -Seconds 3
            $null = Switch-WindowStyle -Process $script:newprocess
        })

    # Make PowerShell Disappear
    $script:newprocess = Start-Process -FilePath powershell -ArgumentList "-NoLogo -NoProfile -Command Start-TvBot -NoTrayIcon -PrimaryPid $PID @script:startboundparams" -PassThru

    Start-Sleep -Seconds 1
    $null = Switch-WindowStyle
    $null = Switch-WindowStyle -Process $script:newprocess

    # Force garbage collection just to start slightly lower RAM usage.
    [System.GC]::Collect()

    # Create an application context for it to all run within.
    # This helps with responsiveness, especially when clicking Exit.
    $appContext = New-Object System.Windows.Forms.ApplicationContext
    $null = [System.Windows.Forms.Application]::Run($appContext)
}