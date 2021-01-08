function New-Logger {
    $dll = Join-Path -Path $script:ModuleRoot -ChildPath log4net.dll
    $null = Add-Type -Path $dll

    $pattern = '[%date{yyyy-MM-dd HH:mm:ss}] [%level] [%message]%n'
    $layout = [log4net.Layout.ILayout](New-Object log4net.Layout.PatternLayout($Pattern))

    $dir = Split-Path -Path (Get-TvConfigValue -Name ConfigFile)
    $dir = Join-Path -Path $dir -ChildPath logs
    if (-not (Test-Path -Path $dir)) {
        $null = New-Item -ItemType Directory -Path $dir
    }
    $logfile = Join-Path -Path $dir -ChildPath "tvbot-$((Get-Date -Format FileDate).ToString()).log"
    $append = $true

    #Load FileAppender Configuration
    $appender = New-Object log4net.Appender.FileAppender($layout,$logfile,$append);
    $null = $appender.Threshold = [log4net.Core.Level]::All
    $null = [log4net.Config.BasicConfigurator]::Configure($appender)
    [log4net.LogManager]::GetLogger("tvbot")
}