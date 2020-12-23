function Watch-TvViewCount {
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
    process {
        $stream = Invoke-TvRequest -ClientId $ClientId -Secret $Token -Path /streams?user_login=$Channel
        $viewcount = $stream.data.viewer_count

        # Add assemblies
        Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms

        # Create custom PowerShell object that will be used to popuplate the ListView
        $localdisks = Get-WmiObject Win32_Volume -Filter "DriveType='3'"
        $itemsource = @()
        foreach ($disk in ($localdisks | Sort-Object -Property Name)) {
            if (!$disk.name.StartsWith("\\")) {
                $itemsource += [PSCustomObject]@{
                    Name  = $disk.Name
                    Label = $disk.Label
                    Total = "$([Math]::Round($disk.Capacity /1GB,1)) GB"
                    Free  = "$([Math]::Round($disk.FreeSpace /1GB,1)) GB"
                }
            }
        }

        # Icon! THANKS VEXX!
        [System.Drawing.Bitmap]$image = [System.Drawing.Bitmap]::New(16, 16)
        $null = $image.SetResolution(96, 96)
        [System.Drawing.Graphics]$surface = [System.Drawing.Graphics]::FromImage($image)
        #$surface.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

        $color = [System.Drawing.Color]::White
        $brush = [System.Drawing.SolidBrush]::New($color)

        if ([int]$viewcount -gt 99) {
            $weight = "Regular"
            $fontsize = 8.5
        } else {
            $fontsize = 12
            $weight = "Bold"
        }

        $font = [System.Drawing.Font]::New("Segoe UI", $fontsize, $weight, "Pixel")
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
        $icon = [System.Drawing.Icon]::FromHandle($image.GetHicon())

        # Create XAML form in Visual Studio, ensuring the ListView looks chromeless
        [xml]$xaml = '<Window
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Name="window" WindowStyle="None" Height="200" Width="400"
ResizeMode="NoResize" ShowInTaskbar="False">
<Window.Resources>
    <Style TargetType="GridViewColumnHeader">
        <Setter Property="Background" Value="Transparent" />
        <Setter Property="Foreground" Value="White"/>
        <Setter Property="BorderBrush" Value="Transparent"/>
        <Setter Property="FontWeight" Value="Bold"/>
        <Setter Property="Template">
            <Setter.Value>
                <ControlTemplate TargetType="GridViewColumnHeader">
                <Border Background="#313130">
                    <ContentPresenter></ContentPresenter>
                </Border>
                </ControlTemplate>
            </Setter.Value>
        </Setter>
    </Style>
</Window.Resources>
    <Grid Name="grid" Background="#313130" Height="200" Width="400">
        <Label Name="label" Content="Current Disk Usage" Foreground="White" FontSize="18" Margin="10,10,0,15"/>
        <ListView Name="listview" SelectionMode="Single" Margin="0,50,0,0" Foreground="White"
        Background="Transparent" BorderBrush="Transparent" IsHitTestVisible="False">
            <ListView.ItemContainerStyle>
                <Style>
                    <Setter Property="Control.HorizontalContentAlignment" Value="Stretch"/>
                    <Setter Property="Control.VerticalContentAlignment" Value="Stretch"/>
                </Style>
            </ListView.ItemContainerStyle>
        </ListView>
    </Grid>
</Window>'

        # Turn XAML into PowerShell objects
        $window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
        $xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $window.FindName($_.Name) -Scope Script }

        # Populate ListView with PS Object data and set width
        $listview.ItemsSource = $itemsource
        $listview.Width = $grid.width * .9

        # Create GridView object to add to ListView
        $gridview = New-Object System.Windows.Controls.GridView
        # Order the columns the way you want to see them in the popup
        $columnorder = 'Name', 'Label', 'Total', 'Free'

        # Dynamically add columns to GridView, then bind data to columns
        foreach ($column in $columnorder) {
            $gridcolumn = New-Object System.Windows.Controls.GridViewColumn
            $gridcolumn.Header = $column
            $gridcolumn.Width = $grid.width * .20
            $gridbinding = New-Object System.Windows.Data.Binding $column
            $gridcolumn.DisplayMemberBinding = $gridbinding
            $gridview.AddChild($gridcolumn)
        }

        # Add GridView to ListView
        $listview.View = $gridview

        # Create notifyicon, and right-click -> Exit menu
        $notifyicon = New-Object System.Windows.Forms.NotifyIcon
        $notifyicon.Text = "tvbot"
        $notifyicon.Icon = $icon
        $notifyicon.Visible = $true

        $menuitem = New-Object System.Windows.Forms.MenuItem
        $menuitem.Text = "Exit"

        $contextmenu = New-Object System.Windows.Forms.ContextMenu
        $notifyicon.ContextMenu = $contextmenu
        $notifyicon.contextMenu.MenuItems.AddRange($menuitem)

        # Add a left click that makes the Window appear in the lower right
        # part of the screen, above the notify icon.
        $notifyicon.add_Click( {
                if ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
                    # reposition each time, in case the resolution or monitor changes
                    $window.Left = $([System.Windows.SystemParameters]::WorkArea.Width - $window.Width)
                    $window.Top = $([System.Windows.SystemParameters]::WorkArea.Height - $window.Height)
                    $window.Show()
                    $window.Activate()
                }
            })

        # Close the window if it's double clicked
        $window.Add_MouseDoubleClick( {
                $window.Hide()
            })

        # Close the window if it loses focus
        $window.Add_Deactivated( {
                $window.Hide()
            })

        # When Exit is clicked, close everything and kill the PowerShell process
        $menuitem.add_Click( {
                $notifyicon.Visible = $false
                $window.Close()
                Stop-Process $pid
            })

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