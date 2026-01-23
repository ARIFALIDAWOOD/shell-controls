<#
.SYNOPSIS
    Test mode infrastructure for Shell-Controls
.DESCRIPTION
    Provides mocking and capture capabilities for automated testing of interactive
    CLI components. Enables testing without user interaction.
#>

function Enable-SCTestMode {
    <#
    .SYNOPSIS
        Enables test mode with optional mock inputs and output capture
    .PARAMETER MockInputs
        Hashtable of prompt text -> response for mock input responses
    .PARAMETER InputQueue
        Array of sequential inputs to return in order
    .PARAMETER CaptureOutput
        Enable output capturing for verification
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$MockInputs = @{},

        [Parameter()]
        [array]$InputQueue = @(),

        [Parameter()]
        [switch]$CaptureOutput
    )

    $script:TestMode.Enabled = $true
    $script:TestMode.MockInputs = $MockInputs
    $script:TestMode.CaptureOutput = $CaptureOutput
    $script:TestMode.OutputBuffer.Clear()
    $script:TestMode.MockInputQueue.Clear()

    foreach ($input in $InputQueue) {
        $script:TestMode.MockInputQueue.Enqueue($input)
    }

    Write-Verbose "Test mode enabled. MockInputs: $($MockInputs.Count), InputQueue: $($InputQueue.Count), CaptureOutput: $CaptureOutput"
}

function Disable-SCTestMode {
    <#
    .SYNOPSIS
        Disables test mode and clears all mock data
    #>
    [CmdletBinding()]
    param()

    $script:TestMode.Enabled = $false
    $script:TestMode.MockInputs = @{}
    $script:TestMode.MockInputQueue.Clear()
    $script:TestMode.OutputBuffer.Clear()
    $script:TestMode.CaptureOutput = $false

    Write-Verbose "Test mode disabled"
}

function Test-SCTestModeEnabled {
    <#
    .SYNOPSIS
        Checks if test mode is currently enabled
    #>
    [CmdletBinding()]
    param()

    return $script:TestMode.Enabled
}

function Get-SCMockInput {
    <#
    .SYNOPSIS
        Gets a mock input value for testing
    .PARAMETER Prompt
        The prompt text to match against mock inputs
    .PARAMETER Default
        Default value if no mock is found
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Prompt,

        [Parameter()]
        [string]$Default
    )

    if (-not $script:TestMode.Enabled) {
        return $null
    }

    # First check the input queue for sequential inputs
    if ($script:TestMode.MockInputQueue.Count -gt 0) {
        return $script:TestMode.MockInputQueue.Dequeue()
    }

    # Then check for prompt-specific mock inputs
    if ($Prompt -and $script:TestMode.MockInputs.ContainsKey($Prompt)) {
        return $script:TestMode.MockInputs[$Prompt]
    }

    # Check for partial prompt matches
    foreach ($key in $script:TestMode.MockInputs.Keys) {
        if ($Prompt -like "*$key*") {
            return $script:TestMode.MockInputs[$key]
        }
    }

    return $Default
}

function Add-SCMockInput {
    <#
    .SYNOPSIS
        Adds a mock input to the queue
    .PARAMETER Value
        The input value to add
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]$Value
    )

    if (-not $script:TestMode.Enabled) {
        Write-Warning "Test mode is not enabled. Call Enable-SCTestMode first."
        return
    }

    $script:TestMode.MockInputQueue.Enqueue($Value)
}

function Get-SCCapturedOutput {
    <#
    .SYNOPSIS
        Gets captured output from test mode
    .PARAMETER AsString
        Return as single string instead of array
    .PARAMETER StripAnsi
        Remove ANSI escape sequences from output
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$AsString,

        [Parameter()]
        [switch]$StripAnsi
    )

    $output = $script:TestMode.OutputBuffer.ToArray()

    if ($StripAnsi) {
        $ansiPattern = '\x1b\[[0-9;]*[a-zA-Z]'
        $output = $output | ForEach-Object {
            [regex]::Replace($_, $ansiPattern, '')
        }
    }

    if ($AsString) {
        return $output -join "`n"
    }

    return $output
}

function Clear-SCCapturedOutput {
    <#
    .SYNOPSIS
        Clears the captured output buffer
    #>
    [CmdletBinding()]
    param()

    $script:TestMode.OutputBuffer.Clear()
}

function Write-SCTestOutput {
    <#
    .SYNOPSIS
        Internal function to capture output in test mode
    .PARAMETER Text
        The text to capture/write
    .PARAMETER NoNewline
        Don't add newline
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]$Text,

        [Parameter()]
        [switch]$NoNewline
    )

    if ($script:TestMode.Enabled -and $script:TestMode.CaptureOutput) {
        $null = $script:TestMode.OutputBuffer.Add($Text)
    }

    if (-not $NoNewline) {
        [Console]::WriteLine($Text)
    } else {
        [Console]::Write($Text)
    }
}

function Invoke-SCReadKey {
    <#
    .SYNOPSIS
        Internal helper for reading a key, respects test mode
    .PARAMETER Intercept
        Don't echo the key to console
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Intercept
    )

    if ($script:TestMode.Enabled -and $script:TestMode.MockInputQueue.Count -gt 0) {
        $mockValue = $script:TestMode.MockInputQueue.Dequeue()

        # Return a mock ConsoleKeyInfo-like object
        $key = switch ($mockValue) {
            'Enter' { [ConsoleKey]::Enter }
            'Escape' { [ConsoleKey]::Escape }
            'UpArrow' { [ConsoleKey]::UpArrow }
            'DownArrow' { [ConsoleKey]::DownArrow }
            'LeftArrow' { [ConsoleKey]::LeftArrow }
            'RightArrow' { [ConsoleKey]::RightArrow }
            'Tab' { [ConsoleKey]::Tab }
            'Backspace' { [ConsoleKey]::Backspace }
            'Spacebar' { [ConsoleKey]::Spacebar }
            'Home' { [ConsoleKey]::Home }
            'End' { [ConsoleKey]::End }
            default {
                if ($mockValue.Length -eq 1) {
                    [System.Char]::ToUpper($mockValue[0])
                } else {
                    [ConsoleKey]::NoName
                }
            }
        }

        $keyChar = if ($mockValue.Length -eq 1) { $mockValue[0] } else { [char]0 }

        return [PSCustomObject]@{
            Key     = $key
            KeyChar = $keyChar
            Modifiers = [ConsoleModifiers]::None
        }
    }

    return [Console]::ReadKey($Intercept)
}

function Invoke-SCReadLine {
    <#
    .SYNOPSIS
        Internal helper for reading a line, respects test mode
    .PARAMETER Prompt
        Optional prompt text for mock lookup
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Prompt
    )

    if ($script:TestMode.Enabled) {
        $mockInput = Get-SCMockInput -Prompt $Prompt
        if ($null -ne $mockInput) {
            return $mockInput
        }
    }

    return [Console]::ReadLine()
}

function Get-SCTestModeState {
    <#
    .SYNOPSIS
        Gets the current test mode state for debugging
    #>
    [CmdletBinding()]
    param()

    return @{
        Enabled       = $script:TestMode.Enabled
        MockInputs    = $script:TestMode.MockInputs
        InputQueueCount = $script:TestMode.MockInputQueue.Count
        OutputBufferCount = $script:TestMode.OutputBuffer.Count
        CaptureOutput = $script:TestMode.CaptureOutput
    }
}
