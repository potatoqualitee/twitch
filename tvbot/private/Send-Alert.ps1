function Send-Alert {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$UserName,
        [parameter(Mandatory)]
        [ValidateSet("Bits","Follow","Raid","Sub", "Message")]
        [string]$Type,
        [string]$Message,
        [int]$Bits,
        [int]$Emote
    )
    begin {
        function Get-TransformedValue {
            param($Value)

            $Value = $Value.Replace("<<username>>",$UserName)

            if ($Type -eq "Bits") {
                if ($Bits -eq 1) {
                    $bitword = "BIT"
                } else {
                    $bitword = "BITS"
                }
                $Value = $Value.Replace("<<bitcount>>", "$Bits $bitword")
            }
            $Value
        }
    }
    process {
        if ($Type -eq "Message") {
            if (-not $PSBoundParameters.Message) {
                throw "You must specify -Message when the -Type is Message"
            }
        } else {
            $icon = Get-TvConfigValue -Name ($Type, "icon" -join "")
            $title = Get-TvConfigValue -Name ($Type, "title" -join "")
            $image = Get-TvConfigValue -Name ($Type, "image" -join "")
            if (-not $Message) {
                $Message = Get-TvConfigValue -Name ($Type, "text" -join "")
            }
        }

        if (-not $title) {
            $title = $UserName
        }
        $title = Get-TransformedValue -Value $title
        $Message = Get-TransformedValue -Value $message

        if (-not $image) {
            $image = Resolve-Path "$script:ModuleRoot\icon.png"
        }

        if (-not $script:toast) {
            $string = [System.Security.SecurityElement]::Escape($Message)
            try {
                Send-OSNotification -Title $title -Body $string -Icon $image -ErrorAction Stop
            } catch {
                Write-Warning "Failure $_"
            }
        } else {
            # Emotes can only be loaded by BurntToast
            if ($Emote) {
                $image = Get-TvEmote -Id $emote
            }
            $image = Get-Avatar -UserName $UserName
            $bticon = New-BTImage -Source $icon -AppLogoOverride
            $btimage = New-BTImage -Source $image -HeroImage
            $bttitle = New-BTText -Text $Title
            $bttext = New-BTText -Text $Message

            $sound = Get-TvConfigValue -Name ($Type, "sound" -join "")
            $soundenabled = Get-TvConfigValue -Name Sound
            if ($sound -and $soundenabled -eq "Enabled") {
                $audio = New-BTAudio -Source $sound
            }

            $binding = New-BTBinding -Children $bttitle, $bttext -HeroImage $btimage -AppLogoOverride $bticon
            $visual = New-BTVisual -BindingGeneric $binding

            $params = @{
                Visual = $visual
            }
            if ($audio) {
                $params.Audio = $audio
            }

            $content = New-BTContent @params

            if (Get-BTHistory -UniqueIdentifier tvbot) {
                Remove-BTNotification -Tag tvbot -Group tvbot
            }
            try {
                Submit-BTNotification -Content $content -UniqueIdentifier tvbot -ErrorAction Stop
            } catch {
                Write-Warning "Failure $_"
            }
        }
    }
}