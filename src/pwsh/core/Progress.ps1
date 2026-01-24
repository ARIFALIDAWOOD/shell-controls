#Requires -Version 7.0
<#
.SYNOPSIS
    Progress bar component for Shell-Controls (tqdm-style)
.DESCRIPTION
    Provides animated progress bars with percentage, ETA, and throughput display.
#>

# Progress bar state
$script:ProgressBars = @{}

function New-SCProgress {
    <#
    .SYNOPSIS
        Creates a new progress bar instance
    .PARAMETER Id
        Unique identifier for this progress bar
    .PARAMETER Total
        Total number of items (omit for indeterminate)
    .PARAMETER Description
        Text description shown before the bar
    .PARAMETER Width
        Width of the progress bar in characters (default: 40)
    .PARAMETER Style
        Bar style: 'blocks', 'ascii', 'slim' (default: 'blocks')
    .OUTPUTS
        Progress bar state object
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Id = [guid]::NewGuid().ToString().Substring(0, 8),

        [Parameter()]
        [int]$Total = 0,

        [Parameter()]
        [string]$Description = "",

        [Parameter()]
        [int]$Width = 40,

        [Parameter()]
        [ValidateSet('blocks', 'ascii', 'slim')]
        [string]$Style = 'blocks'
    )

    $state = @{
        Id          = $Id
        Total       = $Total
        Current     = 0
        Description = $Description
        Width       = $Width
        Style       = $Style
        StartTime   = Get-Date
        LastUpdate  = Get-Date
        Finished    = $false
    }

    $script:ProgressBars[$Id] = $state

    # Hide cursor during progress
    [Console]::Write("`e[?25l")

    return $state
}

function Update-SCProgress {
    <#
    .SYNOPSIS
        Updates progress bar state and redraws
    .PARAMETER Id
        Progress bar ID
    .PARAMETER Current
        Current progress value
    .PARAMETER Increment
        Increment current by this amount instead of setting
    .PARAMETER Description
        Update description text
    .PARAMETER Total
        Update total (for dynamic totals)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Id,

        [Parameter()]
        [int]$Current = -1,

        [Parameter()]
        [int]$Increment = 0,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [int]$Total = -1
    )

    $state = $script:ProgressBars[$Id]
    if (-not $state) { return }

    if ($Current -ge 0) {
        $state.Current = $Current
    } elseif ($Increment -gt 0) {
        $state.Current += $Increment
    }

    if ($Total -ge 0) {
        $state.Total = $Total
    }

    if ($Description) {
        $state.Description = $Description
    }

    $state.LastUpdate = Get-Date

    # Draw the progress bar
    Show-SCProgressBar -State $state
}

function Complete-SCProgress {
    <#
    .SYNOPSIS
        Completes and removes a progress bar
    .PARAMETER Id
        Progress bar ID
    .PARAMETER Message
        Optional completion message
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Id,

        [Parameter()]
        [string]$Message
    )

    $state = $script:ProgressBars[$Id]
    if (-not $state) { return }

    $state.Current = $state.Total
    $state.Finished = $true

    # Final draw
    Show-SCProgressBar -State $state -Final

    # Show cursor
    [Console]::Write("`e[?25h")
    [Console]::WriteLine()

    if ($Message) {
        Write-SCSuccess $Message
    }

    $script:ProgressBars.Remove($Id)
}

function Show-SCProgressBar {
    <#
    .SYNOPSIS
        Renders the progress bar to console
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$State,

        [Parameter()]
        [switch]$Final
    )

    $colorsEnabled = Test-SCColorsEnabled

    # Calculate percentage
    $percent = if ($State.Total -gt 0) {
        [Math]::Min(100, [Math]::Round(($State.Current / $State.Total) * 100))
    } else { 0 }

    # Calculate filled width
    $filledWidth = if ($State.Total -gt 0) {
        [Math]::Floor(($State.Current / $State.Total) * $State.Width)
    } else { 0 }
    $emptyWidth = $State.Width - $filledWidth

    # Get bar characters based on style
    $chars = switch ($State.Style) {
        'blocks' { @{ Filled = '█'; Empty = '░'; Left = ''; Right = '' } }
        'ascii'  { @{ Filled = '#'; Empty = '-'; Left = '['; Right = ']' } }
        'slim'   { @{ Filled = '━'; Empty = '─'; Left = ''; Right = '' } }
        default  { @{ Filled = '█'; Empty = '░'; Left = ''; Right = '' } }
    }

    # Build the bar
    $bar = $chars.Left + ($chars.Filled * $filledWidth) + ($chars.Empty * $emptyWidth) + $chars.Right

    # Calculate elapsed and ETA
    $elapsed = (Get-Date) - $State.StartTime
    $elapsedStr = "{0:mm\:ss}" -f $elapsed

    $etaStr = ""
    if ($State.Total -gt 0 -and $State.Current -gt 0 -and -not $Final) {
        $rate = $State.Current / $elapsed.TotalSeconds
        $remaining = ($State.Total - $State.Current) / $rate
        if ($remaining -lt 3600) {
            $etaStr = " ETA: {0:mm\:ss}" -f [TimeSpan]::FromSeconds($remaining)
        }
    }

    # Build the line
    $desc = if ($State.Description) { "$($State.Description) " } else { "" }
    $progress = if ($State.Total -gt 0) { "$($State.Current)/$($State.Total)" } else { "$($State.Current)" }

    # Colors
    $barColor = if ($colorsEnabled) {
        if ($Final -or $percent -eq 100) {
            ConvertTo-AnsiColor -HexColor (Get-SCColor -Name 'success')
        } else {
            ConvertTo-AnsiColor -HexColor (Get-SCColor -Name 'primary')
        }
    } else { '' }
    $mutedColor = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor (Get-SCColor -Name 'muted') } else { '' }
    $reset = if ($colorsEnabled) { Get-AnsiReset } else { '' }

    # Format: Description |████████░░░░| 50% (50/100) [00:05 ETA: 00:05]
    $line = "${desc}${barColor}${bar}${reset} ${percent}% ${mutedColor}(${progress}) [${elapsedStr}${etaStr}]${reset}"

    # Move to beginning of line and clear
    [Console]::Write("`r`e[K$line")
}

function Show-SCProgressInline {
    <#
    .SYNOPSIS
        Shows a simple inline progress indicator (for quick use)
    .PARAMETER Current
        Current value
    .PARAMETER Total
        Total value
    .PARAMETER Description
        Optional description
    .PARAMETER Width
        Bar width (default: 30)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$Current,

        [Parameter(Mandatory)]
        [int]$Total,

        [Parameter()]
        [string]$Description = "",

        [Parameter()]
        [int]$Width = 30
    )

    $percent = [Math]::Min(100, [Math]::Round(($Current / $Total) * 100))
    $filledWidth = [Math]::Floor(($Current / $Total) * $Width)
    $emptyWidth = $Width - $filledWidth

    $bar = '█' * $filledWidth + '░' * $emptyWidth
    $desc = if ($Description) { "$Description " } else { "" }

    $colorsEnabled = Test-SCColorsEnabled
    $barColor = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor (Get-SCColor -Name 'primary') } else { '' }
    $reset = if ($colorsEnabled) { Get-AnsiReset } else { '' }

    [Console]::Write("`r`e[K${desc}${barColor}${bar}${reset} ${percent}% (${Current}/${Total})")
}
