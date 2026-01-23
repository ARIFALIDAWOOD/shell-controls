<#
.SYNOPSIS
    Output mode management for Shell-Controls
.DESCRIPTION
    Provides output mode control for CI/scripting environments.
    Supports normal, plain, json, and quiet modes.
    Respects NO_COLOR and CI environment variables.
#>

function Get-SCOutputMode {
    <#
    .SYNOPSIS
        Gets the current output mode
    .DESCRIPTION
        Returns: normal, plain, json, quiet
        Checks environment variables:
        - $env:SHELL_CONTROLS_OUTPUT = plain|json|quiet
        - $env:NO_COLOR = any value disables colors (implies plain)
        - $env:CI = true forces plain mode
    #>
    [CmdletBinding()]
    param()

    # Check for explicit output mode setting
    if ($script:OutputMode.CurrentMode) {
        return $script:OutputMode.CurrentMode
    }

    # Check environment variables
    if ($env:SHELL_CONTROLS_OUTPUT) {
        $mode = $env:SHELL_CONTROLS_OUTPUT.ToLower()
        if ($mode -in @('normal', 'plain', 'json', 'quiet')) {
            return $mode
        }
    }

    # CI environment implies plain mode
    if ($env:CI -eq 'true' -or $env:CI -eq '1') {
        return 'plain'
    }

    # NO_COLOR implies plain mode (no colors but still output)
    if ($env:NO_COLOR) {
        return 'plain'
    }

    # Check for non-interactive sessions
    if (-not [Environment]::UserInteractive) {
        return 'plain'
    }

    return 'normal'
}

function Set-SCOutputMode {
    <#
    .SYNOPSIS
        Sets the output mode
    .PARAMETER Mode
        The output mode to set: normal, plain, json, quiet
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('normal', 'plain', 'json', 'quiet')]
        [string]$Mode
    )

    $script:OutputMode.CurrentMode = $Mode
    Write-Verbose "Output mode set to: $Mode"
}

function Reset-SCOutputMode {
    <#
    .SYNOPSIS
        Resets output mode to auto-detect from environment
    #>
    [CmdletBinding()]
    param()

    $script:OutputMode.CurrentMode = $null
    Write-Verbose "Output mode reset to auto-detect"
}

function Test-SCOutputAllowed {
    <#
    .SYNOPSIS
        Tests if output at a given level is allowed
    .PARAMETER Level
        The output level: info, warning, error, debug
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('info', 'warning', 'error', 'debug')]
        [string]$Level
    )

    $mode = Get-SCOutputMode

    switch ($mode) {
        'quiet' {
            # Only errors in quiet mode
            return $Level -eq 'error'
        }
        'json' {
            # All levels allowed, will be converted to JSON
            return $true
        }
        'plain' {
            # All levels allowed
            return $true
        }
        'normal' {
            return $true
        }
        default {
            return $true
        }
    }
}

function Test-SCColorsEnabled {
    <#
    .SYNOPSIS
        Tests if colors should be used in output
    #>
    [CmdletBinding()]
    param()

    # Check NO_COLOR standard
    if ($env:NO_COLOR) {
        return $false
    }

    $mode = Get-SCOutputMode

    switch ($mode) {
        'plain' { return $false }
        'json'  { return $false }
        'quiet' { return $false }
        default { return $true }
    }
}

function Test-SCInteractiveMode {
    <#
    .SYNOPSIS
        Tests if interactive mode is available
    .DESCRIPTION
        Returns false in plain, json, quiet modes or when CI=true
    #>
    [CmdletBinding()]
    param()

    $mode = Get-SCOutputMode

    if ($mode -ne 'normal') {
        return $false
    }

    if ($env:CI -eq 'true' -or $env:CI -eq '1') {
        return $false
    }

    if (-not [Environment]::UserInteractive) {
        return $false
    }

    return $true
}

function ConvertTo-SCJsonOutput {
    <#
    .SYNOPSIS
        Converts component output to JSON format
    .PARAMETER Data
        The data to convert
    .PARAMETER Type
        The type of component output
    .PARAMETER Metadata
        Additional metadata to include
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Data,

        [Parameter()]
        [string]$Type = 'output',

        [Parameter()]
        [hashtable]$Metadata = @{}
    )

    $output = @{
        type      = $Type
        timestamp = (Get-Date).ToString('o')
        data      = $Data
    }

    if ($Metadata.Count -gt 0) {
        $output.metadata = $Metadata
    }

    return $output | ConvertTo-Json -Depth 10 -Compress
}

function Write-SCOutput {
    <#
    .SYNOPSIS
        Writes output respecting the current output mode
    .PARAMETER Text
        The text to output
    .PARAMETER Color
        The color (only used in normal mode)
    .PARAMETER Level
        The output level
    .PARAMETER Type
        The output type for JSON mode
    .PARAMETER Data
        Structured data for JSON mode
    .PARAMETER NoNewline
        Don't add newline
    .PARAMETER PassThru
        Return the output instead of writing
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Text = '',

        [Parameter()]
        [string]$Color,

        [Parameter()]
        [ValidateSet('info', 'warning', 'error', 'debug')]
        [string]$Level = 'info',

        [Parameter()]
        [string]$Type = 'text',

        [Parameter()]
        [object]$Data,

        [Parameter()]
        [switch]$NoNewline,

        [Parameter()]
        [switch]$PassThru
    )

    if (-not (Test-SCOutputAllowed -Level $Level)) {
        return
    }

    $mode = Get-SCOutputMode

    switch ($mode) {
        'json' {
            $jsonData = if ($Data) { $Data } else { $Text }
            $output = ConvertTo-SCJsonOutput -Data $jsonData -Type $Type -Metadata @{ level = $Level }

            if ($PassThru) {
                return $output
            }
            [Console]::WriteLine($output)
        }
        'quiet' {
            # Only output errors in quiet mode
            if ($Level -eq 'error') {
                if ($PassThru) {
                    return $Text
                }
                [Console]::Error.WriteLine($Text)
            }
        }
        'plain' {
            # Plain text without colors
            $plainText = Remove-SCAnsiCodes -Text $Text

            if ($PassThru) {
                return $plainText
            }

            if ($NoNewline) {
                [Console]::Write($plainText)
            } else {
                [Console]::WriteLine($plainText)
            }
        }
        default {
            # Normal mode with colors
            if ($PassThru) {
                return $Text
            }

            $output = $Text
            if ($Color -and (Test-SCColorsEnabled)) {
                $ansi = ConvertTo-AnsiColor -HexColor $Color
                $reset = Get-AnsiReset
                $output = "${ansi}${Text}${reset}"
            }

            if ($NoNewline) {
                [Console]::Write($output)
            } else {
                [Console]::WriteLine($output)
            }
        }
    }
}

function Remove-SCAnsiCodes {
    <#
    .SYNOPSIS
        Removes ANSI escape codes from text
    .PARAMETER Text
        The text to clean
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$Text
    )

    process {
        if ([string]::IsNullOrEmpty($Text)) {
            return $Text
        }
        # Pattern matches ANSI escape sequences
        $ansiPattern = '\x1b\[[0-9;]*[a-zA-Z]|\x1b\].*?\x07'
        return [regex]::Replace($Text, $ansiPattern, '')
    }
}

function Get-SCOutputModeInfo {
    <#
    .SYNOPSIS
        Gets detailed information about current output settings
    #>
    [CmdletBinding()]
    param()

    return @{
        CurrentMode       = Get-SCOutputMode
        ColorsEnabled     = Test-SCColorsEnabled
        InteractiveMode   = Test-SCInteractiveMode
        EnvironmentVars   = @{
            SHELL_CONTROLS_OUTPUT = $env:SHELL_CONTROLS_OUTPUT
            NO_COLOR              = $env:NO_COLOR
            CI                    = $env:CI
        }
        UserInteractive   = [Environment]::UserInteractive
    }
}

function Format-SCPlainOutput {
    <#
    .SYNOPSIS
        Formats output for plain mode (strips ANSI, simplifies structure)
    .PARAMETER Lines
        The lines to format
    .PARAMETER Title
        Optional title to prepend
    .PARAMETER Border
        Include ASCII border
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Lines,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [switch]$Border
    )

    $output = [System.Collections.Generic.List[string]]::new()

    if ($Title) {
        $output.Add("=== $Title ===")
    }

    if ($Border) {
        $maxLen = ($Lines | ForEach-Object { (Remove-SCAnsiCodes -Text $_).Length } | Measure-Object -Maximum).Maximum
        $borderLine = '+' + ('-' * ($maxLen + 2)) + '+'

        $output.Add($borderLine)
        foreach ($line in $Lines) {
            $cleanLine = Remove-SCAnsiCodes -Text $line
            $paddedLine = $cleanLine.PadRight($maxLen)
            $output.Add("| $paddedLine |")
        }
        $output.Add($borderLine)
    } else {
        foreach ($line in $Lines) {
            $output.Add((Remove-SCAnsiCodes -Text $line))
        }
    }

    return $output.ToArray()
}
