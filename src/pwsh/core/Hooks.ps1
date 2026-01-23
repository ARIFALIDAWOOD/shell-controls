<#
.SYNOPSIS
    Event hooks system for Shell-Controls
.DESCRIPTION
    Provides event-driven hooks for extending component behavior.
    Events: OnBeforeRender, OnAfterRender, OnSelect, OnCancel, OnResize,
            OnValidationError, OnFieldFocus, OnFieldBlur, OnFormSubmit
#>

function Get-SCValidEvents {
    <#
    .SYNOPSIS
        Returns list of valid event names
    #>
    [CmdletBinding()]
    param()

    return @(
        'OnBeforeRender',
        'OnAfterRender',
        'OnSelect',
        'OnCancel',
        'OnResize',
        'OnValidationError',
        'OnFieldFocus',
        'OnFieldBlur',
        'OnFormSubmit',
        'OnMenuOpen',
        'OnMenuClose',
        'OnInputStart',
        'OnInputEnd',
        'OnThemeChange',
        'OnConfigChange'
    )
}

function Register-SCHook {
    <#
    .SYNOPSIS
        Registers an event hook
    .PARAMETER Event
        The event name to hook
    .PARAMETER Handler
        The scriptblock to execute { param($context) }
    .PARAMETER Name
        Optional unique name for the hook (for later removal)
    .PARAMETER Priority
        Execution priority (lower runs first)
    .PARAMETER Once
        Remove hook after first execution
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('OnBeforeRender', 'OnAfterRender', 'OnSelect', 'OnCancel',
                     'OnResize', 'OnValidationError', 'OnFieldFocus', 'OnFieldBlur',
                     'OnFormSubmit', 'OnMenuOpen', 'OnMenuClose', 'OnInputStart',
                     'OnInputEnd', 'OnThemeChange', 'OnConfigChange')]
        [string]$Event,

        [Parameter(Mandatory)]
        [scriptblock]$Handler,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [int]$Priority = 100,

        [Parameter()]
        [switch]$Once
    )

    # Initialize event array if needed
    if (-not $script:EventHooks.ContainsKey($Event)) {
        $script:EventHooks[$Event] = @()
    }

    # Generate name if not provided
    if (-not $Name) {
        $Name = "hook_$($script:EventHooks[$Event].Count)_$(Get-Random)"
    }

    # Check for duplicate name
    $existing = $script:EventHooks[$Event] | Where-Object { $_.Name -eq $Name }
    if ($existing) {
        Write-Warning "Hook '$Name' already exists for event '$Event'. Replacing."
        Unregister-SCHook -Event $Event -Name $Name
    }

    # Create hook entry
    $hook = @{
        Name     = $Name
        Handler  = $Handler
        Priority = $Priority
        Once     = $Once.IsPresent
    }

    # Add and sort by priority
    $script:EventHooks[$Event] += $hook
    $script:EventHooks[$Event] = @($script:EventHooks[$Event] | Sort-Object { $_.Priority })

    Write-Verbose "Registered hook '$Name' for event '$Event' with priority $Priority"
    return $Name
}

function Unregister-SCHook {
    <#
    .SYNOPSIS
        Removes an event hook
    .PARAMETER Event
        The event name
    .PARAMETER Name
        The hook name to remove
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Event,

        [Parameter(Mandatory)]
        [string]$Name
    )

    if (-not $script:EventHooks.ContainsKey($Event)) {
        Write-Warning "No hooks registered for event '$Event'"
        return
    }

    $script:EventHooks[$Event] = @($script:EventHooks[$Event] | Where-Object { $_.Name -ne $Name })
    Write-Verbose "Unregistered hook '$Name' from event '$Event'"
}

function Invoke-SCHook {
    <#
    .SYNOPSIS
        Invokes all hooks for an event
    .PARAMETER Event
        The event name to invoke
    .PARAMETER Context
        Context hashtable to pass to handlers
    .PARAMETER StopOnFalse
        Stop processing if a handler returns $false
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Event,

        [Parameter()]
        [hashtable]$Context = @{},

        [Parameter()]
        [switch]$StopOnFalse
    )

    if (-not $script:EventHooks.ContainsKey($Event)) {
        return $true
    }

    $hooks = $script:EventHooks[$Event]
    $toRemove = @()
    $continueProcessing = $true

    foreach ($hook in $hooks) {
        if (-not $continueProcessing) { break }

        try {
            $result = & $hook.Handler $Context

            # Check for stop condition
            if ($StopOnFalse -and $result -eq $false) {
                $continueProcessing = $false
            }

            # Mark for removal if once
            if ($hook.Once) {
                $toRemove += $hook.Name
            }
        } catch {
            Write-Warning "Hook '$($hook.Name)' for event '$Event' threw an error: $($_.Exception.Message)"
        }
    }

    # Remove one-time hooks
    foreach ($name in $toRemove) {
        Unregister-SCHook -Event $Event -Name $name
    }

    return $continueProcessing
}

function Get-SCHooks {
    <#
    .SYNOPSIS
        Gets registered hooks for an event
    .PARAMETER Event
        The event name (optional - returns all if not specified)
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Event
    )

    if ($Event) {
        if ($script:EventHooks.ContainsKey($Event)) {
            return $script:EventHooks[$Event]
        }
        return @()
    }

    return $script:EventHooks
}

function Clear-SCHooks {
    <#
    .SYNOPSIS
        Clears all hooks for an event or all events
    .PARAMETER Event
        The event to clear (optional - clears all if not specified)
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Event
    )

    if ($Event) {
        $script:EventHooks[$Event] = @()
        Write-Verbose "Cleared all hooks for event '$Event'"
    } else {
        $script:EventHooks = @{}
        Write-Verbose "Cleared all hooks"
    }
}

function Test-SCHookExists {
    <#
    .SYNOPSIS
        Tests if a hook exists
    .PARAMETER Event
        The event name
    .PARAMETER Name
        The hook name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Event,

        [Parameter(Mandatory)]
        [string]$Name
    )

    if (-not $script:EventHooks.ContainsKey($Event)) {
        return $false
    }

    $existing = $script:EventHooks[$Event] | Where-Object { $_.Name -eq $Name }
    return $null -ne $existing
}

function New-SCHookContext {
    <#
    .SYNOPSIS
        Creates a context object for hook invocation
    .PARAMETER Component
        The component name
    .PARAMETER Action
        The action being performed
    .PARAMETER Data
        Additional data
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Component,

        [Parameter()]
        [string]$Action,

        [Parameter()]
        [hashtable]$Data = @{}
    )

    return @{
        Component = $Component
        Action    = $Action
        Timestamp = Get-Date
        Data      = $Data
    }
}

# Convenience functions for common hooks

function Add-SCBeforeRenderHook {
    <#
    .SYNOPSIS
        Adds a hook to run before rendering
    .PARAMETER Handler
        The handler scriptblock
    .PARAMETER Name
        Optional hook name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Handler,

        [Parameter()]
        [string]$Name
    )

    Register-SCHook -Event 'OnBeforeRender' -Handler $Handler -Name $Name
}

function Add-SCAfterRenderHook {
    <#
    .SYNOPSIS
        Adds a hook to run after rendering
    .PARAMETER Handler
        The handler scriptblock
    .PARAMETER Name
        Optional hook name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Handler,

        [Parameter()]
        [string]$Name
    )

    Register-SCHook -Event 'OnAfterRender' -Handler $Handler -Name $Name
}

function Add-SCSelectHook {
    <#
    .SYNOPSIS
        Adds a hook for selection events
    .PARAMETER Handler
        The handler scriptblock { param($context) } where context.Data.Selection contains the selected item
    .PARAMETER Name
        Optional hook name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Handler,

        [Parameter()]
        [string]$Name
    )

    Register-SCHook -Event 'OnSelect' -Handler $Handler -Name $Name
}

function Add-SCValidationErrorHook {
    <#
    .SYNOPSIS
        Adds a hook for validation errors
    .PARAMETER Handler
        The handler scriptblock { param($context) } where context.Data contains Field, Value, Errors
    .PARAMETER Name
        Optional hook name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Handler,

        [Parameter()]
        [string]$Name
    )

    Register-SCHook -Event 'OnValidationError' -Handler $Handler -Name $Name
}
