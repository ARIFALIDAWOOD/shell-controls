<#
.SYNOPSIS
    Table rendering for Shell-Controls
#>

function Show-SCTable {
    <#
    .SYNOPSIS
        Renders data as a formatted table
    .PARAMETER Data
        The data to display (array of hashtables or objects)
    .PARAMETER Columns
        Column names to display (auto-detected if not specified)
    .PARAMETER Title
        Optional table title
    .PARAMETER Style
        Border style: simple, rounded, heavy, double, minimal, ascii
    .PARAMETER ColumnWidths
        Custom widths per column
    .PARAMETER ColumnColors
        Custom colors per column
    .PARAMETER NoHeader
        Hide the header row
    .PARAMETER MaxWidth
        Maximum table width
    .PARAMETER MinWidth
        Minimum table width
    .PARAMETER Margin
        Left margin (spaces)
    .PARAMETER PassThru
        Return output as string array instead of writing to console
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [array]$Data,

        [Parameter()]
        [string[]]$Columns,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [ValidateSet('simple', 'rounded', 'heavy', 'double', 'minimal', 'ascii')]
        [string]$Style = 'rounded',

        [Parameter()]
        [hashtable]$ColumnWidths,

        [Parameter()]
        [hashtable]$ColumnColors,

        [Parameter()]
        [switch]$NoHeader,

        [Parameter()]
        [int]$MaxWidth = 0,

        [Parameter()]
        [int]$MinWidth = 40,

        [Parameter()]
        [int]$Margin = 2,

        [Parameter()]
        [switch]$PassThru
    )

    begin {
        $allData = @()
        $output = [System.Collections.Generic.List[string]]::new()
    }
    process { $allData += $Data }
    end {
        $marginStr = ' ' * $Margin

        if ($allData.Count -eq 0) {
            $emptyMsg = "${marginStr}(No data)"
            if ($PassThru) { return @($emptyMsg) }
            Write-SCMuted $emptyMsg
            return
        }

        $box = switch ($Style) {
            'simple' { @{ tl = '+'; tr = '+'; bl = '+'; br = '+'; h = '-'; v = '|'; lm = '+'; rm = '+'; tm = '+'; bm = '+'; mm = '+' } }
            'rounded' { @{ tl = '╭'; tr = '╮'; bl = '╰'; br = '╯'; h = '─'; v = '│'; lm = '├'; rm = '┤'; tm = '┬'; bm = '┴'; mm = '┼' } }
            'heavy' { @{ tl = '┏'; tr = '┓'; bl = '┗'; br = '┛'; h = '━'; v = '┃'; lm = '┣'; rm = '┫'; tm = '┳'; bm = '┻'; mm = '╋' } }
            'double' { @{ tl = '╔'; tr = '╗'; bl = '╚'; br = '╝'; h = '═'; v = '║'; lm = '╠'; rm = '╣'; tm = '╦'; bm = '╩'; mm = '╬' } }
            'minimal' { @{ tl = ' '; tr = ' '; bl = ' '; br = ' '; h = '─'; v = ' '; lm = ' '; rm = ' '; tm = ' '; bm = ' '; mm = ' ' } }
            'ascii' { @{ tl = '+'; tr = '+'; bl = '+'; br = '+'; h = '-'; v = '|'; lm = '+'; rm = '+'; tm = '+'; bm = '+'; mm = '+' } }
            default { @{ tl = '╭'; tr = '╮'; bl = '╰'; br = '╯'; h = '─'; v = '│'; lm = '├'; rm = '┤'; tm = '┬'; bm = '┴'; mm = '┼' } }
        }

        if (-not $Columns) {
            $firstItem = $allData[0]
            if ($firstItem -is [hashtable]) { $Columns = @($firstItem.Keys | Sort-Object) }
            elseif ($firstItem -is [PSCustomObject]) { $Columns = @($firstItem.PSObject.Properties.Name) }
            else { $Columns = @('Value') }
        }

        # Calculate column widths
        $widths = @{}
        foreach ($col in $Columns) {
            $maxWidth = $col.Length
            foreach ($item in $allData) {
                $value = if ($item -is [hashtable]) { $item[$col] } else { $item.$col }
                $len = "$value".Length
                if ($len -gt $maxWidth) { $maxWidth = $len }
            }
            $widths[$col] = [Math]::Min($maxWidth + 2, 40)
            if ($ColumnWidths -and $ColumnWidths.ContainsKey($col)) { $widths[$col] = $ColumnWidths[$col] }
        }

        # Apply max width constraint
        if ($MaxWidth -gt 0) {
            $totalWidth = $Margin + 1 + ($Columns.Count - 1) + ($widths.Values | Measure-Object -Sum).Sum
            if ($totalWidth -gt $MaxWidth) {
                $reduction = [Math]::Ceiling(($totalWidth - $MaxWidth) / $Columns.Count)
                foreach ($col in $Columns) {
                    $widths[$col] = [Math]::Max(8, $widths[$col] - $reduction)
                }
            }
        }

        # Check if colors are enabled
        $colorsEnabled = Test-SCColorsEnabled

        $borderColor = Get-SCColor -Name "border"
        $headerColor = Get-SCColor -Name "primary"
        $textColor = Get-SCColor -Name "text"
        $borderAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $borderColor } else { '' }
        $headerAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $headerColor } else { '' }
        $textAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $textColor } else { '' }
        $reset = if ($colorsEnabled) { Get-AnsiReset } else { '' }

        if ($Title) {
            $output.Add('')
            $titleAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $headerColor } else { '' }
            $output.Add("${marginStr}${titleAnsi}$($colorsEnabled ? "`e[1m" : '')${Title}${reset}")
        }

        # Top border
        $topBorder = $box.tl
        for ($i = 0; $i -lt $Columns.Count; $i++) {
            $topBorder += ($box.h * $widths[$Columns[$i]])
            if ($i -lt $Columns.Count - 1) { $topBorder += $box.tm }
        }
        $topBorder += $box.tr
        $output.Add("${marginStr}${borderAnsi}${topBorder}${reset}")

        # Header row
        if (-not $NoHeader) {
            $headerLine = "${borderAnsi}$($box.v)${reset}"
            foreach ($col in $Columns) {
                $padded = (" " + $col).PadRight($widths[$col])
                $headerLine += "${headerAnsi}${padded}${reset}${borderAnsi}$($box.v)${reset}"
            }
            $output.Add("${marginStr}${headerLine}")

            # Separator
            $sepLine = $box.lm
            for ($i = 0; $i -lt $Columns.Count; $i++) {
                $sepLine += ($box.h * $widths[$Columns[$i]])
                if ($i -lt $Columns.Count - 1) { $sepLine += $box.mm }
            }
            $sepLine += $box.rm
            $output.Add("${marginStr}${borderAnsi}${sepLine}${reset}")
        }

        # Data rows
        foreach ($item in $allData) {
            $rowLine = "${borderAnsi}$($box.v)${reset}"
            foreach ($col in $Columns) {
                $value = if ($item -is [hashtable]) { $item[$col] } else { $item.$col }
                $valueStr = "$value"
                if ($valueStr.Length -gt $widths[$col] - 2) { $valueStr = $valueStr.Substring(0, $widths[$col] - 4) + "..." }
                $padded = (" " + $valueStr).PadRight($widths[$col])
                $color = $textAnsi
                if ($colorsEnabled -and $ColumnColors -and $ColumnColors.ContainsKey($col)) {
                    $color = ConvertTo-AnsiColor -HexColor $ColumnColors[$col]
                }
                $rowLine += "${color}${padded}${reset}${borderAnsi}$($box.v)${reset}"
            }
            $output.Add("${marginStr}${rowLine}")
        }

        # Bottom border
        $bottomBorder = $box.bl
        for ($i = 0; $i -lt $Columns.Count; $i++) {
            $bottomBorder += ($box.h * $widths[$Columns[$i]])
            if ($i -lt $Columns.Count - 1) { $bottomBorder += $box.bm }
        }
        $bottomBorder += $box.br
        $output.Add("${marginStr}${borderAnsi}${bottomBorder}${reset}")
        $output.Add('')

        # Output handling
        if ($PassThru) {
            return $output.ToArray()
        }

        foreach ($line in $output) {
            [Console]::WriteLine($line)
        }
    }
}
