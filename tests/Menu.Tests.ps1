#Requires -Version 7.0
<#
.SYNOPSIS
    Menu tests for Shell-Controls.
#>

$ErrorActionPreference = 'Stop'
$mod = Join-Path $PSScriptRoot "..\src\pwsh\Shell-Controls.psd1"
Import-Module $mod -Force

Initialize-ShellControls -ThemeName "catppuccin" -Force

Describe "Show-SCMenu" {
    It "exists and accepts -Title, -Items" {
        Get-Command Show-SCMenu -ErrorAction Stop | Should Not Be $null
        $cmd = Get-Command Show-SCMenu
        ($cmd.Parameters.Keys -contains "Title") | Should Be $true
        ($cmd.Parameters.Keys -contains "Items") | Should Be $true
    }
}

Describe "Show-SCMultiSelect" {
    It "exists and accepts -Items" {
        ($(Get-Command Show-SCMultiSelect).Parameters.Keys -contains "Items") | Should Be $true
    }
}

Describe "Show-SCRadioSelect" {
    It "exists" { Get-Command Show-SCRadioSelect | Should Not Be $null }
}

Describe "Show-SCPaginated" {
    It "exists" { Get-Command Show-SCPaginated | Should Not Be $null }
}
