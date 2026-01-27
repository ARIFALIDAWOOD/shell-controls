#Requires -Version 7.0
<#
.SYNOPSIS
    UI tests for Shell-Controls.
#>

$ErrorActionPreference = 'Stop'
$mod = Join-Path $PSScriptRoot "..\src\pwsh\Shell-Controls.psd1"
Import-Module $mod -Force

Initialize-ShellControls -ThemeName "catppuccin" -Force

Describe "Write-SCText" {
    It "writes colored text" {
        { Write-SCText -Text "test" -Color "primary" } | Should Not Throw
    }

    It "writes with NoNewline" {
        { Write-SCText -Text "x" -NoNewline } | Should Not Throw
    }
}

Describe "Write-SCSuccess, Write-SCError, Write-SCWarning, Write-SCInfo, Write-SCMuted" {
    It "Write-SCSuccess" { { Write-SCSuccess "ok" } | Should Not Throw }
    It "Write-SCError"   { { Write-SCError "err" } | Should Not Throw }
    It "Write-SCWarning" { { Write-SCWarning "warn" } | Should Not Throw }
    It "Write-SCInfo"    { { Write-SCInfo "info" } | Should Not Throw }
    It "Write-SCMuted"   { { Write-SCMuted "muted" } | Should Not Throw }
}

Describe "Write-SCLine" {
    It "draws a line" { { Write-SCLine } | Should Not Throw }
}

Describe "Write-SCHeader" {
    It "writes header" { { Write-SCHeader -Text "Header" } | Should Not Throw }
}

Describe "Write-SCGradient" {
    It "writes gradient" { { Write-SCGradient -Text "Grad" } | Should Not Throw }
}

Describe "Show-SCTable" {
    It "renders table" {
        $d = @(@{ A = 1; B = 2 }, @{ A = 3; B = 4 })
        { $d | Show-SCTable -Columns A, B } | Should Not Throw
    }
}

Describe "Show-SCPanel" {
    It "renders panel" { { Show-SCPanel -Content "x", "y" -Title "T" } | Should Not Throw }
}

Describe "Show-SCBanner" {
    It "renders banner" { { Show-SCBanner -Text "Hi" -Font block } | Should Not Throw }
}
