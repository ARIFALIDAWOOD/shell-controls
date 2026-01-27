Anthropicclaude-opus-4-5-20251101-thinking-32k

Thought for 11 seconds

Shell-Controls - Interactive CLI Framework
==========================================

A powerful, reusable Git submodule for creating beautiful, interactive CLI runners.

Project Structure
-----------------

text

    shell-controls/
    ├── README.md
    ├── LICENSE
    ├── .gitignore
    ├── install.ps1
    ├── install.sh
    │
    ├── config/
    │   ├── shell-controls.config.json
    │   └── themes/
    │       ├── default.json
    │       ├── dracula.json
    │       ├── catppuccin.json
    │       └── nord.json
    │
    ├── src/
    │   ├── pwsh/
    │   │   ├── Shell-Controls.psd1
    │   │   ├── Shell-Controls.psm1
    │   │   ├── core/
    │   │   │   ├── Theme.ps1
    │   │   │   ├── UI.ps1
    │   │   │   ├── Menu.ps1
    │   │   │   ├── Input.ps1
    │   │   │   ├── Progress.ps1
    │   │   │   ├── Spinner.ps1
    │   │   │   ├── Table.ps1
    │   │   │   ├── Logger.ps1
    │   │   │   ├── Config.ps1
    │   │   │   ├── Process.ps1
    │   │   │   └── Utils.ps1
    │   │   ├── components/
    │   │   │   ├── Banner.ps1
    │   │   │   ├── StatusBar.ps1
    │   │   │   ├── Notification.ps1
    │   │   │   ├── Panel.ps1
    │   │   │   └── Tree.ps1
    │   │   └── templates/
    │   │       ├── Runner.template.ps1
    │   │       ├── MultiService.template.ps1
    │   │       └── DevEnvironment.template.ps1
    │   │
    │   └── bash/
    │       ├── shell-controls.sh
    │       ├── core/
    │       │   ├── theme.sh
    │       │   ├── ui.sh
    │       │   ├── menu.sh
    │       │   └── utils.sh
    │       └── templates/
    │           └── runner.template.sh
    │
    ├── examples/
    │   ├── backend-runner/
    │   │   └── run.ps1
    │   ├── frontend-runner/
    │   │   └── run.ps1
    │   ├── fullstack-runner/
    │   │   └── run.ps1
    │   └── docker-manager/
    │       └── run.ps1
    │
    └── tests/
        ├── Core.Tests.ps1
        ├── UI.Tests.ps1
        └── Menu.Tests.ps1

* * *

Core Files
----------

### `config/shell-controls.config.json`

JSON

    {
      "$schema": "./schema/config.schema.json",
      "version": "1.0.0",
      "theme": "catppuccin",
      "settings": {
        "unicode": true,
        "animations": true,
        "animationSpeed": 50,
        "sounds": false,
        "logLevel": "info",
        "logFile": null,
        "clearScreenOnStart": true,
        "showBreadcrumbs": true,
        "confirmDestructiveActions": true
      },
      "keybindings": {
        "up": ["UpArrow", "k"],
        "down": ["DownArrow", "j"],
        "select": ["Enter", "Spacebar"],
        "back": ["Escape", "Backspace", "q"],
        "quit": ["Ctrl+C", "Ctrl+Q"],
        "help": ["F1", "?"],
        "search": ["Ctrl+F", "/"]
      },
      "defaults": {
        "menuStyle": "boxed",
        "progressStyle": "blocks",
        "spinnerStyle": "dots",
        "tableStyle": "rounded"
      }
    }

* * *

### `config/themes/catppuccin.json`

JSON

    {
      "name": "Catppuccin Mocha",
      "author": "Catppuccin",
      "colors": {
        "primary": "#89b4fa",
        "secondary": "#a6adc8",
        "accent": "#f5c2e7",
        "success": "#a6e3a1",
        "warning": "#f9e2af",
        "error": "#f38ba8",
        "info": "#89dceb",
        "muted": "#6c7086",
        "text": "#cdd6f4",
        "textDark": "#1e1e2e",
        "background": "#1e1e2e",
        "surface": "#313244",
        "overlay": "#45475a",
        "highlight": "#f5c2e7",
        "border": "#585b70"
      },
      "symbols": {
        "bullet": "●",
        "check": "✔",
        "cross": "✖",
        "warning": "⚠",
        "info": "ℹ",
        "question": "?",
        "pointer": "❯",
        "pointerSmall": "›",
        "arrowUp": "↑",
        "arrowDown": "↓",
        "arrowLeft": "←",
        "arrowRight": "→",
        "radioOn": "◉",
        "radioOff": "○",
        "checkboxOn": "☑",
        "checkboxOff": "☐",
        "star": "★",
        "starEmpty": "☆",
        "heart": "♥",
        "play": "▶",
        "stop": "■",
        "pause": "⏸",
        "reload": "↻",
        "spinner": ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"],
        "boxLight": {
          "topLeft": "┌",
          "topRight": "┐",
          "bottomLeft": "└",
          "bottomRight": "┘",
          "horizontal": "─",
          "vertical": "│"
        },
        "boxHeavy": {
          "topLeft": "┏",
          "topRight": "┓",
          "bottomLeft": "┗",
          "bottomRight": "┛",
          "horizontal": "━",
          "vertical": "┃"
        },
        "boxRounded": {
          "topLeft": "╭",
          "topRight": "╮",
          "bottomLeft": "╰",
          "bottomRight": "╯",
          "horizontal": "─",
          "vertical": "│"
        },
        "boxDouble": {
          "topLeft": "╔",
          "topRight": "╗",
          "bottomLeft": "╚",
          "bottomRight": "╝",
          "horizontal": "═",
          "vertical": "║"
        }
      },
      "gradients": {
        "rainbow": ["#f38ba8", "#fab387", "#f9e2af", "#a6e3a1", "#89dceb", "#89b4fa", "#cba6f7"],
        "sunset": ["#f38ba8", "#fab387", "#f9e2af"],
        "ocean": ["#89b4fa", "#89dceb", "#94e2d5"],
        "forest": ["#a6e3a1", "#94e2d5", "#89dceb"]
      }
    }

* * *

### `config/themes/dracula.json`

JSON

    {
      "name": "Dracula",
      "author": "Zeno Rocha",
      "colors": {
        "primary": "#bd93f9",
        "secondary": "#6272a4",
        "accent": "#ff79c6",
        "success": "#50fa7b",
        "warning": "#f1fa8c",
        "error": "#ff5555",
        "info": "#8be9fd",
        "muted": "#6272a4",
        "text": "#f8f8f2",
        "textDark": "#282a36",
        "background": "#282a36",
        "surface": "#44475a",
        "overlay": "#6272a4",
        "highlight": "#ff79c6",
        "border": "#6272a4"
      },
      "symbols": {
        "bullet": "●",
        "check": "✔",
        "cross": "✖",
        "warning": "⚠",
        "info": "ℹ",
        "question": "?",
        "pointer": "❯",
        "pointerSmall": "›",
        "arrowUp": "↑",
        "arrowDown": "↓",
        "arrowLeft": "←",
        "arrowRight": "→",
        "radioOn": "◉",
        "radioOff": "○",
        "checkboxOn": "☑",
        "checkboxOff": "☐",
        "star": "★",
        "starEmpty": "☆",
        "heart": "♥",
        "play": "▶",
        "stop": "■",
        "pause": "⏸",
        "reload": "↻",
        "spinner": ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"],
        "boxLight": {
          "topLeft": "┌",
          "topRight": "┐",
          "bottomLeft": "└",
          "bottomRight": "┘",
          "horizontal": "─",
          "vertical": "│"
        },
        "boxHeavy": {
          "topLeft": "┏",
          "topRight": "┓",
          "bottomLeft": "┗",
          "bottomRight": "┛",
          "horizontal": "━",
          "vertical": "┃"
        },
        "boxRounded": {
          "topLeft": "╭",
          "topRight": "╮",
          "bottomLeft": "╰",
          "bottomRight": "╯",
          "horizontal": "─",
          "vertical": "│"
        },
        "boxDouble": {
          "topLeft": "╔",
          "topRight": "╗",
          "bottomLeft": "╚",
          "bottomRight": "╝",
          "horizontal": "═",
          "vertical": "║"
        }
      },
      "gradients": {
        "rainbow": ["#ff5555", "#ffb86c", "#f1fa8c", "#50fa7b", "#8be9fd", "#bd93f9", "#ff79c6"],
        "sunset": ["#ff5555", "#ffb86c", "#f1fa8c"],
        "ocean": ["#bd93f9", "#8be9fd", "#50fa7b"],
        "forest": ["#50fa7b", "#8be9fd", "#bd93f9"]
      }
    }

* * *

PowerShell Core Module
----------------------

### `src/pwsh/Shell-Controls.psd1`

PowerShell

    @{
        RootModule = 'Shell-Controls.psm1'
        ModuleVersion = '1.0.0'
        GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
        Author = 'Shell Controls Team'
        CompanyName = 'Community'
        Copyright = '(c) 2024. MIT License.'
        Description = 'Interactive CLI framework for creating beautiful, intuitive shell runners'
        PowerShellVersion = '7.0'
        
        FunctionsToExport = @(
            # Theme
            'Initialize-ShellControls',
            'Get-SCTheme',
            'Set-SCTheme',
            'Get-SCColor',
            'Get-SCSymbol',
            
            # UI
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
            
            # Menu
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
            
            # Progress
            'Show-SCProgress',
            'Show-SCSpinner',
            'Invoke-SCWithSpinner',
            'Show-SCCountdown',
            
            # Process
            'Start-SCProcess',
            'Start-SCParallel',
            'Watch-SCProcess',
            
            # Config
            'Get-SCConfig',
            'Set-SCConfig',
            
            # Logger
            'Write-SCLog',
            
            # Utils
            'Get-SCTerminalSize',
            'Test-SCCommand',
            'Invoke-SCCommand'
        )
        
        VariablesToExport = @()
        AliasesToExport = @()
        PrivateData = @{
            PSData = @{
                Tags = @('CLI', 'Interactive', 'Menu', 'UI', 'Terminal', 'Console')
                ProjectUri = 'https://github.com/yourusername/shell-controls'
            }
        }
    }

* * *

### `src/pwsh/Shell-Controls.psm1`

PowerShell

    #Requires -Version 7.0
    <#
    .SYNOPSIS
        Shell-Controls - Interactive CLI Framework for PowerShell
    .DESCRIPTION
        A comprehensive module for creating beautiful, interactive CLI applications
        with modern styling, menus, progress indicators, and more.
    #>
    
    # ============================================================================
    # Module Initialization
    # ============================================================================
    
    $script:ModuleRoot = $PSScriptRoot
    $script:ConfigPath = Join-Path $ModuleRoot "..\..\config"
    $script:Theme = $null
    $script:Config = $null
    $script:IsInitialized = $false
    
    # Import all core and component scripts
    $CorePath = Join-Path $ModuleRoot "core"
    $ComponentsPath = Join-Path $ModuleRoot "components"
    
    # Dot-source all PS1 files
    Get-ChildItem -Path $CorePath -Filter "*.ps1" -ErrorAction SilentlyContinue | 
        ForEach-Object { . $_.FullName }
    Get-ChildItem -Path $ComponentsPath -Filter "*.ps1" -ErrorAction SilentlyContinue | 
        ForEach-Object { . $_.FullName }
    
    # ============================================================================
    # Initialization Function
    # ============================================================================
    
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
        
        # Set custom config path if provided
        if ($ConfigPath) {
            $script:ConfigPath = $ConfigPath
        }
        
        # Load configuration
        $configFile = Join-Path $script:ConfigPath "shell-controls.config.json"
        if (Test-Path $configFile) {
            $script:Config = Get-Content $configFile -Raw | ConvertFrom-Json -AsHashtable
        } else {
            # Default configuration
            $script:Config = @{
                version = "1.0.0"
                theme = $ThemeName
                settings = @{
                    unicode = $true
                    animations = $true
                    animationSpeed = 50
                    sounds = $false
                    logLevel = "info"
                    clearScreenOnStart = $false
                    showBreadcrumbs = $true
                    confirmDestructiveActions = $true
                }
                defaults = @{
                    menuStyle = "boxed"
                    progressStyle = "blocks"
                    spinnerStyle = "dots"
                    tableStyle = "rounded"
                }
            }
        }
        
        # Load theme
        Set-SCTheme -Name ($script:Config.theme ?? $ThemeName)
        
        # Configure output encoding for Unicode support
        if ($script:Config.settings.unicode) {
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
            $OutputEncoding = [System.Text.Encoding]::UTF8
        }
        
        # Enable Virtual Terminal Processing for ANSI colors
        $null = [Console]::Write("`e[?25h") # Show cursor
        
        $script:IsInitialized = $true
        
        Write-Verbose "Shell-Controls initialized with theme: $($script:Theme.name)"
    }
    
    # Auto-initialize with defaults
    Initialize-ShellControls -ThemeName "catppuccin"
    
    # Export module members
    Export-ModuleMember -Function * -Alias *

* * *

### `src/pwsh/core/Theme.ps1`

PowerShell

    <#
    .SYNOPSIS
        Theme management for Shell-Controls
    #>
    
    function Set-SCTheme {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]$Name,
            
            [Parameter()]
            [hashtable]$CustomTheme
        )
        
        if ($CustomTheme) {
            $script:Theme = $CustomTheme
            return
        }
        
        $themePath = Join-Path $script:ConfigPath "themes\$Name.json"
        
        if (-not (Test-Path $themePath)) {
            # Try default themes bundled with module
            $themePath = Join-Path $script:ModuleRoot "..\..\config\themes\$Name.json"
        }
        
        if (Test-Path $themePath) {
            $script:Theme = Get-Content $themePath -Raw | ConvertFrom-Json -AsHashtable
        } else {
            Write-Warning "Theme '$Name' not found. Using built-in default."
            $script:Theme = Get-DefaultTheme
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
        
        # Handle nested symbols (e.g., boxRounded.topLeft)
        $parts = $Name -split '\.'
        $current = $symbols
        
        foreach ($part in $parts) {
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
            name = "Default"
            colors = @{
                primary = "#61AFEF"
                secondary = "#ABB2BF"
                accent = "#C678DD"
                success = "#98C379"
                warning = "#E5C07B"
                error = "#E06C75"
                info = "#56B6C2"
                muted = "#5C6370"
                text = "#ABB2BF"
                textDark = "#282C34"
                background = "#282C34"
                surface = "#3E4451"
                overlay = "#4B5263"
                highlight = "#C678DD"
                border = "#5C6370"
            }
            symbols = @{
                bullet = "●"
                check = "✔"
                cross = "✖"
                warning = "⚠"
                info = "ℹ"
                question = "?"
                pointer = "❯"
                pointerSmall = "›"
                arrowUp = "↑"
                arrowDown = "↓"
                arrowLeft = "←"
                arrowRight = "→"
                radioOn = "◉"
                radioOff = "○"
                checkboxOn = "☑"
                checkboxOff = "☐"
                star = "★"
                starEmpty = "☆"
                heart = "♥"
                play = "▶"
                stop = "■"
                pause = "⏸"
                reload = "↻"
                spinner = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
                boxRounded = @{
                    topLeft = "╭"
                    topRight = "╮"
                    bottomLeft = "╰"
                    bottomRight = "╯"
                    horizontal = "─"
                    vertical = "│"
                }
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
        $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
        $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
        $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)
        
        return "`e[48;2;${r};${g};${b}m"
    }
    
    function Get-AnsiReset {
        return "`e[0m"
    }

* * *

### `src/pwsh/core/UI.ps1`

PowerShell

    <#
    .SYNOPSIS
        Core UI output functions for Shell-Controls
    #>
    
    function Write-SCText {
        <#
        .SYNOPSIS
            Writes styled text to the console
        .PARAMETER Text
            The text to write
        .PARAMETER Color
            Hex color code or theme color name
        .PARAMETER BackgroundColor
            Background hex color code
        .PARAMETER Bold
            Make text bold
        .PARAMETER Italic
            Make text italic
        .PARAMETER Underline
            Underline the text
        .PARAMETER NoNewline
            Don't add a newline at the end
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
            [AllowEmptyString()]
            [string]$Text,
            
            [Parameter()]
            [string]$Color,
            
            [Parameter()]
            [string]$BackgroundColor,
            
            [Parameter()]
            [switch]$Bold,
            
            [Parameter()]
            [switch]$Italic,
            
            [Parameter()]
            [switch]$Underline,
            
            [Parameter()]
            [switch]$NoNewline
        )
        
        begin {
            $ansiSequence = ""
            $reset = Get-AnsiReset
        }
        
        process {
            # Resolve color from theme if not a hex code
            if ($Color -and $Color -notmatch '^#') {
                $Color = Get-SCColor -Name $Color -ErrorAction SilentlyContinue
                if (-not $Color) { $Color = $script:Theme.colors.text }
            }
            
            if ($Color) {
                $ansiSequence += ConvertTo-AnsiColor -HexColor $Color
            }
            
            if ($BackgroundColor) {
                if ($BackgroundColor -notmatch '^#') {
                    $BackgroundColor = Get-SCColor -Name $BackgroundColor
                }
                $ansiSequence += ConvertTo-AnsiBgColor -HexColor $BackgroundColor
            }
            
            if ($Bold) { $ansiSequence += "`e[1m" }
            if ($Italic) { $ansiSequence += "`e[3m" }
            if ($Underline) { $ansiSequence += "`e[4m" }
            
            $output = "${ansiSequence}${Text}${reset}"
            
            if ($NoNewline) {
                [Console]::Write($output)
            } else {
                [Console]::WriteLine($output)
            }
        }
    }
    
    function Write-SCLine {
        <#
        .SYNOPSIS
            Writes a horizontal line across the terminal
        #>
        [CmdletBinding()]
        param(
            [Parameter()]
            [string]$Character,
            
            [Parameter()]
            [string]$Color,
            
            [Parameter()]
            [int]$Width
        )
        
        if (-not $Character) {
            $Character = Get-SCSymbol -Name "boxRounded.horizontal"
        }
        
        if (-not $Color) {
            $Color = Get-SCColor -Name "border"
        }
        
        if (-not $Width) {
            $Width = [Console]::WindowWidth - 1
        }
        
        $line = $Character * $Width
        Write-SCText -Text $line -Color $Color
    }
    
    function Write-SCHeader {
        <#
        .SYNOPSIS
            Writes a styled header with optional icon
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Text,
            
            [Parameter()]
            [string]$Icon,
            
            [Parameter()]
            [string]$Color,
            
            [Parameter()]
            [ValidateSet('Left', 'Center', 'Right')]
            [string]$Align = 'Left',
            
            [Parameter()]
            [switch]$WithLine
        )
        
        if (-not $Color) {
            $Color = Get-SCColor -Name "primary"
        }
        
        if ($Icon) {
            $Text = "$Icon  $Text"
        }
        
        $termWidth = [Console]::WindowWidth - 1
        
        switch ($Align) {
            'Center' {
                $padding = [Math]::Max(0, ($termWidth - $Text.Length) / 2)
                $Text = (' ' * $padding) + $Text
            }
            'Right' {
                $padding = [Math]::Max(0, $termWidth - $Text.Length)
                $Text = (' ' * $padding) + $Text
            }
        }
        
        Write-SCText ""
        Write-SCText -Text $Text -Color $Color -Bold
        
        if ($WithLine) {
            Write-SCLine -Color $Color
        }
        
        Write-SCText ""
    }
    
    function Write-SCSuccess {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Message,
            
            [Parameter()]
            [switch]$NoIcon
        )
        
        $icon = if ($NoIcon) { "" } else { "$(Get-SCSymbol -Name 'check') " }
        Write-SCText -Text "${icon}${Message}" -Color (Get-SCColor -Name "success")
    }
    
    function Write-SCError {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Message,
            
            [Parameter()]
            [switch]$NoIcon
        )
        
        $icon = if ($NoIcon) { "" } else { "$(Get-SCSymbol -Name 'cross') " }
        Write-SCText -Text "${icon}${Message}" -Color (Get-SCColor -Name "error")
    }
    
    function Write-SCWarning {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Message,
            
            [Parameter()]
            [switch]$NoIcon
        )
        
        $icon = if ($NoIcon) { "" } else { "$(Get-SCSymbol -Name 'warning') " }
        Write-SCText -Text "${icon}${Message}" -Color (Get-SCColor -Name "warning")
    }
    
    function Write-SCInfo {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Message,
            
            [Parameter()]
            [switch]$NoIcon
        )
        
        $icon = if ($NoIcon) { "" } else { "$(Get-SCSymbol -Name 'info') " }
        Write-SCText -Text "${icon}${Message}" -Color (Get-SCColor -Name "info")
    }
    
    function Write-SCMuted {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Message
        )
        
        Write-SCText -Text $Message -Color (Get-SCColor -Name "muted")
    }
    
    function Write-SCGradient {
        <#
        .SYNOPSIS
            Writes text with a gradient color effect
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Text,
            
            [Parameter()]
            [string[]]$Colors,
            
            [Parameter()]
            [ValidateSet('rainbow', 'sunset', 'ocean', 'forest')]
            [string]$Preset = 'rainbow',
            
            [Parameter()]
            [switch]$NoNewline
        )
        
        if (-not $Colors) {
            $Colors = $script:Theme.gradients[$Preset]
        }
        
        if (-not $Colors -or $Colors.Count -eq 0) {
            $Colors = @("#ff0000", "#00ff00", "#0000ff")
        }
        
        $chars = $Text.ToCharArray()
        $colorCount = $Colors.Count
        $output = ""
        
        for ($i = 0; $i -lt $chars.Count; $i++) {
            $colorIndex = [Math]::Floor(($i / $chars.Count) * $colorCount)
            $colorIndex = [Math]::Min($colorIndex, $colorCount - 1)
            
            $color = $Colors[$colorIndex]
            $ansi = ConvertTo-AnsiColor -HexColor $color
            $output += "${ansi}$($chars[$i])"
        }
        
        $output += Get-AnsiReset
        
        if ($NoNewline) {
            [Console]::Write($output)
        } else {
            [Console]::WriteLine($output)
        }
    }
    
    function Clear-SCScreen {
        <#
        .SYNOPSIS
            Clears the screen with optional animations
        #>
        [CmdletBinding()]
        param(
            [Parameter()]
            [switch]$SoftClear
        )
        
        if ($SoftClear) {
            # Move cursor to top and clear from there
            [Console]::SetCursorPosition(0, 0)
            $blank = " " * [Console]::WindowWidth
            for ($i = 0; $i -lt [Console]::WindowHeight; $i++) {
                [Console]::WriteLine($blank)
            }
            [Console]::SetCursorPosition(0, 0)
        } else {
            [Console]::Clear()
        }
    }

* * *

### `src/pwsh/core/Menu.ps1`

PowerShell

    <#
    .SYNOPSIS
        Interactive menu system for Shell-Controls
    #>
    
    function Show-SCMenu {
        <#
        .SYNOPSIS
            Displays an interactive menu with arrow key navigation
        .PARAMETER Title
            Menu title
        .PARAMETER Items
            Array of menu items (strings or hashtables with Name, Description, Disabled, Icon)
        .PARAMETER Description
            Optional description below title
        .PARAMETER DefaultIndex
            Index of initially selected item
        .PARAMETER ReturnIndex
            Return the selected index instead of the item
        .PARAMETER PageSize
            Number of items to show at once (enables scrolling)
        .PARAMETER ShowHelp
            Show keyboard help at bottom
        .PARAMETER AllowCancel
            Allow pressing Escape to cancel selection
        .PARAMETER Style
            Menu style (simple, boxed, minimal)
        #>
        [CmdletBinding()]
        param(
            [Parameter()]
            [string]$Title,
            
            [Parameter(Mandatory)]
            [array]$Items,
            
            [Parameter()]
            [string]$Description,
            
            [Parameter()]
            [int]$DefaultIndex = 0,
            
            [Parameter()]
            [switch]$ReturnIndex,
            
            [Parameter()]
            [int]$PageSize = 0,
            
            [Parameter()]
            [switch]$ShowHelp = $true,
            
            [Parameter()]
            [switch]$AllowCancel,
            
            [Parameter()]
            [ValidateSet('simple', 'boxed', 'minimal')]
            [string]$Style = 'boxed'
        )
        
        # Normalize items to hashtables
        $menuItems = $Items | ForEach-Object {
            if ($_ -is [string]) {
                @{ Name = $_; Description = $null; Disabled = $false; Icon = $null }
            } elseif ($_ -is [hashtable]) {
                @{
                    Name = $_.Name ?? $_.Label ?? $_.Text ?? $_
                    Description = $_.Description ?? $_.Desc ?? $null
                    Disabled = $_.Disabled ?? $false
                    Icon = $_.Icon ?? $null
                }
            } else {
                @{ Name = $_.ToString(); Description = $null; Disabled = $false; Icon = $null }
            }
        }
        
        $selectedIndex = $DefaultIndex
        $startIndex = 0
        $displayCount = if ($PageSize -gt 0) { [Math]::Min($PageSize, $menuItems.Count) } else { $menuItems.Count }
        
        # Get theme colors and symbols
        $primaryColor = Get-SCColor -Name "primary"
        $mutedColor = Get-SCColor -Name "muted"
        $accentColor = Get-SCColor -Name "accent"
        $textColor = Get-SCColor -Name "text"
        $errorColor = Get-SCColor -Name "error"
        $pointer = Get-SCSymbol -Name "pointer"
        $box = Get-SCSymbol -Name "boxRounded"
        
        # Hide cursor
        [Console]::CursorVisible = $false
        
        try {
            while ($true) {
                # Calculate visible items
                if ($PageSize -gt 0) {
                    if ($selectedIndex -lt $startIndex) {
                        $startIndex = $selectedIndex
                    } elseif ($selectedIndex -ge $startIndex + $displayCount) {
                        $startIndex = $selectedIndex - $displayCount + 1
                    }
                }
                
                # Clear previous render
                $totalLines = $displayCount + 4  # Adjust based on decorations
                if ($Title) { $totalLines++ }
                if ($Description) { $totalLines++ }
                if ($ShowHelp) { $totalLines += 2 }
                if ($Style -eq 'boxed') { $totalLines += 2 }
                
                # Move cursor up to re-render
                if ($script:menuRendered) {
                    [Console]::SetCursorPosition(0, [Console]::CursorTop - $script:lastMenuHeight)
                    for ($i = 0; $i -lt $script:lastMenuHeight; $i++) {
                        [Console]::WriteLine(" " * [Console]::WindowWidth)
                    }
                    [Console]::SetCursorPosition(0, [Console]::CursorTop - $script:lastMenuHeight)
                }
                
                $linesRendered = 0
                
                # Render title
                if ($Title) {
                    Write-SCText ""
                    $linesRendered++
                    
                    if ($Style -eq 'boxed') {
                        $titleWidth = [Math]::Max($Title.Length + 4, 40)
                        Write-SCText -Text "$($box.topLeft)$($box.horizontal * ($titleWidth - 2))$($box.topRight)" -Color $primaryColor
                        Write-SCText -Text "$($box.vertical) $Title$(' ' * ($titleWidth - $Title.Length - 3))$($box.vertical)" -Color $primaryColor -Bold
                        Write-SCText -Text "$($box.bottomLeft)$($box.horizontal * ($titleWidth - 2))$($box.bottomRight)" -Color $primaryColor
                        $linesRendered += 3
                    } else {
                        Write-SCText -Text $Title -Color $primaryColor -Bold
                        $linesRendered++
                    }
                }
                
                # Render description
                if ($Description) {
                    Write-SCText -Text "  $Description" -Color $mutedColor
                    $linesRendered++
                }
                
                Write-SCText ""
                $linesRendered++
                
                # Render menu items
                $visibleItems = $menuItems[$startIndex..([Math]::Min($startIndex + $displayCount - 1, $menuItems.Count - 1))]
                $visibleIndex = 0
                
                foreach ($item in $visibleItems) {
                    $actualIndex = $startIndex + $visibleIndex
                    $isSelected = ($actualIndex -eq $selectedIndex)
                    $isDisabled = $item.Disabled
                    
                    $prefix = if ($isSelected) { "  $pointer " } else { "    " }
                    $itemText = $item.Name
                    $icon = if ($item.Icon) { "$($item.Icon) " } else { "" }
                    
                    $color = if ($isDisabled) {
                        $mutedColor
                    } elseif ($isSelected) {
                        $accentColor
                    } else {
                        $textColor
                    }
                    
                    $line = "${prefix}${icon}${itemText}"
                    
                    if ($item.Description -and $isSelected) {
                        Write-SCText -Text $line -Color $color -Bold:$isSelected
                        Write-SCText -Text "      $($item.Description)" -Color $mutedColor
                        $linesRendered += 2
                    } else {
                        Write-SCText -Text $line -Color $color -Bold:$isSelected
                        $linesRendered++
                    }
                    
                    $visibleIndex++
                }
                
                # Show scroll indicators
                if ($PageSize -gt 0 -and $menuItems.Count -gt $PageSize) {
                    Write-SCText ""
                    $linesRendered++
                    
                    $scrollInfo = "  $(Get-SCSymbol -Name 'arrowUp')$(Get-SCSymbol -Name 'arrowDown') " +
                                  "($($selectedIndex + 1)/$($menuItems.Count))"
                    Write-SCText -Text $scrollInfo -Color $mutedColor
                    $linesRendered++
                }
                
                # Show help
                if ($ShowHelp) {
                    Write-SCText ""
                    $linesRendered++
                    
                    $helpText = "  ↑/↓ Navigate  •  Enter Select"
                    if ($AllowCancel) {
                        $helpText += "  •  Esc Cancel"
                    }
                    Write-SCText -Text $helpText -Color $mutedColor
                    $linesRendered++
                }
                
                $script:menuRendered = $true
                $script:lastMenuHeight = $linesRendered
                
                # Read key input
                $key = [Console]::ReadKey($true)
                
                switch ($key.Key) {
                    'UpArrow' {
                        do {
                            $selectedIndex = ($selectedIndex - 1 + $menuItems.Count) % $menuItems.Count
                        } while ($menuItems[$selectedIndex].Disabled -and $selectedIndex -ne $DefaultIndex)
                    }
                    'DownArrow' {
                        do {
                            $selectedIndex = ($selectedIndex + 1) % $menuItems.Count
                        } while ($menuItems[$selectedIndex].Disabled -and $selectedIndex -ne $DefaultIndex)
                    }
                    'Home' {
                        $selectedIndex = 0
                        while ($menuItems[$selectedIndex].Disabled -and $selectedIndex -lt $menuItems.Count - 1) {
                            $selectedIndex++
                        }
                    }
                    'End' {
                        $selectedIndex = $menuItems.Count - 1
                        while ($menuItems[$selectedIndex].Disabled -and $selectedIndex -gt 0) {
                            $selectedIndex--
                        }
                    }
                    'Enter' {
                        if (-not $menuItems[$selectedIndex].Disabled) {
                            [Console]::CursorVisible = $true
                            $script:menuRendered = $false
                            Write-SCText ""
                            
                            if ($ReturnIndex) {
                                return $selectedIndex
                            } else {
                                return $Items[$selectedIndex]
                            }
                        }
                    }
                    'Escape' {
                        if ($AllowCancel) {
                            [Console]::CursorVisible = $true
                            $script:menuRendered = $false
                            return $null
                        }
                    }
                }
                
                # Handle vim-style navigation
                if ($key.KeyChar -eq 'j') {
                    do {
                        $selectedIndex = ($selectedIndex + 1) % $menuItems.Count
                    } while ($menuItems[$selectedIndex].Disabled -and $selectedIndex -ne $DefaultIndex)
                } elseif ($key.KeyChar -eq 'k') {
                    do {
                        $selectedIndex = ($selectedIndex - 1 + $menuItems.Count) % $menuItems.Count
                    } while ($menuItems[$selectedIndex].Disabled -and $selectedIndex -ne $DefaultIndex)
                } elseif ($key.KeyChar -eq 'q' -and $AllowCancel) {
                    [Console]::CursorVisible = $true
                    $script:menuRendered = $false
                    return $null
                }
            }
        } finally {
            [Console]::CursorVisible = $true
            $script:menuRendered = $false
        }
    }
    
    function Show-SCMultiSelect {
        <#
        .SYNOPSIS
            Displays a multi-select menu with checkbox selection
        #>
        [CmdletBinding()]
        param(
            [Parameter()]
            [string]$Title,
            
            [Parameter(Mandatory)]
            [array]$Items,
            
            [Parameter()]
            [string]$Description,
            
            [Parameter()]
            [int[]]$DefaultSelected = @(),
            
            [Parameter()]
            [int]$MinSelection = 0,
            
            [Parameter()]
            [int]$MaxSelection = 0,
            
            [Parameter()]
            [switch]$ReturnIndices,
            
            [Parameter()]
            [int]$PageSize = 0
        )
        
        # Normalize items
        $menuItems = $Items | ForEach-Object {
            if ($_ -is [string]) {
                @{ Name = $_; Disabled = $false }
            } else {
                @{ Name = $_.Name ?? $_.ToString(); Disabled = $_.Disabled ?? $false }
            }
        }
        
        $selected = @{}
        $DefaultSelected | ForEach-Object { $selected[$_] = $true }
        
        $currentIndex = 0
        $startIndex = 0
        $displayCount = if ($PageSize -gt 0) { [Math]::Min($PageSize, $menuItems.Count) } else { $menuItems.Count }
        
        $primaryColor = Get-SCColor -Name "primary"
        $successColor = Get-SCColor -Name "success"
        $mutedColor = Get-SCColor -Name "muted"
        $textColor = Get-SCColor -Name "text"
        $pointer = Get-SCSymbol -Name "pointer"
        $checkboxOn = Get-SCSymbol -Name "checkboxOn"
        $checkboxOff = Get-SCSymbol -Name "checkboxOff"
        
        [Console]::CursorVisible = $false
        
        try {
            while ($true) {
                # Adjust scroll position
                if ($PageSize -gt 0) {
                    if ($currentIndex -lt $startIndex) {
                        $startIndex = $currentIndex
                    } elseif ($currentIndex -ge $startIndex + $displayCount) {
                        $startIndex = $currentIndex - $displayCount + 1
                    }
                }
                
                # Clear and re-render
                if ($script:multiSelectRendered) {
                    [Console]::SetCursorPosition(0, [Console]::CursorTop - $script:lastMultiSelectHeight)
                    for ($i = 0; $i -lt $script:lastMultiSelectHeight; $i++) {
                        [Console]::WriteLine(" " * [Console]::WindowWidth)
                    }
                    [Console]::SetCursorPosition(0, [Console]::CursorTop - $script:lastMultiSelectHeight)
                }
                
                $linesRendered = 0
                
                if ($Title) {
                    Write-SCText ""
                    Write-SCText -Text $Title -Color $primaryColor -Bold
                    $linesRendered += 2
                }
                
                if ($Description) {
                    Write-SCText -Text "  $Description" -Color $mutedColor
                    $linesRendered++
                }
                
                Write-SCText ""
                $linesRendered++
                
                $visibleItems = $menuItems[$startIndex..([Math]::Min($startIndex + $displayCount - 1, $menuItems.Count - 1))]
                $visibleIndex = 0
                
                foreach ($item in $visibleItems) {
                    $actualIndex = $startIndex + $visibleIndex
                    $isSelected = ($actualIndex -eq $currentIndex)
                    $isChecked = $selected.ContainsKey($actualIndex)
                    $isDisabled = $item.Disabled
                    
                    $cursor = if ($isSelected) { $pointer } else { " " }
                    $checkbox = if ($isChecked) { $checkboxOn } else { $checkboxOff }
                    $checkColor = if ($isChecked) { $successColor } else { $mutedColor }
                    
                    $color = if ($isDisabled) {
                        $mutedColor
                    } elseif ($isSelected) {
                        $primaryColor
                    } else {
                        $textColor
                    }
                    
                    $reset = Get-AnsiReset
                    $cursorAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
                    $checkAnsi = ConvertTo-AnsiColor -HexColor $checkColor
                    $textAnsi = ConvertTo-AnsiColor -HexColor $color
                    
                    $line = "  ${cursorAnsi}${cursor}${reset} ${checkAnsi}${checkbox}${reset} ${textAnsi}$($item.Name)${reset}"
                    [Console]::WriteLine($line)
                    $linesRendered++
                    
                    $visibleIndex++
                }
                
                $selectedCount = $selected.Count
                Write-SCText ""
                Write-SCText -Text "  Selected: $selectedCount  |  Space: Toggle  •  Enter: Confirm  •  A: All  •  N: None" -Color $mutedColor
                $linesRendered += 2
                
                $script:multiSelectRendered = $true
                $script:lastMultiSelectHeight = $linesRendered
                
                $key = [Console]::ReadKey($true)
                
                switch ($key.Key) {
                    'UpArrow' { $currentIndex = ($currentIndex - 1 + $menuItems.Count) % $menuItems.Count }
                    'DownArrow' { $currentIndex = ($currentIndex + 1) % $menuItems.Count }
                    'Spacebar' {
                        if (-not $menuItems[$currentIndex].Disabled) {
                            if ($selected.ContainsKey($currentIndex)) {
                                $selected.Remove($currentIndex)
                            } else {
                                if ($MaxSelection -eq 0 -or $selected.Count -lt $MaxSelection) {
                                    $selected[$currentIndex] = $true
                                }
                            }
                        }
                    }
                    'Enter' {
                        if ($selected.Count -ge $MinSelection) {
                            [Console]::CursorVisible = $true
                            $script:multiSelectRendered = $false
                            Write-SCText ""
                            
                            $indices = $selected.Keys | Sort-Object
                            if ($ReturnIndices) {
                                return $indices
                            } else {
                                return $indices | ForEach-Object { $Items[$_] }
                            }
                        }
                    }
                    'Escape' {
                        [Console]::CursorVisible = $true
                        $script:multiSelectRendered = $false
                        return $null
                    }
                }
                
                # Handle special keys
                if ($key.KeyChar -eq 'a' -or $key.KeyChar -eq 'A') {
                    # Select all
                    for ($i = 0; $i -lt $menuItems.Count; $i++) {
                        if (-not $menuItems[$i].Disabled) {
                            if ($MaxSelection -eq 0 -or $selected.Count -lt $MaxSelection) {
                                $selected[$i] = $true
                            }
                        }
                    }
                } elseif ($key.KeyChar -eq 'n' -or $key.KeyChar -eq 'N') {
                    # Select none
                    $selected.Clear()
                }
            }
        } finally {
            [Console]::CursorVisible = $true
            $script:multiSelectRendered = $false
        }
    }

* * *

### `src/pwsh/core/Input.ps1`

PowerShell

    <#
    .SYNOPSIS
        Input handling functions for Shell-Controls
    #>
    
    function Read-SCInput {
        <#
        .SYNOPSIS
            Reads styled input from the user
        #>
        [CmdletBinding()]
        param(
            [Parameter(Position = 0)]
            [string]$Prompt = "Enter value",
            
            [Parameter()]
            [string]$Default,
            
            [Parameter()]
            [scriptblock]$Validate,
            
            [Parameter()]
            [string]$ValidationMessage = "Invalid input",
            
            [Parameter()]
            [switch]$Required,
            
            [Parameter()]
            [string]$Placeholder
        )
        
        $primaryColor = Get-SCColor -Name "primary"
        $mutedColor = Get-SCColor -Name "muted"
        $errorColor = Get-SCColor -Name "error"
        $textColor = Get-SCColor -Name "text"
        $pointer = Get-SCSymbol -Name "pointer"
        
        $defaultHint = if ($Default) { " ($Default)" } else { "" }
        $requiredMark = if ($Required) { " *" } else { "" }
        
        while ($true) {
            $promptAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
            $hintAnsi = ConvertTo-AnsiColor -HexColor $mutedColor
            $reset = Get-AnsiReset
            
            Write-Host ""
            Write-Host "  ${promptAnsi}${pointer}${reset} ${promptAnsi}${Prompt}${requiredMark}${reset}${hintAnsi}${defaultHint}${reset}"
            Write-Host -NoNewline "    "
            
            $input = Read-Host
            
            if ([string]::IsNullOrWhiteSpace($input)) {
                if ($Default) {
                    return $Default
                } elseif ($Required) {
                    Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') This field is required" -Color $errorColor
                    continue
                } else {
                    return $null
                }
            }
            
            if ($Validate) {
                $isValid = & $Validate $input
                if (-not $isValid) {
                    Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') $ValidationMessage" -Color $errorColor
                    continue
                }
            }
            
            return $input
        }
    }
    
    function Read-SCPassword {
        <#
        .SYNOPSIS
            Reads a password with masked input
        #>
        [CmdletBinding()]
        param(
            [Parameter(Position = 0)]
            [string]$Prompt = "Enter password",
            
            [Parameter()]
            [switch]$Confirm,
            
            [Parameter()]
            [int]$MinLength = 0,
            
            [Parameter()]
            [switch]$AsPlainText
        )
        
        $primaryColor = Get-SCColor -Name "primary"
        $errorColor = Get-SCColor -Name "error"
        $pointer = Get-SCSymbol -Name "pointer"
        
        while ($true) {
            $promptAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
            $reset = Get-AnsiReset
            
            Write-Host ""
            Write-Host "  ${promptAnsi}${pointer}${reset} ${promptAnsi}${Prompt}${reset}"
            Write-Host -NoNewline "    "
            
            $secureString = Read-Host -AsSecureString
            
            if ($MinLength -gt 0) {
                $plainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
                )
                if ($plainText.Length -lt $MinLength) {
                    Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') Password must be at least $MinLength characters" -Color $errorColor
                    continue
                }
            }
            
            if ($Confirm) {
                Write-Host "  ${promptAnsi}${pointer}${reset} ${promptAnsi}Confirm password${reset}"
                Write-Host -NoNewline "    "
                
                $confirmSecure = Read-Host -AsSecureString
                
                $pass1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
                )
                $pass2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmSecure)
                )
                
                if ($pass1 -ne $pass2) {
                    Write-SCText -Text "    $(Get-SCSymbol -Name 'cross') Passwords do not match" -Color $errorColor
                    continue
                }
            }
            
            if ($AsPlainText) {
                return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
                )
            }
            
            return $secureString
        }
    }
    
    function Read-SCConfirm {
        <#
        .SYNOPSIS
            Displays a confirmation prompt
        #>
        [CmdletBinding()]
        param(
            [Parameter(Position = 0)]
            [string]$Message = "Are you sure?",
            
            [Parameter()]
            [switch]$DefaultYes,
            
            [Parameter()]
            [string]$YesLabel = "Yes",
            
            [Parameter()]
            [string]$NoLabel = "No"
        )
        
        $primaryColor = Get-SCColor -Name "primary"
        $mutedColor = Get-SCColor -Name "muted"
        $question = Get-SCSymbol -Name "question"
        
        $yHint = if ($DefaultYes) { "Y" } else { "y" }
        $nHint = if ($DefaultYes) { "n" } else { "N" }
        $hint = "($yHint/$nHint)"
        
        $primaryAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
        $mutedAnsi = ConvertTo-AnsiColor -HexColor $mutedColor
        $reset = Get-AnsiReset
        
        Write-Host ""
        Write-Host -NoNewline "  ${primaryAnsi}${question}${reset} ${primaryAnsi}${Message}${reset} ${mutedAnsi}${hint}${reset} "
        
        while ($true) {
            $key = [Console]::ReadKey($true)
            
            if ($key.Key -eq 'Enter') {
                [Console]::WriteLine()
                return $DefaultYes
            } elseif ($key.KeyChar -eq 'y' -or $key.KeyChar -eq 'Y') {
                [Console]::WriteLine("Yes")
                return $true
            } elseif ($key.KeyChar -eq 'n' -or $key.KeyChar -eq 'N') {
                [Console]::WriteLine("No")
                return $false
            }
        }
    }
    
    function Read-SCChoice {
        <#
        .SYNOPSIS
            Displays an inline choice prompt
        #>
        [CmdletBinding()]
        param(
            [Parameter(Position = 0)]
            [string]$Message = "Select an option",
            
            [Parameter(Mandatory)]
            [array]$Choices,
            
            [Parameter()]
            [int]$DefaultIndex = 0
        )
        
        $primaryColor = Get-SCColor -Name "primary"
        $accentColor = Get-SCColor -Name "accent"
        $mutedColor = Get-SCColor -Name "muted"
        $pointer = Get-SCSymbol -Name "pointer"
        
        $selectedIndex = $DefaultIndex
        
        [Console]::CursorVisible = $false
        
        try {
            while ($true) {
                $primaryAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
                $accentAnsi = ConvertTo-AnsiColor -HexColor $accentColor
                $mutedAnsi = ConvertTo-AnsiColor -HexColor $mutedColor
                $reset = Get-AnsiReset
                
                # Build choice string
                $choiceDisplay = ""
                for ($i = 0; $i -lt $Choices.Count; $i++) {
                    $choice = $Choices[$i]
                    if ($i -eq $selectedIndex) {
                        $choiceDisplay += " ${accentAnsi}[$choice]${reset}"
                    } else {
                        $choiceDisplay += " ${mutedAnsi}$choice${reset}"
                    }
                }
                
                # Render
                [Console]::SetCursorPosition(0, [Console]::CursorTop)
                [Console]::Write(" " * [Console]::WindowWidth)
                [Console]::SetCursorPosition(0, [Console]::CursorTop)
                [Console]::Write("  ${primaryAnsi}${pointer}${reset} ${primaryAnsi}${Message}${reset}:${choiceDisplay}")
                
                $key = [Console]::ReadKey($true)
                
                switch ($key.Key) {
                    'LeftArrow' { $selectedIndex = ($selectedIndex - 1 + $Choices.Count) % $Choices.Count }
                    'RightArrow' { $selectedIndex = ($selectedIndex + 1) % $Choices.Count }
                    'Enter' {
                        [Console]::WriteLine()
                        [Console]::CursorVisible = $true
                        return $Choices[$selectedIndex]
                    }
                }
            }
        } finally {
            [Console]::CursorVisible = $true
        }
    }
    
    function Read-SCNumber {
        <#
        .SYNOPSIS
            Reads a number with validation
        #>
        [CmdletBinding()]
        param(
            [Parameter(Position = 0)]
            [string]$Prompt = "Enter a number",
            
            [Parameter()]
            [double]$Min = [double]::MinValue,
            
            [Parameter()]
            [double]$Max = [double]::MaxValue,
            
            [Parameter()]
            [double]$Default,
            
            [Parameter()]
            [switch]$Integer
        )
        
        $validation = {
            param($input)
            $num = 0
            if ($Integer) {
                if (-not [int]::TryParse($input, [ref]$num)) { return $false }
            } else {
                if (-not [double]::TryParse($input, [ref]$num)) { return $false }
            }
            return ($num -ge $Min -and $num -le $Max)
        }
        
        $range = if ($Min -ne [double]::MinValue -or $Max -ne [double]::MaxValue) {
            "Range: [$Min - $Max]"
        } else { "" }
        
        $result = Read-SCInput -Prompt "$Prompt $range" -Default $Default -Validate $validation -ValidationMessage "Please enter a valid number"
        
        if ($null -eq $result) { return $null }
        
        if ($Integer) {
            return [int]$result
        } else {
            return [double]$result
        }
    }
    
    function Read-SCPath {
        <#
        .SYNOPSIS
            Reads a file or directory path with validation
        #>
        [CmdletBinding()]
        param(
            [Parameter(Position = 0)]
            [string]$Prompt = "Enter path",
            
            [Parameter()]
            [ValidateSet('File', 'Directory', 'Any')]
            [string]$Type = 'Any',
            
            [Parameter()]
            [switch]$MustExist,
            
            [Parameter()]
            [string]$Default
        )
        
        $validation = {
            param($input)
            
            if (-not $MustExist) { return $true }
            
            switch ($Type) {
                'File' { return Test-Path $input -PathType Leaf }
                'Directory' { return Test-Path $input -PathType Container }
                'Any' { return Test-Path $input }
            }
        }
        
        $message = if ($MustExist) { "Path must exist" } else { "Invalid path" }
        
        return Read-SCInput -Prompt $Prompt -Default $Default -Validate $validation -ValidationMessage $message
    }

* * *

### `src/pwsh/core/Progress.ps1`

PowerShell

    <#
    .SYNOPSIS
        Progress indicators for Shell-Controls
    #>
    
    function Show-SCProgress {
        <#
        .SYNOPSIS
            Displays a progress bar
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [int]$Current,
            
            [Parameter(Mandatory)]
            [int]$Total,
            
            [Parameter()]
            [string]$Label,
            
            [Parameter()]
            [int]$Width = 40,
            
            [Parameter()]
            [ValidateSet('blocks', 'line', 'dots', 'arrows')]
            [string]$Style = 'blocks',
            
            [Parameter()]
            [switch]$ShowPercentage,
            
            [Parameter()]
            [switch]$ShowCount,
            
            [Parameter()]
            [string]$Color
        )
        
        if (-not $Color) {
            $Color = Get-SCColor -Name "primary"
        }
        
        $percentage = [Math]::Min(100, [Math]::Round(($Current / $Total) * 100))
        $filled = [Math]::Round(($percentage / 100) * $Width)
        $empty = $Width - $filled
        
        # Choose characters based on style
        $chars = switch ($Style) {
            'blocks' { @{ filled = '█'; empty = '░'; left = ''; right = '' } }
            'line'   { @{ filled = '━'; empty = '─'; left = '╸'; right = '╺' } }
            'dots'   { @{ filled = '●'; empty = '○'; left = ''; right = '' } }
            'arrows' { @{ filled = '▶'; empty = '▷'; left = ''; right = '' } }
        }
        
        $progressBar = $chars.left + ($chars.filled * $filled) + ($chars.empty * $empty) + $chars.right
        
        $colorAnsi = ConvertTo-AnsiColor -HexColor $Color
        $mutedAnsi = ConvertTo-AnsiColor -HexColor (Get-SCColor -Name "muted")
        $reset = Get-AnsiReset
        
        # Build the line
        $line = ""
        if ($Label) { $line += "${mutedAnsi}${Label} ${reset}" }
        $line += "${colorAnsi}${progressBar}${reset}"
        if ($ShowPercentage) { $line += " ${mutedAnsi}${percentage}%${reset}" }
        if ($ShowCount) { $line += " ${mutedAnsi}(${Current}/${Total})${reset}" }
        
        # Clear line and write
        [Console]::SetCursorPosition(0, [Console]::CursorTop)
        [Console]::Write(" " * [Console]::WindowWidth)
        [Console]::SetCursorPosition(0, [Console]::CursorTop)
        [Console]::Write("  $line")
        
        if ($Current -ge $Total) {
            [Console]::WriteLine()
        }
    }
    
    function Show-SCSpinner {
        <#
        .SYNOPSIS
            Shows a spinner animation (returns a disposable object)
        #>
        [CmdletBinding()]
        param(
            [Parameter()]
            [string]$Message = "Loading...",
            
            [Parameter()]
            [ValidateSet('dots', 'line', 'arc', 'bounce', 'circle')]
            [string]$Style = 'dots',
            
            [Parameter()]
            [string]$Color
        )
        
        if (-not $Color) {
            $Color = Get-SCColor -Name "primary"
        }
        
        $spinnerChars = switch ($Style) {
            'dots'   { @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏') }
            'line'   { @('|', '/', '-', '\') }
            'arc'    { @('◜', '◠', '◝', '◞', '◡', '◟') }
            'bounce' { @('⠁', '⠂', '⠄', '⠂') }
            'circle' { @('◐', '◓', '◑', '◒') }
        }
        
        $state = @{
            Running = $true
            Message = $Message
            Frame = 0
            Color = $Color
            Chars = $spinnerChars
            StartPosition = [Console]::CursorTop
        }
        
        $job = Start-ThreadJob -ScriptBlock {
            param($state, $colorAnsi, $reset)
            
            [Console]::CursorVisible = $false
            
            while ($state.Running) {
                $char = $state.Chars[$state.Frame % $state.Chars.Count]
                $msg = $state.Message
                
                [Console]::SetCursorPosition(0, $state.StartPosition)
                [Console]::Write(" " * [Console]::WindowWidth)
                [Console]::SetCursorPosition(0, $state.StartPosition)
                [Console]::Write("  ${colorAnsi}${char}${reset} ${msg}")
                
                $state.Frame++
                Start-Sleep -Milliseconds 80
            }
            
            [Console]::CursorVisible = $true
        } -ArgumentList $state, (ConvertTo-AnsiColor -HexColor $Color), (Get-AnsiReset)
        
        # Return object that can be used to stop the spinner
        return [PSCustomObject]@{
            State = $state
            Job = $job
            Stop = {
                param($success = $true, $message = $null)
                
                $this.State.Running = $false
                $this.Job | Wait-Job | Remove-Job -Force
                
                [Console]::CursorVisible = $true
                [Console]::SetCursorPosition(0, $this.State.StartPosition)
                [Console]::Write(" " * [Console]::WindowWidth)
                [Console]::SetCursorPosition(0, $this.State.StartPosition)
                
                $symbol = if ($success) { 
                    "$(ConvertTo-AnsiColor -HexColor (Get-SCColor -Name 'success'))$(Get-SCSymbol -Name 'check')$(Get-AnsiReset)" 
                } else { 
                    "$(ConvertTo-AnsiColor -HexColor (Get-SCColor -Name 'error'))$(Get-SCSymbol -Name 'cross')$(Get-AnsiReset)" 
                }
                
                $finalMessage = $message ?? $this.State.Message
                [Console]::WriteLine("  $symbol $finalMessage")
            }.GetNewClosure()
            UpdateMessage = {
                param($newMessage)
                $this.State.Message = $newMessage
            }.GetNewClosure()
        }
    }
    
    function Invoke-SCWithSpinner {
        <#
        .SYNOPSIS
            Executes a script block while showing a spinner
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [scriptblock]$ScriptBlock,
            
            [Parameter()]
            [string]$Message = "Processing...",
            
            [Parameter()]
            [string]$SuccessMessage,
            
            [Parameter()]
            [string]$FailureMessage,
            
            [Parameter()]
            [string]$Style = 'dots'
        )
        
        $colorAnsi = ConvertTo-AnsiColor -HexColor (Get-SCColor -Name "primary")
        $successAnsi = ConvertTo-AnsiColor -HexColor (Get-SCColor -Name "success")
        $errorAnsi = ConvertTo-AnsiColor -HexColor (Get-SCColor -Name "error")
        $reset = Get-AnsiReset
        
        $spinnerChars = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
        $frame = 0
        $startPos = [Console]::CursorTop
        
        [Console]::CursorVisible = $false
        
        try {
            $job = Start-Job -ScriptBlock $ScriptBlock
            
            while ($job.State -eq 'Running') {
                $char = $spinnerChars[$frame % $spinnerChars.Count]
                
                [Console]::SetCursorPosition(0, $startPos)
                [Console]::Write(" " * [Console]::WindowWidth)
                [Console]::SetCursorPosition(0, $startPos)
                [Console]::Write("  ${colorAnsi}${char}${reset} ${Message}")
                
                $frame++
                Start-Sleep -Milliseconds 80
            }
            
            $result = Receive-Job -Job $job
            $success = $job.State -eq 'Completed'
            
            Remove-Job -Job $job -Force
            
            # Final state
            [Console]::SetCursorPosition(0, $startPos)
            [Console]::Write(" " * [Console]::WindowWidth)
            [Console]::SetCursorPosition(0, $startPos)
            
            if ($success) {
                $symbol = Get-SCSymbol -Name 'check'
                $msg = $SuccessMessage ?? $Message
                [Console]::WriteLine("  ${successAnsi}${symbol}${reset} ${msg}")
            } else {
                $symbol = Get-SCSymbol -Name 'cross'
                $msg = $FailureMessage ?? "Failed: $Message"
                [Console]::WriteLine("  ${errorAnsi}${symbol}${reset} ${msg}")
            }
            
            return $result
            
        } finally {
            [Console]::CursorVisible = $true
        }
    }
    
    function Show-SCCountdown {
        <#
        .SYNOPSIS
            Displays a countdown timer
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [int]$Seconds,
            
            [Parameter()]
            [string]$Message = "Starting in {0}s...",
            
            [Parameter()]
            [scriptblock]$OnComplete
        )
        
        $colorAnsi = ConvertTo-AnsiColor -HexColor (Get-SCColor -Name "warning")
        $reset = Get-AnsiReset
        $startPos = [Console]::CursorTop
        
        [Console]::CursorVisible = $false
        
        try {
            for ($i = $Seconds; $i -gt 0; $i--) {
                $display = $Message -f $i
                
                [Console]::SetCursorPosition(0, $startPos)
                [Console]::Write(" " * [Console]::WindowWidth)
                [Console]::SetCursorPosition(0, $startPos)
                [Console]::Write("  ${colorAnsi}⏱${reset} ${display}")
                
                Start-Sleep -Seconds 1
            }
            
            [Console]::SetCursorPosition(0, $startPos)
            [Console]::Write(" " * [Console]::WindowWidth)
            [Console]::SetCursorPosition(0, $startPos)
            
            if ($OnComplete) {
                & $OnComplete
            }
            
        } finally {
            [Console]::CursorVisible = $true
        }
    }

* * *

### `src/pwsh/core/Spinner.ps1`

PowerShell

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
        <#
        .SYNOPSIS
            Runs multiple tasks with visual progress
        #>
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
        $mutedColor = Get-SCColor -Name "muted"
        
        $check = Get-SCSymbol -Name "check"
        $cross = Get-SCSymbol -Name "cross"
        $spinner = Get-SCSymbol -Name "spinner"
        
        Write-SCText ""
        Write-SCText -Text $Title -Color $primaryColor -Bold
        Write-SCText ""
        
        $taskObjects = $Tasks | ForEach-Object {
            if ($_ -is [hashtable]) {
                [SCTaskRunner]::new($_.Name, $_.Action)
            } else {
                [SCTaskRunner]::new($_.ToString(), $_)
            }
        }
        
        $startLine = [Console]::CursorTop
        $taskCount = $taskObjects.Count
        
        # Initial render
        foreach ($task in $taskObjects) {
            Write-SCMuted "  ○ $($task.Name)"
        }
        
        [Console]::CursorVisible = $false
        
        try {
            for ($i = 0; $i -lt $taskCount; $i++) {
                $task = $taskObjects[$i]
                $task.Status = "running"
                
                # Animate spinner for current task
                $spinnerJob = Start-Job -ScriptBlock {
                    param($taskIndex, $startLine, $taskName, $spinnerChars, $colorAnsi, $reset)
                    
                    $frame = 0
                    while ($true) {
                        $char = $spinnerChars[$frame % $spinnerChars.Count]
                        [Console]::SetCursorPosition(0, $startLine + $taskIndex)
                        [Console]::Write("  ${colorAnsi}${char}${reset} ${taskName}")
                        $frame++
                        Start-Sleep -Milliseconds 80
                    }
                } -ArgumentList $i, $startLine, $task.Name, $spinner, (ConvertTo-AnsiColor -HexColor $primaryColor), (Get-AnsiReset)
                
                try {
                    $task.Result = & $task.Action
                    $task.Success = $true
                    $task.Status = "completed"
                } catch {
                    $task.Success = $false
                    $task.Status = "failed"
                    $task.Error = $_
                }
                
                # Stop spinner and update display
                Stop-Job -Job $spinnerJob -ErrorAction SilentlyContinue
                Remove-Job -Job $spinnerJob -Force -ErrorAction SilentlyContinue
                
                [Console]::SetCursorPosition(0, $startLine + $i)
                [Console]::Write(" " * [Console]::WindowWidth)
                [Console]::SetCursorPosition(0, $startLine + $i)
                
                if ($task.Success) {
                    $successAnsi = ConvertTo-AnsiColor -HexColor $successColor
                    $reset = Get-AnsiReset
                    [Console]::WriteLine("  ${successAnsi}${check}${reset} $($task.Name)")
                } else {
                    $errorAnsi = ConvertTo-AnsiColor -HexColor $errorColor
                    $reset = Get-AnsiReset
                    [Console]::WriteLine("  ${errorAnsi}${cross}${reset} $($task.Name)")
                    
                    if ($StopOnError) {
                        break
                    }
                }
            }
            
            # Move cursor to end
            [Console]::SetCursorPosition(0, $startLine + $taskCount)
            Write-SCText ""
            
            $succeeded = ($taskObjects | Where-Object { $_.Success }).Count
            $failed = ($taskObjects | Where-Object { -not $_.Success }).Count
            
            if ($failed -eq 0) {
                Write-SCSuccess "All $taskCount tasks completed successfully"
            } else {
                Write-SCWarning "$succeeded/$taskCount tasks completed, $failed failed"
            }
            
            return $taskObjects
            
        } finally {
            [Console]::CursorVisible = $true
        }
    }

* * *

### `src/pwsh/core/Table.ps1`

PowerShell

    <#
    .SYNOPSIS
        Table rendering for Shell-Controls
    #>
    
    function Show-SCTable {
        <#
        .SYNOPSIS
            Displays data in a formatted table
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, ValueFromPipeline)]
            [array]$Data,
            
            [Parameter()]
            [string[]]$Columns,
            
            [Parameter()]
            [string]$Title,
            
            [Parameter()]
            [ValidateSet('simple', 'rounded', 'heavy', 'double', 'minimal')]
            [string]$Style = 'rounded',
            
            [Parameter()]
            [hashtable]$ColumnWidths,
            
            [Parameter()]
            [hashtable]$ColumnColors,
            
            [Parameter()]
            [switch]$NoHeader
        )
        
        begin {
            $allData = @()
        }
        
        process {
            $allData += $Data
        }
        
        end {
            if ($allData.Count -eq 0) {
                Write-SCMuted "  (No data)"
                return
            }
            
            # Get box characters based on style
            $box = switch ($Style) {
                'simple' {
                    @{
                        tl = '+'; tr = '+'; bl = '+'; br = '+'
                        h = '-'; v = '|'
                        lm = '+'; rm = '+'; tm = '+'; bm = '+'; mm = '+'
                    }
                }
                'rounded' {
                    @{
                        tl = '╭'; tr = '╮'; bl = '╰'; br = '╯'
                        h = '─'; v = '│'
                        lm = '├'; rm = '┤'; tm = '┬'; bm = '┴'; mm = '┼'
                    }
                }
                'heavy' {
                    @{
                        tl = '┏'; tr = '┓'; bl = '┗'; br = '┛'
                        h = '━'; v = '┃'
                        lm = '┣'; rm = '┫'; tm = '┳'; bm = '┻'; mm = '╋'
                    }
                }
                'double' {
                    @{
                        tl = '╔'; tr = '╗'; bl = '╚'; br = '╝'
                        h = '═'; v = '║'
                        lm = '╠'; rm = '╣'; tm = '╦'; bm = '╩'; mm = '╬'
                    }
                }
                'minimal' {
                    @{
                        tl = ' '; tr = ' '; bl = ' '; br = ' '
                        h = '─'; v = ' '
                        lm = ' '; rm = ' '; tm = ' '; bm = ' '; mm = ' '
                    }
                }
            }
            
            # Determine columns
            if (-not $Columns) {
                $firstItem = $allData[0]
                if ($firstItem -is [hashtable]) {
                    $Columns = $firstItem.Keys | Sort-Object
                } elseif ($firstItem -is [PSCustomObject]) {
                    $Columns = $firstItem.PSObject.Properties.Name
                } else {
                    $Columns = @('Value')
                }
            }
            
            # Calculate column widths
            $widths = @{}
            foreach ($col in $Columns) {
                $maxWidth = $col.Length
                foreach ($item in $allData) {
                    $value = if ($item -is [hashtable]) { $item[$col] } else { $item.$col }
                    $len = "$value".Length
                    if ($len -gt $maxWidth) { $maxWidth = $len }
                }
                $widths[$col] = [Math]::Min($maxWidth + 2, 40)  # Max 40 chars per column
                
                if ($ColumnWidths -and $ColumnWidths.ContainsKey($col)) {
                    $widths[$col] = $ColumnWidths[$col]
                }
            }
            
            $borderColor = Get-SCColor -Name "border"
            $headerColor = Get-SCColor -Name "primary"
            $textColor = Get-SCColor -Name "text"
            
            $borderAnsi = ConvertTo-AnsiColor -HexColor $borderColor
            $headerAnsi = ConvertTo-AnsiColor -HexColor $headerColor
            $textAnsi = ConvertTo-AnsiColor -HexColor $textColor
            $reset = Get-AnsiReset
            
            # Title
            if ($Title) {
                Write-SCText ""
                Write-SCText -Text $Title -Color $headerColor -Bold
            }
            
            # Top border
            $topBorder = $box.tl
            for ($i = 0; $i -lt $Columns.Count; $i++) {
                $topBorder += ($box.h * $widths[$Columns[$i]])
                if ($i -lt $Columns.Count - 1) { $topBorder += $box.tm }
            }
            $topBorder += $box.tr
            Write-SCText -Text "  $topBorder" -Color $borderColor
            
            # Header
            if (-not $NoHeader) {
                $headerLine = $box.v
                foreach ($col in $Columns) {
                    $padded = " $col".PadRight($widths[$col])
                    $headerLine += "${headerAnsi}${padded}${reset}${borderAnsi}${box.v}${reset}"
                }
                [Console]::WriteLine("  ${borderAnsi}${headerLine}")
                
                # Header separator
                $sepLine = $box.lm
                for ($i = 0; $i -lt $Columns.Count; $i++) {
                    $sepLine += ($box.h * $widths[$Columns[$i]])
                    if ($i -lt $Columns.Count - 1) { $sepLine += $box.mm }
                }
                $sepLine += $box.rm
                Write-SCText -Text "  $sepLine" -Color $borderColor
            }
            
            # Data rows
            foreach ($item in $allData) {
                $rowLine = $box.v
                foreach ($col in $Columns) {
                    $value = if ($item -is [hashtable]) { $item[$col] } else { $item.$col }
                    $valueStr = "$value"
                    if ($valueStr.Length -gt $widths[$col] - 2) {
                        $valueStr = $valueStr.Substring(0, $widths[$col] - 4) + "..."
                    }
                    $padded = " $valueStr".PadRight($widths[$col])
                    
                    $color = $textAnsi
                    if ($ColumnColors -and $ColumnColors.ContainsKey($col)) {
                        $color = ConvertTo-AnsiColor -HexColor $ColumnColors[$col]
                    }
                    
                    $rowLine += "${color}${padded}${reset}${borderAnsi}${box.v}${reset}"
                }
                [Console]::WriteLine("  ${borderAnsi}${rowLine}")
            }
            
            # Bottom border
            $bottomBorder = $box.bl
            for ($i = 0; $i -lt $Columns.Count; $i++) {
                $bottomBorder += ($box.h * $widths[$Columns[$i]])
                if ($i -lt $Columns.Count - 1) { $bottomBorder += $box.bm }
            }
            $bottomBorder += $box.br
            Write-SCText -Text "  $bottomBorder" -Color $borderColor
            Write-SCText ""
        }
    }

* * *

### `src/pwsh/components/Banner.ps1`

PowerShell

    <#
    .SYNOPSIS
        ASCII banner and logo components
    #>
    
    function Show-SCBanner {
        <#
        .SYNOPSIS
            Displays a styled ASCII banner
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Text,
            
            [Parameter()]
            [ValidateSet('standard', 'slant', 'small', 'block', 'mini')]
            [string]$Font = 'standard',
            
            [Parameter()]
            [string[]]$GradientColors,
            
            [Parameter()]
            [string]$Subtitle,
            
            [Parameter()]
            [string]$Version,
            
            [Parameter()]
            [switch]$Centered
        )
        
        # ASCII art fonts (simplified versions)
        $fonts = @{
            'standard' = @{
                height = 6
                chars = @{
                    'A' = @('  █████╗ ', ' ██╔══██╗', ' ███████║', ' ██╔══██║', ' ██║  ██║', ' ╚═╝  ╚═╝')
                    'B' = @(' ██████╗ ', ' ██╔══██╗', ' ██████╔╝', ' ██╔══██╗', ' ██████╔╝', ' ╚═════╝ ')
                    'C' = @('  ██████╗', ' ██╔════╝', ' ██║     ', ' ██║     ', ' ╚██████╗', '  ╚═════╝')
                    'D' = @(' ██████╗ ', ' ██╔══██╗', ' ██║  ██║', ' ██║  ██║', ' ██████╔╝', ' ╚═════╝ ')
                    'E' = @(' ███████╗', ' ██╔════╝', ' █████╗  ', ' ██╔══╝  ', ' ███████╗', ' ╚══════╝')
                    'F' = @(' ███████╗', ' ██╔════╝', ' █████╗  ', ' ██╔══╝  ', ' ██║     ', ' ╚═╝     ')
                    'G' = @('  ██████╗ ', ' ██╔════╝ ', ' ██║  ███╗', ' ██║   ██║', ' ╚██████╔╝', '  ╚═════╝ ')
                    'H' = @(' ██╗  ██╗', ' ██║  ██║', ' ███████║', ' ██╔══██║', ' ██║  ██║', ' ╚═╝  ╚═╝')
                    'I' = @(' ██╗', ' ██║', ' ██║', ' ██║', ' ██║', ' ╚═╝')
                    'J' = @('     ██╗', '     ██║', '     ██║', ' ██  ██║', ' ╚████╔╝', '  ╚═══╝ ')
                    'K' = @(' ██╗  ██╗', ' ██║ ██╔╝', ' █████╔╝ ', ' ██╔═██╗ ', ' ██║  ██╗', ' ╚═╝  ╚═╝')
                    'L' = @(' ██╗     ', ' ██║     ', ' ██║     ', ' ██║     ', ' ███████╗', ' ╚══════╝')
                    'M' = @(' ███╗   ███╗', ' ████╗ ████║', ' ██╔████╔██║', ' ██║╚██╔╝██║', ' ██║ ╚═╝ ██║', ' ╚═╝     ╚═╝')
                    'N' = @(' ███╗   ██╗', ' ████╗  ██║', ' ██╔██╗ ██║', ' ██║╚██╗██║', ' ██║ ╚████║', ' ╚═╝  ╚═══╝')
                    'O' = @('  ██████╗ ', ' ██╔═══██╗', ' ██║   ██║', ' ██║   ██║', ' ╚██████╔╝', '  ╚═════╝ ')
                    'P' = @(' ██████╗ ', ' ██╔══██╗', ' ██████╔╝', ' ██╔═══╝ ', ' ██║     ', ' ╚═╝     ')
                    'Q' = @('  ██████╗ ', ' ██╔═══██╗', ' ██║   ██║', ' ██║▄▄ ██║', ' ╚██████╔╝', '  ╚══▀▀═╝ ')
                    'R' = @(' ██████╗ ', ' ██╔══██╗', ' ██████╔╝', ' ██╔══██╗', ' ██║  ██║', ' ╚═╝  ╚═╝')
                    'S' = @(' ███████╗', ' ██╔════╝', ' ███████╗', ' ╚════██║', ' ███████║', ' ╚══════╝')
                    'T' = @(' ████████╗', ' ╚══██╔══╝', '    ██║   ', '    ██║   ', '    ██║   ', '    ╚═╝   ')
                    'U' = @(' ██╗   ██╗', ' ██║   ██║', ' ██║   ██║', ' ██║   ██║', ' ╚██████╔╝', '  ╚═════╝ ')
                    'V' = @(' ██╗   ██╗', ' ██║   ██║', ' ██║   ██║', ' ╚██╗ ██╔╝', '  ╚████╔╝ ', '   ╚═══╝  ')
                    'W' = @(' ██╗    ██╗', ' ██║    ██║', ' ██║ █╗ ██║', ' ██║███╗██║', ' ╚███╔███╔╝', '  ╚══╝╚══╝ ')
                    'X' = @(' ██╗  ██╗', ' ╚██╗██╔╝', '  ╚███╔╝ ', '  ██╔██╗ ', ' ██╔╝ ██╗', ' ╚═╝  ╚═╝')
                    'Y' = @(' ██╗   ██╗', ' ╚██╗ ██╔╝', '  ╚████╔╝ ', '   ╚██╔╝  ', '    ██║   ', '    ╚═╝   ')
                    'Z' = @(' ███████╗', ' ╚══███╔╝', '   ███╔╝ ', '  ███╔╝  ', ' ███████╗', ' ╚══════╝')
                    ' ' = @('   ', '   ', '   ', '   ', '   ', '   ')
                    '-' = @('        ', '        ', ' ██████╗', ' ╚═════╝', '        ', '        ')
                }
            }
            'small' = @{
                height = 4
                chars = @{
                    'A' = @(' █▀█ ', ' █▀█ ', ' ▀ ▀ ', '     ')
                    'B' = @(' █▀▄ ', ' █▀▄ ', ' ▀▀  ', '     ')
                    'C' = @(' █▀▀ ', ' █   ', ' ▀▀▀ ', '     ')
                    'D' = @(' █▀▄ ', ' █ █ ', ' ▀▀  ', '     ')
                    'E' = @(' █▀▀ ', ' █▀▀ ', ' ▀▀▀ ', '     ')
                    'F' = @(' █▀▀ ', ' █▀▀ ', ' ▀   ', '     ')
                    ' ' = @('  ', '  ', '  ', '  ')
                }
            }
            'block' = @{
                height = 3
                chars = @{
                    'A' = @('███', '█▀█', '▀ ▀')
                    'B' = @('██▄', '█▄█', '▀▀▀')
                    'C' = @('█▀▀', '█  ', '▀▀▀')
                    'D' = @('██▄', '█ █', '▀▀▀')
                    'E' = @('█▀▀', '█▀▀', '▀▀▀')
                    'F' = @('█▀▀', '█▀ ', '▀  ')
                    'G' = @('█▀▀', '█ █', '▀▀▀')
                    'H' = @('█ █', '███', '▀ ▀')
                    'I' = @('█', '█', '▀')
                    'L' = @('█  ', '█  ', '▀▀▀')
                    'N' = @('█▀█', '█ █', '▀ ▀')
                    'O' = @('█▀█', '█ █', '▀▀▀')
                    'R' = @('█▀▄', '██▀', '▀ ▀')
                    'S' = @('▀█▀', ' █ ', '▀▀▀')
                    'T' = @('▀█▀', ' █ ', ' ▀ ')
                    'U' = @('█ █', '█ █', '▀▀▀')
                    ' ' = @(' ', ' ', ' ')
                }
            }
        }
        
        $font = $fonts[$Font]
        if (-not $font) { $font = $fonts['block'] }
        
        $lines = @()
        for ($i = 0; $i -lt $font.height; $i++) {
            $line = ""
            foreach ($char in $Text.ToUpper().ToCharArray()) {
                $charArt = $font.chars[$char.ToString()]
                if ($charArt) {
                    $line += $charArt[$i]
                } else {
                    $line += " " * 4
                }
            }
            $lines += $line
        }
        
        # Get gradient colors or use theme
        if (-not $GradientColors) {
            $GradientColors = $script:Theme.gradients.rainbow
        }
        
        Write-SCText ""
        
        $termWidth = [Console]::WindowWidth
        
        foreach ($line in $lines) {
            if ($Centered) {
                $padding = [Math]::Max(0, ($termWidth - $line.Length) / 2)
                $line = (' ' * $padding) + $line
            } else {
                $line = "  $line"
            }
            Write-SCGradient -Text $line -Colors $GradientColors
        }
        
        if ($Subtitle -or $Version) {
            $info = ""
            if ($Subtitle) { $info += $Subtitle }
            if ($Version) { $info += "  v$Version" }
            
            if ($Centered) {
                $padding = [Math]::Max(0, ($termWidth - $info.Length) / 2)
                $info = (' ' * $padding) + $info
            } else {
                $info = "  $info"
            }
            
            Write-SCText ""
            Write-SCText -Text $info -Color (Get-SCColor -Name "muted")
        }
        
        Write-SCText ""
    }

* * *

### `src/pwsh/components/Panel.ps1`

PowerShell

    <#
    .SYNOPSIS
        Panel/box components for Shell-Controls
    #>
    
    function Show-SCPanel {
        <#
        .SYNOPSIS
            Displays content in a styled panel/box
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string[]]$Content,
            
            [Parameter()]
            [string]$Title,
            
            [Parameter()]
            [int]$Width = 0,
            
            [Parameter()]
            [ValidateSet('rounded', 'heavy', 'double', 'simple')]
            [string]$Style = 'rounded',
            
            [Parameter()]
            [string]$BorderColor,
            
            [Parameter()]
            [string]$TitleColor,
            
            [Parameter()]
            [ValidateSet('Left', 'Center', 'Right')]
            [string]$TitleAlign = 'Left',
            
            [Parameter()]
            [int]$Padding = 1
        )
        
        $box = switch ($Style) {
            'rounded' { Get-SCSymbol -Name "boxRounded" }
            'heavy'   { Get-SCSymbol -Name "boxHeavy" }
            'double'  { Get-SCSymbol -Name "boxDouble" }
            'simple'  { Get-SCSymbol -Name "boxLight" }
        }
        
        if (-not $BorderColor) { $BorderColor = Get-SCColor -Name "border" }
        if (-not $TitleColor) { $TitleColor = Get-SCColor -Name "primary" }
        
        # Calculate width
        if ($Width -eq 0) {
            $maxContentWidth = ($Content | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
            $Width = [Math]::Max($maxContentWidth + ($Padding * 2) + 2, 40)
            if ($Title) { $Width = [Math]::Max($Width, $Title.Length + 4) }
        }
        
        $innerWidth = $Width - 2
        
        $borderAnsi = ConvertTo-AnsiColor -HexColor $BorderColor
        $titleAnsi = ConvertTo-AnsiColor -HexColor $TitleColor
        $reset = Get-AnsiReset
        
        # Top border with title
        if ($Title) {
            $titleDisplay = " $Title "
            $titlePadding = switch ($TitleAlign) {
                'Left'   { 2 }
                'Center' { [Math]::Floor(($innerWidth - $titleDisplay.Length) / 2) }
                'Right'  { $innerWidth - $titleDisplay.Length - 2 }
            }
            $leftLine = $box.horizontal * $titlePadding
            $rightLine = $box.horizontal * ($innerWidth - $titlePadding - $titleDisplay.Length)
            
            [Console]::WriteLine("  ${borderAnsi}$($box.topLeft)${leftLine}${reset}${titleAnsi}${titleDisplay}${reset}${borderAnsi}${rightLine}$($box.topRight)${reset}")
        } else {
            $topLine = $box.horizontal * $innerWidth
            [Console]::WriteLine("  ${borderAnsi}$($box.topLeft)${topLine}$($box.topRight)${reset}")
        }
        
        # Padding top
        for ($i = 0; $i -lt $Padding; $i++) {
            $paddingLine = ' ' * $innerWidth
            [Console]::WriteLine("  ${borderAnsi}$($box.vertical)${reset}${paddingLine}${borderAnsi}$($box.vertical)${reset}")
        }
        
        # Content
        foreach ($line in $Content) {
            $paddedLine = (' ' * $Padding) + $line
            $paddedLine = $paddedLine.PadRight($innerWidth)
            if ($paddedLine.Length -gt $innerWidth) {
                $paddedLine = $paddedLine.Substring(0, $innerWidth - 3) + "..."
            }
            [Console]::WriteLine("  ${borderAnsi}$($box.vertical)${reset}${paddedLine}${borderAnsi}$($box.vertical)${reset}")
        }
        
        # Padding bottom
        for ($i = 0; $i -lt $Padding; $i++) {
            $paddingLine = ' ' * $innerWidth
            [Console]::WriteLine("  ${borderAnsi}$($box.vertical)${reset}${paddingLine}${borderAnsi}$($box.vertical)${reset}")
        }
        
        # Bottom border
        $bottomLine = $box.horizontal * $innerWidth
        [Console]::WriteLine("  ${borderAnsi}$($box.bottomLeft)${bottomLine}$($box.bottomRight)${reset}")
    }
    
    function Show-SCNotification {
        <#
        .SYNOPSIS
            Displays a styled notification message
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Message,
            
            [Parameter()]
            [ValidateSet('info', 'success', 'warning', 'error')]
            [string]$Type = 'info',
            
            [Parameter()]
            [string]$Title,
            
            [Parameter()]
            [switch]$Dismissible
        )
        
        $colors = @{
            'info'    = Get-SCColor -Name "info"
            'success' = Get-SCColor -Name "success"
            'warning' = Get-SCColor -Name "warning"
            'error'   = Get-SCColor -Name "error"
        }
        
        $icons = @{
            'info'    = Get-SCSymbol -Name "info"
            'success' = Get-SCSymbol -Name "check"
            'warning' = Get-SCSymbol -Name "warning"
            'error'   = Get-SCSymbol -Name "cross"
        }
        
        $color = $colors[$Type]
        $icon = $icons[$Type]
        
        Write-SCText ""
        
        $header = if ($Title) { "$icon $Title" } else { $icon }
        
        Show-SCPanel -Content @($Message) -Title $header -BorderColor $color -TitleColor $color -Width 60
        
        if ($Dismissible) {
            Write-SCMuted "  Press any key to dismiss..."
            $null = [Console]::ReadKey($true)
        }
    }

* * *

### `src/pwsh/core/Process.ps1`

PowerShell

    <#
    .SYNOPSIS
        Process management for Shell-Controls
    #>
    
    function Start-SCProcess {
        <#
        .SYNOPSIS
            Starts a process with visual feedback
        #>
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
        
        $desc = $Description ?? "$Command $($Arguments -join ' ')"
        
        Write-SCText ""
        Write-SCInfo "Starting: $desc"
        Write-SCText ""
        
        $psi = [System.Diagnostics.ProcessStartInfo]::new()
        $psi.FileName = $Command
        $psi.Arguments = $Arguments -join ' '
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true
        
        if ($WorkingDirectory) {
            $psi.WorkingDirectory = $WorkingDirectory
        }
        
        $process = [System.Diagnostics.Process]::new()
        $process.StartInfo = $psi
        
        $outputBuilder = [System.Text.StringBuilder]::new()
        $errorBuilder = [System.Text.StringBuilder]::new()
        
        $outputHandler = {
            param($sender, $e)
            if ($null -ne $e.Data) {
                [void]$outputBuilder.AppendLine($e.Data)
                if ($ShowOutput) {
                    Write-SCMuted "  $($e.Data)"
                }
            }
        }
        
        $errorHandler = {
            param($sender, $e)
            if ($null -ne $e.Data) {
                [void]$errorBuilder.AppendLine($e.Data)
                if ($ShowOutput) {
                    Write-SCText -Text "  $($e.Data)" -Color (Get-SCColor -Name "error")
                }
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
                Output = $outputBuilder.ToString()
                Error = $errorBuilder.ToString()
                Success = ($process.ExitCode -eq 0)
            }
            
            if ($result.Success) {
                Write-SCSuccess "Process completed successfully"
            } else {
                Write-SCError "Process failed with exit code: $($result.ExitCode)"
            }
            
            if ($PassThru) {
                return $result
            }
            
        } finally {
            $process.Dispose()
        }
    }
    
    function Watch-SCProcess {
        <#
        .SYNOPSIS
            Watches a running process with status updates
        #>
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
                [Console]::Write(" " * [Console]::WindowWidth)
                [Console]::SetCursorPosition(0, $startPos)
                [Console]::Write("  ${primaryAnsi}${char}${reset} ${Message}  [PID: $($Process.Id) | Mem: ${mem}MB | CPU: ${cpu}s]")
                
                $frame++
                Start-Sleep -Milliseconds $PollInterval
            }
            
            [Console]::SetCursorPosition(0, $startPos)
            [Console]::Write(" " * [Console]::WindowWidth)
            [Console]::SetCursorPosition(0, $startPos)
            
            if ($Process.ExitCode -eq 0) {
                Write-SCSuccess "$Message - Completed"
            } else {
                Write-SCError "$Message - Failed (Exit: $($Process.ExitCode))"
            }
            
        } finally {
            [Console]::CursorVisible = $true
        }
    }

* * *

### `src/pwsh/core/Utils.ps1`

PowerShell

    <#
    .SYNOPSIS
        Utility functions for Shell-Controls
    #>
    
    function Get-SCTerminalSize {
        <#
        .SYNOPSIS
            Gets the current terminal size
        #>
        [CmdletBinding()]
        param()
        
        return [PSCustomObject]@{
            Width = [Console]::WindowWidth
            Height = [Console]::WindowHeight
            BufferWidth = [Console]::BufferWidth
            BufferHeight = [Console]::BufferHeight
        }
    }
    
    function Test-SCCommand {
        <#
        .SYNOPSIS
            Tests if a command exists
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Name
        )
        
        return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
    }
    
    function Invoke-SCCommand {
        <#
        .SYNOPSIS
            Invokes a command with error handling
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [scriptblock]$ScriptBlock,
            
            [Parameter()]
            [string]$ErrorMessage = "Command failed",
            
            [Parameter()]
            [switch]$SuppressErrors
        )
        
        try {
            & $ScriptBlock
        } catch {
            if (-not $SuppressErrors) {
                Write-SCError "$ErrorMessage`: $_"
            }
            return $null
        }
    }
    
    function ConvertTo-SCSlug {
        <#
        .SYNOPSIS
            Converts a string to a URL-friendly slug
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Text
        )
        
        $slug = $Text.ToLower()
        $slug = $slug -replace '[^a-z0-9\s-]', ''
        $slug = $slug -replace '\s+', '-'
        $slug = $slug -replace '-+', '-'
        $slug = $slug.Trim('-')
        
        return $slug
    }
    
    function Get-SCRelativePath {
        <#
        .SYNOPSIS
            Gets a relative path from one path to another
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]$From,
            
            [Parameter(Mandatory)]
            [string]$To
        )
        
        $fromUri = [Uri]::new($From + [IO.Path]::DirectorySeparatorChar)
        $toUri = [Uri]::new($To)
        
        $relativeUri = $fromUri.MakeRelativeUri($toUri)
        $relativePath = [Uri]::UnescapeDataString($relativeUri.ToString())
        
        return $relativePath.Replace('/', [IO.Path]::DirectorySeparatorChar)
    }
    
    function Format-SCDuration {
        <#
        .SYNOPSIS
            Formats a timespan as a human-readable duration
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [TimeSpan]$Duration
        )
        
        if ($Duration.TotalMilliseconds -lt 1000) {
            return "{0:N0}ms" -f $Duration.TotalMilliseconds
        } elseif ($Duration.TotalSeconds -lt 60) {
            return "{0:N1}s" -f $Duration.TotalSeconds
        } elseif ($Duration.TotalMinutes -lt 60) {
            return "{0:N0}m {1:N0}s" -f [Math]::Floor($Duration.TotalMinutes), $Duration.Seconds
        } else {
            return "{0:N0}h {1:N0}m" -f [Math]::Floor($Duration.TotalHours), $Duration.Minutes
        }
    }
    
    function Get-SCEnvironmentInfo {
        <#
        .SYNOPSIS
            Gets information about the current environment
        #>
        [CmdletBinding()]
        param()
        
        return [PSCustomObject]@{
            OS = [System.Environment]::OSVersion.Platform
            OSVersion = [System.Environment]::OSVersion.VersionString
            PowerShell = $PSVersionTable.PSVersion.ToString()
            IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            User = [Environment]::UserName
            Machine = [Environment]::MachineName
            CurrentDirectory = (Get-Location).Path
            HomeDirectory = $HOME
        }
    }

* * *

### `src/pwsh/core/Logger.ps1`

PowerShell

    <#
    .SYNOPSIS
        Logging functionality for Shell-Controls
    #>
    
    $script:LogLevel = @{
        Debug = 0
        Info = 1
        Warning = 2
        Error = 3
        None = 4
    }
    
    $script:CurrentLogLevel = $script:LogLevel.Info
    $script:LogFile = $null
    
    function Set-SCLogLevel {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [ValidateSet('Debug', 'Info', 'Warning', 'Error', 'None')]
            [string]$Level
        )
        
        $script:CurrentLogLevel = $script:LogLevel[$Level]
    }
    
    function Set-SCLogFile {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]$Path
        )
        
        $script:LogFile = $Path
        
        # Ensure directory exists
        $dir = Split-Path $Path -Parent
        if ($dir -and -not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    function Write-SCLog {
        <#
        .SYNOPSIS
            Writes a log message
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$Message,
            
            [Parameter()]
            [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
            [string]$Level = 'Info',
            
            [Parameter()]
            [switch]$NoConsole,
            
            [Parameter()]
            [switch]$NoFile
        )
        
        $levelNum = $script:LogLevel[$Level]
        
        if ($levelNum -lt $script:CurrentLogLevel) {
            return
        }
        
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] [$Level.ToUpper().PadRight(7)] $Message"
        
        # Console output
        if (-not $NoConsole) {
            switch ($Level) {
                'Debug'   { Write-SCMuted $Message }
                'Info'    { Write-SCInfo $Message }
                'Warning' { Write-SCWarning $Message }
                'Error'   { Write-SCError $Message }
            }
        }
        
        # File output
        if (-not $NoFile -and $script:LogFile) {
            Add-Content -Path $script:LogFile -Value $logMessage
        }
    }

* * *

Example Runners
---------------

### `examples/fullstack-runner/run.ps1`

PowerShell

    #!/usr/bin/env pwsh
    #Requires -Version 7.0
    <#
    .SYNOPSIS
        Full-Stack Development Runner
    .DESCRIPTION
        Interactive runner for managing full-stack development environment
    #>
    
    param(
        [switch]$SkipMenu
    )
    
    # Import Shell-Controls
    $shellControlsPath = Join-Path $PSScriptRoot "..\..\src\pwsh\Shell-Controls.psd1"
    Import-Module $shellControlsPath -Force
    
    # Initialize with custom theme
    Initialize-ShellControls -ThemeName "catppuccin"
    
    # Configuration
    $config = @{
        ProjectName = "My Full-Stack App"
        Version = "1.0.0"
        Services = @(
            @{
                Name = "Backend API"
                Icon = "🔧"
                Path = "./backend"
                Command = "dotnet"
                Arguments = @("run")
                Port = 5000
                HealthCheck = "http://localhost:5000/health"
            }
            @{
                Name = "Frontend"
                Icon = "🎨"
                Path = "./frontend"
                Command = "npm"
                Arguments = @("run", "dev")
                Port = 3000
                HealthCheck = "http://localhost:3000"
            }
            @{
                Name = "Database"
                Icon = "🗄️"
                Path = "./docker"
                Command = "docker-compose"
                Arguments = @("up", "-d", "db")
                Port = 5432
            }
            @{
                Name = "Redis Cache"
                Icon = "⚡"
                Path = "./docker"
                Command = "docker-compose"
                Arguments = @("up", "-d", "redis")
                Port = 6379
            }
        )
    }
    
    # Running processes tracker
    $script:RunningProcesses = @{}
    
    function Show-MainBanner {
        Clear-SCScreen
        Show-SCBanner -Text $config.ProjectName -Font "block" -Subtitle "Full-Stack Development Environment" -Version $config.Version
        Write-SCLine
    }
    
    function Get-ServiceStatus {
        $statuses = @()
        
        foreach ($service in $config.Services) {
            $isRunning = $script:RunningProcesses.ContainsKey($service.Name)
            $status = if ($isRunning) { "Running" } else { "Stopped" }
            $statusColor = if ($isRunning) { "success" } else { "muted" }
            
            $statuses += @{
                Name = "$($service.Icon) $($service.Name)"
                Status = $status
                Port = $service.Port
            }
        }
        
        return $statuses
    }
    
    function Show-Dashboard {
        Show-MainBanner
        
        Write-SCHeader -Text "Service Status" -Icon "📊"
        
        $statuses = Get-ServiceStatus
        Show-SCTable -Data $statuses -Columns @("Name", "Status", "Port") -Style "rounded"
        
        Write-SCText ""
    }
    
    function Start-Service {
        param([hashtable]$Service)
        
        if ($script:RunningProcesses.ContainsKey($Service.Name)) {
            Write-SCWarning "$($Service.Name) is already running"
            return
        }
        
        Write-SCInfo "Starting $($Service.Name)..."
        
        $psi = [System.Diagnostics.ProcessStartInfo]::new()
        $psi.FileName = $Service.Command
        $psi.Arguments = $Service.Arguments -join ' '
        $psi.WorkingDirectory = Join-Path $PSScriptRoot $Service.Path
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true
        
        try {
            $process = [System.Diagnostics.Process]::Start($psi)
            $script:RunningProcesses[$Service.Name] = $process
            
            Start-Sleep -Seconds 2
            
            if (-not $process.HasExited) {
                Write-SCSuccess "$($Service.Name) started on port $($Service.Port)"
            } else {
                Write-SCError "$($Service.Name) failed to start"
                $script:RunningProcesses.Remove($Service.Name)
            }
        } catch {
            Write-SCError "Failed to start $($Service.Name): $_"
        }
    }
    
    function Stop-Service {
        param([hashtable]$Service)
        
        if (-not $script:RunningProcesses.ContainsKey($Service.Name)) {
            Write-SCWarning "$($Service.Name) is not running"
            return
        }
        
        Write-SCInfo "Stopping $($Service.Name)..."
        
        try {
            $process = $script:RunningProcesses[$Service.Name]
            $process.Kill()
            $process.WaitForExit(5000)
            $script:RunningProcesses.Remove($Service.Name)
            Write-SCSuccess "$($Service.Name) stopped"
        } catch {
            Write-SCError "Failed to stop $($Service.Name): $_"
        }
    }
    
    function Start-AllServices {
        Write-SCHeader -Text "Starting All Services" -Icon "🚀"
        
        $tasks = $config.Services | ForEach-Object {
            $svc = $_
            @{
                Name = "Starting $($svc.Name)"
                Action = { Start-Service -Service $svc }.GetNewClosure()
            }
        }
        
        Start-SCTasks -Tasks $tasks -Title "Starting Services"
    }
    
    function Stop-AllServices {
        Write-SCHeader -Text "Stopping All Services" -Icon "🛑"
        
        foreach ($service in $config.Services) {
            Stop-Service -Service $service
        }
        
        Write-SCSuccess "All services stopped"
    }
    
    function Show-ServiceMenu {
        $items = $config.Services | ForEach-Object {
            $isRunning = $script:RunningProcesses.ContainsKey($_.Name)
            $status = if ($isRunning) { "[Running]" } else { "[Stopped]" }
            
            @{
                Name = "$($_.Icon) $($_.Name) $status"
                Description = "Port: $($_.Port)"
                Service = $_
            }
        }
        
        $items += @{ Name = "← Back"; Description = "Return to main menu" }
        
        $selection = Show-SCMenu -Title "Select a Service" -Items $items -AllowCancel
        
        if ($null -eq $selection -or $selection.Name -eq "← Back") {
            return
        }
        
        $service = $selection.Service
        $isRunning = $script:RunningProcesses.ContainsKey($service.Name)
        
        $actions = if ($isRunning) {
            @("Stop", "Restart", "View Logs", "Cancel")
        } else {
            @("Start", "Cancel")
        }
        
        $action = Show-SCMenu -Title "Action for $($service.Name)" -Items $actions -AllowCancel
        
        switch ($action) {
            "Start" { Start-Service -Service $service }
            "Stop" { Stop-Service -Service $service }
            "Restart" { 
                Stop-Service -Service $service
                Start-Sleep -Seconds 1
                Start-Service -Service $service
            }
        }
    }
    
    function Show-QuickActions {
        $actions = @(
            @{ Name = "🚀 Start All Services"; Action = { Start-AllServices } }
            @{ Name = "🛑 Stop All Services"; Action = { Stop-AllServices } }
            @{ Name = "🔄 Restart All Services"; Action = { Stop-AllServices; Start-AllServices } }
            @{ Name = "📊 Show Dashboard"; Action = { Show-Dashboard } }
            @{ Name = "🔧 Manage Services"; Action = { Show-ServiceMenu } }
            @{ Name = "📦 Install Dependencies"; Action = { Install-Dependencies } }
            @{ Name = "🧪 Run Tests"; Action = { Invoke-Tests } }
            @{ Name = "🗃️ Database Operations"; Action = { Show-DatabaseMenu } }
            @{ Name = "📝 View Logs"; Action = { Show-LogViewer } }
            @{ Name = "⚙️ Settings"; Action = { Show-Settings } }
            @{ Name = "❌ Exit"; Action = { Exit-Runner } }
        )
        
        return $actions
    }
    
    function Install-Dependencies {
        Write-SCHeader -Text "Installing Dependencies" -Icon "📦"
        
        $tasks = @(
            @{
                Name = "Installing Backend Dependencies"
                Action = {
                    if (Test-Path "./backend/package.json") {
                        & npm install --prefix "./backend"
                    } elseif (Test-Path "./backend/*.csproj") {
                        & dotnet restore "./backend"
                    }
                }
            }
            @{
                Name = "Installing Frontend Dependencies"
                Action = { & npm install --prefix "./frontend" }
            }
        )
        
        Start-SCTasks -Tasks $tasks
    }
    
    function Invoke-Tests {
        $testType = Read-SCChoice -Message "Select test type" -Choices @("All", "Backend", "Frontend", "E2E")
        
        Write-SCHeader -Text "Running Tests" -Icon "🧪"
        
        Invoke-SCWithSpinner -Message "Running $testType tests..." -ScriptBlock {
            Start-Sleep -Seconds 3  # Simulated test run
        } -SuccessMessage "All tests passed!"
    }
    
    function Show-DatabaseMenu {
        $actions = @(
            "Run Migrations"
            "Seed Database"
            "Reset Database"
            "Create Backup"
            "Restore Backup"
            "← Back"
        )
        
        $action = Show-SCMenu -Title "Database Operations" -Items $actions -AllowCancel
        
        switch ($action) {
            "Run Migrations" {
                Invoke-SCWithSpinner -Message "Running migrations..." -ScriptBlock {
                    Start-Sleep -Seconds 2
                } -SuccessMessage "Migrations completed!"
            }
            "Seed Database" {
                if (Read-SCConfirm -Message "This will add seed data. Continue?") {
                    Write-SCInfo "Seeding database..."
                }
            }
            "Reset Database" {
                if (Read-SCConfirm -Message "⚠️ This will DELETE all data. Are you sure?") {
                    if (Read-SCConfirm -Message "This action cannot be undone. 

Something went wrong with this response, please try again.