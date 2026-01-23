<#
.SYNOPSIS
    Panel/box components for Shell-Controls
#>

function Show-SCPanel {
    <#
    .SYNOPSIS
        Displays a panel/box with optional title
    .PARAMETER Content
        The content lines to display
    .PARAMETER Title
        Optional title for the panel
    .PARAMETER Width
        Panel width (0 = auto)
    .PARAMETER MaxWidth
        Maximum width constraint
    .PARAMETER MinWidth
        Minimum width constraint
    .PARAMETER Margin
        External margin (spaces before panel)
    .PARAMETER Align
        Panel alignment: Left, Center, Right
    .PARAMETER Style
        Border style: rounded, heavy, double, simple, ascii, none
    .PARAMETER BorderColor
        Border color (hex or theme color name)
    .PARAMETER TitleColor
        Title color (hex or theme color name)
    .PARAMETER TitleAlign
        Title alignment within border
    .PARAMETER Padding
        Internal padding
    .PARAMETER PassThru
        Return output as string array instead of writing to console
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$Content,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [int]$Width = 0,

        [Parameter()]
        [int]$MaxWidth = 0,

        [Parameter()]
        [int]$MinWidth = 40,

        [Parameter()]
        [int]$Margin = 2,

        [Parameter()]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Align = 'Left',

        [Parameter()]
        [ValidateSet('rounded', 'heavy', 'double', 'simple', 'ascii', 'none')]
        [string]$Style = 'rounded',

        [Parameter()]
        [string]$BorderColor,

        [Parameter()]
        [string]$TitleColor,

        [Parameter()]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$TitleAlign = 'Left',

        [Parameter()]
        [int]$Padding = 1,

        [Parameter()]
        [switch]$PassThru
    )

    # Output buffer for PassThru support
    $output = [System.Collections.Generic.List[string]]::new()

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

    if (-not $BorderColor) { $BorderColor = Get-SCColor -Name "border" }
    if (-not $TitleColor) { $TitleColor = Get-SCColor -Name "primary" }

    # Calculate width
    if ($Width -eq 0) {
        $maxContentWidth = ($Content | ForEach-Object {
            if ($_) { (Get-SCVisibleLength -Text $_) } else { 0 }
        } | Measure-Object -Maximum).Maximum
        $Width = [Math]::Max($maxContentWidth + ($Padding * 2) + 2, $MinWidth)
        if ($Title) { $Width = [Math]::Max($Width, $Title.Length + 4) }
    }

    # Apply max width constraint
    if ($MaxWidth -gt 0 -and $Width -gt $MaxWidth) {
        $Width = $MaxWidth
    }

    $innerWidth = $Width - 2
    $marginStr = ' ' * $Margin

    # Check if colors are enabled
    $colorsEnabled = Test-SCColorsEnabled
    $borderAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $BorderColor } else { '' }
    $titleAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $TitleColor } else { '' }
    $reset = if ($colorsEnabled) { Get-AnsiReset } else { '' }

    # Top border
    if ($Title) {
        $titleDisplay = " $Title "
        $titlePadding = switch ($TitleAlign) {
            'Left'   { 2 }
            'Center' { [Math]::Max(0, [Math]::Floor(($innerWidth - $titleDisplay.Length) / 2)) }
            'Right'  { [Math]::Max(0, $innerWidth - $titleDisplay.Length - 2) }
            default  { 2 }
        }
        $leftLine = $box['horizontal'] * $titlePadding
        $rightLine = $box['horizontal'] * [Math]::Max(0, $innerWidth - $titlePadding - $titleDisplay.Length)
        $output.Add("${marginStr}${borderAnsi}$($box['topLeft'])${leftLine}${reset}${titleAnsi}${titleDisplay}${reset}${borderAnsi}${rightLine}$($box['topRight'])${reset}")
    } else {
        $output.Add("${marginStr}${borderAnsi}$($box['topLeft'])$($box['horizontal'] * $innerWidth)$($box['topRight'])${reset}")
    }

    # Top padding
    for ($i = 0; $i -lt $Padding; $i++) {
        $output.Add("${marginStr}${borderAnsi}$($box['vertical'])${reset}$(' ' * $innerWidth)${borderAnsi}$($box['vertical'])${reset}")
    }

    # Content
    foreach ($line in $Content) {
        $paddedLine = (' ' * $Padding) + $line
        $visLen = Get-SCVisibleLength -Text $paddedLine
        if ($visLen -gt $innerWidth) {
            $paddedLine = Get-SCTruncatedText -Text $paddedLine -MaxLength ($innerWidth - 3)
            $paddedLine = "$paddedLine..."
            $visLen = Get-SCVisibleLength -Text $paddedLine
        }
        $rightPad = ' ' * [Math]::Max(0, $innerWidth - $visLen)
        $output.Add("${marginStr}${borderAnsi}$($box['vertical'])${reset}${paddedLine}${rightPad}${borderAnsi}$($box['vertical'])${reset}")
    }

    # Bottom padding
    for ($i = 0; $i -lt $Padding; $i++) {
        $output.Add("${marginStr}${borderAnsi}$($box['vertical'])${reset}$(' ' * $innerWidth)${borderAnsi}$($box['vertical'])${reset}")
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

function Show-SCNotification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('info', 'success', 'warning', 'error')]
        [string]$Type = 'info',

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [switch]$Dismissible
    )

    $colors = @{ info = (Get-SCColor -Name "info"); success = (Get-SCColor -Name "success"); warning = (Get-SCColor -Name "warning"); error = (Get-SCColor -Name "error") }
    $icons = @{ info = (Get-SCSymbol -Name "info"); success = (Get-SCSymbol -Name "check"); warning = (Get-SCSymbol -Name "warning"); error = (Get-SCSymbol -Name "cross") }
    $color = $colors[$Type]
    $icon = $icons[$Type]
    Write-SCText ""
    $header = if ($Title) { "$icon $Title" } else { $icon }
    Show-SCPanel -Content @($Message) -Title $header -BorderColor $color -TitleColor $color -Width 60
    if ($Dismissible) { Write-SCMuted "  Press any key to dismiss..."; $null = [Console]::ReadKey($true) }
}
