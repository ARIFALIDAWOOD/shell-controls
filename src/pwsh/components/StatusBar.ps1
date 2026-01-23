<#
.SYNOPSIS
    Status bar component for Shell-Controls
#>

function Show-SCStatusBar {
    <#
    .SYNOPSIS
        Displays a status bar with left, center, and right sections
    .PARAMETER Left
        Left-aligned content
    .PARAMETER Center
        Center-aligned content
    .PARAMETER Right
        Right-aligned content
    .PARAMETER Color
        Text color (hex or theme color name)
    .PARAMETER BackgroundColor
        Background color (hex or theme color name)
    .PARAMETER PassThru
        Return output as string instead of writing to console
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Left = "",

        [Parameter()]
        [string]$Center = "",

        [Parameter()]
        [string]$Right = "",

        [Parameter()]
        [string]$Color,

        [Parameter()]
        [string]$BackgroundColor,

        [Parameter()]
        [switch]$PassThru
    )

    if (-not $Color) { $Color = Get-SCColor -Name "muted" }

    try { $w = [Console]::WindowWidth - 1 } catch { $w = 78 }

    $colorsEnabled = Test-SCColorsEnabled
    $colorAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $Color } else { '' }
    $bgAnsi = ''
    if ($colorsEnabled -and $BackgroundColor) {
        if ($BackgroundColor -notmatch '^#') {
            $BackgroundColor = Get-SCColor -Name $BackgroundColor
        }
        $bgAnsi = ConvertTo-AnsiBgColor -HexColor $BackgroundColor
    }
    $reset = if ($colorsEnabled) { Get-AnsiReset } else { '' }

    $half = [Math]::Floor($w / 2)
    $leftLen = [Math]::Min($Left.Length, $half - 2)
    $rightLen = [Math]::Min($Right.Length, $half - 2)

    $leftStr = if ($Left.Length -gt $leftLen) { $Left.Substring(0, $leftLen) } else { $Left }
    $leftStr = $leftStr.PadRight($half - 1)

    $rightStr = if ($Right.Length -gt $rightLen) { $Right.Substring(0, $rightLen) } else { $Right }
    $rightStr = $rightStr.PadLeft($half - 1)

    $centerMax = $w - $leftStr.Length - $rightStr.Length - 2
    $centerStr = if ($Center.Length -gt $centerMax) { $Center.Substring(0, $centerMax) } else { $Center }

    $line = "${colorAnsi}${bgAnsi}${leftStr}${centerStr}${rightStr}${reset}"

    if ($PassThru) {
        return $line
    }

    [Console]::WriteLine($line)
}
