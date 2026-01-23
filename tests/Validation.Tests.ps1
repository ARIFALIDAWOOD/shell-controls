#Requires -Version 7.0
<#
.SYNOPSIS
    Tests for Validation Library.
#>

$ErrorActionPreference = 'Stop'
$mod = Join-Path $PSScriptRoot "..\src\pwsh\Shell-Controls.psd1"
Import-Module $mod -Force

Describe "Validation Library - New-SCValidator" {

    It "Should create required validator" {
        $validator = New-SCValidator -Required
        $validator.Required | Should Be $true
    }

    It "Should create regex validator" {
        $validator = New-SCValidator -Regex "^\d+$"
        $validator.Regex | Should Be "^\d+$"
    }

    It "Should create range validator" {
        $validator = New-SCValidator -Min 1 -Max 100
        $validator.Min | Should Be 1
        $validator.Max | Should Be 100
    }

    It "Should create length validator" {
        $validator = New-SCValidator -MinLength 5 -MaxLength 10
        $validator.MinLength | Should Be 5
        $validator.MaxLength | Should Be 10
    }

    It "Should create type validator" {
        $validator = New-SCValidator -Type 'email'
        $validator.Type | Should Be 'email'
    }

    It "Should create allowed values validator" {
        $validator = New-SCValidator -AllowedValues @('a', 'b', 'c')
        $validator.AllowedValues -contains 'a' | Should Be $true
    }
}

Describe "Validation Library - Required" {

    It "Should fail for null when required" {
        $validator = New-SCValidator -Required
        $result = Test-SCValue -Value $null -Validator $validator
        $result.IsValid | Should Be $false
    }

    It "Should fail for empty string when required" {
        $validator = New-SCValidator -Required
        $result = Test-SCValue -Value "" -Validator $validator
        $result.IsValid | Should Be $false
    }

    It "Should pass for value when required" {
        $validator = New-SCValidator -Required
        $result = Test-SCValue -Value "test" -Validator $validator
        $result.IsValid | Should Be $true
    }

    It "Should pass for empty when not required" {
        $validator = New-SCValidator
        $result = Test-SCValue -Value "" -Validator $validator
        $result.IsValid | Should Be $true
    }
}

Describe "Validation Library - Email" {

    It "Should validate correct email" {
        $validator = New-SCValidator -Type 'email'
        $result = Test-SCValue -Value "test@example.com" -Validator $validator
        $result.IsValid | Should Be $true
    }

    It "Should reject invalid email" {
        $validator = New-SCValidator -Type 'email'
        $result = Test-SCValue -Value "not-an-email" -Validator $validator
        $result.IsValid | Should Be $false
    }

    It "Should reject email without domain" {
        $validator = New-SCValidator -Type 'email'
        $result = Test-SCValue -Value "test@" -Validator $validator
        $result.IsValid | Should Be $false
    }
}

Describe "Validation Library - URL" {

    It "Should validate correct URL" {
        $validator = New-SCValidator -Type 'url'
        $result = Test-SCValue -Value "https://example.com" -Validator $validator
        $result.IsValid | Should Be $true
    }

    It "Should validate URL with path" {
        $validator = New-SCValidator -Type 'url'
        $result = Test-SCValue -Value "https://example.com/path/to/page" -Validator $validator
        $result.IsValid | Should Be $true
    }

    It "Should reject invalid URL" {
        $validator = New-SCValidator -Type 'url'
        $result = Test-SCValue -Value "not-a-url" -Validator $validator
        $result.IsValid | Should Be $false
    }
}

Describe "Validation Library - Number" {

    It "Should validate number" {
        $validator = New-SCValidator -Type 'number'
        $result = Test-SCValue -Value "42.5" -Validator $validator
        $result.IsValid | Should Be $true
        $result.TransformedValue | Should Be 42.5
    }

    It "Should reject non-number" {
        $validator = New-SCValidator -Type 'number'
        $result = Test-SCValue -Value "abc" -Validator $validator
        $result.IsValid | Should Be $false
    }
}

Describe "Validation Library - Integer" {

    It "Should validate integer" {
        $validator = New-SCValidator -Type 'integer'
        $result = Test-SCValue -Value "42" -Validator $validator
        $result.IsValid | Should Be $true
        $result.TransformedValue | Should Be 42
    }

    It "Should reject float" {
        $validator = New-SCValidator -Type 'integer'
        $result = Test-SCValue -Value "42.5" -Validator $validator
        $result.IsValid | Should Be $false
    }
}

Describe "Validation Library - Range" {

    It "Should pass value within range" {
        $validator = New-SCValidator -Min 1 -Max 100
        $result = Test-SCValue -Value "50" -Validator $validator
        $result.IsValid | Should Be $true
    }

    It "Should fail value below min" {
        $validator = New-SCValidator -Min 10 -Max 100
        $result = Test-SCValue -Value "5" -Validator $validator
        $result.IsValid | Should Be $false
    }

    It "Should fail value above max" {
        $validator = New-SCValidator -Min 1 -Max 100
        $result = Test-SCValue -Value "150" -Validator $validator
        $result.IsValid | Should Be $false
    }
}

Describe "Validation Library - Length" {

    It "Should pass correct length" {
        $validator = New-SCValidator -MinLength 3 -MaxLength 10
        $result = Test-SCValue -Value "hello" -Validator $validator
        $result.IsValid | Should Be $true
    }

    It "Should fail too short" {
        $validator = New-SCValidator -MinLength 5
        $result = Test-SCValue -Value "hi" -Validator $validator
        $result.IsValid | Should Be $false
    }

    It "Should fail too long" {
        $validator = New-SCValidator -MaxLength 5
        $result = Test-SCValue -Value "hello world" -Validator $validator
        $result.IsValid | Should Be $false
    }
}

Describe "Validation Library - Regex" {

    It "Should pass matching pattern" {
        $validator = New-SCValidator -Regex "^\d{3}-\d{4}$"
        $result = Test-SCValue -Value "123-4567" -Validator $validator
        $result.IsValid | Should Be $true
    }

    It "Should fail non-matching pattern" {
        $validator = New-SCValidator -Regex "^\d{3}-\d{4}$"
        $result = Test-SCValue -Value "12-345" -Validator $validator
        $result.IsValid | Should Be $false
    }
}

Describe "Validation Library - Allowed Values" {

    It "Should pass allowed value" {
        $validator = New-SCValidator -AllowedValues @('red', 'green', 'blue')
        $result = Test-SCValue -Value "green" -Validator $validator
        $result.IsValid | Should Be $true
    }

    It "Should fail disallowed value" {
        $validator = New-SCValidator -AllowedValues @('red', 'green', 'blue')
        $result = Test-SCValue -Value "yellow" -Validator $validator
        $result.IsValid | Should Be $false
    }
}

Describe "Validation Library - Custom Script" {

    It "Should pass when script returns true" {
        $validator = New-SCValidator -Script { param($v) $v -gt 5 }
        $result = Test-SCValue -Value 10 -Validator $validator
        $result.IsValid | Should Be $true
    }

    It "Should fail when script returns false" {
        $validator = New-SCValidator -Script { param($v) $v -gt 5 }
        $result = Test-SCValue -Value 3 -Validator $validator
        $result.IsValid | Should Be $false
    }
}

Describe "Validation Library - Quick Validators" {

    It "Test-SCEmail should validate email" {
        Test-SCEmail -Value "test@test.com" | Should Be $true
        Test-SCEmail -Value "invalid" | Should Be $false
    }

    It "Test-SCUrl should validate URL" {
        Test-SCUrl -Value "https://test.com" | Should Be $true
        Test-SCUrl -Value "invalid" | Should Be $false
    }

    It "Test-SCRequired should check presence" {
        Test-SCRequired -Value "value" | Should Be $true
        Test-SCRequired -Value "" | Should Be $false
        Test-SCRequired -Value $null | Should Be $false
    }
}
