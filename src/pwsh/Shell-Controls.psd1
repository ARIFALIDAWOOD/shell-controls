@{
    RootModule = 'Shell-Controls.psm1'
    ModuleVersion = '2.0.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author = 'Shell Controls Team'
    CompanyName = 'Community'
    Copyright = '(c) 2024. MIT License.'
    Description = 'Interactive CLI framework for creating beautiful, intuitive shell runners with Theme v2, unified layout, and form support'
    PowerShellVersion = '7.0'

    FunctionsToExport = @(
        # Initialization
        'Initialize-ShellControls',

        # Theme v2
        'Get-SCTheme',
        'Set-SCTheme',
        'Get-SCColor',
        'Get-SCSymbol',
        'Get-SCSpacing',
        'Get-SCBorder',
        'Get-SCTextStyle',
        'Get-SCSemanticColor',
        'Get-SCThemeValue',
        'Get-SCThemeOverrides',
        'Reset-SCThemeOverrides',
        'Merge-SCThemeDeep',
        'Test-SCThemeVersion',

        # Terminal Capabilities
        'Get-SCTerminalCapabilities',
        'Get-SCColorFallback',
        'Get-SCSymbolFallback',
        'Get-SCAdaptiveColor',
        'Get-SCAdaptiveSymbol',
        'Test-SCUnicodeSupport',
        'Test-SCTrueColorSupport',

        # Output Modes
        'Get-SCOutputMode',
        'Set-SCOutputMode',
        'Reset-SCOutputMode',
        'Test-SCOutputAllowed',
        'Test-SCColorsEnabled',
        'Test-SCInteractiveMode',
        'Write-SCOutput',
        'Remove-SCAnsiCodes',
        'Get-SCOutputModeInfo',
        'Format-SCPlainOutput',

        # Test Mode
        'Enable-SCTestMode',
        'Disable-SCTestMode',
        'Test-SCTestModeEnabled',
        'Get-SCMockInput',
        'Add-SCMockInput',
        'Get-SCCapturedOutput',
        'Clear-SCCapturedOutput',
        'Write-SCTestOutput',
        'Invoke-SCReadKey',
        'Invoke-SCReadLine',
        'Get-SCTestModeState',

        # Layout
        'Format-SCLayout',
        'Get-SCVisibleLength',
        'Get-SCTruncatedText',
        'Split-SCTextToWidth',
        'Format-SCAlignedText',
        'Get-SCResponsiveBreakpoint',
        'Get-SCResponsiveValue',
        'Get-SCTerminalWidth',
        'Get-SCTerminalHeight',
        'New-SCLayoutConfig',
        'Get-SCDefaultLayoutConfig',
        'Format-SCColumns',

        # Core UI
        'Write-SCText',
        'Write-SCLine',
        'Write-SCHeader',
        'Write-SCSuccess',
        'Write-SCError',
        'Write-SCWarning',
        'Write-SCInfo',
        'Write-SCMuted',
        'Write-SCGradient',
        'Clear-SCScreen',

        # Components
        'Show-SCBanner',
        'Show-SCPanel',
        'Show-SCTable',
        'Show-SCTree',
        'Show-SCStatusBar',
        'Show-SCNotification',
        'Show-SCCard',
        'Show-SCStack',
        'Show-SCGrid',
        'Add-SCStackItem',

        # Menus
        'Show-SCMenu',
        'Show-SCMultiSelect',
        'Show-SCRadioSelect',
        'Show-SCPaginated',

        # Input
        'Read-SCInput',
        'Read-SCPassword',
        'Read-SCConfirm',
        'Read-SCChoice',
        'Read-SCPath',
        'Read-SCNumber',
        'Read-SCDate',
        'Read-SCUrl',
        'Read-SCEmail',
        'Read-SCInputWithSuggest',

        # Validation
        'New-SCValidator',
        'Test-SCValue',
        'Test-SCEmail',
        'Test-SCUrl',
        'Test-SCRequired',
        'New-SCCompositeValidator',
        'Test-SCComposite',

        # Forms
        'Show-SCForm',
        'Show-SCWizard',
        'New-SCFormField',
        'New-SCWizardStep',

        # Progress
        'Show-SCProgress',
        'Show-SCSpinner',
        'Invoke-SCWithSpinner',
        'Show-SCCountdown',
        'Start-SCTasks',

        # Process
        'Start-SCProcess',
        'Start-SCParallel',
        'Watch-SCProcess',

        # Config
        'Get-SCConfig',
        'Set-SCConfig',

        # Logging
        'Write-SCLog',
        'Set-SCLogLevel',
        'Set-SCLogFile',

        # Utilities
        'Get-SCTerminalSize',
        'Test-SCCommand',
        'Invoke-SCCommand',
        'ConvertTo-SCSlug',
        'Get-SCRelativePath',
        'Format-SCDuration',
        'Get-SCEnvironmentInfo',

        # Keybindings
        'Get-SCDefaultKeybindings',
        'Initialize-SCKeybindings',
        'Set-SCKeybindingContext',
        'Get-SCKeybindingContext',
        'Get-SCKeybinding',
        'Set-SCKeybinding',
        'Test-SCKeybinding',
        'Test-SCKeyMatch',
        'Get-SCActionForKey',
        'Format-SCKeybindingHelp',
        'Show-SCKeybindingHelp',

        # Hooks
        'Get-SCValidEvents',
        'Register-SCHook',
        'Unregister-SCHook',
        'Invoke-SCHook',
        'Get-SCHooks',
        'Clear-SCHooks',
        'Test-SCHookExists',
        'New-SCHookContext',
        'Add-SCBeforeRenderHook',
        'Add-SCAfterRenderHook',
        'Add-SCSelectHook',
        'Add-SCValidationErrorHook'
    )

    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('CLI', 'Interactive', 'Menu', 'UI', 'Terminal', 'Console', 'Forms', 'Validation', 'Themes')
            ProjectUri = 'https://github.com/yourusername/shell-controls'
            ReleaseNotes = @'
v2.0.0 - Major Enhancement Release
- Theme v2 with semantic tokens, text styles, spacing, and borders
- Unified layout system with responsive breakpoints
- Output modes (normal, plain, json, quiet) for CI/scripting
- NO_COLOR environment variable support
- Test mode infrastructure for automated testing
- New components: Card, Stack, Grid
- Form and wizard system
- Input validation library
- Typed input functions (date, url, email with autocomplete)
- Keybinding contexts and customization
- Event hooks system
- PassThru parameter on all components
- High-contrast theme
'@
        }
    }
}
