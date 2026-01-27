<#
.SYNOPSIS
    Advanced spinner and task progress for Shell-Controls
#>

class SCTaskRunner {
    [string]$Name
    [scriptblock]$Action
    [string]$Status
    [bool]$Success
    [object]$Result
    [System.Exception]$Error

    SCTaskRunner([string]$name, [scriptblock]$action) {
        $this.Name = $name
        $this.Action = $action
        $this.Status = "pending"
        $this.Success = $false
    }
}

function Start-SCTasks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Tasks,

        [Parameter()]
        [string]$Title = "Running Tasks",

        [Parameter()]
        [switch]$StopOnError,

        [Parameter()]
        [switch]$Parallel
    )

    $successColor = Get-SCColor -Name "success"
    $errorColor = Get-SCColor -Name "error"
    $primaryColor = Get-SCColor -Name "primary"
    $check = Get-SCSymbol -Name "check"
    $cross = Get-SCSymbol -Name "cross"
    $spinner = Get-SCSymbol -Name "spinner"
    if (-not $spinner -or -not ($spinner -is [Array])) { $spinner = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏') }

    Write-SCText ""
    Write-SCText -Text $Title -Color $primaryColor -Bold
    Write-SCText ""

    $taskObjects = $Tasks | ForEach-Object {
        if ($_ -is [hashtable]) { [SCTaskRunner]::new($_.Name, $_.Action) }
        else { [SCTaskRunner]::new($_.ToString(), $_) }
    }

    $startLine = [Console]::CursorTop
    $taskCount = $taskObjects.Count

    foreach ($task in $taskObjects) { Write-SCMuted "  ○ $($task.Name)" }

    [Console]::CursorVisible = $false

    try {
        for ($i = 0; $i -lt $taskCount; $i++) {
            $task = $taskObjects[$i]
            $task.Status = "running"

            $colorAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
            $reset = Get-AnsiReset

            $spinnerJob = Start-Job -ScriptBlock {
                param($taskIndex, $startLine, $taskName, $spinnerChars, $colorAnsi, $reset)
                $frame = 0
                while ($true) {
                    $char = $spinnerChars[$frame % [Math]::Max(1, $spinnerChars.Count)]
                    [Console]::SetCursorPosition(0, $startLine + $taskIndex)
                    [Console]::Write((" " * [Math]::Max(1, [Console]::WindowWidth)))
                    [Console]::SetCursorPosition(0, $startLine + $taskIndex)
                    [Console]::Write("  ${colorAnsi}${char}${reset} ${taskName}")
                    $frame++
                    Start-Sleep -Milliseconds 80
                }
            } -ArgumentList $i, $startLine, $task.Name, $spinner, $colorAnsi, $reset

            try {
                $task.Result = & $task.Action
                $task.Success = $true
                $task.Status = "completed"
            } catch {
                $task.Success = $false
                $task.Status = "failed"
                $task.Error = $_
            }

            Stop-Job -Job $spinnerJob -ErrorAction SilentlyContinue
            Remove-Job -Job $spinnerJob -Force -ErrorAction SilentlyContinue

            [Console]::SetCursorPosition(0, $startLine + $i)
            [Console]::Write((" " * [Math]::Max(1, [Console]::WindowWidth)))
            [Console]::SetCursorPosition(0, $startLine + $i)

            if ($task.Success) {
                $successAnsi = ConvertTo-AnsiColor -HexColor $successColor
                [Console]::WriteLine("  ${successAnsi}${check}${reset} $($task.Name)")
            } else {
                $errorAnsi = ConvertTo-AnsiColor -HexColor $errorColor
                [Console]::WriteLine("  ${errorAnsi}${cross}${reset} $($task.Name)")
                if ($StopOnError) { break }
            }
        }

        [Console]::SetCursorPosition(0, $startLine + $taskCount)
        Write-SCText ""

        $succeeded = (@($taskObjects | Where-Object { $_.Success }).Count)
        $failed = $taskCount - $succeeded

        if ($failed -eq 0) { Write-SCSuccess "All $taskCount tasks completed successfully" }
        else { Write-SCWarning "$succeeded/$taskCount tasks completed, $failed failed" }

        return $taskObjects

    } finally { [Console]::CursorVisible = $true }
}
