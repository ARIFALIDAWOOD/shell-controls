<#
.SYNOPSIS
    Utility functions for Shell-Controls
#>

function Get-SCTerminalSize {
    [CmdletBinding()]
    param()
    try {
        return [PSCustomObject]@{
            Width        = [Console]::WindowWidth
            Height       = [Console]::WindowHeight
            BufferWidth  = [Console]::BufferWidth
            BufferHeight = [Console]::BufferHeight
        }
    } catch {
        return [PSCustomObject]@{ Width = 80; Height = 24; BufferWidth = 80; BufferHeight = 100 }
    }
}

function Test-SCCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Name
    )
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-SCCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [scriptblock]$ScriptBlock,

        [Parameter()]
        [string]$ErrorMessage = "Command failed",

        [Parameter()]
        [switch]$SuppressErrors
    )
    try { & $ScriptBlock }
    catch {
        if (-not $SuppressErrors) { Write-SCError "$ErrorMessage`: $_" }
        return $null
    }
}

function ConvertTo-SCSlug {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Text
    )
    $slug = $Text.ToLower()
    $slug = $slug -replace '[^a-z0-9\s-]', ''
    $slug = $slug -replace '\s+', '-'
    $slug = $slug -replace '-+', '-'
    $slug = $slug.Trim('-')
    return $slug
}

function Get-SCRelativePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$From,

        [Parameter(Mandatory)]
        [string]$To
    )
    $fromUri = [Uri]::new($From + [IO.Path]::DirectorySeparatorChar)
    $toUri = [Uri]::new($To)
    $relativeUri = $fromUri.MakeRelativeUri($toUri)
    $relativePath = [Uri]::UnescapeDataString($relativeUri.ToString())
    return $relativePath.Replace('/', [IO.Path]::DirectorySeparatorChar)
}

function Format-SCDuration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [TimeSpan]$Duration
    )
    if ($Duration.TotalMilliseconds -lt 1000) { return "{0:N0}ms" -f $Duration.TotalMilliseconds }
    elseif ($Duration.TotalSeconds -lt 60) { return "{0:N1}s" -f $Duration.TotalSeconds }
    elseif ($Duration.TotalMinutes -lt 60) { return "{0:N0}m {1:N0}s" -f [Math]::Floor($Duration.TotalMinutes), $Duration.Seconds }
    else { return "{0:N0}h {1:N0}m" -f [Math]::Floor($Duration.TotalHours), $Duration.Minutes }
}

function Get-SCEnvironmentInfo {
    [CmdletBinding()]
    param()
    $isAdmin = $false
    try {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { }
    return [PSCustomObject]@{
        OS              = [System.Environment]::OSVersion.Platform
        OSVersion       = [System.Environment]::OSVersion.VersionString
        PowerShell      = $PSVersionTable.PSVersion.ToString()
        IsAdmin         = $isAdmin
        User            = [Environment]::UserName
        Machine         = [Environment]::MachineName
        CurrentDirectory = (Get-Location).Path
        HomeDirectory   = $HOME
    }
}
