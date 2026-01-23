#Requires -Version 7.0
<#
.SYNOPSIS
    Tests for Layout System.
#>

$ErrorActionPreference = 'Stop'
$mod = Join-Path $PSScriptRoot "..\src\pwsh\Shell-Controls.psd1"
Import-Module $mod -Force

Describe "Layout System - Get-SCVisibleLength" {

    It "Should return length for plain text" {
        Get-SCVisibleLength -Text "Hello" | Should Be 5
    }

    It "Should return 0 for empty string" {
        Get-SCVisibleLength -Text "" | Should Be 0
    }

    It "Should strip ANSI codes" {
        $coloredText = "`e[31mRed Text`e[0m"
        Get-SCVisibleLength -Text $coloredText | Should Be 8
    }

    It "Should handle multiple ANSI codes" {
        $text = "`e[1m`e[31mBold Red`e[0m"
        Get-SCVisibleLength -Text $text | Should Be 8
    }
}

Describe "Layout System - Get-SCTruncatedText" {

    It "Should truncate long text" {
        $result = Get-SCTruncatedText -Text "Hello World" -MaxLength 5
        $result.Length | Should BeLessThan 15  # Account for ANSI reset
        (Get-SCVisibleLength -Text $result) | Should Be 5
    }

    It "Should not modify short text" {
        $result = Get-SCTruncatedText -Text "Hi" -MaxLength 10
        Get-SCVisibleLength -Text $result | Should BeLessThan 11
    }

    It "Should preserve ANSI codes before truncation point" {
        $text = "`e[31mRed Text Here`e[0m"
        $result = Get-SCTruncatedText -Text $text -MaxLength 3
        $result | Should Match "`e\[31m"
    }

    It "Should return empty for zero max length" {
        $result = Get-SCTruncatedText -Text "Hello" -MaxLength 0
        $result | Should Be ''
    }
}

Describe "Layout System - Split-SCTextToWidth" {

    It "Should split text at word boundaries" {
        $result = Split-SCTextToWidth -Text "Hello World Test" -MaxWidth 10
        $result.Count | Should BeGreaterThan 1
    }

    It "Should handle single word longer than width" {
        $result = Split-SCTextToWidth -Text "Supercalifragilisticexpialidocious" -MaxWidth 10
        $result.Count | Should BeGreaterThan 1
    }

    It "Should return single line for short text" {
        $result = Split-SCTextToWidth -Text "Short" -MaxWidth 20
        $result.Count | Should Be 1
    }

    It "Should handle empty text" {
        $result = Split-SCTextToWidth -Text "" -MaxWidth 10
        $result -contains '' | Should Be $true
    }
}

Describe "Layout System - Format-SCAlignedText" {

    It "Should left-align text" {
        $result = Format-SCAlignedText -Text "Hi" -Width 10 -Align 'Left'
        $result | Should Be "Hi        "
    }

    It "Should right-align text" {
        $result = Format-SCAlignedText -Text "Hi" -Width 10 -Align 'Right'
        $result | Should Be "        Hi"
    }

    It "Should center text" {
        $result = Format-SCAlignedText -Text "Hi" -Width 10 -Align 'Center'
        $result.Length | Should Be 10
        $result.Trim() | Should Be "Hi"
    }
}

Describe "Layout System - Format-SCLayout" {

    It "Should format lines with padding" {
        $result = Format-SCLayout -Lines @("Hello") -Padding 2 -MaxWidth 20
        $result[0] | Should Match "^\s{2}Hello"
    }

    It "Should format lines with margin" {
        $result = Format-SCLayout -Lines @("Hello") -Margin 3 -MaxWidth 20
        $result[0] | Should Match "^\s{3}"
    }

    It "Should truncate with ellipsis" {
        $result = Format-SCLayout -Lines @("This is a very long line") -MaxWidth 15 -Overflow 'Ellipsis'
        $result[0] | Should Match '\.\.\.$'
    }

    It "Should wrap text" {
        $result = Format-SCLayout -Lines @("Hello World Test") -MaxWidth 10 -Overflow 'Wrap'
        $result.Count | Should BeGreaterThan 0
    }
}

Describe "Layout System - Responsive Breakpoints" {

    It "Get-SCResponsiveBreakpoint should return valid breakpoint" {
        $bp = Get-SCResponsiveBreakpoint
        @('xs', 'sm', 'md', 'lg') -contains $bp | Should Be $true
    }

    It "Get-SCResponsiveValue should return correct value" {
        $values = @{ xs = 1; sm = 2; md = 3; lg = 4 }
        $result = Get-SCResponsiveValue -Values $values
        @(1, 2, 3, 4) -contains $result | Should Be $true
    }

    It "Get-SCResponsiveValue should fall back" {
        $values = @{ lg = 4 }
        $result = Get-SCResponsiveValue -Values $values -Default 0
        @(0, 4) -contains $result | Should Be $true
    }
}

Describe "Layout System - Terminal Dimensions" {

    It "Get-SCTerminalWidth should return positive number" {
        $width = Get-SCTerminalWidth
        $width | Should BeGreaterThan 0
    }

    It "Get-SCTerminalHeight should return positive number" {
        $height = Get-SCTerminalHeight
        $height | Should BeGreaterThan 0
    }
}

Describe "Layout System - Layout Configuration" {

    It "New-SCLayoutConfig should create config" {
        $config = New-SCLayoutConfig -MaxWidth 80 -Padding 2 -Align 'Center'
        $config.MaxWidth | Should Be 80
        $config.Padding | Should Be 2
        $config.Align | Should Be 'Center'
    }

    It "Get-SCDefaultLayoutConfig should return defaults" {
        $config = Get-SCDefaultLayoutConfig
        $config.Align | Should Be 'Left'
        $config.Overflow | Should Be 'Ellipsis'
    }
}

Describe "Layout System - Format-SCColumns" {

    It "Should format items into columns" {
        $items = @("Item1", "Item2", "Item3", "Item4")
        $result = Format-SCColumns -Items $items -Columns 2
        $result.Count | Should BeGreaterThan 0
    }

    It "Should auto-calculate columns" {
        $items = @("A", "B", "C", "D")
        $result = Format-SCColumns -Items $items -MinColumnWidth 5
        $result | Should Not BeNullOrEmpty
    }
}

Describe "Component PassThru - Show-SCPanel" {

    It "Should return array of strings" {
        $result = Show-SCPanel -Content @("Test") -PassThru
        $result | Should BeOfType [string]
        $result.Count | Should BeGreaterThan 0
    }

    It "Should contain border characters" {
        $result = Show-SCPanel -Content @("Test") -PassThru
        $joined = $result -join ""
        $joined | Should Match "[╭╮╰╯│─]"
    }
}

Describe "Component PassThru - Show-SCTable" {

    It "Should return array of strings" {
        $data = @(@{ Name = "Test"; Value = 1 })
        $result = Show-SCTable -Data $data -PassThru
        $result | Should BeOfType [string]
    }
}

Describe "Component PassThru - Show-SCBanner" {

    It "Should return array of strings" {
        $result = Show-SCBanner -Text "HI" -PassThru
        $result | Should BeOfType [string]
    }
}

Describe "Component PassThru - Show-SCTree" {

    It "Should return array of strings" {
        $items = @("Item1", "Item2")
        $result = Show-SCTree -Items $items -PassThru
        $result | Should BeOfType [string]
    }
}

Describe "Component PassThru - Show-SCCard" {

    It "Should return array of strings" {
        $result = Show-SCCard -Title "Test" -Body "Content" -PassThru
        $result | Should BeOfType [string]
        $result.Count | Should BeGreaterThan 0
    }
}
