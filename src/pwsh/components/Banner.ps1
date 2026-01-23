<#
.SYNOPSIS
    ASCII banner and logo components
#>

function Show-SCBanner {
    <#
    .SYNOPSIS
        Displays an ASCII art banner
    .PARAMETER Text
        The text to display as banner
    .PARAMETER Font
        Font style: standard, slant, small, block, mini
    .PARAMETER GradientColors
        Colors for gradient effect
    .PARAMETER Subtitle
        Subtitle text
    .PARAMETER Version
        Version string
    .PARAMETER Centered
        Center the banner
    .PARAMETER Margin
        Left margin (spaces)
    .PARAMETER MaxWidth
        Maximum width constraint
    .PARAMETER PassThru
        Return output as string array instead of writing to console
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Text,

        [Parameter()]
        [ValidateSet('standard', 'slant', 'small', 'block', 'mini')]
        [string]$Font = 'standard',

        [Parameter()]
        [string[]]$GradientColors,

        [Parameter()]
        [string]$Subtitle,

        [Parameter()]
        [string]$Version,

        [Parameter()]
        [switch]$Centered,

        [Parameter()]
        [int]$Margin = 2,

        [Parameter()]
        [int]$MaxWidth = 0,

        [Parameter()]
        [switch]$PassThru
    )

    $output = [System.Collections.Generic.List[string]]::new()

    $fonts = @{
        'block' = @{
            height = 3
            defWidth = 3
            chars = @{
                'A'=@('███','█▀█','▀ ▀'); 'B'=@('██▄','█▄█','▀▀▀'); 'C'=@('█▀▀','█  ','▀▀▀'); 'D'=@('██▄','█ █','▀▀▀')
                'E'=@('█▀▀','█▀▀','▀▀▀'); 'F'=@('█▀▀','█▀ ','▀  '); 'G'=@('█▀▀','█ █','▀▀▀'); 'H'=@('█ █','███','▀ ▀')
                'I'=@('█','█','▀'); 'J'=@(' █ ',' █ ','▀▀ '); 'K'=@('█ █','██ ','▀ ▀'); 'L'=@('█  ','█  ','▀▀▀')
                'M'=@('█▀█','█ █','▀ ▀'); 'N'=@('█▀█','█ █','▀ ▀'); 'O'=@('█▀█','█ █','▀▀▀'); 'P'=@('█▀▄','██▀','▀  ')
                'Q'=@('█▀█','█ █','▀▀█'); 'R'=@('█▀▄','██▀','▀ ▀'); 'S'=@('▀█▀',' █ ','▀▀▀'); 'T'=@('▀█▀',' █ ',' ▀ ')
                'U'=@('█ █','█ █','▀▀▀'); 'V'=@('█ █','█ █',' ▀ '); 'W'=@('█ █','█▄█','▀ ▀'); 'X'=@('█ █',' █ ','▀ ▀')
                'Y'=@('█ █','▀█▀',' ▀ '); 'Z'=@('▀▀█',' █ ','▀▀▀'); ' '=@('   ','   ','   ')
                '-'=@('   ','▀▀▀','   '); '.'=@('   ','   ',' ▀ '); '!'=@(' █ ',' █ ',' ▀ ')
                '0'=@('█▀█','█ █','▀▀▀'); '1'=@(' █ ',' █ ',' ▀ '); '2'=@('▀▀█','█▀▀','▀▀▀'); '3'=@('▀▀█','▀▀█','▀▀▀')
                '4'=@('█ █','▀▀█','  ▀'); '5'=@('█▀▀','▀▀█','▀▀▀'); '6'=@('█▀▀','█▀█','▀▀▀'); '7'=@('▀▀█','  █','  ▀')
                '8'=@('█▀█','█▀█','▀▀▀'); '9'=@('█▀█','▀▀█','▀▀▀')
            }
        }
        'small' = @{
            height = 4
            defWidth = 4
            chars = @{
                'A'=@(' █▀█ ',' █▀█ ',' ▀ ▀ ','     '); 'B'=@(' █▀▄ ',' █▀▄ ',' ▀▀  ','     ')
                'C'=@(' █▀▀ ',' █   ',' ▀▀▀ ','     '); 'D'=@(' █▀▄ ',' █ █ ',' ▀▀  ','     ')
                'E'=@(' █▀▀ ',' █▀▀ ',' ▀▀▀ ','     '); 'F'=@(' █▀▀ ',' █▀▀ ',' ▀   ','     ')
                'G'=@(' █▀▀ ',' █ █ ',' ▀▀▀ ','     '); 'H'=@(' █ █ ',' █▀█ ',' ▀ ▀ ','     ')
                'I'=@('  █  ','  █  ','  ▀  ','     '); 'L'=@(' █   ',' █   ',' ▀▀▀ ','     ')
                'M'=@(' █▀█ ',' █ █ ',' ▀ ▀ ','     '); 'N'=@(' █▀█ ',' █ █ ',' ▀ ▀ ','     ')
                'O'=@(' █▀█ ',' █ █ ',' ▀▀▀ ','     '); 'P'=@(' █▀▄ ',' █▀  ',' ▀   ','     ')
                'R'=@(' █▀▄ ',' █▀▄ ',' ▀ ▀ ','     '); 'S'=@(' ▀█▀ ','  █  ',' ▀▀▀ ','     ')
                'T'=@(' ▀█▀ ','  █  ','  ▀  ','     '); 'U'=@(' █ █ ',' █ █ ',' ▀▀▀ ','     ')
                ' '=@('  ','  ','  ','  ')
            }
        }
        'mini' = @{
            height = 2
            defWidth = 2
            chars = @{
                'A'=@('█▀','▀▀'); 'B'=@('█▀','▀▀'); 'C'=@('█▀','▀▀'); 'D'=@('█▀','▀▀'); 'E'=@('█▀','▀▀')
                'F'=@('█▀','▀ '); 'G'=@('█▀','▀█'); 'H'=@('█▀','▀▀'); 'I'=@('█','▀'); 'L'=@('█ ','▀▀')
                'M'=@('█▀█','▀ ▀'); 'N'=@('█▀','▀▀'); 'O'=@('█▀','▀▀'); 'P'=@('█▀','▀ '); 'R'=@('█▀','▀▀')
                'S'=@('▀█','▀▀'); 'T'=@('▀█','▀ '); 'U'=@('█ ','▀▀'); 'Y'=@('█ ',' ▀'); ' '=@('  ','  ')
            }
        }
    }

    if (-not $fonts.ContainsKey($Font)) { $Font = 'block' }
    $fontDef = $fonts[$Font]
    $defW = if ($fontDef.defWidth) { $fontDef.defWidth } else { 4 }

    $lines = @()
    for ($i = 0; $i -lt $fontDef.height; $i++) {
        $line = ""
        foreach ($c in $Text.ToUpper().ToCharArray()) {
            $k = $c.ToString()
            $charArt = $fontDef.chars[$k]
            if ($charArt) { $line += $charArt[$i] }
            else { $line += " " * $defW }
        }
        $lines += $line
    }

    if (-not $GradientColors) { $GradientColors = $script:Theme.gradients.rainbow }
    if (-not $GradientColors -or $GradientColors.Count -eq 0) { $GradientColors = @("#89b4fa", "#f5c2e7") }

    $output.Add('')
    try { $termWidth = [Console]::WindowWidth } catch { $termWidth = 80 }

    # Check if colors are enabled
    $colorsEnabled = Test-SCColorsEnabled
    $marginStr = ' ' * $Margin

    foreach ($line in $lines) {
        if ($Centered) {
            $padding = [Math]::Max(0, [Math]::Floor(($termWidth - $line.Length) / 2))
            $line = (' ' * $padding) + $line
        } else {
            $line = "${marginStr}$line"
        }

        if ($colorsEnabled) {
            # Build gradient text
            $chars = $line.ToCharArray()
            $colorCount = $GradientColors.Count
            $gradientLine = ""

            for ($i = 0; $i -lt $chars.Count; $i++) {
                $colorIndex = [Math]::Floor(($i / [Math]::Max(1, $chars.Count)) * $colorCount)
                $colorIndex = [Math]::Min($colorIndex, $colorCount - 1)
                $color = $GradientColors[$colorIndex]
                $ansi = ConvertTo-AnsiColor -HexColor $color
                $gradientLine += "${ansi}$($chars[$i])"
            }
            $gradientLine += Get-AnsiReset
            $output.Add($gradientLine)
        } else {
            $output.Add($line)
        }
    }

    if ($Subtitle -or $Version) {
        $info = if ($Subtitle) { $Subtitle } else { "" }
        if ($Version) { $info += "  v$Version" }
        if ($Centered) {
            $padding = [Math]::Max(0, [Math]::Floor(($termWidth - $info.Length) / 2))
            $info = (' ' * $padding) + $info
        } else {
            $info = "${marginStr}$info"
        }
        $output.Add('')
        if ($colorsEnabled) {
            $mutedColor = Get-SCColor -Name "muted"
            $mutedAnsi = ConvertTo-AnsiColor -HexColor $mutedColor
            $reset = Get-AnsiReset
            $output.Add("${mutedAnsi}${info}${reset}")
        } else {
            $output.Add($info)
        }
    }
    $output.Add('')

    # Output handling
    if ($PassThru) {
        return $output.ToArray()
    }

    foreach ($line in $output) {
        [Console]::WriteLine($line)
    }
}
