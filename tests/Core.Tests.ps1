#Requires -Version 7.0
<#
.SYNOPSIS
    Core tests for Shell-Controls (Theme, Config, Utils).
#>

$ErrorActionPreference = 'Stop'
$mod = Join-Path $PSScriptRoot "..\src\pwsh\Shell-Controls.psd1"
Import-Module $mod -Force

Describe "Theme" {
    It "Set-SCTheme and Get-SCTheme" {
        Initialize-ShellControls -ThemeName "catppuccin" -Force
        $t = Get-SCTheme
        $t | Should Not Be $null
        $t.name | Should Match "Catppuccin"
    }

    It "Get-SCColor" {
        $c = Get-SCColor -Name "primary"
        $c | Should Match "^#[0-9a-fA-F]{6}$"
    }

    It "Get-SCSymbol" {
        $s = Get-SCSymbol -Name "check"
        $s | Should Be "✔"
        $box = Get-SCSymbol -Name "boxRounded"
        $box | Should Not Be $null
        $box['topLeft'] | Should Be "╭"
    }
}

Describe "Config" {
    It "Get-SCConfig" {
        $cfg = Get-SCConfig
        $cfg | Should Not Be $null
        $cfg.theme | Should Not Be $null
    }

    It "Get-SCConfig with key" {
        $theme = Get-SCConfig -Key "theme"
        $theme | Should Not Be $null
    }
}

Describe "Utils" {
    It "Get-SCTerminalSize" {
        $sz = Get-SCTerminalSize
        $sz.Width | Should BeGreaterThan 0
        $sz.Height | Should BeGreaterThan 0
    }

    It "Test-SCCommand" {
        Test-SCCommand -Name "Get-Command" | Should Be $true
        Test-SCCommand -Name "NonExistentCmd_XYZ" | Should Be $false
    }

    It "ConvertTo-SCSlug" {
        (ConvertTo-SCSlug -Text "Hello World") | Should Be "hello-world"
    }

    It "Format-SCDuration" {
        (Format-SCDuration -Duration ([TimeSpan]::FromSeconds(65))) | Should Match "1m"
    }
}
