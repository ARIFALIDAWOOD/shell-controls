<#
.SYNOPSIS
    Input validation library for Shell-Controls
.DESCRIPTION
    Provides validators for common input types with composable validation rules.
#>

class SCValidationResult {
    [bool]$IsValid
    [string[]]$Errors
    [object]$Value
    [object]$TransformedValue

    SCValidationResult() {
        $this.IsValid = $true
        $this.Errors = @()
        $this.Value = $null
        $this.TransformedValue = $null
    }

    [void] AddError([string]$message) {
        $this.IsValid = $false
        $this.Errors += $message
    }
}

function New-SCValidator {
    <#
    .SYNOPSIS
        Creates a validator configuration object
    .PARAMETER Required
        Value cannot be null or empty
    .PARAMETER Regex
        Regular expression pattern to match
    .PARAMETER Min
        Minimum numeric value
    .PARAMETER Max
        Maximum numeric value
    .PARAMETER MinLength
        Minimum string length
    .PARAMETER MaxLength
        Maximum string length
    .PARAMETER Script
        Custom validation scriptblock { param($value) return $true/$false }
    .PARAMETER Type
        Built-in type validation: email, url, date, number, integer, ipv4, guid
    .PARAMETER AllowedValues
        Array of allowed values
    .PARAMETER ErrorMessage
        Custom error message template
    .PARAMETER Transform
        Scriptblock to transform value after validation { param($value) return $transformed }
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Required,

        [Parameter()]
        [string]$Regex,

        [Parameter()]
        [double]$Min = [double]::MinValue,

        [Parameter()]
        [double]$Max = [double]::MaxValue,

        [Parameter()]
        [int]$MinLength = -1,

        [Parameter()]
        [int]$MaxLength = -1,

        [Parameter()]
        [scriptblock]$Script,

        [Parameter()]
        [ValidateSet('email', 'url', 'date', 'number', 'integer', 'ipv4', 'guid', 'phone')]
        [string]$Type,

        [Parameter()]
        [array]$AllowedValues,

        [Parameter()]
        [string]$ErrorMessage,

        [Parameter()]
        [scriptblock]$Transform
    )

    return @{
        Required      = $Required.IsPresent
        Regex         = $Regex
        Min           = $Min
        Max           = $Max
        MinLength     = $MinLength
        MaxLength     = $MaxLength
        Script        = $Script
        Type          = $Type
        AllowedValues = $AllowedValues
        ErrorMessage  = $ErrorMessage
        Transform     = $Transform
    }
}

function Test-SCValue {
    <#
    .SYNOPSIS
        Validates a value against a validator configuration
    .PARAMETER Value
        The value to validate
    .PARAMETER Validator
        The validator configuration (from New-SCValidator)
    .OUTPUTS
        SCValidationResult object with IsValid, Errors, Value, TransformedValue
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [object]$Value,

        [Parameter(Mandatory, Position = 1)]
        [hashtable]$Validator
    )

    $result = [SCValidationResult]::new()
    $result.Value = $Value

    # Required check
    if ($Validator.Required) {
        if ($null -eq $Value -or ($Value -is [string] -and [string]::IsNullOrWhiteSpace($Value))) {
            $msg = if ($Validator.ErrorMessage) { $Validator.ErrorMessage } else { "This field is required" }
            $result.AddError($msg)
            return $result
        }
    } elseif ($null -eq $Value -or ($Value -is [string] -and [string]::IsNullOrWhiteSpace($Value))) {
        # Not required and empty - valid
        $result.TransformedValue = $Value
        return $result
    }

    $stringValue = "$Value"

    # Type-specific validation
    if ($Validator.Type) {
        switch ($Validator.Type) {
            'email' {
                $emailPattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                if ($stringValue -notmatch $emailPattern) {
                    $result.AddError("Please enter a valid email address")
                }
            }
            'url' {
                $urlPattern = '^https?://[^\s/$.?#].[^\s]*$'
                if ($stringValue -notmatch $urlPattern) {
                    $result.AddError("Please enter a valid URL (http:// or https://)")
                }
            }
            'date' {
                $parsed = [datetime]::MinValue
                if (-not [datetime]::TryParse($stringValue, [ref]$parsed)) {
                    $result.AddError("Please enter a valid date")
                } else {
                    $result.TransformedValue = $parsed
                }
            }
            'number' {
                $parsed = 0.0
                if (-not [double]::TryParse($stringValue, [ref]$parsed)) {
                    $result.AddError("Please enter a valid number")
                } else {
                    $result.TransformedValue = $parsed
                }
            }
            'integer' {
                $parsed = 0
                if (-not [int]::TryParse($stringValue, [ref]$parsed)) {
                    $result.AddError("Please enter a valid integer")
                } else {
                    $result.TransformedValue = $parsed
                }
            }
            'ipv4' {
                $ipPattern = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
                if ($stringValue -notmatch $ipPattern) {
                    $result.AddError("Please enter a valid IPv4 address")
                }
            }
            'guid' {
                $parsed = [guid]::Empty
                if (-not [guid]::TryParse($stringValue, [ref]$parsed)) {
                    $result.AddError("Please enter a valid GUID")
                } else {
                    $result.TransformedValue = $parsed
                }
            }
            'phone' {
                $phonePattern = '^[\d\s\-\+\(\)]+$'
                if ($stringValue -notmatch $phonePattern -or $stringValue.Length -lt 7) {
                    $result.AddError("Please enter a valid phone number")
                }
            }
        }
    }

    # String length validation
    if ($Validator.MinLength -ge 0 -and $stringValue.Length -lt $Validator.MinLength) {
        $result.AddError("Must be at least $($Validator.MinLength) characters")
    }

    if ($Validator.MaxLength -ge 0 -and $stringValue.Length -gt $Validator.MaxLength) {
        $result.AddError("Must be no more than $($Validator.MaxLength) characters")
    }

    # Numeric range validation
    $numericValue = $null
    if ($Validator.Min -ne [double]::MinValue -or $Validator.Max -ne [double]::MaxValue) {
        if ([double]::TryParse($stringValue, [ref]$numericValue)) {
            if ($numericValue -lt $Validator.Min) {
                $result.AddError("Value must be at least $($Validator.Min)")
            }
            if ($numericValue -gt $Validator.Max) {
                $result.AddError("Value must be no more than $($Validator.Max)")
            }
        }
    }

    # Regex validation
    if ($Validator.Regex -and $stringValue -notmatch $Validator.Regex) {
        $msg = if ($Validator.ErrorMessage) { $Validator.ErrorMessage } else { "Value does not match required format" }
        $result.AddError($msg)
    }

    # Allowed values validation
    if ($Validator.AllowedValues -and $Validator.AllowedValues.Count -gt 0) {
        if ($Value -notin $Validator.AllowedValues) {
            $allowedList = $Validator.AllowedValues -join ', '
            $result.AddError("Value must be one of: $allowedList")
        }
    }

    # Custom script validation
    if ($Validator.Script) {
        try {
            $scriptResult = & $Validator.Script $Value
            if (-not $scriptResult) {
                $msg = if ($Validator.ErrorMessage) { $Validator.ErrorMessage } else { "Validation failed" }
                $result.AddError($msg)
            }
        } catch {
            $result.AddError("Validation error: $($_.Exception.Message)")
        }
    }

    # Apply transform if valid
    if ($result.IsValid -and $Validator.Transform) {
        try {
            $result.TransformedValue = & $Validator.Transform $Value
        } catch {
            $result.AddError("Transform error: $($_.Exception.Message)")
        }
    } elseif (-not $result.TransformedValue) {
        $result.TransformedValue = $Value
    }

    return $result
}

function Test-SCEmail {
    <#
    .SYNOPSIS
        Quick validation for email addresses
    .PARAMETER Value
        The value to validate
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Value
    )

    $validator = New-SCValidator -Type 'email'
    $result = Test-SCValue -Value $Value -Validator $validator
    return $result.IsValid
}

function Test-SCUrl {
    <#
    .SYNOPSIS
        Quick validation for URLs
    .PARAMETER Value
        The value to validate
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Value
    )

    $validator = New-SCValidator -Type 'url'
    $result = Test-SCValue -Value $Value -Validator $validator
    return $result.IsValid
}

function Test-SCRequired {
    <#
    .SYNOPSIS
        Quick check if value is present (not null/empty)
    .PARAMETER Value
        The value to check
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [object]$Value
    )

    if ($null -eq $Value) { return $false }
    if ($Value -is [string] -and [string]::IsNullOrWhiteSpace($Value)) { return $false }
    return $true
}

function New-SCCompositeValidator {
    <#
    .SYNOPSIS
        Creates a composite validator from multiple validators
    .PARAMETER Validators
        Array of validator configurations
    .PARAMETER Mode
        Combination mode: All (must pass all), Any (must pass at least one)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable[]]$Validators,

        [Parameter()]
        [ValidateSet('All', 'Any')]
        [string]$Mode = 'All'
    )

    return @{
        Type       = 'composite'
        Validators = $Validators
        Mode       = $Mode
    }
}

function Test-SCComposite {
    <#
    .SYNOPSIS
        Validates against a composite validator
    .PARAMETER Value
        The value to validate
    .PARAMETER CompositeValidator
        The composite validator configuration
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [object]$Value,

        [Parameter(Mandatory, Position = 1)]
        [hashtable]$CompositeValidator
    )

    $result = [SCValidationResult]::new()
    $result.Value = $Value
    $results = @()

    foreach ($validator in $CompositeValidator.Validators) {
        $validationResult = Test-SCValue -Value $Value -Validator $validator
        $results += $validationResult
    }

    if ($CompositeValidator.Mode -eq 'All') {
        foreach ($r in $results) {
            if (-not $r.IsValid) {
                foreach ($error in $r.Errors) {
                    $result.AddError($error)
                }
            }
        }
    } else {
        # Any mode - at least one must pass
        $anyValid = $results | Where-Object { $_.IsValid } | Select-Object -First 1
        if (-not $anyValid) {
            foreach ($r in $results) {
                foreach ($error in $r.Errors) {
                    $result.AddError($error)
                }
            }
        }
    }

    $result.TransformedValue = $Value
    return $result
}
