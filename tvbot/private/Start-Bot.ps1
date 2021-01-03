function Start-Bot {
    Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms
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
    # Create notifyicon, and right-click -> Exit menu
    $script:notifyicon = New-Object System.Windows.Forms.NotifyIcon
    $script:notifyicon.Icon = $icon
    $script:notifyicon.Visible = $true

    $menuexit = New-Object System.Windows.Forms.MenuItem
    $menuexit.Text = "Exit"
    $menurestart = New-Object System.Windows.Forms.MenuItem
    $menurestart.Text = "Restart bot"

    $contextmenu = New-Object System.Windows.Forms.ContextMenu
    $script:notifyicon.ContextMenu = $contextmenu
    $script:notifyicon.contextMenu.MenuItems.AddRange($menurestart)
    $script:notifyicon.contextMenu.MenuItems.AddRange($menuexit)

    # Add Event to exit example
    $script:notifyicon.add_Click( {
            if ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
                if ($script:hidden) {
                    $script:hidden = $false
                    Set-WindowStyle -Process $script:newprocess -Style Show
                } else {
                    $script:hidden = $true
                    Set-WindowStyle -Process $script:newprocess -Style Hide
                }
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
            $script:hidden = $true
            Set-WindowStyle -Process $script:newprocess -Style Hide
        })

    # Make PowerShell Disappear
    $script:newprocess = Start-Process -FilePath powershell -ArgumentList "-NoLogo -NoProfile -Command Start-TvBot -NoTrayIcon -PrimaryPid $PID @script:startboundparams" -PassThru

    $script:hidden = $true
    Set-WindowStyle -Style Hide
    Set-WindowStyle -Process $script:newprocess -Style Hide

    # Force garbage collection just to start slightly lower RAM usage.
    [System.GC]::Collect()

    # Create an application context for it to all run within.
    # This helps with responsiveness, especially when clicking Exit.
    $appContext = New-Object System.Windows.Forms.ApplicationContext
    $null = [System.Windows.Forms.Application]::Run($appContext)
}