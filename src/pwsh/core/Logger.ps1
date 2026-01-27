<#
.SYNOPSIS
    Logging functionality for Shell-Controls
#>

$script:LogLevel = @{ Debug = 0; Info = 1; Warning = 2; Error = 3; None = 4 }
$script:CurrentLogLevel = $script:LogLevel.Info
$script:LogFile = $null

function Set-SCLogLevel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Debug', 'Info', 'Warning', 'Error', 'None')]
        [string]$Level
    )
    $script:CurrentLogLevel = $script:LogLevel[$Level]
}

function Set-SCLogFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    $script:LogFile = $Path
    $dir = Split-Path $Path -Parent
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

function Write-SCLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
        [string]$Level = 'Info',

        [Parameter()]
        [switch]$NoConsole,

        [Parameter()]
        [switch]$NoFile
    )

    $levelNum = $script:LogLevel[$Level]
    if ($levelNum -lt $script:CurrentLogLevel) { return }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$($Level.ToUpper().PadRight(7))] $Message"

    if (-not $NoConsole) {
        switch ($Level) {
            'Debug'   { Write-SCMuted $Message }
            'Info'    { Write-SCInfo $Message }
            'Warning' { Write-SCWarning $Message }
            'Error'   { Write-SCError $Message }
        }
    }

    if (-not $NoFile -and $script:LogFile) { Add-Content -Path $script:LogFile -Value $logMessage }
}
