<#
.SYNOPSIS
    Process management for Shell-Controls
#>

function Start-SCProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Command,

        [Parameter()]
        [string[]]$Arguments,

        [Parameter()]
        [string]$WorkingDirectory,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [switch]$ShowOutput,

        [Parameter()]
        [switch]$PassThru
    )

    $desc = if ($Description) { $Description } else { "$Command $($Arguments -join ' ')" }

    Write-SCText ""
    Write-SCInfo "Starting: $desc"
    Write-SCText ""

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $Command
    $psi.Arguments = if ($Arguments) { $Arguments -join ' ' } else { '' }
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    if ($WorkingDirectory) { $psi.WorkingDirectory = $WorkingDirectory }

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $psi

    $outputBuilder = [System.Text.StringBuilder]::new()
    $errorBuilder = [System.Text.StringBuilder]::new()

    $outputHandler = {
        param($sender, $e)
        if ($null -ne $e.Data) {
            [void]$outputBuilder.AppendLine($e.Data)
            if ($ShowOutput) { Write-SCMuted "  $($e.Data)" }
        }
    }

    $errorHandler = {
        param($sender, $e)
        if ($null -ne $e.Data) {
            [void]$errorBuilder.AppendLine($e.Data)
            if ($ShowOutput) { Write-SCText -Text "  $($e.Data)" -Color (Get-SCColor -Name "error") }
        }
    }

    $process.add_OutputDataReceived($outputHandler)
    $process.add_ErrorDataReceived($errorHandler)

    try {
        [void]$process.Start()
        $process.BeginOutputReadLine()
        $process.BeginErrorReadLine()
        $process.WaitForExit()

        $result = [PSCustomObject]@{
            ExitCode = $process.ExitCode
            Output   = $outputBuilder.ToString()
            Error    = $errorBuilder.ToString()
            Success  = ($process.ExitCode -eq 0)
        }

        if ($result.Success) { Write-SCSuccess "Process completed successfully" }
        else { Write-SCError "Process failed with exit code: $($result.ExitCode)" }

        if ($PassThru) { return $result }
    } finally { $process.Dispose() }
}

function Start-SCParallel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Processes,

        [Parameter()]
        [string]$Title = "Running in parallel"
    )

    $jobs = @()
    foreach ($p in $Processes) {
        $cmd = $p.Command
        $args = $p.Arguments
        $wd = $p.WorkingDirectory
        $desc = $p.Description
        $jobs += Start-Job -ScriptBlock {
            param($Command, $Arguments, $WorkingDirectory, $Description)
            $psi = [System.Diagnostics.ProcessStartInfo]::new()
            $psi.FileName = $Command
            $psi.Arguments = if ($Arguments) { $Arguments -join ' ' } else { '' }
            $psi.UseShellExecute = $false
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.CreateNoWindow = $true
            if ($WorkingDirectory) { $psi.WorkingDirectory = $WorkingDirectory }
            $proc = [System.Diagnostics.Process]::Start($psi)
            $proc.WaitForExit()
            return [PSCustomObject]@{ ExitCode = $proc.ExitCode; Name = $Description }
        } -ArgumentList $cmd, $args, $wd, (if ($p.Description) { $p.Description } else { $cmd })
    }

    $jobs | Wait-Job | Out-Null
    $results = $jobs | ForEach-Object { Receive-Job $_; Remove-Job $_ -Force }
    return $results
}

function Watch-SCProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Diagnostics.Process]$Process,

        [Parameter()]
        [string]$Message = "Watching process...",

        [Parameter()]
        [int]$PollInterval = 1000
    )

    $spinnerChars = Get-SCSymbol -Name "spinner"
    if (-not $spinnerChars -or -not ($spinnerChars -is [Array])) { $spinnerChars = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏') }
    $primaryAnsi = ConvertTo-AnsiColor -HexColor (Get-SCColor -Name "primary")
    $reset = Get-AnsiReset
    $frame = 0
    $startPos = [Console]::CursorTop

    [Console]::CursorVisible = $false

    try {
        while (-not $Process.HasExited) {
            $char = $spinnerChars[$frame % $spinnerChars.Count]
            $mem = [Math]::Round($Process.WorkingSet64 / 1MB, 1)
            $cpu = $Process.TotalProcessorTime.TotalSeconds
            [Console]::SetCursorPosition(0, $startPos)
            [Console]::Write((" " * [Math]::Max(1, [Console]::WindowWidth)))
            [Console]::SetCursorPosition(0, $startPos)
            [Console]::Write("  ${primaryAnsi}${char}${reset} ${Message}  [PID: $($Process.Id) | Mem: ${mem}MB | CPU: ${cpu}s]")
            $frame++
            Start-Sleep -Milliseconds $PollInterval
        }
        [Console]::SetCursorPosition(0, $startPos)
        [Console]::Write((" " * [Math]::Max(1, [Console]::WindowWidth)))
        [Console]::SetCursorPosition(0, $startPos)
        if ($Process.ExitCode -eq 0) { Write-SCSuccess "$Message - Completed" }
        else { Write-SCError "$Message - Failed (Exit: $($Process.ExitCode))" }
    } finally { [Console]::CursorVisible = $true }
}
