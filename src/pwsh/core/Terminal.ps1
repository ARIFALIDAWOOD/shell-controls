<#
.SYNOPSIS
    Terminal capability detection and fallbacks for Shell-Controls
.DESCRIPTION
    Detects terminal capabilities and provides graceful fallbacks for colors
    and symbols based on terminal support levels.
#>

function Get-SCTerminalCapabilities {
    <#
    .SYNOPSIS
        Detects terminal capabilities and returns a capabilities object
    .DESCRIPTION
        Detects: TrueColor, Color256, Unicode, Hyperlinks, TerminalName
        Checks: $env:WT_SESSION, $env:COLORTERM, $env:TERM_PROGRAM
    #>
    [CmdletBinding()]
    param()

    $capabilities = @{
        TerminalName  = 'Unknown'
        TrueColor     = $false
        Color256      = $false
        Color16       = $true  # Assume at least 16 colors
        Unicode       = $true  # Assume unicode by default on PowerShell 7+
        Hyperlinks    = $false
        WindowTitle   = $true
        CursorControl = $true
    }

    # Detect terminal emulator
    if ($env:WT_SESSION) {
        $capabilities.TerminalName = 'Windows Terminal'
        $capabilities.TrueColor = $true
        $capabilities.Color256 = $true
        $capabilities.Hyperlinks = $true
    }
    elseif ($env:TERM_PROGRAM -eq 'vscode') {
        $capabilities.TerminalName = 'VS Code'
        $capabilities.TrueColor = $true
        $capabilities.Color256 = $true
        $capabilities.Hyperlinks = $true
    }
    elseif ($env:TERM_PROGRAM -eq 'iTerm.app') {
        $capabilities.TerminalName = 'iTerm2'
        $capabilities.TrueColor = $true
        $capabilities.Color256 = $true
        $capabilities.Hyperlinks = $true
    }
    elseif ($env:TERM_PROGRAM -eq 'Apple_Terminal') {
        $capabilities.TerminalName = 'Apple Terminal'
        $capabilities.TrueColor = $false
        $capabilities.Color256 = $true
        $capabilities.Hyperlinks = $false
    }
    elseif ($env:TERM_PROGRAM -eq 'Hyper') {
        $capabilities.TerminalName = 'Hyper'
        $capabilities.TrueColor = $true
        $capabilities.Color256 = $true
        $capabilities.Hyperlinks = $true
    }
    elseif ($env:TERM_PROGRAM -eq 'Tabby') {
        $capabilities.TerminalName = 'Tabby'
        $capabilities.TrueColor = $true
        $capabilities.Color256 = $true
        $capabilities.Hyperlinks = $true
    }
    elseif ($env:KONSOLE_VERSION) {
        $capabilities.TerminalName = 'Konsole'
        $capabilities.TrueColor = $true
        $capabilities.Color256 = $true
        $capabilities.Hyperlinks = $true
    }
    elseif ($env:GNOME_TERMINAL_SCREEN) {
        $capabilities.TerminalName = 'GNOME Terminal'
        $capabilities.TrueColor = $true
        $capabilities.Color256 = $true
        $capabilities.Hyperlinks = $true
    }

    # Check COLORTERM environment variable
    if ($env:COLORTERM -eq 'truecolor' -or $env:COLORTERM -eq '24bit') {
        $capabilities.TrueColor = $true
        $capabilities.Color256 = $true
    }

    # Check TERM for 256color support
    if ($env:TERM -and $env:TERM -match '256color') {
        $capabilities.Color256 = $true
    }

    # Check for NO_COLOR standard
    if ($env:NO_COLOR) {
        $capabilities.TrueColor = $false
        $capabilities.Color256 = $false
        $capabilities.Color16 = $false
    }

    # Check for dumb terminal
    if ($env:TERM -eq 'dumb') {
        $capabilities.TrueColor = $false
        $capabilities.Color256 = $false
        $capabilities.Color16 = $false
        $capabilities.Unicode = $false
        $capabilities.CursorControl = $false
    }

    # Windows conhost detection
    if ($IsWindows -and -not $env:WT_SESSION -and -not $env:TERM_PROGRAM) {
        $capabilities.TerminalName = 'Windows Console'
        # Modern Windows 10+ console supports these
        $capabilities.TrueColor = $true
        $capabilities.Color256 = $true
    }

    # Check for SSH session (may have limited capabilities)
    if ($env:SSH_CONNECTION -or $env:SSH_TTY) {
        # Be conservative with SSH unless we detect better support
        if (-not $env:COLORTERM) {
            $capabilities.TrueColor = $false
        }
    }

    # Cache the result
    $script:TerminalCapabilities = $capabilities
    return $capabilities
}

function Get-SCColorFallback {
    <#
    .SYNOPSIS
        Gets a fallback color based on terminal capabilities
    .PARAMETER HexColor
        The original hex color
    .PARAMETER TargetMode
        Target color mode: TrueColor, Color256, Color16
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$HexColor,

        [Parameter()]
        [ValidateSet('TrueColor', 'Color256', 'Color16', 'None')]
        [string]$TargetMode
    )

    # If no target mode specified, auto-detect
    if (-not $TargetMode) {
        $caps = Get-SCTerminalCapabilities
        if ($caps.TrueColor) { $TargetMode = 'TrueColor' }
        elseif ($caps.Color256) { $TargetMode = 'Color256' }
        elseif ($caps.Color16) { $TargetMode = 'Color16' }
        else { $TargetMode = 'None' }
    }

    switch ($TargetMode) {
        'TrueColor' {
            # Return original hex for true color
            return $HexColor
        }
        'Color256' {
            # Convert to nearest 256 color
            return ConvertTo-256Color -HexColor $HexColor
        }
        'Color16' {
            # Convert to nearest 16 color
            return ConvertTo-16Color -HexColor $HexColor
        }
        'None' {
            return $null
        }
    }
}

function ConvertTo-256Color {
    <#
    .SYNOPSIS
        Converts hex color to nearest 256-color palette index
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$HexColor
    )

    $hex = $HexColor.TrimStart('#')
    if ($hex.Length -lt 6) { return 7 } # Default to white

    $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)

    # Check if it's a grayscale color
    if ($r -eq $g -and $g -eq $b) {
        if ($r -lt 8) { return 16 }
        if ($r -gt 248) { return 231 }
        return [Math]::Round(($r - 8) / 247 * 24) + 232
    }

    # Map to 6x6x6 color cube (indices 16-231)
    $ri = [Math]::Round($r / 255 * 5)
    $gi = [Math]::Round($g / 255 * 5)
    $bi = [Math]::Round($b / 255 * 5)

    return 16 + (36 * $ri) + (6 * $gi) + $bi
}

function ConvertTo-16Color {
    <#
    .SYNOPSIS
        Converts hex color to nearest 16-color ANSI index
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$HexColor
    )

    $hex = $HexColor.TrimStart('#')
    if ($hex.Length -lt 6) { return 7 }

    $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)

    # Basic 16 colors with their RGB values
    $colors = @(
        @{ Index = 0;  R = 0;   G = 0;   B = 0   }  # Black
        @{ Index = 1;  R = 128; G = 0;   B = 0   }  # Red
        @{ Index = 2;  R = 0;   G = 128; B = 0   }  # Green
        @{ Index = 3;  R = 128; G = 128; B = 0   }  # Yellow
        @{ Index = 4;  R = 0;   G = 0;   B = 128 }  # Blue
        @{ Index = 5;  R = 128; G = 0;   B = 128 }  # Magenta
        @{ Index = 6;  R = 0;   G = 128; B = 128 }  # Cyan
        @{ Index = 7;  R = 192; G = 192; B = 192 }  # White
        @{ Index = 8;  R = 128; G = 128; B = 128 }  # Bright Black (Gray)
        @{ Index = 9;  R = 255; G = 0;   B = 0   }  # Bright Red
        @{ Index = 10; R = 0;   G = 255; B = 0   }  # Bright Green
        @{ Index = 11; R = 255; G = 255; B = 0   }  # Bright Yellow
        @{ Index = 12; R = 0;   G = 0;   B = 255 }  # Bright Blue
        @{ Index = 13; R = 255; G = 0;   B = 255 }  # Bright Magenta
        @{ Index = 14; R = 0;   G = 255; B = 255 }  # Bright Cyan
        @{ Index = 15; R = 255; G = 255; B = 255 }  # Bright White
    )

    $minDistance = [double]::MaxValue
    $nearestIndex = 7

    foreach ($color in $colors) {
        $distance = [Math]::Sqrt(
            [Math]::Pow($r - $color.R, 2) +
            [Math]::Pow($g - $color.G, 2) +
            [Math]::Pow($b - $color.B, 2)
        )
        if ($distance -lt $minDistance) {
            $minDistance = $distance
            $nearestIndex = $color.Index
        }
    }

    return $nearestIndex
}

function Get-SCAnsiColor256 {
    <#
    .SYNOPSIS
        Gets ANSI escape sequence for 256-color mode
    .PARAMETER ColorIndex
        The 256-color palette index
    .PARAMETER Background
        Use as background color
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$ColorIndex,

        [Parameter()]
        [switch]$Background
    )

    if ($Background) {
        return "`e[48;5;${ColorIndex}m"
    }
    return "`e[38;5;${ColorIndex}m"
}

function Get-SCAnsiColor16 {
    <#
    .SYNOPSIS
        Gets ANSI escape sequence for 16-color mode
    .PARAMETER ColorIndex
        The 16-color index (0-15)
    .PARAMETER Background
        Use as background color
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$ColorIndex,

        [Parameter()]
        [switch]$Background
    )

    # Standard ANSI 16-color codes
    if ($ColorIndex -lt 8) {
        $base = if ($Background) { 40 } else { 30 }
        return "`e[${base}$($ColorIndex)m"
    } else {
        # Bright colors
        $base = if ($Background) { 100 } else { 90 }
        return "`e[$($base + $ColorIndex - 8)m"
    }
}

function Get-SCSymbolFallback {
    <#
    .SYNOPSIS
        Gets ASCII fallback for Unicode symbols
    .PARAMETER SymbolName
        The symbol name to get fallback for
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SymbolName
    )

    $fallbacks = @{
        'check'       = '[x]'
        'cross'       = '[!]'
        'bullet'      = '*'
        'warning'     = '/!\'
        'info'        = '(i)'
        'question'    = '?'
        'pointer'     = '>'
        'pointerSmall' = '>'
        'arrowUp'     = '^'
        'arrowDown'   = 'v'
        'arrowLeft'   = '<'
        'arrowRight'  = '>'
        'radioOn'     = '(*)'
        'radioOff'    = '( )'
        'checkboxOn'  = '[x]'
        'checkboxOff' = '[ ]'
        'star'        = '*'
        'starEmpty'   = '*'
        'heart'       = '<3'
        'play'        = '>'
        'stop'        = '#'
        'pause'       = '||'
        'reload'      = '@'
    }

    if ($fallbacks.ContainsKey($SymbolName)) {
        return $fallbacks[$SymbolName]
    }

    return '?'
}

function Test-SCUnicodeSupport {
    <#
    .SYNOPSIS
        Tests if the terminal supports Unicode
    #>
    [CmdletBinding()]
    param()

    $caps = Get-SCTerminalCapabilities
    return $caps.Unicode
}

function Test-SCTrueColorSupport {
    <#
    .SYNOPSIS
        Tests if the terminal supports true color (24-bit)
    #>
    [CmdletBinding()]
    param()

    $caps = Get-SCTerminalCapabilities
    return $caps.TrueColor
}

function Get-SCAdaptiveColor {
    <#
    .SYNOPSIS
        Gets an ANSI color string adaptive to terminal capabilities
    .PARAMETER HexColor
        The hex color code
    .PARAMETER Background
        Use as background color
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$HexColor,

        [Parameter()]
        [switch]$Background
    )

    $caps = if ($script:TerminalCapabilities) {
        $script:TerminalCapabilities
    } else {
        Get-SCTerminalCapabilities
    }

    # Check NO_COLOR
    if ($env:NO_COLOR -or (-not $caps.Color16)) {
        return ''
    }

    if ($caps.TrueColor) {
        $hex = $HexColor.TrimStart('#')
        if ($hex.Length -lt 6) { return '' }
        $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
        $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
        $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)

        if ($Background) {
            return "`e[48;2;${r};${g};${b}m"
        }
        return "`e[38;2;${r};${g};${b}m"
    }
    elseif ($caps.Color256) {
        $colorIndex = ConvertTo-256Color -HexColor $HexColor
        return Get-SCAnsiColor256 -ColorIndex $colorIndex -Background:$Background
    }
    elseif ($caps.Color16) {
        $colorIndex = ConvertTo-16Color -HexColor $HexColor
        return Get-SCAnsiColor16 -ColorIndex $colorIndex -Background:$Background
    }

    return ''
}

function Get-SCAdaptiveSymbol {
    <#
    .SYNOPSIS
        Gets a symbol with automatic fallback based on terminal capabilities
    .PARAMETER Name
        The symbol name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $caps = if ($script:TerminalCapabilities) {
        $script:TerminalCapabilities
    } else {
        Get-SCTerminalCapabilities
    }

    if ($caps.Unicode) {
        $symbol = Get-SCSymbol -Name $Name
        if ($symbol) { return $symbol }
    }

    return Get-SCSymbolFallback -SymbolName $Name
}
