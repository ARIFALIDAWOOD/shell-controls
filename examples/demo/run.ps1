#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Demo script for Shell-Controls (non-interactive showcase).
#>

$mod = Join-Path $PSScriptRoot "..\..\src\pwsh\Shell-Controls.psd1"
Import-Module $mod -Force

Initialize-ShellControls -ThemeName "catppuccin" -Force

Write-SCText ""
Write-SCHeader -Text "Shell-Controls Demo" -Icon "◆" -WithLine

Write-SCSuccess "Success message"
Write-SCWarning "Warning message"
Write-SCInfo "Info message"
Write-SCMuted "Muted message"

Write-SCText ""
Write-SCLine

$data = @(
    @{ Name = "Alpha"; Status = "OK"; N = 1 }
    @{ Name = "Beta"; Status = "Warn"; N = 2 }
    @{ Name = "Gamma"; Status = "OK"; N = 3 }
)
Show-SCTable -Data $data -Columns @("Name","Status","N") -Title "Sample Table" -Style rounded

Show-SCPanel -Content @("Line 1", "Line 2", "Line 3") -Title "Panel" -Style rounded

Write-SCText ""
Write-SCGradient -Text "Gradient" -Preset rainbow

Show-SCBanner -Text "SHELL" -Font block -Subtitle "Demo" -Version "1.0"

Write-SCText ""
Write-SCSuccess "Demo complete."
