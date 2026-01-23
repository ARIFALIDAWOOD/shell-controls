<#
.SYNOPSIS
    Keybinding management for Shell-Controls
.DESCRIPTION
    Provides customizable keybindings with context support for menus, inputs, and global actions.
#>

function Get-SCDefaultKeybindings {
    <#
    .SYNOPSIS
        Gets the default keybinding configuration
    #>
    [CmdletBinding()]
    param()

    return @{
        global = @{
            quit = @('Ctrl+C', 'Ctrl+Q')
            help = @('F1', '?')
        }
        menu = @{
            up = @('UpArrow', 'k')
            down = @('DownArrow', 'j')
            pageUp = @('PageUp')
            pageDown = @('PageDown')
            home = @('Home')
            end = @('End')
            select = @('Enter', 'Spacebar')
            back = @('Escape', 'Backspace', 'q')
            search = @('Ctrl+F', '/')
        }
        input = @{
            submit = @('Enter')
            cancel = @('Escape')
            clear = @('Ctrl+U')
            deleteWord = @('Ctrl+W')
            historyPrev = @('UpArrow')
            historyNext = @('DownArrow')
        }
        form = @{
            nextField = @('Tab')
            prevField = @('Shift+Tab')
            submit = @('Ctrl+Enter')
            cancel = @('Escape')
        }
        multiselect = @{
            toggle = @('Spacebar')
            selectAll = @('Ctrl+A')
            deselectAll = @('Ctrl+D')
            confirm = @('Enter')
        }
    }
}

function Initialize-SCKeybindings {
    <#
    .SYNOPSIS
        Initializes keybinding contexts from config
    #>
    [CmdletBinding()]
    param()

    # Start with defaults
    $script:KeybindingContexts = Get-SCDefaultKeybindings

    # Override with config if present
    if ($script:Config.keybindings) {
        foreach ($context in $script:Config.keybindings.Keys) {
            if (-not $script:KeybindingContexts.ContainsKey($context)) {
                $script:KeybindingContexts[$context] = @{}
            }
            foreach ($action in $script:Config.keybindings[$context].Keys) {
                $script:KeybindingContexts[$context][$action] = $script:Config.keybindings[$context][$action]
            }
        }
    }
}

function Set-SCKeybindingContext {
    <#
    .SYNOPSIS
        Sets the current keybinding context
    .PARAMETER Context
        The context name: global, menu, input, form, multiselect
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('global', 'menu', 'input', 'form', 'multiselect')]
        [string]$Context
    )

    $script:CurrentKeybindingContext = $Context
    Write-Verbose "Keybinding context set to: $Context"
}

function Get-SCKeybindingContext {
    <#
    .SYNOPSIS
        Gets the current keybinding context
    #>
    [CmdletBinding()]
    param()

    return $script:CurrentKeybindingContext
}

function Get-SCKeybinding {
    <#
    .SYNOPSIS
        Gets keybindings for an action in a context
    .PARAMETER Action
        The action name (e.g., 'up', 'select', 'quit')
    .PARAMETER Context
        The context (defaults to current context)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Action,

        [Parameter()]
        [string]$Context
    )

    if (-not $Context) {
        $Context = $script:CurrentKeybindingContext
    }

    if ($script:KeybindingContexts.ContainsKey($Context)) {
        if ($script:KeybindingContexts[$Context].ContainsKey($Action)) {
            return $script:KeybindingContexts[$Context][$Action]
        }
    }

    # Fall back to global
    if ($Context -ne 'global' -and $script:KeybindingContexts.global.ContainsKey($Action)) {
        return $script:KeybindingContexts.global[$Action]
    }

    return @()
}

function Set-SCKeybinding {
    <#
    .SYNOPSIS
        Sets a keybinding for an action in a context
    .PARAMETER Context
        The context name
    .PARAMETER Action
        The action name
    .PARAMETER Bindings
        Array of key binding strings
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Context,

        [Parameter(Mandatory)]
        [string]$Action,

        [Parameter(Mandatory)]
        [string[]]$Bindings
    )

    if (-not $script:KeybindingContexts.ContainsKey($Context)) {
        $script:KeybindingContexts[$Context] = @{}
    }

    $script:KeybindingContexts[$Context][$Action] = $Bindings
    Write-Verbose "Set keybinding: $Context.$Action = $($Bindings -join ', ')"
}

function Test-SCKeybinding {
    <#
    .SYNOPSIS
        Tests if a key matches an action binding
    .PARAMETER Action
        The action to test for
    .PARAMETER KeyInfo
        The ConsoleKeyInfo object from ReadKey
    .PARAMETER Context
        The context (defaults to current)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Action,

        [Parameter(Mandatory)]
        [object]$KeyInfo,

        [Parameter()]
        [string]$Context
    )

    $bindings = Get-SCKeybinding -Action $Action -Context $Context

    foreach ($binding in $bindings) {
        if (Test-SCKeyMatch -KeyInfo $KeyInfo -Binding $binding) {
            return $true
        }
    }

    return $false
}

function Test-SCKeyMatch {
    <#
    .SYNOPSIS
        Tests if a key matches a binding string
    .PARAMETER KeyInfo
        The ConsoleKeyInfo object
    .PARAMETER Binding
        The binding string (e.g., 'Ctrl+C', 'UpArrow', 'a')
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$KeyInfo,

        [Parameter(Mandatory)]
        [string]$Binding
    )

    $parts = $Binding -split '\+'
    $key = $parts[-1]
    $modifiers = $parts[0..($parts.Length - 2)]

    # Check modifiers
    $hasCtrl = 'Ctrl' -in $modifiers
    $hasAlt = 'Alt' -in $modifiers
    $hasShift = 'Shift' -in $modifiers

    $keyCtrl = $KeyInfo.Modifiers -band [ConsoleModifiers]::Control
    $keyAlt = $KeyInfo.Modifiers -band [ConsoleModifiers]::Alt
    $keyShift = $KeyInfo.Modifiers -band [ConsoleModifiers]::Shift

    if ($hasCtrl -ne [bool]$keyCtrl) { return $false }
    if ($hasAlt -ne [bool]$keyAlt) { return $false }
    if ($hasShift -ne [bool]$keyShift) { return $false }

    # Check key
    $consoleKey = $null

    # Try to match ConsoleKey enum
    try {
        $consoleKey = [ConsoleKey]$key
        if ($KeyInfo.Key -eq $consoleKey) { return $true }
    } catch { }

    # Try character match
    if ($key.Length -eq 1) {
        if ($KeyInfo.KeyChar -eq $key[0]) { return $true }
        if ([char]::ToLower($KeyInfo.KeyChar) -eq [char]::ToLower($key[0])) { return $true }
    }

    return $false
}

function Get-SCActionForKey {
    <#
    .SYNOPSIS
        Gets the action for a key in the current context
    .PARAMETER KeyInfo
        The ConsoleKeyInfo object
    .PARAMETER Context
        The context (defaults to current)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$KeyInfo,

        [Parameter()]
        [string]$Context
    )

    if (-not $Context) {
        $Context = $script:CurrentKeybindingContext
    }

    # Check context-specific bindings first
    if ($script:KeybindingContexts.ContainsKey($Context)) {
        foreach ($action in $script:KeybindingContexts[$Context].Keys) {
            if (Test-SCKeybinding -Action $action -KeyInfo $KeyInfo -Context $Context) {
                return $action
            }
        }
    }

    # Check global bindings
    if ($Context -ne 'global') {
        foreach ($action in $script:KeybindingContexts.global.Keys) {
            if (Test-SCKeybinding -Action $action -KeyInfo $KeyInfo -Context 'global') {
                return $action
            }
        }
    }

    return $null
}

function Format-SCKeybindingHelp {
    <#
    .SYNOPSIS
        Formats keybinding help for display
    .PARAMETER Context
        The context to show help for (defaults to current)
    .PARAMETER Actions
        Specific actions to show (defaults to all)
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Context,

        [Parameter()]
        [string[]]$Actions
    )

    if (-not $Context) {
        $Context = $script:CurrentKeybindingContext
    }

    $output = @()
    $bindings = @{}

    # Collect context bindings
    if ($script:KeybindingContexts.ContainsKey($Context)) {
        foreach ($action in $script:KeybindingContexts[$Context].Keys) {
            if (-not $Actions -or $action -in $Actions) {
                $bindings[$action] = $script:KeybindingContexts[$Context][$action]
            }
        }
    }

    # Add global bindings
    foreach ($action in $script:KeybindingContexts.global.Keys) {
        if (-not $bindings.ContainsKey($action)) {
            if (-not $Actions -or $action -in $Actions) {
                $bindings[$action] = $script:KeybindingContexts.global[$action]
            }
        }
    }

    # Format output
    $maxActionLen = ($bindings.Keys | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
    if (-not $maxActionLen) { $maxActionLen = 10 }

    foreach ($action in ($bindings.Keys | Sort-Object)) {
        $keys = $bindings[$action] -join ', '
        $paddedAction = $action.PadRight($maxActionLen)
        $output += "  $paddedAction : $keys"
    }

    return $output
}

function Show-SCKeybindingHelp {
    <#
    .SYNOPSIS
        Displays keybinding help
    .PARAMETER Context
        The context to show help for
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Context
    )

    if (-not $Context) {
        $Context = $script:CurrentKeybindingContext
    }

    $primaryColor = Get-SCColor -Name "primary"
    $mutedColor = Get-SCColor -Name "muted"

    Write-SCText ""
    Write-SCText -Text "Keybindings ($Context)" -Color $primaryColor -Bold
    Write-SCLine -Color $mutedColor

    $help = Format-SCKeybindingHelp -Context $Context
    foreach ($line in $help) {
        Write-SCText $line
    }

    Write-SCText ""
}

# Initialize on load
Initialize-SCKeybindings
