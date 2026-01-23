<#
.SYNOPSIS
    Tree view component for Shell-Controls
#>

function Show-SCTree {
    <#
    .SYNOPSIS
        Displays hierarchical data as a tree view
    .PARAMETER Items
        The items to display (array of strings or hashtables with Name and Children)
    .PARAMETER Title
        Optional title for the tree
    .PARAMETER Icon
        Icon to prefix each node
    .PARAMETER Indent
        Base indentation
    .PARAMETER Margin
        Left margin
    .PARAMETER PassThru
        Return output as string array instead of writing to console
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [array]$Items,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [string]$Icon = "",

        [Parameter()]
        [int]$Indent = 2,

        [Parameter()]
        [int]$Margin = 0,

        [Parameter()]
        [switch]$PassThru
    )

    begin {
        $allItems = @()
        $output = [System.Collections.Generic.List[string]]::new()
    }
    process { $allItems += $Items }
    end {
        $colorsEnabled = Test-SCColorsEnabled
        $marginStr = ' ' * $Margin

        if ($Title) {
            $titleColor = Get-SCColor -Name "primary"
            if ($colorsEnabled) {
                $titleAnsi = ConvertTo-AnsiColor -HexColor $titleColor
                $reset = Get-AnsiReset
                $output.Add("${marginStr}${titleAnsi}`e[1m${Title}${reset}")
            } else {
                $output.Add("${marginStr}${Title}")
            }
            $output.Add('')
        }

        $border = Get-SCSymbol -Name "boxRounded.horizontal"
        if (-not $border) { $border = "─" }
        $tee = "├"
        $last = "└"
        $v = "│"

        $textColor = Get-SCColor -Name "text"
        $textAnsi = if ($colorsEnabled) { ConvertTo-AnsiColor -HexColor $textColor } else { '' }
        $reset = if ($colorsEnabled) { Get-AnsiReset } else { '' }

        function Write-TreeNode {
            param($item, $prefix, $isLast, [ref]$outputRef)

            $name = if ($item -is [hashtable]) {
                $item.Name ?? $item.Key ?? $item.Text ?? ($item | Out-String)
            } else {
                $item.ToString()
            }

            $branch = if ($isLast) { $last } else { $tee }
            $iconStr = if ($Icon) { "$Icon " } else { "" }
            $outputRef.Value.Add("${marginStr}${prefix}${branch}${border} ${textAnsi}${iconStr}${name}${reset}")

            $children = if ($item -is [hashtable] -and $item.Children) { $item.Children } else { @() }
            $childPrefix = $prefix + ($isLast ? "   " : "$v  ")

            $i = 0
            foreach ($c in $children) {
                Write-TreeNode -item $c -prefix $childPrefix -isLast ($i -eq $children.Count - 1) -outputRef $outputRef
                $i++
            }
        }

        $i = 0
        foreach ($item in $allItems) {
            Write-TreeNode -item $item -prefix (' ' * $Indent) -isLast ($i -eq $allItems.Count - 1) -outputRef ([ref]$output)
            $i++
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
}
