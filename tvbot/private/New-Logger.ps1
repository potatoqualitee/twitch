


$dll = Resolve-XPlatPath (Join-Path -Path $DllPath -ChildPath 'log4net.dll')
Add-Type -Path $dll
[Void][Reflection.Assembly]::LoadFile($DllFile)


#Define Values for FileAppender Configuration
$Pattern = '[%date{yyyy-MM-dd HH:mm:ss.fff} (%utcdate{yyyy-MM-dd HH:mm:ss.fff})] [%level] [%message]%n'
$PatternLayout = [log4net.Layout.ILayout](New-Object log4net.Layout.PatternLayout($Pattern))

$LogPath = "C:\Users\ctrlb\AppData\Roaming\tvclient"
$LogFile = Join-Path -Path $LogPath -ChildPath $('LogFile_{0:yyyy-MM-dd}_{0:HH-mm-ss}.log' -f (Get-Date))

$AppendToFile = $True

#Load FileAppender Configuration
$FileAppender = New-Object log4net.Appender.FileAppender($PatternLayout,$LogFile,$AppendToFile);
$FileAppender.Threshold = [log4net.Core.Level]::All
[log4net.Config.BasicConfigurator]::Configure($FileAppender)

$script:logger = [log4net.LogManager]::GetLogger("tvbot")