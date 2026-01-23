<#
.SYNOPSIS
    Theme management for Shell-Controls
#>

function Set-SCTheme {
    <#
    .SYNOPSIS
        Sets the current theme
    .PARAMETER Name
        Theme name to load from config/themes/
    .PARAMETER CustomTheme
        Custom theme hashtable
    .PARAMETER Override
        Hashtable of dot-notation paths to override values
        Example: @{ "colors.primary" = "#FF0000"; "spacing.md" = 6 }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Name,

        [Parameter()]
        [hashtable]$CustomTheme,

        [Parameter()]
        [hashtable]$Override
    )

    # Handle override-only calls
    if ($Override -and -not $Name -and -not $CustomTheme) {
        foreach ($key in $Override.Keys) {
            $script:ThemeOverrides[$key] = $Override[$key]
        }
        # Reapply overrides to current theme
        Apply-SCThemeOverrides
        return
    }

    if ($CustomTheme) {
        $script:Theme = $CustomTheme
        $script:ThemeOverrides = @{}
    } else {
        $themePath = Join-Path $script:ConfigPath "themes\$Name.json"

        if (-not (Test-Path $themePath)) {
            $themePath = Join-Path $script:ModuleRoot "..\..\config\themes\$Name.json"
        }

        if (Test-Path $themePath) {
            $script:Theme = Get-Content $themePath -Raw | ConvertFrom-Json -AsHashtable
        } else {
            Write-Warning "Theme '$Name' not found. Using built-in default."
            $script:Theme = Get-DefaultTheme
        }
        $script:ThemeOverrides = @{}
    }

    # Apply any passed overrides
    if ($Override) {
        foreach ($key in $Override.Keys) {
            $script:ThemeOverrides[$key] = $Override[$key]
        }
        Apply-SCThemeOverrides
    }
}

function Get-SCTheme {
    [CmdletBinding()]
    param()
    return $script:Theme
}

function Get-SCColor {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('primary', 'secondary', 'accent', 'success', 'warning', 'error',
                     'info', 'muted', 'text', 'textDark', 'background', 'surface',
                     'overlay', 'highlight', 'border')]
        [string]$Name
    )

    return $script:Theme.colors[$Name]
}

function Get-SCSymbol {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $symbols = $script:Theme.symbols
    $parts = $Name -split '\.'
    $current = $symbols

    foreach ($part in $parts) {
        if ($null -eq $current) { return $null }
        if ($current -is [hashtable] -and $current.ContainsKey($part)) {
            $current = $current[$part]
        } else {
            return $null
        }
    }

    return $current
}

function Get-DefaultTheme {
    return @{
        name    = "Default"
        colors  = @{
            primary    = "#61AFEF"
            secondary  = "#ABB2BF"
            accent     = "#C678DD"
            success    = "#98C379"
            warning    = "#E5C07B"
            error      = "#E06C75"
            info       = "#56B6C2"
            muted      = "#5C6370"
            text       = "#ABB2BF"
            textDark   = "#282C34"
            background = "#282C34"
            surface    = "#3E4451"
            overlay    = "#4B5263"
            highlight  = "#C678DD"
            border     = "#5C6370"
        }
        symbols = @{
            bullet      = "●"
            check      = "✔"
            cross      = "✖"
            warning    = "⚠"
            info       = "ℹ"
            question   = "?"
            pointer    = "❯"
            pointerSmall = "›"
            arrowUp    = "↑"
            arrowDown  = "↓"
            arrowLeft  = "←"
            arrowRight = "→"
            radioOn    = "◉"
            radioOff   = "○"
            checkboxOn = "☑"
            checkboxOff = "☐"
            star       = "★"
            starEmpty  = "☆"
            heart      = "♥"
            play       = "▶"
            stop       = "■"
            pause      = "⏸"
            reload     = "↻"
            spinner    = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
            boxRounded = @{
                topLeft     = "╭"
                topRight    = "╮"
                bottomLeft  = "╰"
                bottomRight = "╯"
                horizontal  = "─"
                vertical    = "│"
            }
        }
        gradients = @{
            rainbow = @("#f38ba8", "#fab387", "#f9e2af", "#a6e3a1", "#89dceb", "#89b4fa", "#cba6f7")
            sunset  = @("#f38ba8", "#fab387", "#f9e2af")
            ocean   = @("#89b4fa", "#89dceb", "#94e2d5")
            forest  = @("#a6e3a1", "#94e2d5", "#89dceb")
        }
    }
}

function ConvertTo-AnsiColor {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$HexColor
    )

    $hex = $HexColor.TrimStart('#')
    if ($hex.Length -lt 6) { return "`e[0m" }
    $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)

    return "`e[38;2;${r};${g};${b}m"
}

function ConvertTo-AnsiBgColor {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$HexColor
    )

    $hex = $HexColor.TrimStart('#')
    if ($hex.Length -lt 6) { return "" }
    $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)

    return "`e[48;2;${r};${g};${b}m"
}

function Get-AnsiReset {
    return "`e[0m"
}

function Apply-SCThemeOverrides {
    <#
    .SYNOPSIS
        Internal function to apply theme overrides to current theme
    #>
    [CmdletBinding()]
    param()

    foreach ($key in $script:ThemeOverrides.Keys) {
        $value = $script:ThemeOverrides[$key]
        $parts = $key -split '\.'
        $current = $script:Theme

        # Navigate to parent
        for ($i = 0; $i -lt $parts.Count - 1; $i++) {
            $part = $parts[$i]
            if (-not $current.ContainsKey($part)) {
                $current[$part] = @{}
            }
            $current = $current[$part]
        }

        # Set the value
        $lastKey = $parts[-1]
        $current[$lastKey] = $value
    }
}

function Reset-SCThemeOverrides {
    <#
    .SYNOPSIS
        Resets all theme overrides and reloads the base theme
    #>
    [CmdletBinding()]
    param()

    $themeName = $script:Theme.name
    $script:ThemeOverrides = @{}

    # Reload the theme
    if ($themeName) {
        Set-SCTheme -Name $themeName
    }
}

function Get-SCThemeOverrides {
    <#
    .SYNOPSIS
        Gets current theme overrides
    #>
    [CmdletBinding()]
    param()

    return $script:ThemeOverrides.Clone()
}

function Get-SCSpacing {
    <#
    .SYNOPSIS
        Gets a spacing value from the theme
    .PARAMETER Size
        The spacing size: none, xs, sm, md, lg, xl
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('none', 'xs', 'sm', 'md', 'lg', 'xl')]
        [string]$Size
    )

    # Default spacing values if not defined in theme
    $defaultSpacing = @{
        none = 0
        xs   = 1
        sm   = 2
        md   = 4
        lg   = 6
        xl   = 8
    }

    if ($script:Theme.spacing -and $script:Theme.spacing.ContainsKey($Size)) {
        return $script:Theme.spacing[$Size]
    }

    return $defaultSpacing[$Size]
}

function Get-SCBorder {
    <#
    .SYNOPSIS
        Gets border characters for a specific style
    .PARAMETER Style
        The border style: default, heavy, double, ascii, none, rounded
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('default', 'heavy', 'double', 'ascii', 'none', 'rounded')]
        [string]$Style = 'default'
    )

    # Check theme for border definitions first
    if ($script:Theme.borders -and $script:Theme.borders.ContainsKey($Style)) {
        return $script:Theme.borders[$Style]
    }

    # Default border definitions
    $borders = @{
        default = @{
            topLeft     = "╭"
            topRight    = "╮"
            bottomLeft  = "╰"
            bottomRight = "╯"
            horizontal  = "─"
            vertical    = "│"
            leftT       = "├"
            rightT      = "┤"
            topT        = "┬"
            bottomT     = "┴"
            cross       = "┼"
        }
        rounded = @{
            topLeft     = "╭"
            topRight    = "╮"
            bottomLeft  = "╰"
            bottomRight = "╯"
            horizontal  = "─"
            vertical    = "│"
            leftT       = "├"
            rightT      = "┤"
            topT        = "┬"
            bottomT     = "┴"
            cross       = "┼"
        }
        heavy = @{
            topLeft     = "┏"
            topRight    = "┓"
            bottomLeft  = "┗"
            bottomRight = "┛"
            horizontal  = "━"
            vertical    = "┃"
            leftT       = "┣"
            rightT      = "┫"
            topT        = "┳"
            bottomT     = "┻"
            cross       = "╋"
        }
        double = @{
            topLeft     = "╔"
            topRight    = "╗"
            bottomLeft  = "╚"
            bottomRight = "╝"
            horizontal  = "═"
            vertical    = "║"
            leftT       = "╠"
            rightT      = "╣"
            topT        = "╦"
            bottomT     = "╩"
            cross       = "╬"
        }
        ascii = @{
            topLeft     = "+"
            topRight    = "+"
            bottomLeft  = "+"
            bottomRight = "+"
            horizontal  = "-"
            vertical    = "|"
            leftT       = "+"
            rightT      = "+"
            topT        = "+"
            bottomT     = "+"
            cross       = "+"
        }
        none = @{
            topLeft     = " "
            topRight    = " "
            bottomLeft  = " "
            bottomRight = " "
            horizontal  = " "
            vertical    = " "
            leftT       = " "
            rightT      = " "
            topT        = " "
            bottomT     = " "
            cross       = " "
        }
    }

    return $borders[$Style]
}

function Get-SCTextStyle {
    <#
    .SYNOPSIS
        Gets a text style definition from the theme
    .PARAMETER Style
        The style name: heading, caption, code, error, success, warning, info, link
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('heading', 'caption', 'code', 'error', 'success', 'warning', 'info', 'link', 'muted')]
        [string]$Style
    )

    # Default text styles
    $defaultStyles = @{
        heading = @{ color = 'primary'; bold = $true }
        caption = @{ color = 'muted'; italic = $true }
        code    = @{ color = 'accent' }
        error   = @{ color = 'error'; bold = $true }
        success = @{ color = 'success' }
        warning = @{ color = 'warning' }
        info    = @{ color = 'info' }
        link    = @{ color = 'info'; underline = $true }
        muted   = @{ color = 'muted' }
    }

    if ($script:Theme.textStyles -and $script:Theme.textStyles.ContainsKey($Style)) {
        return $script:Theme.textStyles[$Style]
    }

    return $defaultStyles[$Style]
}

function Get-SCSemanticColor {
    <#
    .SYNOPSIS
        Gets a semantic color token value
    .PARAMETER Token
        The token name: heading, caption, code, link, errorText, successText, warningText, infoText
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Token
    )

    # Default token mappings
    $defaultTokens = @{
        heading     = 'primary'
        caption     = 'muted'
        code        = 'accent'
        link        = 'info'
        errorText   = 'error'
        successText = 'success'
        warningText = 'warning'
        infoText    = 'info'
    }

    $colorName = $Token
    if ($script:Theme.tokens -and $script:Theme.tokens.ContainsKey($Token)) {
        $colorName = $script:Theme.tokens[$Token]
    } elseif ($defaultTokens.ContainsKey($Token)) {
        $colorName = $defaultTokens[$Token]
    }

    # Resolve the color name to actual color
    return Get-SCColor -Name $colorName
}

function Merge-SCThemeDeep {
    <#
    .SYNOPSIS
        Deep merges two theme hashtables
    .PARAMETER Base
        The base theme
    .PARAMETER Patch
        The patch to apply
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Base,

        [Parameter(Mandatory)]
        [hashtable]$Patch
    )

    $result = @{}

    # Copy all base keys
    foreach ($key in $Base.Keys) {
        if ($Base[$key] -is [hashtable]) {
            $result[$key] = $Base[$key].Clone()
        } else {
            $result[$key] = $Base[$key]
        }
    }

    # Apply patch
    foreach ($key in $Patch.Keys) {
        $patchValue = $Patch[$key]

        if ($patchValue -is [hashtable] -and $result.ContainsKey($key) -and $result[$key] -is [hashtable]) {
            # Recursive merge for nested hashtables
            $result[$key] = Merge-SCThemeDeep -Base $result[$key] -Patch $patchValue
        } else {
            $result[$key] = $patchValue
        }
    }

    return $result
}

function Get-SCThemeValue {
    <#
    .SYNOPSIS
        Gets a value from the theme using dot notation
    .PARAMETER Path
        The dot-notation path to the value (e.g., "colors.primary", "spacing.md")
    .PARAMETER Default
        Default value if path not found
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter()]
        [object]$Default
    )

    $parts = $Path -split '\.'
    $current = $script:Theme

    foreach ($part in $parts) {
        if ($null -eq $current) {
            return $Default
        }
        if ($current -is [hashtable] -and $current.ContainsKey($part)) {
            $current = $current[$part]
        } else {
            return $Default
        }
    }

    return $current
}

function Test-SCThemeVersion {
    <#
    .SYNOPSIS
        Tests if the current theme supports a specific version
    .PARAMETER MinVersion
        Minimum version required (e.g., "2.0")
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$MinVersion
    )

    $themeVersion = if ($script:Theme.version) { $script:Theme.version } else { "1.0" }

    try {
        $current = [version]$themeVersion
        $required = [version]$MinVersion
        return $current -ge $required
    } catch {
        return $false
    }
}
