<#
.SYNOPSIS
    Configuration get/set for Shell-Controls
#>

function Get-SCConfig {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Key
    )

    if (-not $Key) { return $script:Config }
    $parts = $Key -split '\.'
    $current = $script:Config
    foreach ($p in $parts) {
        if ($null -eq $current) { return $null }
        if ($current -is [hashtable] -and $current.ContainsKey($p)) { $current = $current[$p] }
        else { return $null }
    }
    return $current
}

function Set-SCConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [object]$Value
    )

    if (-not $script:Config) { $script:Config = @{} }
    $parts = $Key -split '\.'
    $current = $script:Config
    for ($i = 0; $i -lt $parts.Count - 1; $i++) {
        $p = $parts[$i]
        if (-not $current.ContainsKey($p)) { $current[$p] = @{} }
        $current = $current[$p]
    }
    $current[$parts[-1]] = $Value
}
