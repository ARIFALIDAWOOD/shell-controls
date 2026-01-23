<#
.SYNOPSIS
    Core UI output functions for Shell-Controls
#>

function Write-SCText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$Text,

        [Parameter()]
        [string]$Color,

        [Parameter()]
        [string]$BackgroundColor,

        [Parameter()]
        [switch]$Bold,

        [Parameter()]
        [switch]$Italic,

        [Parameter()]
        [switch]$Underline,

        [Parameter()]
        [switch]$NoNewline
    )

    begin {
        $reset = Get-AnsiReset
    }

    process {
        $ansiSequence = ""

        if ($Color -and $Color -notmatch '^#') {
            $Color = Get-SCColor -Name $Color -ErrorAction SilentlyContinue
            if (-not $Color) { $Color = $script:Theme.colors['text'] }
        }

        if ($Color) {
            $ansiSequence += ConvertTo-AnsiColor -HexColor $Color
        }

        if ($BackgroundColor) {
            if ($BackgroundColor -notmatch '^#') {
                $BackgroundColor = Get-SCColor -Name $BackgroundColor
            }
            $ansiSequence += ConvertTo-AnsiBgColor -HexColor $BackgroundColor
        }

        if ($Bold) { $ansiSequence += "`e[1m" }
        if ($Italic) { $ansiSequence += "`e[3m" }
        if ($Underline) { $ansiSequence += "`e[4m" }

        $output = "${ansiSequence}${Text}${reset}"

        if ($NoNewline) {
            [Console]::Write($output)
        } else {
            [Console]::WriteLine($output)
        }
    }
}

function Write-SCLine {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Character,

        [Parameter()]
        [string]$Color,

        [Parameter()]
        [int]$Width
    )

    if (-not $Character) {
        $box = Get-SCSymbol -Name "boxRounded"
        $Character = if ($box -and $box['horizontal']) { $box['horizontal'] } else { "─" }
    }

    if (-not $Color) {
        $Color = Get-SCColor -Name "border"
    }

    if (-not $Width -or $Width -le 0) {
        try { $Width = [Console]::WindowWidth - 1 } catch { $Width = 78 }
    }

    $line = $Character * [Math]::Max(1, $Width)
    Write-SCText -Text $line -Color $Color
}

function Write-SCHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Text,

        [Parameter()]
        [string]$Icon,

        [Parameter()]
        [string]$Color,

        [Parameter()]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Align = 'Left',

        [Parameter()]
        [switch]$WithLine
    )

    if (-not $Color) {
        $Color = Get-SCColor -Name "primary"
    }

    if ($Icon) {
        $Text = "$Icon  $Text"
    }

    try { $termWidth = [Console]::WindowWidth - 1 } catch { $termWidth = 78 }

    switch ($Align) {
        'Center' {
            $padding = [Math]::Max(0, [Math]::Floor(($termWidth - $Text.Length) / 2))
            $Text = (' ' * $padding) + $Text
        }
        'Right' {
            $padding = [Math]::Max(0, $termWidth - $Text.Length)
            $Text = (' ' * $padding) + $Text
        }
    }

    Write-SCText ""
    Write-SCText -Text $Text -Color $Color -Bold

    if ($WithLine) {
        Write-SCLine -Color $Color
    }

    Write-SCText ""
}

function Write-SCSuccess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message,

        [Parameter()]
        [switch]$NoIcon
    )

    $icon = if ($NoIcon) { "" } else { "$(Get-SCSymbol -Name 'check') " }
    Write-SCText -Text "${icon}${Message}" -Color (Get-SCColor -Name "success")
}

function Write-SCError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message,

        [Parameter()]
        [switch]$NoIcon
    )

    $icon = if ($NoIcon) { "" } else { "$(Get-SCSymbol -Name 'cross') " }
    Write-SCText -Text "${icon}${Message}" -Color (Get-SCColor -Name "error")
}

function Write-SCWarning {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message,

        [Parameter()]
        [switch]$NoIcon
    )

    $icon = if ($NoIcon) { "" } else { "$(Get-SCSymbol -Name 'warning') " }
    Write-SCText -Text "${icon}${Message}" -Color (Get-SCColor -Name "warning")
}

function Write-SCInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message,

        [Parameter()]
        [switch]$NoIcon
    )

    $icon = if ($NoIcon) { "" } else { "$(Get-SCSymbol -Name 'info') " }
    Write-SCText -Text "${icon}${Message}" -Color (Get-SCColor -Name "info")
}

function Write-SCMuted {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message
    )

    Write-SCText -Text $Message -Color (Get-SCColor -Name "muted")
}

function Write-SCGradient {
    <#
    .SYNOPSIS
        Writes text with gradient coloring
    .PARAMETER Text
        The text to display
    .PARAMETER Colors
        Array of hex colors for the gradient
    .PARAMETER Preset
        Gradient preset: rainbow, sunset, ocean, forest
    .PARAMETER NoNewline
        Don't add newline
    .PARAMETER PassThru
        Return output string instead of writing to console
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Text,

        [Parameter()]
        [string[]]$Colors,

        [Parameter()]
        [ValidateSet('rainbow', 'sunset', 'ocean', 'forest')]
        [string]$Preset = 'rainbow',

        [Parameter()]
        [switch]$NoNewline,

        [Parameter()]
        [switch]$PassThru
    )

    if (-not $Colors) {
        $Colors = $script:Theme.gradients[$Preset]
    }

    if (-not $Colors -or $Colors.Count -eq 0) {
        $Colors = @("#ff0000", "#00ff00", "#0000ff")
    }

    $colorsEnabled = Test-SCColorsEnabled

    if (-not $colorsEnabled) {
        if ($PassThru) { return $Text }
        if ($NoNewline) { [Console]::Write($Text) }
        else { [Console]::WriteLine($Text) }
        return
    }

    $chars = $Text.ToCharArray()
    $colorCount = $Colors.Count
    $output = ""

    for ($i = 0; $i -lt $chars.Count; $i++) {
        $colorIndex = [Math]::Floor(($i / [Math]::Max(1, $chars.Count)) * $colorCount)
        $colorIndex = [Math]::Min($colorIndex, $colorCount - 1)
        $color = $Colors[$colorIndex]
        $ansi = ConvertTo-AnsiColor -HexColor $color
        $output += "${ansi}$($chars[$i])"
    }

    $output += Get-AnsiReset

    if ($PassThru) {
        return $output
    }

    if ($NoNewline) {
        [Console]::Write($output)
    } else {
        [Console]::WriteLine($output)
    }
}

function Clear-SCScreen {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$SoftClear
    )

    if ($SoftClear) {
        [Console]::SetCursorPosition(0, 0)
        try {
            $blank = " " * [Math]::Max(1, [Console]::WindowWidth)
            for ($i = 0; $i -lt [Console]::WindowHeight; $i++) {
                [Console]::WriteLine($blank)
            }
            [Console]::SetCursorPosition(0, 0)
        } catch { [Console]::Clear() }
    } else {
        [Console]::Clear()
    }
}
