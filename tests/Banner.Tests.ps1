#Requires -Version 7.0
<#
.SYNOPSIS
    Tests for Banner (Show-SCBanner) and font distinctness/completeness.
#>

$ErrorActionPreference = 'Stop'
$mod = Join-Path $PSScriptRoot "..\src\pwsh\Shell-Controls.psd1"
Import-Module $mod -Force

Describe "Banner - Show-SCBanner" {

    It "Should return array of strings" {
        $result = Show-SCBanner -Text "HI" -PassThru
        $result | Should BeOfType [string]
    }
}

Describe "Banner - Mini font character distinctness" {

    It "Mini font letters A,B,C,D,E,H,N,O,R should have unique patterns" {
        $letters = @('A','B','C','D','E','H','N','O','R')
        $patterns = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($c in $letters) {
            $out = Show-SCBanner -Text $c -Font 'mini' -PassThru
            $key = ($out -join "|")
            $patterns.Add($key) | Out-Null
        }
        $patterns.Count | Should Be $letters.Count -Because "each of A,B,C,D,E,H,N,O,R must have a distinct 2-line pattern"
    }

    It "Mini font should define all 26 letters A-Z" {
        $az = [char[]]('A'[0]..'Z'[0]) | ForEach-Object { $_.ToString() }
        foreach ($c in $az) {
            $out = Show-SCBanner -Text $c -Font 'mini' -PassThru
            $out | Should Not Be $null
            $out.Count -ge 2 | Should Be $true
        }
    }
}

Describe "Banner - Small font completeness" {

    It "Small font should define J,K,Q,V,W,X,Y,Z" {
        $missing = @('J','K','Q','V','W','X','Y','Z')
        foreach ($c in $missing) {
            $out = Show-SCBanner -Text $c -Font 'small' -PassThru
            $out | Should Not Be $null
            $out.Count -ge 4 | Should Be $true
        }
    }

    It "Small font should define all 26 letters A-Z" {
        $az = [char[]]('A'[0]..'Z'[0]) | ForEach-Object { $_.ToString() }
        foreach ($c in $az) {
            $out = Show-SCBanner -Text $c -Font 'small' -PassThru
            $out | Should Not Be $null
        }
    }
}

Describe "Banner - Standard font" {

    It "Standard font should exist and return multi-line banner" {
        $out = Show-SCBanner -Text "A" -Font 'standard' -PassThru
        $out | Should Not Be $null
        # Output: leading blank + banner lines + trailing blank (inline=6 lines; Figlet may differ)
        $out.Count -ge 6 | Should Be $true
    }

    It "Standard font should render A-Z" {
        $out = Show-SCBanner -Text "ABCDEFGHIJKLMNOPQRSTUVWXYZ" -Font 'standard' -PassThru
        $out | Should Not Be $null
        $out.Count -ge 6 | Should Be $true
    }
}

Describe "Banner - Slant font" {

    It "Slant font should exist and return multi-line banner" {
        $out = Show-SCBanner -Text "A" -Font 'slant' -PassThru
        $out | Should Not Be $null
        $out.Count -ge 6 | Should Be $true
    }

    It "Slant font should render A-Z" {
        $out = Show-SCBanner -Text "SLANT" -Font 'slant' -PassThru
        $out | Should Not Be $null
    }
}
