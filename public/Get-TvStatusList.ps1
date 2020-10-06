Function Get-TvStatusList {
    <#
    .SYNOPSIS
        Gets a list of IRC statuses.

    .DESCRIPTION
        Gets a list of IRC statuses. This is mostly for future implementations.

        Thanks to https://github.com/alejandro5042/Run-IrcBot for the list

        .EXAMPLE
        PS> Get-TvStatusList
    #>
    process {
        # Thanks to https://github.com/alejandro5042/Run-IrcBot
        Import-Csv -Path "$script:ModuleRoot\codes.txt" -Delimiter `t
    }
}