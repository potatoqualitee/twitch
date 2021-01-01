
# Set userid just once
function Get-Id {
    $script:userid = (Invoke-TvRequest -Path "/users" -ErrorAction Stop).id
}