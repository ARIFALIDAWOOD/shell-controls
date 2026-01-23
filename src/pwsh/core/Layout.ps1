<#
.SYNOPSIS
    Layout engine for Shell-Controls
.DESCRIPTION
    Provides layout utilities for text formatting, alignment, overflow handling,
    and responsive breakpoints.
#>

function Format-SCLayout {
    <#
    .SYNOPSIS
        Formats lines with layout constraints
    .PARAMETER Lines
        The lines to format
    .PARAMETER MaxWidth
        Maximum width (0 = terminal width)
    .PARAMETER MinWidth
        Minimum width
    .PARAMETER Padding
        Internal padding
    .PARAMETER Margin
        External margin (spaces before content)
    .PARAMETER Align
        Text alignment: Left, Center, Right
    .PARAMETER Overflow
        Overflow handling: Truncate, Wrap, Ellipsis
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [string[]]$Lines,

        [Parameter()]
        [int]$MaxWidth = 0,

        [Parameter()]
        [int]$MinWidth = 0,

        [Parameter()]
        [int]$Padding = 0,

        [Parameter()]
        [int]$Margin = 0,

        [Parameter()]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Align = 'Left',

        [Parameter()]
        [ValidateSet('Truncate', 'Wrap', 'Ellipsis')]
        [string]$Overflow = 'Ellipsis'
    )

    begin {
        $output = [System.Collections.Generic.List[string]]::new()

        # Determine effective max width
        if ($MaxWidth -le 0) {
            try { $MaxWidth = [Console]::WindowWidth - 1 } catch { $MaxWidth = 80 }
        }

        # Account for margin
        $effectiveMaxWidth = $MaxWidth - ($Margin * 2)
        $contentWidth = $effectiveMaxWidth - ($Padding * 2)

        # Ensure minimum width
        if ($MinWidth -gt 0 -and $contentWidth -lt $MinWidth) {
            $contentWidth = $MinWidth
        }
    }

    process {
        foreach ($line in $Lines) {
            $visibleLength = Get-SCVisibleLength -Text $line
            $marginStr = ' ' * $Margin
            $paddingStr = ' ' * $Padding

            if ($visibleLength -gt $contentWidth) {
                # Handle overflow
                switch ($Overflow) {
                    'Truncate' {
                        $truncated = Get-SCTruncatedText -Text $line -MaxLength $contentWidth
                        $aligned = Format-SCAlignedText -Text $truncated -Width $contentWidth -Align $Align
                        $output.Add("${marginStr}${paddingStr}${aligned}${paddingStr}")
                    }
                    'Ellipsis' {
                        $ellipsisLen = $contentWidth - 3
                        if ($ellipsisLen -gt 0) {
                            $truncated = Get-SCTruncatedText -Text $line -MaxLength $ellipsisLen
                            $truncated = "$truncated..."
                        } else {
                            $truncated = "..."
                        }
                        $aligned = Format-SCAlignedText -Text $truncated -Width $contentWidth -Align $Align
                        $output.Add("${marginStr}${paddingStr}${aligned}${paddingStr}")
                    }
                    'Wrap' {
                        $wrappedLines = Split-SCTextToWidth -Text $line -MaxWidth $contentWidth
                        foreach ($wrapped in $wrappedLines) {
                            $aligned = Format-SCAlignedText -Text $wrapped -Width $contentWidth -Align $Align
                            $output.Add("${marginStr}${paddingStr}${aligned}${paddingStr}")
                        }
                    }
                }
            } else {
                $aligned = Format-SCAlignedText -Text $line -Width $contentWidth -Align $Align
                $output.Add("${marginStr}${paddingStr}${aligned}${paddingStr}")
            }
        }
    }

    end {
        return ,$output.ToArray()
    }
}

function Get-SCVisibleLength {
    <#
    .SYNOPSIS
        Gets the visible character count (strips ANSI codes)
    .PARAMETER Text
        The text to measure
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$Text
    )

    process {
        if ([string]::IsNullOrEmpty($Text)) {
            return 0
        }
        # Remove ANSI escape sequences
        $ansiPattern = '\x1b\[[0-9;]*[a-zA-Z]|\x1b\].*?\x07'
        $cleanText = [regex]::Replace($Text, $ansiPattern, '')
        return $cleanText.Length
    }
}

function Get-SCTruncatedText {
    <#
    .SYNOPSIS
        Truncates text to max visible length, preserving ANSI codes
    .PARAMETER Text
        The text to truncate
    .PARAMETER MaxLength
        Maximum visible characters
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text,

        [Parameter(Mandatory)]
        [int]$MaxLength
    )

    if ([string]::IsNullOrEmpty($Text) -or $MaxLength -le 0) {
        return ''
    }

    $ansiPattern = '\x1b\[[0-9;]*[a-zA-Z]|\x1b\].*?\x07'
    $result = [System.Text.StringBuilder]::new()
    $visibleCount = 0
    $i = 0

    while ($i -lt $Text.Length -and $visibleCount -lt $MaxLength) {
        # Check if we're at an ANSI sequence
        $match = [regex]::Match($Text.Substring($i), "^($ansiPattern)")
        if ($match.Success) {
            $result.Append($match.Value) | Out-Null
            $i += $match.Length
        } else {
            $result.Append($Text[$i]) | Out-Null
            $visibleCount++
            $i++
        }
    }

    # Append reset if we truncated mid-styling
    $result.Append("`e[0m") | Out-Null

    return $result.ToString()
}

function Split-SCTextToWidth {
    <#
    .SYNOPSIS
        Splits text into multiple lines at word boundaries
    .PARAMETER Text
        The text to wrap
    .PARAMETER MaxWidth
        Maximum line width
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text,

        [Parameter(Mandatory)]
        [int]$MaxWidth
    )

    if ([string]::IsNullOrEmpty($Text) -or $MaxWidth -le 0) {
        return @('')
    }

    # Strip ANSI for word wrapping calculation
    $ansiPattern = '\x1b\[[0-9;]*[a-zA-Z]|\x1b\].*?\x07'
    $cleanText = [regex]::Replace($Text, $ansiPattern, '')

    $words = $cleanText -split '\s+'
    $lines = [System.Collections.Generic.List[string]]::new()
    $currentLine = ''

    foreach ($word in $words) {
        if ([string]::IsNullOrWhiteSpace($word)) { continue }

        $testLine = if ($currentLine) { "$currentLine $word" } else { $word }

        if ($testLine.Length -le $MaxWidth) {
            $currentLine = $testLine
        } else {
            if ($currentLine) {
                $lines.Add($currentLine)
            }
            # Handle words longer than max width
            if ($word.Length -gt $MaxWidth) {
                for ($i = 0; $i -lt $word.Length; $i += $MaxWidth) {
                    $chunk = $word.Substring($i, [Math]::Min($MaxWidth, $word.Length - $i))
                    if ($i + $MaxWidth -lt $word.Length) {
                        $lines.Add($chunk)
                    } else {
                        $currentLine = $chunk
                    }
                }
            } else {
                $currentLine = $word
            }
        }
    }

    if ($currentLine) {
        $lines.Add($currentLine)
    }

    if ($lines.Count -eq 0) {
        $lines.Add('')
    }

    return ,$lines.ToArray()
}

function Format-SCAlignedText {
    <#
    .SYNOPSIS
        Aligns text within a specified width
    .PARAMETER Text
        The text to align
    .PARAMETER Width
        The total width
    .PARAMETER Align
        Alignment: Left, Center, Right
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text,

        [Parameter(Mandatory)]
        [int]$Width,

        [Parameter()]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Align = 'Left'
    )

    $visibleLength = Get-SCVisibleLength -Text $Text
    $padAmount = [Math]::Max(0, $Width - $visibleLength)

    switch ($Align) {
        'Left' {
            return $Text + (' ' * $padAmount)
        }
        'Right' {
            return (' ' * $padAmount) + $Text
        }
        'Center' {
            $leftPad = [Math]::Floor($padAmount / 2)
            $rightPad = $padAmount - $leftPad
            return (' ' * $leftPad) + $Text + (' ' * $rightPad)
        }
    }
}

function Get-SCResponsiveBreakpoint {
    <#
    .SYNOPSIS
        Gets the current responsive breakpoint based on terminal width
    .DESCRIPTION
        Returns: xs (< 60), sm (60-99), md (100-139), lg (>= 140)
    #>
    [CmdletBinding()]
    param()

    try { $width = [Console]::WindowWidth } catch { $width = 80 }

    # Get breakpoints from config or use defaults
    $breakpoints = @{ sm = 60; md = 100; lg = 140 }
    if ($script:Config.responsive -and $script:Config.responsive.breakpoints) {
        $breakpoints = $script:Config.responsive.breakpoints
    }

    if ($width -ge $breakpoints.lg) { return 'lg' }
    if ($width -ge $breakpoints.md) { return 'md' }
    if ($width -ge $breakpoints.sm) { return 'sm' }
    return 'xs'
}

function Get-SCResponsiveValue {
    <#
    .SYNOPSIS
        Gets a value based on current breakpoint
    .PARAMETER Values
        Hashtable of breakpoint -> value mappings
    .PARAMETER Default
        Default value if no breakpoint matches
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Values,

        [Parameter()]
        [object]$Default
    )

    $breakpoint = Get-SCResponsiveBreakpoint

    # Try exact match first
    if ($Values.ContainsKey($breakpoint)) {
        return $Values[$breakpoint]
    }

    # Fall back to smaller breakpoints
    $order = @('lg', 'md', 'sm', 'xs')
    $startIndex = $order.IndexOf($breakpoint)

    for ($i = $startIndex; $i -lt $order.Count; $i++) {
        if ($Values.ContainsKey($order[$i])) {
            return $Values[$order[$i]]
        }
    }

    return $Default
}

function Get-SCTerminalWidth {
    <#
    .SYNOPSIS
        Gets the current terminal width with fallback
    #>
    [CmdletBinding()]
    param()

    try {
        return [Console]::WindowWidth
    } catch {
        return 80
    }
}

function Get-SCTerminalHeight {
    <#
    .SYNOPSIS
        Gets the current terminal height with fallback
    #>
    [CmdletBinding()]
    param()

    try {
        return [Console]::WindowHeight
    } catch {
        return 24
    }
}

function New-SCLayoutConfig {
    <#
    .SYNOPSIS
        Creates a layout configuration object
    .PARAMETER MaxWidth
        Maximum width (0 = terminal width)
    .PARAMETER MinWidth
        Minimum width
    .PARAMETER Padding
        Internal padding
    .PARAMETER Margin
        External margin
    .PARAMETER Align
        Text alignment
    .PARAMETER Overflow
        Overflow handling
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$MaxWidth = 0,

        [Parameter()]
        [int]$MinWidth = 20,

        [Parameter()]
        [int]$Padding = 1,

        [Parameter()]
        [int]$Margin = 0,

        [Parameter()]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Align = 'Left',

        [Parameter()]
        [ValidateSet('Truncate', 'Wrap', 'Ellipsis')]
        [string]$Overflow = 'Ellipsis'
    )

    return @{
        MaxWidth = $MaxWidth
        MinWidth = $MinWidth
        Padding  = $Padding
        Margin   = $Margin
        Align    = $Align
        Overflow = $Overflow
    }
}

function Get-SCDefaultLayoutConfig {
    <#
    .SYNOPSIS
        Gets the default layout configuration from config
    #>
    [CmdletBinding()]
    param()

    $defaults = @{
        MaxWidth = 0
        MinWidth = 20
        Padding  = 1
        Margin   = 0
        Align    = 'Left'
        Overflow = 'Ellipsis'
    }

    if ($script:Config.defaults -and $script:Config.defaults.layout) {
        $configLayout = $script:Config.defaults.layout
        if ($null -ne $configLayout.maxWidth) { $defaults.MaxWidth = $configLayout.maxWidth }
        if ($null -ne $configLayout.minWidth) { $defaults.MinWidth = $configLayout.minWidth }
        if ($null -ne $configLayout.padding) { $defaults.Padding = $configLayout.padding }
        if ($null -ne $configLayout.margin) { $defaults.Margin = $configLayout.margin }
        if ($configLayout.align) { $defaults.Align = $configLayout.align }
        if ($configLayout.overflow) { $defaults.Overflow = $configLayout.overflow }
    }

    return $defaults
}

function Format-SCColumns {
    <#
    .SYNOPSIS
        Formats content into multiple columns
    .PARAMETER Items
        The items to display in columns
    .PARAMETER Columns
        Number of columns (0 = auto)
    .PARAMETER MinColumnWidth
        Minimum width per column
    .PARAMETER Gap
        Gap between columns
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Items,

        [Parameter()]
        [int]$Columns = 0,

        [Parameter()]
        [int]$MinColumnWidth = 20,

        [Parameter()]
        [int]$Gap = 2
    )

    $termWidth = Get-SCTerminalWidth

    # Auto-calculate columns if not specified
    if ($Columns -le 0) {
        $Columns = [Math]::Max(1, [Math]::Floor($termWidth / ($MinColumnWidth + $Gap)))
    }

    $columnWidth = [Math]::Floor(($termWidth - ($Gap * ($Columns - 1))) / $Columns)
    $rows = [Math]::Ceiling($Items.Count / $Columns)
    $output = [System.Collections.Generic.List[string]]::new()

    for ($row = 0; $row -lt $rows; $row++) {
        $rowText = ''
        for ($col = 0; $col -lt $Columns; $col++) {
            $index = $row + ($col * $rows)
            if ($index -lt $Items.Count) {
                $item = $Items[$index]
                $visLen = Get-SCVisibleLength -Text $item
                if ($visLen -gt $columnWidth) {
                    $item = Get-SCTruncatedText -Text $item -MaxLength ($columnWidth - 3)
                    $item = "$item..."
                }
                $padded = Format-SCAlignedText -Text $item -Width $columnWidth -Align 'Left'
                $rowText += $padded
                if ($col -lt $Columns - 1) {
                    $rowText += ' ' * $Gap
                }
            }
        }
        $output.Add($rowText.TrimEnd())
    }

    return ,$output.ToArray()
}
