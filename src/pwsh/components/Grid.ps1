<#
.SYNOPSIS
    Grid layout component for Shell-Controls
.DESCRIPTION
    Arranges child components in a responsive grid layout.
#>

function Show-SCGrid {
    <#
    .SYNOPSIS
        Arranges content in a grid layout
    .PARAMETER Children
        Scriptblock containing child components (must use -PassThru)
    .PARAMETER Items
        Pre-rendered items as array of string arrays
    .PARAMETER Columns
        Number of columns (0 = auto based on terminal width)
    .PARAMETER MinCellWidth
        Minimum width per cell
    .PARAMETER Gap
        Gap between cells (spaces)
    .PARAMETER RowGap
        Gap between rows (blank lines)
    .PARAMETER Margin
        Left margin (spaces)
    .PARAMETER PassThru
        Return output as string array instead of writing to console
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [scriptblock]$Children,

        [Parameter()]
        [array]$Items,

        [Parameter()]
        [int]$Columns = 0,

        [Parameter()]
        [int]$MinCellWidth = 20,

        [Parameter()]
        [int]$Gap = 2,

        [Parameter()]
        [int]$RowGap = 1,

        [Parameter()]
        [int]$Margin = 0,

        [Parameter()]
        [switch]$PassThru
    )

    $output = [System.Collections.Generic.List[string]]::new()
    $marginStr = ' ' * $Margin
    $gapStr = ' ' * $Gap

    # Collect children output
    $childOutputs = [System.Collections.Generic.List[string[]]]::new()

    if ($Children) {
        # Execute scriptblock and capture output
        $capturedOutput = & $Children

        if ($capturedOutput) {
            if ($capturedOutput -is [array]) {
                foreach ($item in $capturedOutput) {
                    if ($item -is [array]) {
                        $childOutputs.Add([string[]]$item)
                    } else {
                        $childOutputs.Add([string[]]@($item.ToString()))
                    }
                }
            } else {
                $childOutputs.Add([string[]]@($capturedOutput.ToString()))
            }
        }
    }

    if ($Items) {
        foreach ($item in $Items) {
            if ($item -is [array]) {
                $childOutputs.Add([string[]]$item)
            } else {
                $childOutputs.Add([string[]]@($item.ToString()))
            }
        }
    }

    if ($childOutputs.Count -eq 0) {
        if ($PassThru) { return @() }
        return
    }

    # Calculate grid dimensions
    try { $termWidth = [Console]::WindowWidth - 1 } catch { $termWidth = 80 }
    $availableWidth = $termWidth - ($Margin * 2)

    # Auto-calculate columns if not specified
    if ($Columns -le 0) {
        $Columns = [Math]::Max(1, [Math]::Floor($availableWidth / ($MinCellWidth + $Gap)))
    }

    # Calculate cell width
    $totalGapWidth = ($Columns - 1) * $Gap
    $cellWidth = [Math]::Floor(($availableWidth - $totalGapWidth) / $Columns)
    $cellWidth = [Math]::Max($cellWidth, $MinCellWidth)

    # Organize into rows
    $rows = [System.Collections.Generic.List[array]]::new()
    $currentRow = @()

    foreach ($child in $childOutputs) {
        $currentRow += ,$child
        if ($currentRow.Count -ge $Columns) {
            $rows.Add($currentRow)
            $currentRow = @()
        }
    }

    # Add remaining items
    if ($currentRow.Count -gt 0) {
        $rows.Add($currentRow)
    }

    # Render each row
    $isFirstRow = $true
    foreach ($row in $rows) {
        # Add row gap
        if (-not $isFirstRow -and $RowGap -gt 0) {
            for ($i = 0; $i -lt $RowGap; $i++) {
                $output.Add('')
            }
        }
        $isFirstRow = $false

        # Find max height in row
        $maxHeight = 0
        foreach ($cell in $row) {
            if ($cell.Count -gt $maxHeight) {
                $maxHeight = $cell.Count
            }
        }

        # Render row line by line
        for ($lineIdx = 0; $lineIdx -lt $maxHeight; $lineIdx++) {
            $rowLine = $marginStr
            $isFirstCell = $true

            for ($cellIdx = 0; $cellIdx -lt $Columns; $cellIdx++) {
                if (-not $isFirstCell) {
                    $rowLine += $gapStr
                }
                $isFirstCell = $false

                $cell = if ($cellIdx -lt $row.Count) { $row[$cellIdx] } else { @() }
                $line = if ($lineIdx -lt $cell.Count) { $cell[$lineIdx] } else { '' }

                # Truncate or pad to cell width
                $visLen = Get-SCVisibleLength -Text $line

                if ($visLen -gt $cellWidth) {
                    $line = Get-SCTruncatedText -Text $line -MaxLength ($cellWidth - 3)
                    $line = "$line..."
                    $visLen = Get-SCVisibleLength -Text $line
                }

                $padAmount = $cellWidth - $visLen
                $rowLine += $line + (' ' * $padAmount)
            }

            $output.Add($rowLine.TrimEnd())
        }
    }

    # Output handling
    if ($PassThru) {
        return $output.ToArray()
    }

    foreach ($line in $output) {
        [Console]::WriteLine($line)
    }
}
