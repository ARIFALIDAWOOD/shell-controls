<#
.SYNOPSIS
    Card component for Shell-Controls
.DESCRIPTION
    Displays content in a card-style container with header, body, and footer sections.
#>

function Show-SCCard {
    <#
    .SYNOPSIS
        Displays a card with optional header and footer
    .PARAMETER Title
        Card header/title
    .PARAMETER Body
        Card body content - can be string array or scriptblock
    .PARAMETER Footer
        Card footer content
    .PARAMETER Style
        Border style: rounded, heavy, double, simple, ascii, none
    .PARAMETER BorderColor
        Border color (hex or theme color name)
    .PARAMETER TitleColor
        Title color (hex or theme color name)
    .PARAMETER FooterColor
        Footer color (hex or theme color name)
    .PARAMETER Width
        Fixed width (0 = auto)
    .PARAMETER MaxWidth
        Maximum width constraint
    .PARAMETER MinWidth
        Minimum width constraint
    .PARAMETER Margin
        Left margin (spaces)
    .PARAMETER Padding
        Internal padding
    .PARAMETER Align
        Content alignment: Left, Center, Right
    .PARAMETER PassThru
        Return output as string array instead of writing to console
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Title,

        [Parameter(Position = 0)]
        [object]$Body,

        [Parameter()]
        [string]$Footer,

        [Parameter()]
        [ValidateSet('rounded', 'heavy', 'double', 'simple', 'ascii', 'none')]
        [string]$Style = 'rounded',

        [Parameter()]
        [string]$BorderColor,

        [Parameter()]
        [string]$TitleColor,

        [Parameter()]
        [string]$FooterColor,

        [Parameter()]
        [int]$Width = 0,

        [Parameter()]
        [int]$MaxWidth = 0,

        [Parameter()]
        [int]$MinWidth = 40,

        [Parameter()]
        [int]$Margin = 2,

        [Parameter()]
        [int]$Padding = 1,

        [Parameter()]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Align = 'Left',

        [Parameter()]
        [switch]$PassThru
    )

    $output = [System.Collections.Generic.List[string]]::new()

    # Get body content
    $bodyLines = @()
    if ($Body -is [scriptblock]) {
        # Execute scriptblock and capture output
        $capturedOutput = & $Body
        if ($capturedOutput) {
            if ($capturedOutput -is [array]) {
                $bodyLines = $capturedOutput | ForEach-Object { $_.ToString() }
            } else {
                $bodyLines = @($capturedOutput.ToString())
            }
        }
    } elseif ($Body -is [array]) {
        $bodyLines = $Body | ForEach-Object { $_.ToString() }
    } elseif ($Body) {
        $bodyLines = @($Body.ToString())
    }

    # Get border characters
    $box = switch ($Style) {
        'rounded' { Get-SCSymbol -Name "boxRounded" }
        'heavy'   { Get-SCSymbol -Name "boxHeavy" }
        'double'  { Get-SCSymbol -Name "boxDouble" }
        'simple'  { Get-SCSymbol -Name "boxLight" }
        'ascii'   { Get-SCBorder -Style 'ascii' }
        'none'    { Get-SCBorder -Style 'none' }
        default   { Get-SCSymbol -Name "boxRounded" }
    }
    if (-not $box -or $box -isnot [hashtable]) {
        $box = @{ topLeft = "╭"; topRight = "╮"; bottomLeft = "╰"; bottomRight = "╯"; horizontal = "─"; vertical = "│" }
    }

    # Get colors
    if (-not $BorderColor) { $BorderColor = Get-SCColor -Name "border" }
    if (-not $TitleColor) { $TitleColor = Get-SCColor -Name "primary" }
    if (-not $FooterColor) { $FooterColor = Get-SCColor -Name "muted" }

    # Calculate width
    if ($Width -eq 0) {
        $maxContentWidth = 0
        foreach ($line in $bodyLines) {
            $len = Get-SCVisibleLength -Text $line
            if ($len -gt $maxContentWidth) { $maxContentWidth = $len }
        }
        if ($Title) {
            $titleLen = $Title.Length
            if ($titleLen -gt $maxContentWidth) { $maxContentWidth = $titleLen }
        }
        if ($Footer) {
            $footerLen = $Footer.Length
            if ($footerLen -gt $maxContentWidth) { $maxContentWidth = $footerLen }
        }
        $Width = [Math]::Max($maxContentWidth + ($Padding * 2) + 2, $MinWidth)
    }

    # Apply max width constraint
    if ($MaxWidth -gt 0 -and $Width -gt $MaxWidth) {
        $Width = $MaxWidth
    }

    $innerWidth = $Width - 2
    $marginStr = ' ' * $Margin

    # Color setup
    $colorsEnabled = Test-SCColorsEnabled
    $borderAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $BorderColor } else { '' }
    $titleAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $TitleColor } else { '' }
    $footerAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $FooterColor } else { '' }
    $reset = if ($colorsEnabled) { Get-AnsiReset } else { '' }
    $bold = if ($colorsEnabled) { "`e[1m" } else { '' }

    # Top border with title
    if ($Title) {
        $titleDisplay = " $Title "
        $titlePadding = 2
        $leftLine = $box['horizontal'] * $titlePadding
        $rightLine = $box['horizontal'] * [Math]::Max(0, $innerWidth - $titlePadding - $titleDisplay.Length)
        $output.Add("${marginStr}${borderAnsi}$($box['topLeft'])${leftLine}${reset}${titleAnsi}${bold}${titleDisplay}${reset}${borderAnsi}${rightLine}$($box['topRight'])${reset}")
    } else {
        $output.Add("${marginStr}${borderAnsi}$($box['topLeft'])$($box['horizontal'] * $innerWidth)$($box['topRight'])${reset}")
    }

    # Top padding
    for ($i = 0; $i -lt $Padding; $i++) {
        $output.Add("${marginStr}${borderAnsi}$($box['vertical'])${reset}$(' ' * $innerWidth)${borderAnsi}$($box['vertical'])${reset}")
    }

    # Body content
    foreach ($line in $bodyLines) {
        $visLen = Get-SCVisibleLength -Text $line
        $contentWidth = $innerWidth - ($Padding * 2)

        if ($visLen -gt $contentWidth) {
            $line = Get-SCTruncatedText -Text $line -MaxLength ($contentWidth - 3)
            $line = "$line..."
            $visLen = Get-SCVisibleLength -Text $line
        }

        $padAmount = $contentWidth - $visLen
        $formattedLine = switch ($Align) {
            'Left'   { (' ' * $Padding) + $line + (' ' * ($padAmount + $Padding)) }
            'Right'  { (' ' * ($Padding + $padAmount)) + $line + (' ' * $Padding) }
            'Center' {
                $leftPad = [Math]::Floor($padAmount / 2)
                $rightPad = $padAmount - $leftPad
                (' ' * ($Padding + $leftPad)) + $line + (' ' * ($rightPad + $Padding))
            }
        }

        $output.Add("${marginStr}${borderAnsi}$($box['vertical'])${reset}${formattedLine}${borderAnsi}$($box['vertical'])${reset}")
    }

    # Bottom padding
    for ($i = 0; $i -lt $Padding; $i++) {
        $output.Add("${marginStr}${borderAnsi}$($box['vertical'])${reset}$(' ' * $innerWidth)${borderAnsi}$($box['vertical'])${reset}")
    }

    # Footer
    if ($Footer) {
        # Separator before footer
        $output.Add("${marginStr}${borderAnsi}$($box['leftT'] ?? '├')$($box['horizontal'] * $innerWidth)$($box['rightT'] ?? '┤')${reset}")

        $footerPadded = (' ' * $Padding) + $Footer
        $footerLen = Get-SCVisibleLength -Text $footerPadded
        if ($footerLen -gt $innerWidth) {
            $footerPadded = Get-SCTruncatedText -Text $footerPadded -MaxLength ($innerWidth - 3)
            $footerPadded = "$footerPadded..."
            $footerLen = Get-SCVisibleLength -Text $footerPadded
        }
        $footerRightPad = ' ' * [Math]::Max(0, $innerWidth - $footerLen)
        $output.Add("${marginStr}${borderAnsi}$($box['vertical'])${reset}${footerAnsi}${footerPadded}${reset}${footerRightPad}${borderAnsi}$($box['vertical'])${reset}")
    }

    # Bottom border
    $output.Add("${marginStr}${borderAnsi}$($box['bottomLeft'])$($box['horizontal'] * $innerWidth)$($box['bottomRight'])${reset}")

    # Output handling
    if ($PassThru) {
        return $output.ToArray()
    }

    foreach ($line in $output) {
        [Console]::WriteLine($line)
    }
}
