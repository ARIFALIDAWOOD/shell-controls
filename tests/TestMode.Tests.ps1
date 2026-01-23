#Requires -Version 7.0
<#
.SYNOPSIS
    Tests for Test Mode Infrastructure.
#>

$ErrorActionPreference = 'Stop'
$mod = Join-Path $PSScriptRoot "..\src\pwsh\Shell-Controls.psd1"
Import-Module $mod -Force

Describe "Test Mode Infrastructure" {

    BeforeEach {
        Disable-SCTestMode
    }

    AfterEach {
        Disable-SCTestMode
    }

    It "Enable-SCTestMode should enable test mode" {
        Enable-SCTestMode
        Test-SCTestModeEnabled | Should Be $true
    }

    It "Enable-SCTestMode should accept mock inputs" {
        Enable-SCTestMode -MockInputs @{ "name" = "TestUser" }
        $state = Get-SCTestModeState
        $state.MockInputs.Count | Should Be 1
    }

    It "Enable-SCTestMode should accept input queue" {
        Enable-SCTestMode -InputQueue @("input1", "input2", "input3")
        $state = Get-SCTestModeState
        $state.InputQueueCount | Should Be 3
    }

    It "Enable-SCTestMode should enable output capture" {
        Enable-SCTestMode -CaptureOutput
        $state = Get-SCTestModeState
        $state.CaptureOutput | Should Be $true
    }

    It "Disable-SCTestMode should disable test mode" {
        Enable-SCTestMode
        Disable-SCTestMode
        Test-SCTestModeEnabled | Should Be $false
    }

    It "Disable-SCTestMode should clear all mock data" {
        Enable-SCTestMode -MockInputs @{ "test" = "value" } -InputQueue @("a", "b")
        Disable-SCTestMode
        $state = Get-SCTestModeState
        $state.MockInputs.Count | Should Be 0
        $state.InputQueueCount | Should Be 0
    }

    It "Get-SCMockInput should return queued input" {
        Enable-SCTestMode -InputQueue @("first", "second")
        Get-SCMockInput | Should Be "first"
        Get-SCMockInput | Should Be "second"
    }

    It "Get-SCMockInput should return mock input by prompt" {
        Enable-SCTestMode -MockInputs @{ "Enter name" = "John" }
        Get-SCMockInput -Prompt "Enter name" | Should Be "John"
    }

    It "Get-SCMockInput should return default when no mock found" {
        Enable-SCTestMode
        Get-SCMockInput -Prompt "Unknown" -Default "fallback" | Should Be "fallback"
    }

    It "Add-SCMockInput should add input to queue" {
        Enable-SCTestMode
        Add-SCMockInput "newInput"
        $state = Get-SCTestModeState
        $state.InputQueueCount | Should Be 1
    }

    It "Output capture should capture output when enabled" {
        Enable-SCTestMode -CaptureOutput
        Write-SCTestOutput "Test output"
        $output = Get-SCCapturedOutput
        $output -contains "Test output" | Should Be $true
    }

    It "Get-SCCapturedOutput should return output as string" {
        Enable-SCTestMode -CaptureOutput
        Write-SCTestOutput "Line1"
        Write-SCTestOutput "Line2"
        $output = Get-SCCapturedOutput -AsString
        $output | Should BeOfType [string]
    }

    It "Get-SCCapturedOutput should strip ANSI codes when requested" {
        Enable-SCTestMode -CaptureOutput
        Write-SCTestOutput "`e[31mRed text`e[0m"
        $output = Get-SCCapturedOutput -StripAnsi -AsString
        $output | Should Be "Red text"
    }

    It "Clear-SCCapturedOutput should clear captured output" {
        Enable-SCTestMode -CaptureOutput
        Write-SCTestOutput "Test"
        Clear-SCCapturedOutput
        $output = Get-SCCapturedOutput
        $output.Count | Should Be 0
    }

    It "Invoke-SCReadKey should return mock key when in test mode" {
        Enable-SCTestMode -InputQueue @("Enter")
        $key = Invoke-SCReadKey
        $key.Key | Should Be ([ConsoleKey]::Enter)
    }

    It "Invoke-SCReadKey should handle character input" {
        Enable-SCTestMode -InputQueue @("a")
        $key = Invoke-SCReadKey
        $key.KeyChar | Should Be 'a'
    }

    It "Invoke-SCReadLine should return mock input" {
        Enable-SCTestMode -InputQueue @("test line")
        $line = Invoke-SCReadLine
        $line | Should Be "test line"
    }

    It "Invoke-SCReadLine should use prompt for mock lookup" {
        Enable-SCTestMode -MockInputs @{ "name" = "MockName" }
        $line = Invoke-SCReadLine -Prompt "name"
        $line | Should Be "MockName"
    }
}
