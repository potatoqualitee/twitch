function Get-ValidColor {
    [Enum]::GetValues([System.Drawing.KnownColor]) | Where-Object {
        $PSItem -notmatch "Active|Workspace|Button|Control|Desktop|Highlight|Border|Caption|Menu|Scroll|Window"
    }
}