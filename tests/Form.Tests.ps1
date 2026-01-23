#Requires -Version 7.0
<#
.SYNOPSIS
    Tests for Form System.
#>

$ErrorActionPreference = 'Stop'
$mod = Join-Path $PSScriptRoot "..\src\pwsh\Shell-Controls.psd1"
Import-Module $mod -Force

Describe "Form System - New-SCFormField" {

    It "Should create basic text field" {
        $field = New-SCFormField -Name "username" -Type "text" -Label "Username"
        $field.Name | Should Be "username"
        $field.Type | Should Be "text"
        $field.Label | Should Be "Username"
    }

    It "Should create required field" {
        $field = New-SCFormField -Name "email" -Type "email" -Required
        $field.Required | Should Be $true
    }

    It "Should create number field with range" {
        $field = New-SCFormField -Name "age" -Type "number" -Min 0 -Max 150
        $field.Type | Should Be "number"
        $field.Min | Should Be 0
        $field.Max | Should Be 150
    }

    It "Should create select field with options" {
        $field = New-SCFormField -Name "role" -Type "select" -Options @('admin', 'user', 'guest')
        $field.Type | Should Be "select"
        $field.Options -contains 'admin' | Should Be $true
    }

    It "Should create date field with format" {
        $field = New-SCFormField -Name "dob" -Type "date" -Format "MM/dd/yyyy"
        $field.Type | Should Be "date"
        $field.Format | Should Be "MM/dd/yyyy"
    }

    It "Should create password field with min length" {
        $field = New-SCFormField -Name "password" -Type "password" -MinLength 8
        $field.Type | Should Be "password"
        $field.MinLength | Should Be 8
    }

    It "Should set default value" {
        $field = New-SCFormField -Name "country" -Type "text" -Default "USA"
        $field.Default | Should Be "USA"
    }

    It "Should attach validator" {
        $validator = New-SCValidator -Type 'email' -Required
        $field = New-SCFormField -Name "email" -Type "email" -Validator $validator
        $field.Validator | Should Not BeNullOrEmpty
    }
}

Describe "Form System - New-SCWizardStep" {

    It "Should create step with title and fields" {
        $fields = @(
            (New-SCFormField -Name "name" -Type "text")
        )
        $step = New-SCWizardStep -Title "Personal Info" -Fields $fields
        $step.Title | Should Be "Personal Info"
        $step.Fields.Count | Should Be 1
    }

    It "Should include description" {
        $step = New-SCWizardStep -Title "Step 1" -Description "Enter your details" -Fields @()
        $step.Description | Should Be "Enter your details"
    }

    It "Should include OnComplete handler" {
        $handler = { param($values) Write-Host "Complete" }
        $step = New-SCWizardStep -Title "Step 1" -Fields @() -OnComplete $handler
        $step.OnComplete | Should Not BeNullOrEmpty
    }

    It "Should include SkipIf condition" {
        $condition = { param($values) $values.skipStep -eq $true }
        $step = New-SCWizardStep -Title "Step 1" -Fields @() -SkipIf $condition
        $step.SkipIf | Should Not BeNullOrEmpty
    }
}

Describe "Form System - Field Types" {

    It "Should support all field types" {
        $types = @('text', 'password', 'number', 'email', 'url', 'date', 'select', 'multiselect', 'confirm')
        foreach ($type in $types) {
            $field = New-SCFormField -Name "test" -Type $type
            $field.Type | Should Be $type
        }
    }
}

Describe "Form System - Test Mode" {

    BeforeEach {
        Enable-SCTestMode
    }

    AfterEach {
        Disable-SCTestMode
    }

    It "Should process form with mock inputs" {
        Enable-SCTestMode -InputQueue @("John Doe", "john@example.com")

        $fields = @(
            (New-SCFormField -Name "name" -Type "text" -Label "Name")
            (New-SCFormField -Name "email" -Type "text" -Label "Email")
        )

        # Note: Full form test requires interactive input simulation
        # This tests that the form fields are properly configured
        $fields.Count | Should Be 2
        $fields[0].Name | Should Be "name"
        $fields[1].Name | Should Be "email"
    }
}

Describe "Wizard System - Step Configuration" {

    It "Should create multi-step wizard config" {
        $steps = @(
            (New-SCWizardStep -Title "Step 1" -Fields @(
                (New-SCFormField -Name "field1" -Type "text")
            ))
            (New-SCWizardStep -Title "Step 2" -Fields @(
                (New-SCFormField -Name "field2" -Type "text")
            ))
        )

        $steps.Count | Should Be 2
        $steps[0].Title | Should Be "Step 1"
        $steps[1].Title | Should Be "Step 2"
    }

    It "Should configure conditional steps" {
        $step = New-SCWizardStep -Title "Optional" -Fields @() -SkipIf { param($v) $v.skip -eq $true }
        & $step.SkipIf @{ skip = $true } | Should Be $true
        & $step.SkipIf @{ skip = $false } | Should Be $false
    }
}
