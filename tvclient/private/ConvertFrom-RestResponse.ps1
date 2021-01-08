function ConvertFrom-RestResponse {
    <#
    .SYNOPSIS
        Converts Nessus and tenable.sc responses to a readable, PowerShell-styled format

    .DESCRIPTION
        Converts Nessus and tenable.sc responses to a readable, PowerShell-styled format

    .PARAMETER InputObject
        The rest response to parse from pipeline

    .EXAMPLE
        PS C:\> $session = Connect-TNServer -ComputerName nessus -Credential admin
        PS C:\> $params = @{
                    SessionObject   = $session
                    Path            = "/folders"
                    Method          = "GET"
                    EnableException = $EnableException
                }
        PS C:\> Invoke-TNRequest @params | ConvertFrom-RestResponse

        Connects to https://nessus:8834 using the admin credential, gets the results in JSON format then converts to PowerShell styled output

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject[]]$InputObject,
        [switch]$NoUri,
        [switch]$ExcludeEmptyResult
    )
    begin {
        function Convert-Name ($string) {
            if ($string -match "_") {
                $whole = @()
                $split = $string -split "_"
                foreach ($name in $split) {
                    $first = $name.Substring(0, 1).ToUpperInvariant()
                    $rest = $name.Substring(1, $name.length - 1)
                    $whole += "$first$rest"
                }
                $string = -join $whole
            }
            return $string
        }

        function Convert-Value {
            param (
                [string]$Key,
                $Value
            )
            if ($value -match '\b[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z\b') {
                $datetime = ([DateTime]$value).ToUniversalTime()
                return [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($datetime, (Get-TimeZone).Id)
            }
            if ($Key -notmatch 'date' -and $Key -notmatch 'time' -or $Key -match 'Updates') {
                if ("$Value".StartsWith("@") -or "$Value".StartsWith("{")) {
                    return $Value | ConvertFrom-RestResponse -NoUri
                } else {
                    return $Value
                }
            } else {
                return $Value
            }
        }

        function Convert-Row {
            param (
                [object[]]$Object,
                [string]$Type
            )
            # get columns to convert to camel case
            if ($null -eq $Object) {
                return
            }
            try {
                $fields = $Object | Get-Member -Type NoteProperty -ErrorAction Stop | Sort-Object Name
            } catch {
                return
            }

            foreach ($row in $Object) {
                $hash = @{}

                if ($Type) {
                    $hash["Type"] = $Type
                }

                if ($script:includeid) {
                    $hash["Id"] = $script:includeid
                }

                foreach ($name in $fields.Name) {
                    # Proper case first letter, tenable takes care of the rest
                    $first = $name.Substring(0, 1).ToUpperInvariant()
                    $rest = $name.Substring(1, $name.length - 1)
                    $column = "$first$rest"

                    # some columns need special attention
                    switch ($column) {
                        "Shared" {
                            $hash["Shared"] = $(if ($row.shared -eq 1) { $true } elseif ($row.shared -eq 0) { $false } else { $row.shared })
                        }
                        "Status" {
                            $hash["Status"] = $(if ($row.status -eq 1) { $true } elseif ($row.status -eq 0) { $false } else { $row.status })
                        }
                        "User_permissions" {
                            $hash["UserPermissions"] = $permidenum[$row.user_permissions]
                        }
                        { $PSItem -match "Modifi" } {
                            $value = Convert-Value -Key $column -Value $row.$column
                            $hash["Modified"] = $value
                        }
                        { $PSItem -match "Create" } {
                            $value = Convert-Value -Key $column -Value $row.$column
                            $hash["CreatedAt"] = $value
                        }
                        { $PSItem -match "Last.Login" -or $PSItem -eq "LastLogin" } {
                            $value = $script:origin.AddSeconds($row.$column).ToLocalTime()
                            $hash["LastLogin"] = $value
                        }
                        default {
                            # remove _, cap all words
                            $key = Convert-Name $column
                            $value = Convert-Value -Key $column -Value $row.$column
                            $hash[$key] = $value
                        }
                    }
                }

                # Set column order
                $order = New-Object System.Collections.ArrayList
                $keys = $hash.Keys
                if ('Rank' -in $keys) {
                    $null = $order.Add("Rank")
                }
                if ('Id' -in $keys) {
                    $null = $order.Add("Id")
                }
                if ($Type) {
                    $null = $order.Add("Type")
                }
                if ('Username' -in $keys) {
                    $null = $order.Add("Username")
                }
                if ('Title' -in $keys) {
                    $null = $order.Add("Title")
                }
                if ('Name' -in $keys) {
                    $null = $order.Add("Name")
                }
                if ('Description' -in $keys) {
                    $null = $order.Add("Description")
                }
                foreach ($column in ($keys | Sort-Object | Where-Object { $PSItem -notin "ServerUri", "Id", "Type", "Name", "Description", "Title", "Username", "Rank" })) {
                    $null = $order.Add($column)
                }

                Write-TvSystemMessage -Type Debug "Columns: $order"
                Write-TvSystemMessage -Type Debug "Count: $($hash.Count)"
                [pscustomobject]$hash | Select-Object -Property $order
            }
        }
    }
    process {
        if ($null -eq $InputObject -or ($ExcludeEmptyResult -and $InputObject.type -eq "regular")) {
            return
        }
        foreach ($object in $InputObject) {
            Write-TvSystemMessage -Type Debug "Processing object"

            # determine if it has an inner field to extract
            $fields = $object | Get-Member -Type NoteProperty

            # IF EVERY ONE HAS MULTIPLES INSIDE
            if ($fields.Count -eq 0) {
                Write-TvSystemMessage -Type Verbose -Message "Found no inner objects"
                if ($object.ToString().StartsWith("{")) {
                    $object = $object.Replace("\","\\") | ConvertFrom-Json
                    $fields = $object | Get-Member -Type NoteProperty
                } elseif ($object.ToString().StartsWith("@{")) {
                    $object = $object.Substring(2, $object.Length - 3) -split ';' | ConvertFrom-StringData | ConvertTo-PSCustomObject
                    $fields = $object | Get-Member -Type NoteProperty
                } else {
                    try {
                        $object = $object | ConvertFrom-Json -ErrorAction Stop
                        $fields = $object | Get-Member -Type NoteProperty -ErrorAction Stop
                    } catch {
                        # nothing
                    }
                }
            }

            if ($fields.Count -eq 1) {
                Write-TvSystemMessage -Type Verbose -Message "Found one inner object"
                $name = $fields.Name
                Convert-Row -Object $object.$name -Type $null
            } else {
                # Write-TvSystemMessage -Type Verbose -Message "Found multiple inner objects"
                $result = $true
                foreach ($definition in $fields.Definition) {
                    if (-not $definition.Contains("Object[]")) {
                        $result = $false
                    }
                }
                if ($result) {
                    foreach ($field in $fields) {
                        $name = (Get-Culture).TextInfo.ToTitleCase($field.Name)
                        Convert-Row -Object $object.$name -Type $name
                    }
                } else {
                    Convert-Row -Object $object
                }
            }
        }
    }
}