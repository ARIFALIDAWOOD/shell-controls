#Requires -Version 7.0
<#
.SYNOPSIS
    Shell-Controls - Interactive CLI Framework for PowerShell
.DESCRIPTION
    A comprehensive module for creating beautiful, interactive CLI applications
    with modern styling, menus, progress indicators, and more.
#>

$script:ModuleRoot = $PSScriptRoot
# Prefer config next to module (installed); else ../../config (development from src/pwsh)
$script:ConfigPath = Join-Path $ModuleRoot "config"
if (-not (Test-Path $script:ConfigPath)) {
    $script:ConfigPath = Join-Path (Split-Path (Split-Path $ModuleRoot -Parent) -Parent) "config"
}
$script:Theme = $null
$script:Config = $null
$script:IsInitialized = $false

# Test Mode state variables
$script:TestMode = @{
    Enabled        = $false
    MockInputs     = @{}
    MockInputQueue = [System.Collections.Queue]::new()
    OutputBuffer   = [System.Collections.ArrayList]::new()
    CaptureOutput  = $false
}

# Output Mode state variables
$script:OutputMode = @{
    CurrentMode = $null  # null = auto-detect from environment
}

# Terminal capabilities cache
$script:TerminalCapabilities = $null

# Theme override storage
$script:ThemeOverrides = @{}

# Keybinding contexts
$script:KeybindingContexts = @{}
$script:CurrentKeybindingContext = 'global'

# Event hooks storage
$script:EventHooks = @{}

# Core modules loaded in dependency order:
# TestMode, Terminal, OutputMode first (no deps), then Theme (uses Terminal), then rest
$coreOrder = @(
    'TestMode',    # Test infrastructure - no dependencies
    'Terminal',    # Terminal capability detection - no dependencies
    'OutputMode',  # Output mode management - depends on Terminal
    'Theme',       # Theme management - may use Terminal for adaptive colors
    'Layout',      # Layout engine - depends on Theme
    'Validation',  # Input validation - no dependencies
    'UI',          # Core UI functions - depends on Theme, OutputMode
    'Menu',        # Interactive menus - depends on UI, Input
    'Input',       # User input - depends on UI, TestMode
    'Form',        # Form/wizard system - depends on Input, Validation
    'Progress',    # Progress indicators - depends on UI
    'Spinner',     # Task runner - depends on Progress
    'Table',       # Table rendering - depends on Theme, Layout
    'Logger',      # Logging - depends on OutputMode
    'Config',      # Configuration - no dependencies
    'Process',     # Process management - depends on Spinner
    'Utils',       # Utilities - no dependencies
    'Keybindings', # Keybinding management - depends on Config
    'Hooks'        # Event hooks - no dependencies
)
$compOrder = @('Banner', 'Panel', 'StatusBar', 'Tree', 'Card', 'Stack', 'Grid')

foreach ($name in $coreOrder) {
    $p = Join-Path $script:ModuleRoot "core\$name.ps1"
    if (Test-Path $p) { . $p }
}
foreach ($name in $compOrder) {
    $p = Join-Path $script:ModuleRoot "components\$name.ps1"
    if (Test-Path $p) { . $p }
}

function Initialize-ShellControls {
    <#
    .SYNOPSIS
        Initializes the Shell-Controls module with specified configuration
    .PARAMETER ThemeName
        Name of the theme to load (default, dracula, catppuccin, nord)
    .PARAMETER ConfigPath
        Custom path to configuration files
    .PARAMETER Force
        Force reinitialization even if already initialized
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ThemeName = "catppuccin",

        [Parameter()]
        [string]$ConfigPath,

        [Parameter()]
        [switch]$Force
    )

    if ($script:IsInitialized -and -not $Force) {
        Write-Verbose "Shell-Controls already initialized. Use -Force to reinitialize."
        return
    }

    if ($ConfigPath) { $script:ConfigPath = $ConfigPath }

    $configFile = Join-Path $script:ConfigPath "shell-controls.config.json"
    if (Test-Path $configFile) {
        $script:Config = Get-Content $configFile -Raw | ConvertFrom-Json -AsHashtable
    } else {
        $script:Config = @{
            version  = "1.0.0"
            theme    = $ThemeName
            settings = @{
                unicode                    = $true
                animations                 = $true
                animationSpeed             = 50
                sounds                     = $false
                logLevel                   = "info"
                clearScreenOnStart         = $false
                showBreadcrumbs             = $true
                confirmDestructiveActions   = $true
            }
            defaults = @{
                menuStyle     = "boxed"
                progressStyle = "blocks"
                spinnerStyle  = "dots"
                tableStyle    = "rounded"
            }
        }
    }

    $themeToLoad = if ($script:Config.theme) { $script:Config.theme } else { $ThemeName }
    Set-SCTheme -Name $themeToLoad

    if ($script:Config.settings.unicode) {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $OutputEncoding = [System.Text.Encoding]::UTF8
    }

    $null = [Console]::Write("`e[?25h")

    $script:IsInitialized = $true
    Write-Verbose "Shell-Controls initialized with theme: $($script:Theme.name)"
}

Initialize-ShellControls -ThemeName "catppuccin"

Export-ModuleMember -Function * -Alias *
