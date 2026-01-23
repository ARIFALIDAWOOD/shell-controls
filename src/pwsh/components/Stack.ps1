<#
.SYNOPSIS
    Stack layout component for Shell-Controls
.DESCRIPTION
    Arranges child components vertically with configurable gap spacing.
#>

function Show-SCStack {
    <#
    .SYNOPSIS
        Arranges content vertically with gap spacing
    .PARAMETER Children
        Scriptblock containing child components (must use -PassThru)
    .PARAMETER Content
        Pre-rendered content as string array
    .PARAMETER Gap
        Number of blank lines between children
    .PARAMETER Align
        Horizontal alignment of content: Left, Center, Right
    .PARAMETER Margin
        Left margin (spaces)
    .PARAMETER MaxWidth
        Maximum width constraint
    .PARAMETER PassThru
        Return output as string array instead of writing to console
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [scriptblock]$Children,

        [Parameter()]
        [string[][]]$Content,

        [Parameter()]
        [int]$Gap = 1,

        [Parameter()]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Align = 'Left',

        [Parameter()]
        [int]$Margin = 0,

        [Parameter()]
        [int]$MaxWidth = 0,

        [Parameter()]
        [switch]$PassThru
    )

    $output = [System.Collections.Generic.List[string]]::new()
    $marginStr = ' ' * $Margin

    # Collect children output
    $childOutputs = @()

    if ($Children) {
        # Execute scriptblock and capture output
        $capturedOutput = & $Children

        if ($capturedOutput) {
            if ($capturedOutput -is [array]) {
                foreach ($item in $capturedOutput) {
                    if ($item -is [array]) {
                        $childOutputs += ,@($item)
                    } else {
                        $childOutputs += ,@($item.ToString())
                    }
                }
            } else {
                $childOutputs += ,@($capturedOutput.ToString())
            }
        }
    }

    if ($Content) {
        foreach ($contentBlock in $Content) {
            $childOutputs += ,$contentBlock
        }
    }

    # Process and output
    try { $termWidth = [Console]::WindowWidth } catch { $termWidth = 80 }
    $effectiveMaxWidth = if ($MaxWidth -gt 0) { $MaxWidth } else { $termWidth - $Margin }

    $isFirst = $true
    foreach ($childBlock in $childOutputs) {
        # Add gap between children
        if (-not $isFirst -and $Gap -gt 0) {
            for ($i = 0; $i -lt $Gap; $i++) {
                $output.Add('')
            }
        }
        $isFirst = $false

        # Process each line of child
        foreach ($line in $childBlock) {
            if ([string]::IsNullOrEmpty($line)) {
                $output.Add('')
                continue
            }

            $visLen = Get-SCVisibleLength -Text $line

            # Apply margin
            $processedLine = if ($Margin -gt 0) { "${marginStr}${line}" } else { $line }

            # Apply alignment
            if ($Align -ne 'Left') {
                $padAmount = [Math]::Max(0, $effectiveMaxWidth - $visLen - $Margin)

                switch ($Align) {
                    'Right' {
                        $processedLine = (' ' * $padAmount) + $processedLine
                    }
                    'Center' {
                        $leftPad = [Math]::Floor($padAmount / 2)
                        $processedLine = (' ' * $leftPad) + $processedLine
                    }
                }
            }

            $output.Add($processedLine)
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

function Add-SCStackItem {
    <#
    .SYNOPSIS
        Helper to add items to a stack (for use in scriptblocks)
    .PARAMETER Content
        Content to add to the stack
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$Content
    )

    process {
        return $Content
    }
}
