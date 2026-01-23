<#
.SYNOPSIS
    Input handling functions for Shell-Controls
#>

function Read-SCInput {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Prompt = "Enter value",

        [Parameter()]
        [string]$Default,

        [Parameter()]
        [scriptblock]$Validate,

        [Parameter()]
        [string]$ValidationMessage = "Invalid input",

        [Parameter()]
        [switch]$Required,

        [Parameter()]
        [string]$Placeholder
    )

    $primaryColor = Get-SCColor -Name "primary"
    $mutedColor = Get-SCColor -Name "muted"
    $errorColor = Get-SCColor -Name "error"
    $pointer = Get-SCSymbol -Name "pointer"

    $defaultHint = if ($Default) { " ($Default)" } else { "" }
    $requiredMark = if ($Required) { " *" } else { "" }

    while ($true) {
        $promptAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
        $hintAnsi = ConvertTo-AnsiColor -HexColor $mutedColor
        $reset = Get-AnsiReset

        Write-Host ""
        Write-Host "  ${promptAnsi}${pointer}${reset} ${promptAnsi}${Prompt}${requiredMark}${reset}${hintAnsi}${defaultHint}${reset}"
        Write-Host -NoNewline "    "

        $inputVal = Read-Host

        if ([string]::IsNullOrWhiteSpace($inputVal)) {
            if ($Default) { return $Default }
            elseif ($Required) {
                Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') This field is required" -Color $errorColor
                continue
            } else { return $null }
        }

        if ($Validate) {
            $isValid = & $Validate $inputVal
            if (-not $isValid) {
                Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') $ValidationMessage" -Color $errorColor
                continue
            }
        }

        return $inputVal
    }
}

function Read-SCPassword {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Prompt = "Enter password",

        [Parameter()]
        [switch]$Confirm,

        [Parameter()]
        [int]$MinLength = 0,

        [Parameter()]
        [switch]$AsPlainText
    )

    $primaryColor = Get-SCColor -Name "primary"
    $errorColor = Get-SCColor -Name "error"
    $pointer = Get-SCSymbol -Name "pointer"

    while ($true) {
        $promptAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
        $reset = Get-AnsiReset

        Write-Host ""
        Write-Host "  ${promptAnsi}${pointer}${reset} ${promptAnsi}${Prompt}${reset}"
        Write-Host -NoNewline "    "

        $secureString = Read-Host -AsSecureString

        if ($MinLength -gt 0) {
            $plainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
            )
            if ($plainText.Length -lt $MinLength) {
                Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') Password must be at least $MinLength characters" -Color $errorColor
                continue
            }
        }

        if ($Confirm) {
            Write-Host "  ${promptAnsi}${pointer}${reset} ${promptAnsi}Confirm password${reset}"
            Write-Host -NoNewline "    "
            $confirmSecure = Read-Host -AsSecureString
            $pass1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
            )
            $pass2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmSecure)
            )
            if ($pass1 -ne $pass2) {
                Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') Passwords do not match" -Color $errorColor
                continue
            }
        }

        if ($AsPlainText) {
            return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
            )
        }
        return $secureString
    }
}

function Read-SCConfirm {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Message = "Are you sure?",

        [Parameter()]
        [switch]$DefaultYes,

        [Parameter()]
        [string]$YesLabel = "Yes",

        [Parameter()]
        [string]$NoLabel = "No"
    )

    $primaryColor = Get-SCColor -Name "primary"
    $mutedColor = Get-SCColor -Name "muted"
    $question = Get-SCSymbol -Name "question"

    $yHint = if ($DefaultYes) { "Y" } else { "y" }
    $nHint = if ($DefaultYes) { "n" } else { "N" }
    $hint = "($yHint/$nHint)"

    $primaryAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
    $mutedAnsi = ConvertTo-AnsiColor -HexColor $mutedColor
    $reset = Get-AnsiReset

    Write-Host ""
    Write-Host -NoNewline "  ${primaryAnsi}${question}${reset} ${primaryAnsi}${Message}${reset} ${mutedAnsi}${hint}${reset} "

    while ($true) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq 'Enter') { [Console]::WriteLine(); return $DefaultYes }
        elseif ($key.KeyChar -eq 'y' -or $key.KeyChar -eq 'Y') { [Console]::WriteLine("Yes"); return $true }
        elseif ($key.KeyChar -eq 'n' -or $key.KeyChar -eq 'N') { [Console]::WriteLine("No"); return $false }
    }
}

function Read-SCChoice {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Message = "Select an option",

        [Parameter(Mandatory)]
        [array]$Choices,

        [Parameter()]
        [int]$DefaultIndex = 0
    )

    $primaryColor = Get-SCColor -Name "primary"
    $accentColor = Get-SCColor -Name "accent"
    $mutedColor = Get-SCColor -Name "muted"
    $pointer = Get-SCSymbol -Name "pointer"

    $selectedIndex = [Math]::Min($DefaultIndex, [Math]::Max(0, $Choices.Count - 1))
    [Console]::CursorVisible = $false

    try {
        while ($true) {
            $primaryAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
            $accentAnsi = ConvertTo-AnsiColor -HexColor $accentColor
            $mutedAnsi = ConvertTo-AnsiColor -HexColor $mutedColor
            $reset = Get-AnsiReset

            $choiceDisplay = ""
            for ($i = 0; $i -lt $Choices.Count; $i++) {
                $c = $Choices[$i]
                if ($i -eq $selectedIndex) { $choiceDisplay += " ${accentAnsi}[$c]${reset}" }
                else { $choiceDisplay += " ${mutedAnsi}$c${reset}" }
            }

            [Console]::SetCursorPosition(0, [Console]::CursorTop)
            [Console]::Write((" " * [Math]::Max(1, [Console]::WindowWidth)))
            [Console]::SetCursorPosition(0, [Console]::CursorTop)
            [Console]::Write("  ${primaryAnsi}${pointer}${reset} ${primaryAnsi}${Message}${reset}:${choiceDisplay}")

            $key = [Console]::ReadKey($true)
            switch ($key.Key) {
                'LeftArrow' { $selectedIndex = ($selectedIndex - 1 + $Choices.Count) % [Math]::Max(1, $Choices.Count) }
                'RightArrow' { $selectedIndex = ($selectedIndex + 1) % [Math]::Max(1, $Choices.Count) }
                'Enter' { [Console]::WriteLine(); [Console]::CursorVisible = $true; return $Choices[$selectedIndex] }
            }
        }
    } finally { [Console]::CursorVisible = $true }
}

function Read-SCNumber {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Prompt = "Enter a number",

        [Parameter()]
        [double]$Min = [double]::MinValue,

        [Parameter()]
        [double]$Max = [double]::MaxValue,

        [Parameter()]
        [object]$Default = $null,

        [Parameter()]
        [switch]$Integer
    )

    $defaultStr = if ($null -ne $Default) { [string]$Default } else { $null }
    $validation = {
        param($input)
        $num = 0
        if ($Integer) { if (-not [int]::TryParse($input, [ref]$num)) { return $false } }
        else { if (-not [double]::TryParse($input, [ref]$num)) { return $false } }
        return ($num -ge $Min -and $num -le $Max)
    }

    $range = if ($Min -ne [double]::MinValue -or $Max -ne [double]::MaxValue) { "Range: [$Min - $Max]" } else { "" }
    $result = Read-SCInput -Prompt "$Prompt $range" -Default $defaultStr -Validate $validation -ValidationMessage "Please enter a valid number"

    if ($null -eq $result) { return $null }
    if ($Integer) { return [int]$result }
    return [double]$result
}

function Read-SCPath {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Prompt = "Enter path",

        [Parameter()]
        [ValidateSet('File', 'Directory', 'Any')]
        [string]$Type = 'Any',

        [Parameter()]
        [switch]$MustExist,

        [Parameter()]
        [string]$Default
    )

    $validation = {
        param($input)
        if (-not $MustExist) { return $true }
        switch ($Type) {
            'File' { return Test-Path $input -PathType Leaf }
            'Directory' { return Test-Path $input -PathType Container }
            'Any' { return Test-Path $input }
        }
    }

    $message = if ($MustExist) { "Path must exist" } else { "Invalid path" }
    return Read-SCInput -Prompt $Prompt -Default $Default -Validate $validation -ValidationMessage $message
}

function Read-SCDate {
    <#
    .SYNOPSIS
        Reads a date input with validation
    .PARAMETER Prompt
        The prompt to display
    .PARAMETER Format
        Expected date format for display hint
    .PARAMETER Min
        Minimum allowed date
    .PARAMETER Max
        Maximum allowed date
    .PARAMETER Default
        Default value
    .PARAMETER AllowEmpty
        Allow empty input
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Prompt = "Enter date",

        [Parameter()]
        [string]$Format = "yyyy-MM-dd",

        [Parameter()]
        [datetime]$Min,

        [Parameter()]
        [datetime]$Max,

        [Parameter()]
        [string]$Default,

        [Parameter()]
        [switch]$AllowEmpty
    )

    $errorColor = Get-SCColor -Name "error"

    while ($true) {
        $hint = "Format: $Format"
        $result = Read-SCInput -Prompt "$Prompt ($hint)" -Default $Default -Required:(-not $AllowEmpty)

        if ([string]::IsNullOrWhiteSpace($result) -and $AllowEmpty) {
            return $null
        }

        $parsed = [datetime]::MinValue
        if (-not [datetime]::TryParse($result, [ref]$parsed)) {
            Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') Please enter a valid date" -Color $errorColor
            continue
        }

        if ($Min -and $parsed -lt $Min) {
            Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') Date must be on or after $($Min.ToString($Format))" -Color $errorColor
            continue
        }

        if ($Max -and $parsed -gt $Max) {
            Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') Date must be on or before $($Max.ToString($Format))" -Color $errorColor
            continue
        }

        return $parsed
    }
}

function Read-SCUrl {
    <#
    .SYNOPSIS
        Reads a URL input with validation
    .PARAMETER Prompt
        The prompt to display
    .PARAMETER AllowedSchemes
        Allowed URL schemes (default: http, https)
    .PARAMETER CheckReachable
        Attempt to verify URL is reachable
    .PARAMETER Default
        Default value
    .PARAMETER AllowEmpty
        Allow empty input
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Prompt = "Enter URL",

        [Parameter()]
        [string[]]$AllowedSchemes = @('http', 'https'),

        [Parameter()]
        [switch]$CheckReachable,

        [Parameter()]
        [string]$Default,

        [Parameter()]
        [switch]$AllowEmpty
    )

    $errorColor = Get-SCColor -Name "error"
    $infoColor = Get-SCColor -Name "info"

    while ($true) {
        $result = Read-SCInput -Prompt $Prompt -Default $Default -Required:(-not $AllowEmpty)

        if ([string]::IsNullOrWhiteSpace($result) -and $AllowEmpty) {
            return $null
        }

        # Validate URL format
        try {
            $uri = [System.Uri]::new($result)

            if ($AllowedSchemes -and $uri.Scheme -notin $AllowedSchemes) {
                $schemeList = $AllowedSchemes -join ', '
                Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') URL must use one of: $schemeList" -Color $errorColor
                continue
            }

            if ($CheckReachable) {
                Write-SCText -Text "    $(Get-SCSymbol -Name 'info') Checking URL..." -Color $infoColor
                try {
                    $response = Invoke-WebRequest -Uri $result -Method Head -TimeoutSec 5 -ErrorAction Stop
                    if ($response.StatusCode -ge 400) {
                        Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') URL returned error: $($response.StatusCode)" -Color $errorColor
                        continue
                    }
                } catch {
                    Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') URL is not reachable" -Color $errorColor
                    continue
                }
            }

            return $result
        } catch {
            Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') Please enter a valid URL" -Color $errorColor
        }
    }
}

function Read-SCEmail {
    <#
    .SYNOPSIS
        Reads an email input with validation
    .PARAMETER Prompt
        The prompt to display
    .PARAMETER AllowedDomains
        Restrict to specific domains (empty = allow all)
    .PARAMETER Default
        Default value
    .PARAMETER AllowEmpty
        Allow empty input
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Prompt = "Enter email",

        [Parameter()]
        [string[]]$AllowedDomains = @(),

        [Parameter()]
        [string]$Default,

        [Parameter()]
        [switch]$AllowEmpty
    )

    $errorColor = Get-SCColor -Name "error"
    $emailPattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

    while ($true) {
        $result = Read-SCInput -Prompt $Prompt -Default $Default -Required:(-not $AllowEmpty)

        if ([string]::IsNullOrWhiteSpace($result) -and $AllowEmpty) {
            return $null
        }

        if ($result -notmatch $emailPattern) {
            Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') Please enter a valid email address" -Color $errorColor
            continue
        }

        if ($AllowedDomains.Count -gt 0) {
            $domain = $result.Split('@')[1].ToLower()
            $allowed = $false
            foreach ($allowedDomain in $AllowedDomains) {
                if ($domain -eq $allowedDomain.ToLower() -or $domain.EndsWith(".$($allowedDomain.ToLower())")) {
                    $allowed = $true
                    break
                }
            }
            if (-not $allowed) {
                $domainList = $AllowedDomains -join ', '
                Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') Email domain must be: $domainList" -Color $errorColor
                continue
            }
        }

        return $result
    }
}

function Read-SCInputWithSuggest {
    <#
    .SYNOPSIS
        Reads input with autocomplete suggestions
    .PARAMETER Prompt
        The prompt to display
    .PARAMETER Suggestions
        Static list of suggestions
    .PARAMETER SuggestScript
        Dynamic suggestion scriptblock { param($input) return @(...) }
    .PARAMETER SuggestMode
        How to match: Prefix, Contains, Fuzzy
    .PARAMETER MaxSuggestions
        Maximum suggestions to show
    .PARAMETER Default
        Default value
    .PARAMETER Required
        Require non-empty input
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Prompt = "Enter value",

        [Parameter()]
        [string[]]$Suggestions = @(),

        [Parameter()]
        [scriptblock]$SuggestScript,

        [Parameter()]
        [ValidateSet('Prefix', 'Contains', 'Fuzzy')]
        [string]$SuggestMode = 'Prefix',

        [Parameter()]
        [int]$MaxSuggestions = 5,

        [Parameter()]
        [string]$Default,

        [Parameter()]
        [switch]$Required
    )

    $primaryColor = Get-SCColor -Name "primary"
    $mutedColor = Get-SCColor -Name "muted"
    $accentColor = Get-SCColor -Name "accent"
    $errorColor = Get-SCColor -Name "error"
    $pointer = Get-SCSymbol -Name "pointer"

    $defaultHint = if ($Default) { " ($Default)" } else { "" }
    $requiredMark = if ($Required) { " *" } else { "" }

    $promptAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
    $hintAnsi = ConvertTo-AnsiColor -HexColor $mutedColor
    $accentAnsi = ConvertTo-AnsiColor -HexColor $accentColor
    $reset = Get-AnsiReset

    while ($true) {
        Write-Host ""
        Write-Host "  ${promptAnsi}${pointer}${reset} ${promptAnsi}${Prompt}${requiredMark}${reset}${hintAnsi}${defaultHint}${reset}"

        $input = ""
        $selectedSuggestion = -1
        $currentSuggestions = @()

        [Console]::CursorVisible = $true
        Write-Host -NoNewline "    "

        while ($true) {
            $key = [Console]::ReadKey($true)

            if ($key.Key -eq 'Enter') {
                if ($selectedSuggestion -ge 0 -and $currentSuggestions.Count -gt 0) {
                    $input = $currentSuggestions[$selectedSuggestion]
                }
                [Console]::WriteLine()
                break
            }
            elseif ($key.Key -eq 'Escape') {
                $input = ""
                [Console]::WriteLine()
                break
            }
            elseif ($key.Key -eq 'Tab' -and $currentSuggestions.Count -gt 0) {
                $selectedSuggestion = ($selectedSuggestion + 1) % $currentSuggestions.Count
            }
            elseif ($key.Key -eq 'Backspace' -and $input.Length -gt 0) {
                $input = $input.Substring(0, $input.Length - 1)
                $selectedSuggestion = -1
            }
            elseif ($key.KeyChar -and -not [char]::IsControl($key.KeyChar)) {
                $input += $key.KeyChar
                $selectedSuggestion = -1
            }

            # Get suggestions
            if ($SuggestScript) {
                $currentSuggestions = @(& $SuggestScript $input | Select-Object -First $MaxSuggestions)
            } elseif ($Suggestions.Count -gt 0) {
                $currentSuggestions = switch ($SuggestMode) {
                    'Prefix'   { @($Suggestions | Where-Object { $_ -like "$input*" } | Select-Object -First $MaxSuggestions) }
                    'Contains' { @($Suggestions | Where-Object { $_ -like "*$input*" } | Select-Object -First $MaxSuggestions) }
                    'Fuzzy'    { @($Suggestions | Where-Object { $_ -match ($input -replace '.', '$0.*') } | Select-Object -First $MaxSuggestions) }
                }
            }

            # Redraw input line
            [Console]::SetCursorPosition(0, [Console]::CursorTop)
            $displayText = "    $input"
            if ($currentSuggestions.Count -gt 0) {
                $hint = if ($selectedSuggestion -ge 0) { $currentSuggestions[$selectedSuggestion] } else { $currentSuggestions[0] }
                if ($hint.StartsWith($input)) {
                    $completion = $hint.Substring($input.Length)
                    $displayText = "    $input${hintAnsi}${completion}${reset}"
                }
            }
            $padLen = [Math]::Max(0, [Console]::WindowWidth - $displayText.Length - 5)
            [Console]::Write("${displayText}$(' ' * $padLen)")
            [Console]::SetCursorPosition(4 + $input.Length, [Console]::CursorTop)
        }

        [Console]::CursorVisible = $true

        if ([string]::IsNullOrWhiteSpace($input)) {
            if ($Default) { return $Default }
            elseif ($Required) {
                Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') This field is required" -Color $errorColor
                continue
            } else { return $null }
        }

        return $input
    }
}
