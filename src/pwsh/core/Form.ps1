<#
.SYNOPSIS
    Form and wizard system for Shell-Controls
.DESCRIPTION
    Provides structured form input and multi-step wizard functionality.
#>

function Show-SCForm {
    <#
    .SYNOPSIS
        Displays an interactive form with multiple fields
    .PARAMETER Fields
        Array of field definitions with: Name, Type, Label, Default, Validator, Options, Required
        Types: text, password, number, email, url, date, select, multiselect, confirm
    .PARAMETER Title
        Form title
    .PARAMETER InitialValues
        Hashtable of initial field values
    .PARAMETER ShowSummary
        Show summary before final submission
    .PARAMETER OnSubmit
        Scriptblock to execute on submit { param($values) }
    .PARAMETER AllowCancel
        Allow form cancellation with Escape
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Fields,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [hashtable]$InitialValues = @{},

        [Parameter()]
        [switch]$ShowSummary,

        [Parameter()]
        [scriptblock]$OnSubmit,

        [Parameter()]
        [switch]$AllowCancel
    )

    $values = @{}
    $primaryColor = Get-SCColor -Name "primary"
    $errorColor = Get-SCColor -Name "error"
    $successColor = Get-SCColor -Name "success"
    $mutedColor = Get-SCColor -Name "muted"

    # Display title
    if ($Title) {
        Write-SCText ""
        Write-SCText -Text $Title -Color $primaryColor -Bold
        Write-SCLine -Color $mutedColor
        Write-SCText ""
    }

    # Process each field
    foreach ($field in $Fields) {
        $fieldName = $field.Name
        $fieldType = if ($field.Type) { $field.Type } else { 'text' }
        $fieldLabel = if ($field.Label) { $field.Label } else { $fieldName }
        $fieldDefault = if ($InitialValues.ContainsKey($fieldName)) { $InitialValues[$fieldName] } elseif ($field.Default) { $field.Default } else { $null }
        $fieldRequired = if ($null -ne $field.Required) { $field.Required } else { $false }
        $fieldValidator = $field.Validator
        $fieldOptions = $field.Options

        $value = $null
        $valid = $false

        while (-not $valid) {
            $value = switch ($fieldType) {
                'text' {
                    Read-SCInput -Prompt $fieldLabel -Default $fieldDefault -Required:$fieldRequired
                }
                'password' {
                    $minLen = if ($field.MinLength) { $field.MinLength } else { 0 }
                    Read-SCPassword -Prompt $fieldLabel -MinLength $minLen -AsPlainText
                }
                'number' {
                    $min = if ($null -ne $field.Min) { $field.Min } else { [double]::MinValue }
                    $max = if ($null -ne $field.Max) { $field.Max } else { [double]::MaxValue }
                    Read-SCNumber -Prompt $fieldLabel -Min $min -Max $max -Default $fieldDefault -Integer:($field.Integer -eq $true)
                }
                'email' {
                    $allowedDomains = if ($field.AllowedDomains) { $field.AllowedDomains } else { @() }
                    Read-SCEmail -Prompt $fieldLabel -AllowedDomains $allowedDomains -Default $fieldDefault -AllowEmpty:(-not $fieldRequired)
                }
                'url' {
                    $schemes = if ($field.AllowedSchemes) { $field.AllowedSchemes } else { @('http', 'https') }
                    Read-SCUrl -Prompt $fieldLabel -AllowedSchemes $schemes -Default $fieldDefault -AllowEmpty:(-not $fieldRequired)
                }
                'date' {
                    $format = if ($field.Format) { $field.Format } else { "yyyy-MM-dd" }
                    Read-SCDate -Prompt $fieldLabel -Format $format -Default $fieldDefault -AllowEmpty:(-not $fieldRequired)
                }
                'select' {
                    if ($fieldOptions -and $fieldOptions.Count -gt 0) {
                        if ($fieldOptions.Count -le 5) {
                            Read-SCChoice -Message $fieldLabel -Choices $fieldOptions -DefaultIndex 0
                        } else {
                            Show-SCMenu -Title $fieldLabel -Items $fieldOptions -ReturnIndex:$false
                        }
                    } else {
                        Write-SCWarning "No options provided for select field: $fieldName"
                        $null
                    }
                }
                'multiselect' {
                    if ($fieldOptions -and $fieldOptions.Count -gt 0) {
                        Show-SCMultiSelect -Title $fieldLabel -Items $fieldOptions
                    } else {
                        Write-SCWarning "No options provided for multiselect field: $fieldName"
                        @()
                    }
                }
                'confirm' {
                    $defaultYes = if ($fieldDefault -eq $true) { $true } else { $false }
                    Read-SCConfirm -Message $fieldLabel -DefaultYes:$defaultYes
                }
                default {
                    Read-SCInput -Prompt $fieldLabel -Default $fieldDefault -Required:$fieldRequired
                }
            }

            # Apply custom validator
            if ($fieldValidator) {
                $validationResult = Test-SCValue -Value $value -Validator $fieldValidator
                if (-not $validationResult.IsValid) {
                    foreach ($error in $validationResult.Errors) {
                        Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') $error" -Color $errorColor
                    }
                    continue
                }
                $value = $validationResult.TransformedValue ?? $value
            }

            $valid = $true
        }

        $values[$fieldName] = $value
    }

    # Show summary
    if ($ShowSummary) {
        Write-SCText ""
        Write-SCText -Text "Summary" -Color $primaryColor -Bold
        Write-SCLine -Color $mutedColor

        foreach ($field in $Fields) {
            $fieldName = $field.Name
            $fieldLabel = if ($field.Label) { $field.Label } else { $fieldName }
            $displayValue = $values[$fieldName]

            if ($field.Type -eq 'password') {
                $displayValue = '*' * 8
            } elseif ($displayValue -is [array]) {
                $displayValue = $displayValue -join ', '
            } elseif ($displayValue -is [datetime]) {
                $format = if ($field.Format) { $field.Format } else { "yyyy-MM-dd" }
                $displayValue = $displayValue.ToString($format)
            }

            Write-SCText -Text "  $fieldLabel`: $displayValue" -Color $mutedColor
        }

        Write-SCText ""
        $confirm = Read-SCConfirm -Message "Submit this form?" -DefaultYes
        if (-not $confirm) {
            Write-SCInfo "Form cancelled"
            return $null
        }
    }

    # Execute OnSubmit
    if ($OnSubmit) {
        try {
            & $OnSubmit $values
        } catch {
            Write-SCError "Submit error: $($_.Exception.Message)"
        }
    }

    return $values
}

function Show-SCWizard {
    <#
    .SYNOPSIS
        Displays a multi-step wizard
    .PARAMETER Steps
        Array of step definitions with: Title, Fields, OnComplete, SkipIf
    .PARAMETER Title
        Wizard title
    .PARAMETER AllowBack
        Allow going back to previous steps
    .PARAMETER ShowProgress
        Show step progress indicator
    .PARAMETER OnComplete
        Scriptblock to execute when wizard completes { param($allValues) }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Steps,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [switch]$AllowBack,

        [Parameter()]
        [switch]$ShowProgress,

        [Parameter()]
        [scriptblock]$OnComplete
    )

    $allValues = @{}
    $stepIndex = 0
    $totalSteps = $Steps.Count
    $primaryColor = Get-SCColor -Name "primary"
    $mutedColor = Get-SCColor -Name "muted"
    $successColor = Get-SCColor -Name "success"

    while ($stepIndex -lt $totalSteps) {
        $step = $Steps[$stepIndex]

        # Check skip condition
        if ($step.SkipIf -and (& $step.SkipIf $allValues)) {
            $stepIndex++
            continue
        }

        # Clear and show header
        Write-SCText ""

        if ($Title) {
            Write-SCText -Text $Title -Color $primaryColor -Bold
        }

        if ($ShowProgress) {
            $progressBar = ""
            for ($i = 0; $i -lt $totalSteps; $i++) {
                if ($i -lt $stepIndex) {
                    $progressBar += "$(Get-SCSymbol -Name 'check') "
                } elseif ($i -eq $stepIndex) {
                    $progressBar += "$(Get-SCSymbol -Name 'bullet') "
                } else {
                    $progressBar += "○ "
                }
            }
            Write-SCText -Text "  Step $($stepIndex + 1) of $totalSteps  $progressBar" -Color $mutedColor
            Write-SCText ""
        }

        # Show step title
        $stepTitle = if ($step.Title) { $step.Title } else { "Step $($stepIndex + 1)" }
        Write-SCText -Text $stepTitle -Color $primaryColor -Bold
        Write-SCLine -Color $mutedColor

        if ($step.Description) {
            Write-SCText -Text $step.Description -Color $mutedColor
            Write-SCText ""
        }

        # Process step fields
        $stepValues = Show-SCForm -Fields $step.Fields -InitialValues $allValues

        if ($null -eq $stepValues) {
            # Form was cancelled
            if ($AllowBack -and $stepIndex -gt 0) {
                $goBack = Read-SCConfirm -Message "Go back to previous step?" -DefaultYes
                if ($goBack) {
                    $stepIndex--
                    continue
                }
            }
            Write-SCWarning "Wizard cancelled"
            return $null
        }

        # Merge values
        foreach ($key in $stepValues.Keys) {
            $allValues[$key] = $stepValues[$key]
        }

        # Execute step OnComplete
        if ($step.OnComplete) {
            try {
                & $step.OnComplete $allValues
            } catch {
                Write-SCError "Step error: $($_.Exception.Message)"
            }
        }

        # Navigation
        if ($AllowBack -and $stepIndex -gt 0 -and $stepIndex -lt $totalSteps - 1) {
            Write-SCText ""
            $nav = Read-SCChoice -Message "Continue" -Choices @('Next', 'Back', 'Cancel')
            switch ($nav) {
                'Back' { $stepIndex--; continue }
                'Cancel' { Write-SCWarning "Wizard cancelled"; return $null }
            }
        }

        $stepIndex++
    }

    # Wizard complete
    Write-SCText ""
    Write-SCSuccess "Wizard completed!"

    if ($OnComplete) {
        try {
            & $OnComplete $allValues
        } catch {
            Write-SCError "Completion error: $($_.Exception.Message)"
        }
    }

    return $allValues
}

function New-SCFormField {
    <#
    .SYNOPSIS
        Helper to create a form field definition
    .PARAMETER Name
        Field name (key in result hashtable)
    .PARAMETER Type
        Field type: text, password, number, email, url, date, select, multiselect, confirm
    .PARAMETER Label
        Display label
    .PARAMETER Default
        Default value
    .PARAMETER Required
        Mark as required
    .PARAMETER Validator
        Validator from New-SCValidator
    .PARAMETER Options
        Options for select/multiselect fields
    .PARAMETER Min
        Minimum value (for number)
    .PARAMETER Max
        Maximum value (for number)
    .PARAMETER MinLength
        Minimum length (for password)
    .PARAMETER AllowedDomains
        Allowed domains (for email)
    .PARAMETER AllowedSchemes
        Allowed schemes (for url)
    .PARAMETER Format
        Date format (for date)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [ValidateSet('text', 'password', 'number', 'email', 'url', 'date', 'select', 'multiselect', 'confirm')]
        [string]$Type = 'text',

        [Parameter()]
        [string]$Label,

        [Parameter()]
        [object]$Default,

        [Parameter()]
        [switch]$Required,

        [Parameter()]
        [hashtable]$Validator,

        [Parameter()]
        [array]$Options,

        [Parameter()]
        [double]$Min,

        [Parameter()]
        [double]$Max,

        [Parameter()]
        [int]$MinLength,

        [Parameter()]
        [string[]]$AllowedDomains,

        [Parameter()]
        [string[]]$AllowedSchemes,

        [Parameter()]
        [string]$Format,

        [Parameter()]
        [switch]$Integer
    )

    $field = @{
        Name = $Name
        Type = $Type
        Label = if ($Label) { $Label } else { $Name }
        Required = $Required.IsPresent
    }

    if ($null -ne $Default) { $field.Default = $Default }
    if ($Validator) { $field.Validator = $Validator }
    if ($Options) { $field.Options = $Options }
    if ($PSBoundParameters.ContainsKey('Min')) { $field.Min = $Min }
    if ($PSBoundParameters.ContainsKey('Max')) { $field.Max = $Max }
    if ($MinLength -gt 0) { $field.MinLength = $MinLength }
    if ($AllowedDomains) { $field.AllowedDomains = $AllowedDomains }
    if ($AllowedSchemes) { $field.AllowedSchemes = $AllowedSchemes }
    if ($Format) { $field.Format = $Format }
    if ($Integer) { $field.Integer = $true }

    return $field
}

function New-SCWizardStep {
    <#
    .SYNOPSIS
        Helper to create a wizard step definition
    .PARAMETER Title
        Step title
    .PARAMETER Description
        Step description
    .PARAMETER Fields
        Array of field definitions
    .PARAMETER OnComplete
        Scriptblock to execute after step { param($allValues) }
    .PARAMETER SkipIf
        Scriptblock that returns $true to skip step { param($allValues) }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [AllowEmptyCollection()]
        [array]$Fields = @(),

        [Parameter()]
        [scriptblock]$OnComplete,

        [Parameter()]
        [scriptblock]$SkipIf
    )

    $step = @{
        Title = $Title
        Fields = $Fields
    }

    if ($Description) { $step.Description = $Description }
    if ($OnComplete) { $step.OnComplete = $OnComplete }
    if ($SkipIf) { $step.SkipIf = $SkipIf }

    return $step
}
