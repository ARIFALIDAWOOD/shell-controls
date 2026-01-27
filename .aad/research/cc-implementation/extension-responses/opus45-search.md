# Shell-Controls Extension Specification

## Quick Wins (High Impact, Low Effort)

1. **`-PassThru` on all components** – Return structured output instead of only writing to host; enables piping and testing
2. **`Set-SCTheme -Override`** – Merge partial theme changes at runtime without replacing entire theme
3. **`Get-SCConfig -Schema`** – Emit JSON Schema for config validation and editor autocomplete
4. **`-MaxWidth` parameter** – Add to `Show-SCTable`, `Show-SCPanel`, `Show-SCBanner` for constrained layouts
5. **`$env:SHELL_CONTROLS_NO_COLOR`** – Instant plain-text mode via environment variable

---

## Defer List (Valuable but Complex)

- **Mouse support** – Requires significant input loop changes; terminal support varies widely
- **Plugin marketplace/registry** – Overhead of hosting, versioning, trust; let users load from paths first
- **Persistent undo/redo for forms** – Complex state management; focus on single-pass forms first
- **Live-reload themes** – File watcher complexity; manual reload via `Reset-SCTheme` is sufficient
- **Localization/i18n** – Defer until core is stable; add hook points now for future use

---

## 1. Theme & Visual Customization

### 1.1 Extended Theme Schema Fields

| Name | Category | Description |
|------|----------|-------------|
| **BorderStyles** | Theme | Define reusable border character sets beyond the current single style |

**Spec:**
```jsonc
// themes/dracula.json
{
  "borders": {
    "default": {
      "topLeft": "╭", "topRight": "╮", "bottomLeft": "╰", "bottomRight": "╯",
      "horizontal": "─", "vertical": "│",
      "teeLeft": "├", "teeRight": "┤", "teeUp": "┴", "teeDown": "┬", "cross": "┼"
    },
    "heavy": {
      "topLeft": "┏", "topRight": "┓", "bottomLeft": "┗", "bottomRight": "┛",
      "horizontal": "━", "vertical": "┃",
      "teeLeft": "┣", "teeRight": "┫", "teeUp": "┻", "teeDown": "┳", "cross": "╋"
    },
    "double": { /* ... */ },
    "ascii": {
      "topLeft": "+", "topRight": "+", "bottomLeft": "+", "bottomRight": "+",
      "horizontal": "-", "vertical": "|", "teeLeft": "+", "teeRight": "+",
      "teeUp": "+", "teeDown": "+", "cross": "+"
    }
  }
}
```

**Usage in components:**
```powershell
# In src/pwsh/core/Borders.ps1
function Get-SCBorder {
    param(
        [string]$Style = 'default'  # or 'heavy', 'double', 'ascii', 'none'
    )
    $theme = Get-SCTheme
    return $theme.borders[$Style] ?? $theme.borders.default
}
```

**Dependencies:** `Get-SCTheme`  
**Priority:** High

---

| Name | Category | Description |
|------|----------|-------------|
| **Spacing Tokens** | Theme | Consistent spacing units for padding/margin across components |

**Spec:**
```jsonc
{
  "spacing": {
    "none": 0,
    "xs": 1,
    "sm": 2,
    "md": 4,
    "lg": 6,
    "xl": 8
  },
  "defaults": {
    "panelPadding": "sm",      // resolves to 2
    "tableRowGap": "xs",       // resolves to 1
    "sectionGap": "md"         // resolves to 4
  }
}
```

**Helper function:**
```powershell
function Get-SCSpacing {
    param([string]$Token)
    $theme = Get-SCTheme
    $value = $theme.spacing[$Token]
    if ($null -eq $value) { return [int]$Token }  # allow raw integers
    return $value
}
```

**Dependencies:** `Get-SCTheme`  
**Priority:** Medium

---

### 1.2 Runtime Theme Overrides

| Name | Category | Description |
|------|----------|-------------|
| **Set-SCTheme -Override** | Theme | Merge partial theme changes without replacing the entire theme object |

**Spec:**
```powershell
function Set-SCTheme {
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName='Name')]
        [string]$Name,
        
        [Parameter(ParameterSetName='Override')]
        [hashtable]$Override,
        
        [Parameter(ParameterSetName='Override')]
        [switch]$Persist  # Write to user config
    )
    
    if ($Override) {
        $current = Get-SCTheme -AsHashtable
        $merged = Merge-SCHashtable -Base $current -Override $Override -Deep
        $script:ActiveTheme = $merged
        
        if ($Persist) {
            $configPath = Get-SCConfigPath
            $config = Get-Content $configPath | ConvertFrom-Json -AsHashtable
            $config.themeOverrides = $Override
            $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
        }
    }
}

# Usage
Set-SCTheme -Override @{
    'colors' = @{ 'primary' = '#ff5500'; 'danger' = '#ff0000' }
    'borders' = @{ 'default' = @{ 'topLeft' = '┌' } }
}
```

**Config file support:**
```jsonc
// ~/.config/shell-controls/config.json
{
  "theme": "dracula",
  "themeOverrides": {
    "colors": { "primary": "#ff5500" },
    "symbols": { "success": "✓" }
  }
}
```

**Dependencies:** `Get-SCTheme`, `Merge-SCHashtable` (new utility)  
**Priority:** High

---

### 1.3 Semantic Tokens

| Name | Category | Description |
|------|----------|-------------|
| **SemanticColorMap** | Theme | Named tokens for UI purposes that map to base colors |

**Spec:**
```jsonc
{
  "colors": {
    "base": {
      "red": "#ff5555", "green": "#50fa7b", "blue": "#8be9fd",
      "yellow": "#f1fa8c", "purple": "#bd93f9", "cyan": "#8be9fd",
      "gray100": "#f8f8f2", "gray500": "#6272a4", "gray900": "#282a36"
    },
    "semantic": {
      "heading":     { "fg": "$purple", "bold": true },
      "caption":     { "fg": "$gray500", "italic": true },
      "code":        { "fg": "$green", "bg": "$gray900" },
      "link":        { "fg": "$cyan", "underline": true },
      "label":       { "fg": "$gray100" },
      "placeholder": { "fg": "$gray500" },
      "success":     { "fg": "$green" },
      "warning":     { "fg": "$yellow" },
      "danger":      { "fg": "$red" },
      "info":        { "fg": "$blue" },
      "muted":       { "fg": "$gray500" },
      "highlight":   { "bg": "$purple", "fg": "$gray900" }
    }
  }
}
```

**Resolution function:**
```powershell
function Resolve-SCColor {
    param([string]$TokenOrColor)
    $theme = Get-SCTheme
    
    # Check if it's a semantic token
    if ($theme.colors.semantic.ContainsKey($TokenOrColor)) {
        $semantic = $theme.colors.semantic[$TokenOrColor]
        return @{
            Fg = Resolve-SCColorValue $semantic.fg $theme
            Bg = Resolve-SCColorValue $semantic.bg $theme
            Bold = $semantic.bold -eq $true
            Italic = $semantic.italic -eq $true
            Underline = $semantic.underline -eq $true
        }
    }
    # Check if reference to base color
    if ($TokenOrColor -match '^\$(.+)$') {
        return @{ Fg = $theme.colors.base[$Matches[1]] }
    }
    # Raw hex/color
    return @{ Fg = $TokenOrColor }
}
```

**Dependencies:** Theme loader  
**Priority:** Medium

---

### 1.4 High-Contrast / Accessibility Preset

| Name | Category | Description |
|------|----------|-------------|
| **AccessibilityMode** | Theme | Auto-detect or manually enable high-contrast settings |

**Spec:**
```jsonc
// themes/high-contrast.json
{
  "meta": { "name": "high-contrast", "accessibility": true },
  "colors": {
    "base": {
      "background": "#000000",
      "foreground": "#ffffff",
      "primary": "#00ffff",
      "danger": "#ff0000",
      "success": "#00ff00",
      "warning": "#ffff00"
    }
  },
  "borders": {
    "default": "ascii"  // reference to ascii border set
  },
  "symbols": {
    "success": "[OK]",
    "error": "[ERR]",
    "warning": "[WARN]",
    "info": "[i]",
    "bullet": "*",
    "selected": "[X]",
    "unselected": "[ ]",
    "arrow": "->",
    "spinner": ["-", "\\", "|", "/"]
  },
  "accessibility": {
    "minContrastRatio": 7.0,
    "avoidBlinking": true,
    "extendedFocusIndicator": true,
    "verboseLabels": true
  }
}
```

**Detection and activation:**
```powershell
function Get-SCAccessibilityMode {
    # Check explicit config
    $config = Get-SCConfig
    if ($config.accessibility.forceHighContrast) { return $true }
    
    # Check environment
    if ($env:SHELL_CONTROLS_HIGH_CONTRAST -eq '1') { return $true }
    if ($env:HIGH_CONTRAST -eq '1') { return $true }
    
    # Windows: check system setting
    if ($IsWindows) {
        $regPath = 'HKCU:\Control Panel\Accessibility\HighContrast'
        $flags = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).Flags
        if ($flags -band 1) { return $true }  # HCF_HIGHCONTRASTON
    }
    
    # macOS: check via defaults
    if ($IsMacOS) {
        $result = defaults read -g AppleInterfaceStyle 2>$null
        # Additional contrast checks could go here
    }
    
    return $false
}

function Initialize-SCTheme {
    if (Get-SCAccessibilityMode) {
        Set-SCTheme -Name 'high-contrast'
        Write-SCVerbose "Accessibility mode enabled"
    }
}
```

**Dependencies:** Platform detection, theme loader  
**Priority:** Medium

---

## 2. Components & Layouts

### 2.1 Show-SCCard

| Name | Category | Description |
|------|----------|-------------|
| **Show-SCCard** | Component | A bordered container with optional header, body, and footer sections |

**Spec:**
```powershell
function Show-SCCard {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Title,
        
        [Parameter(ValueFromPipeline)]
        [string[]]$Body,
        
        [string]$Footer,
        
        [ValidateSet('default','heavy','double','ascii','none')]
        [string]$BorderStyle = 'default',
        
        [ValidateSet('left','center','right')]
        [string]$TitleAlign = 'left',
        
        [int]$MaxWidth,           # 0 = auto (terminal width - 4)
        [int]$MinWidth = 20,
        [string]$Padding = 'sm',  # spacing token or int
        
        [string]$HeaderColor,     # semantic token or hex
        [string]$BodyColor,
        [string]$BorderColor,
        
        [switch]$PassThru
    )
    # ... implementation
}
```

**Layout rules:**
- Width = max(MinWidth, min(MaxWidth ?? termWidth-4, max content line width + 2*padding))
- Title rendered in top border: `╭─ Title ───────╮`
- Footer rendered in bottom border: `╰─────── Footer ╯`
- Body lines wrapped at inner width, respecting word boundaries

**Theme keys needed:**
```jsonc
{
  "components": {
    "card": {
      "borderStyle": "default",
      "borderColor": "$gray500",
      "headerColor": "heading",
      "padding": "sm"
    }
  }
}
```

**Dependencies:** `Get-SCBorder`, `Get-SCSpacing`, `Get-SCColor`  
**Priority:** High

---

### 2.2 Show-SCStack / Show-SCGrid

| Name | Category | Description |
|------|----------|-------------|
| **Show-SCStack** | Component | Vertical layout container with consistent spacing between children |

**Spec:**
```powershell
function Show-SCStack {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [scriptblock[]]$Children,
        
        [string]$Gap = 'sm',           # spacing token
        [ValidateSet('left','center','right')]
        [string]$Align = 'left',
        [int]$MaxWidth,
        [switch]$PassThru
    )
    
    $spacing = Get-SCSpacing $Gap
    $output = @()
    
    foreach ($child in $Children) {
        $rendered = & $child
        $output += $rendered
        $output += ('' * $spacing)  # gap lines
    }
    
    if ($PassThru) { return $output }
    $output | ForEach-Object { Write-Host $_ }
}

# Usage
Show-SCStack -Gap 'md' -Children {
    Show-SCCard -Title "Status" -Body "All systems operational" -PassThru
}, {
    Show-SCTable -Data $services -PassThru
}, {
    Show-SCBanner -Text "Complete" -PassThru
}
```

**Dependencies:** `Get-SCSpacing`  
**Priority:** Medium

---

| Name | Category | Description |
|------|----------|-------------|
| **Show-SCGrid** | Component | Multi-column layout that adapts to terminal width |

**Spec:**
```powershell
function Show-SCGrid {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock[]]$Cells,
        
        [int]$Columns = 0,            # 0 = auto based on terminal width
        [int]$MinCellWidth = 30,
        [string]$Gap = 'sm',
        [switch]$PassThru
    )
    
    $termWidth = $Host.UI.RawUI.WindowSize.Width
    $actualCols = if ($Columns -gt 0) { $Columns } 
                  else { [Math]::Max(1, [Math]::Floor($termWidth / ($MinCellWidth + (Get-SCSpacing $Gap)))) }
    
    # Render each cell, then combine side-by-side
    $renderedCells = $Cells | ForEach-Object { & $_ }
    
    # Combine into rows
    # ... (line-by-line horizontal join with padding)
}

# Usage
Show-SCGrid -Columns 2 -Cells {
    Show-SCCard -Title "CPU" -Body "45%" -PassThru
}, {
    Show-SCCard -Title "Memory" -Body "2.1GB" -PassThru
}, {
    Show-SCCard -Title "Disk" -Body "67%" -PassThru
}
```

**Dependencies:** `Get-SCSpacing`, terminal width detection  
**Priority:** Medium

---

### 2.3 Show-SCTabs

| Name | Category | Description |
|------|----------|-------------|
| **Show-SCTabs** | Component | Tabbed interface for switching between content panes |

**Spec:**
```powershell
function Show-SCTabs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable[]]$Tabs,  # @{ Label='Tab1'; Content={...}; Shortcut='1' }
        
        [int]$DefaultIndex = 0,
        
        [ValidateSet('top','bottom')]
        [string]$TabPosition = 'top',
        
        [ValidateSet('line','box','pill')]
        [string]$TabStyle = 'line',
        
        [switch]$Persistent,   # Remember selection in session
        [string]$Id            # Required if Persistent
    )
    
    # Tab bar rendering
    # ─ Tab1 ─┬─ Tab2 ─┬─ Tab3 ─   (line style)
    # [ Tab1 ] [ Tab2 ] [ Tab3 ]   (box style)
    # (•Tab1)  ( Tab2)  ( Tab3)    (pill style)
    
    # Key handling: Left/Right arrows, number shortcuts, Enter to confirm
}
```

**Theme keys:**
```jsonc
{
  "components": {
    "tabs": {
      "style": "line",
      "activeColor": "primary",
      "inactiveColor": "muted",
      "indicatorChar": "●"
    }
  }
}
```

**Dependencies:** `Read-SCKey`, `Get-SCColor`  
**Priority:** Low

---

### 2.4 Layout Parameters (Global Pattern)

| Name | Category | Description |
|------|----------|-------------|
| **StandardLayoutParams** | Component | Common parameter set for all visual components |

**Spec – Add to all `Show-SC*` functions:**
```powershell
# Common parameter block (consider a helper to generate)
[int]$MaxWidth,
[int]$MinWidth,
[string]$Padding,        # spacing token or int
[string]$Margin,         # spacing token or int  
[ValidateSet('left','center','right')]
[string]$Align,
[switch]$PassThru

# Implementation helper
function Format-SCLayout {
    param(
        [string[]]$Lines,
        [int]$MaxWidth,
        [int]$MinWidth,
        [string]$Padding,
        [string]$Margin,
        [string]$Align
    )
    
    $pad = Get-SCSpacing ($Padding ?? 0)
    $mar = Get-SCSpacing ($Margin ?? 0)
    $termWidth = $Host.UI.RawUI.WindowSize.Width
    
    $contentWidth = ($Lines | Measure-Object -Property Length -Maximum).Maximum
    $targetWidth = [Math]::Max($MinWidth, [Math]::Min($MaxWidth ?? $termWidth, $contentWidth + 2*$pad))
    
    $result = foreach ($line in $Lines) {
        $inner = $line.PadRight($targetWidth - 2*$pad)
        $padded = (' ' * $pad) + $inner + (' ' * $pad)
        
        $aligned = switch ($Align) {
            'center' { $padded.PadLeft(($termWidth + $padded.Length) / 2).PadRight($termWidth) }
            'right'  { $padded.PadLeft($termWidth - $mar) }
            default  { (' ' * $mar) + $padded }
        }
        $aligned
    }
    return $result
}
```

**Priority:** High

---

### 2.5 Responsive Behavior

| Name | Category | Description |
|------|----------|-------------|
| **ResponsiveRules** | Component | Config-driven rules for how components adapt to terminal size |

**Spec:**
```jsonc
// config.json
{
  "responsive": {
    "breakpoints": {
      "sm": 60,
      "md": 100,
      "lg": 140
    },
    "rules": {
      "Show-SCTable": {
        "sm": { "truncateColumns": true, "maxColumns": 3 },
        "md": { "truncateColumns": false }
      },
      "Show-SCGrid": {
        "sm": { "columns": 1 },
        "md": { "columns": 2 },
        "lg": { "columns": 3 }
      },
      "Show-SCBanner": {
        "sm": { "style": "simple" },   // no figlet
        "md": { "style": "default" }
      }
    }
  }
}
```

**Resolution:**
```powershell
function Get-SCResponsiveValue {
    param(
        [string]$Component,
        [string]$Property
    )
    
    $config = Get-SCConfig
    $width = $Host.UI.RawUI.WindowSize.Width
    
    # Determine current breakpoint
    $bp = 'lg'
    foreach ($name in 'sm','md','lg') {
        if ($width -lt $config.responsive.breakpoints[$name]) {
            $bp = $name
            break
        }
    }
    
    return $config.responsive.rules[$Component][$bp][$Property]
}
```

**Dependencies:** `Get-SCConfig`, terminal width  
**Priority:** Low

---

## 3. Input, Validation & Forms

### 3.1 New Input Types

| Name | Category | Description |
|------|----------|-------------|
| **Read-SCDate** | Input | Date picker with validation and multiple format support |

**Spec:**
```powershell
function Read-SCDate {
    [CmdletBinding()]
    param(
        [string]$Prompt = "Enter date",
        [string]$Format = "yyyy-MM-dd",        # .NET format string
        [datetime]$Default,
        [datetime]$Min,
        [datetime]$Max,
        [switch]$AllowEmpty,
        [string]$ErrorMessage = "Invalid date format. Expected: {0}"
    )
    
    $formatDisplay = $Format.ToLower() -replace 'yyyy','YYYY' -replace 'mm','MM' -replace 'dd','DD'
    
    while ($true) {
        $input = Read-SCInput -Prompt "$Prompt ($formatDisplay)" -Default $Default?.ToString($Format)
        
        if ([string]::IsNullOrEmpty($input) -and $AllowEmpty) { return $null }
        
        if ([datetime]::TryParseExact($input, $Format, [CultureInfo]::InvariantCulture, 
                                       [DateTimeStyles]::None, [ref]$parsed)) {
            if ($Min -and $parsed -lt $Min) {
                Write-SCError "Date must be on or after $($Min.ToString($Format))"
                continue
            }
            if ($Max -and $parsed -gt $Max) {
                Write-SCError "Date must be on or before $($Max.ToString($Format))"
                continue
            }
            return $parsed
        }
        
        Write-SCError ($ErrorMessage -f $Format)
    }
}
```

**Dependencies:** `Read-SCInput`, `Write-SCError`  
**Priority:** Medium

---

| Name | Category | Description |
|------|----------|-------------|
| **Read-SCUrl / Read-SCEmail** | Input | Validated string inputs with regex and optional reachability check |

**Spec:**
```powershell
function Read-SCUrl {
    param(
        [string]$Prompt = "Enter URL",
        [string[]]$AllowedSchemes = @('http','https'),
        [switch]$CheckReachable,      # HEAD request to verify
        [int]$TimeoutSeconds = 5,
        [switch]$AllowEmpty
    )
    
    $pattern = "^($(($AllowedSchemes -join '|')))://[^\s/$.?#].[^\s]*$"
    
    while ($true) {
        $input = Read-SCInput -Prompt $Prompt
        if ([string]::IsNullOrEmpty($input) -and $AllowEmpty) { return $null }
        
        if ($input -notmatch $pattern) {
            Write-SCError "Invalid URL. Must start with: $($AllowedSchemes -join ', ')"
            continue
        }
        
        if ($CheckReachable) {
            try {
                $response = Invoke-WebRequest -Uri $input -Method Head -TimeoutSec $TimeoutSeconds -ErrorAction Stop
                return $input
            } catch {
                Write-SCWarning "URL not reachable: $_"
                if (Read-SCConfirm "Use anyway?") { return $input }
                continue
            }
        }
        return $input
    }
}

function Read-SCEmail {
    param(
        [string]$Prompt = "Enter email",
        [switch]$AllowEmpty
    )
    
    # RFC 5322 simplified pattern
    $pattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    while ($true) {
        $input = Read-SCInput -Prompt $Prompt
        if ([string]::IsNullOrEmpty($input) -and $AllowEmpty) { return $null }
        
        if ($input -match $pattern) { return $input }
        Write-SCError "Invalid email format"
    }
}
```

**Dependencies:** `Read-SCInput`, `Write-SCError`, `Read-SCConfirm`  
**Priority:** Medium

---

### 3.2 Form / Wizard Helper

| Name | Category | Description |
|------|----------|-------------|
| **Show-SCForm** | Input | Multi-field form with validation, navigation, and summary |

**Spec:**
```powershell
function Show-SCForm {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable[]]$Fields,
        # Field schema:
        # @{
        #   Name = 'username'           # Required: key in result
        #   Label = 'Username'          # Display label
        #   Type = 'text'               # text|password|email|url|date|number|select|multiselect|confirm
        #   Default = ''                # Default value
        #   Required = $true            # Validation
        #   Validate = { $_ -match '^\w+$' }  # Custom scriptblock
        #   ValidateMessage = 'Alphanumeric only'
        #   Options = @()               # For select/multiselect types
        #   Placeholder = 'jdoe'        # Hint text
        #   Help = 'Your login name'    # Extended help (F1)
        # }
        
        [string]$Title,
        [string]$Description,
        
        [switch]$ShowSummary,          # Show review page before submit
        [switch]$AllowBack,            # Enable back navigation
        
        [scriptblock]$OnSubmit,        # Called with result hashtable
        [scriptblock]$OnCancel,
        
        [switch]$Wizard               # One field per screen vs all at once
    )
    
    $result = @{}
    $index = 0
    
    if ($Title) { Show-SCHeader $Title }
    if ($Description) { Write-SCText $Description -Color 'caption' }
    
    while ($index -lt $Fields.Count) {
        $field = $Fields[$index]
        $value = Invoke-SCFieldInput -Field $field -CurrentValue $result[$field.Name]
        
        if ($value -eq $script:SC_BACK -and $AllowBack -and $index -gt 0) {
            $index--
            continue
        }
        if ($value -eq $script:SC_CANCEL) {
            if ($OnCancel) { & $OnCancel }
            return $null
        }
        
        $result[$field.Name] = $value
        $index++
    }
    
    if ($ShowSummary) {
        Show-SCFormSummary -Fields $Fields -Values $result
        if (-not (Read-SCConfirm "Submit?")) {
            $index = 0  # restart or allow editing
            # ... edit logic
        }
    }
    
    if ($OnSubmit) { & $OnSubmit $result }
    return $result
}

# Usage
$user = Show-SCForm -Title "Create User" -Wizard -ShowSummary -Fields @(
    @{ Name='username'; Label='Username'; Type='text'; Required=$true; Validate={ $_ -match '^\w{3,20}$' } }
    @{ Name='email'; Label='Email'; Type='email'; Required=$true }
    @{ Name='role'; Label='Role'; Type='select'; Options=@('admin','user','guest'); Default='user' }
    @{ Name='notify'; Label='Send welcome email?'; Type='confirm'; Default=$true }
)
```

**Dependencies:** All `Read-SC*` functions, `Show-SCHeader`, `Write-SCText`  
**Priority:** High

---

### 3.3 Autocomplete / Suggestions

| Name | Category | Description |
|------|----------|-------------|
| **Read-SCInput -Autocomplete** | Input | Inline suggestions from static list, filesystem, or dynamic source |

**Spec:**
```powershell
function Read-SCInput {
    param(
        # ... existing params ...
        
        [string[]]$Autocomplete,                  # Static list
        [scriptblock]$AutocompleteScript,         # Dynamic: receives current text, returns suggestions
        [ValidateSet('inline','popup','tab')]
        [string]$AutocompleteStyle = 'inline',
        [switch]$AutocompleteFileSystem,          # Built-in path completion
        [int]$AutocompleteMinChars = 1            # Start suggesting after N chars
    )
}

# Internal completion handler
function Get-SCCompletions {
    param([string]$Text, $Source, [bool]$FileSystem)
    
    if ($FileSystem) {
        return Get-ChildItem -Path "$Text*" -ErrorAction SilentlyContinue | 
               Select-Object -First 10 -ExpandProperty Name
    }
    if ($Source -is [scriptblock]) {
        return & $Source $Text | Select-Object -First 10
    }
    if ($Source -is [array]) {
        return $Source | Where-Object { $_ -like "$Text*" } | Select-Object -First 10
    }
    return @()
}
```

**UI behavior by style:**
- `inline`: Ghost text after cursor (Tab to accept) – `myfi|le.txt` (ghost: `le.txt`)
- `popup`: Dropdown below input (Up/Down to select, Enter to accept)
- `tab`: Cycle through matches with Tab (like bash)

**Keybindings:**
```jsonc
{
  "keybindings": {
    "autocomplete": {
      "accept": "Tab",
      "next": "Ctrl+N",
      "prev": "Ctrl+P",
      "dismiss": "Escape"
    }
  }
}
```

**Dependencies:** `Read-SCKey`, theme colors for ghost text  
**Priority:** Medium

---

## 4. Keybindings, Hooks & Behavior

### 4.1 Extended Keybinding Schema

| Name | Category | Description |
|------|----------|-------------|
| **KeybindingSchema** | Keybindings | Support for chords, context-specific bindings, and custom actions |

**Spec:**
```jsonc
{
  "keybindings": {
    "global": {
      "cancel": ["Escape", "Ctrl+C"],
      "help": ["F1", "?"],
      "submit": ["Enter", "Ctrl+Enter"]
    },
    "menu": {
      "up": ["UpArrow", "k", "Ctrl+P"],
      "down": ["DownArrow", "j", "Ctrl+N"],
      "select": ["Space"],
      "selectAll": ["Ctrl+A"],
      "pageUp": ["PageUp", "Ctrl+U"],
      "pageDown": ["PageDown", "Ctrl+D"],
      "top": ["Home", "g g"],           // chord: g then g
      "bottom": ["End", "G"],
      "search": ["/", "Ctrl+F"]
    },
    "input": {
      "clear": ["Ctrl+U"],
      "deleteWord": ["Ctrl+W"],
      "paste": ["Ctrl+V", "Ctrl+Shift+V"],
      "history": ["UpArrow"]            // cycle through history
    },
    "chords": {
      "g g": { "timeout": 500 }         // ms to wait for second key
    }
  }
}
```

**Resolver:**
```powershell
function Test-SCKeybinding {
    param(
        [string]$Context,      # 'global', 'menu', 'input'
        [string]$Action,       # 'cancel', 'up', etc.
        [ConsoleKeyInfo]$Key,
        [string]$PendingChord  # previous key if in chord sequence
    )
    
    $config = Get-SCConfig
    $bindings = $config.keybindings[$Context][$Action] + $config.keybindings.global[$Action]
    
    $keyString = Format-SCKeyString $Key  # e.g., "Ctrl+K"
    
    if ($PendingChord) {
        $chord = "$PendingChord $keyString"
        return $bindings -contains $chord
    }
    
    # Check if this key starts a chord
    $chordStarts = $config.keybindings.chords.Keys | ForEach-Object { ($_ -split ' ')[0] }
    if ($keyString -in $chordStarts) {
        return @{ Pending = $keyString }
    }
    
    return $bindings -contains $keyString
}
```

**Dependencies:** `Get-SCConfig`  
**Priority:** Medium

---

### 4.2 Hooks / Callbacks

| Name | Category | Description |
|------|----------|-------------|
| **EventHooks** | Hooks | Configurable callbacks for component lifecycle events |

**Spec:**
```powershell
# Global hook registration
function Register-SCHook {
    param(
        [Parameter(Mandatory)]
        [ValidateSet(
            'OnBeforeRender', 'OnAfterRender',
            'OnBeforeInput', 'OnAfterInput',
            'OnSelect', 'OnCancel', 'OnSubmit',
            'OnResize', 'OnError',
            'OnThemeChange', 'OnConfigChange'
        )]
        [string]$Event,
        
        [Parameter(Mandatory)]
        [scriptblock]$Action,
        
        [string]$Component,    # Filter to specific component, or '*' for all
        [string]$Id            # Unique ID for this registration (for removal)
    )
    
    $script:SCHooks[$Event] += @{
        Id = $Id ?? [guid]::NewGuid().ToString()
        Component = $Component ?? '*'
        Action = $Action
    }
}

function Invoke-SCHook {
    param(
        [string]$Event,
        [string]$Component,
        [hashtable]$Context    # Event-specific data
    )
    
    $hooks = $script:SCHooks[$Event] | Where-Object {
        $_.Component -eq '*' -or $_.Component -eq $Component
    }
    
    foreach ($hook in $hooks) {
        try {
            & $hook.Action $Context
        } catch {
            Write-SCVerbose "Hook error [$Event]: $_"
        }
    }
}

# Usage
Register-SCHook -Event OnAfterSelect -Component 'Show-SCMenu' -Action {
    param($ctx)
    # $ctx = @{ Component='Show-SCMenu'; Selection='Option 1'; Index=0 }
    Write-SCLog "User selected: $($ctx.Selection)"
}

Register-SCHook -Event OnResize -Action {
    param($ctx)
    # $ctx = @{ OldWidth=80; OldHeight=24; NewWidth=120; NewHeight=40 }
    Clear-Host
    # Re-render current view
}
```

**Hook context by event:**
| Event | Context Properties |
|-------|-------------------|
| OnBeforeRender | Component, Parameters |
| OnAfterRender | Component, RenderedLines, Duration |
| OnSelect | Component, Selection, Index, AllSelections |
| OnCancel | Component, PartialInput |
| OnResize | OldWidth, OldHeight, NewWidth, NewHeight |
| OnError | Component, Exception, Recoverable |

**Dependencies:** None (core feature)  
**Priority:** Medium

---

### 4.3 Config-Driven Behavior

| Name | Category | Description |
|------|----------|-------------|
| **BehaviorConfig** | Hooks | Centralized behavior toggles with sensible defaults |

**Spec:**
```jsonc
{
  "behavior": {
    "confirmDestructiveActions": true,
    "confirmBeforeExit": false,
    "exitOnCancel": true,
    "showKeyHints": true,               // e.g., "[↑↓] Navigate [Enter] Select [Esc] Cancel"
    "keyHintPosition": "bottom",        // 'bottom', 'top', 'none'
    "animationsEnabled": true,
    "spinnerInterval": 80,              // ms
    "cursorBlink": true,
    
    "menu": {
      "cycleSelection": true,           // wrap around at top/bottom
      "showIndex": false,               // show "1. Option" numbers
      "pageSize": 10,
      "searchable": true
    },
    
    "input": {
      "historyEnabled": true,
      "historySize": 50,
      "trimWhitespace": true,
      "maskCharacter": "●"
    },
    
    "progress": {
      "showPercentage": true,
      "showEta": true,
      "completedSound": false           // terminal bell on completion
    },
    
    "logging": {
      "enabled": false,
      "path": "~/.local/share/shell-controls/audit.log",
      "level": "info",                  // 'debug', 'info', 'warn', 'error'
      "includeTimestamps": true,
      "includeUserInput": false         // privacy consideration
    }
  }
}
```

**Accessor:**
```powershell
function Get-SCBehavior {
    param([string]$Path)  # e.g., 'menu.cycleSelection'
    
    $config = Get-SCConfig
    $value = $config.behavior
    
    foreach ($segment in $Path -split '\.') {
        $value = $value[$segment]
        if ($null -eq $value) { break }
    }
    
    return $value
}

# Usage in components
$cycle = Get-SCBehavior 'menu.cycleSelection'
```

**Dependencies:** `Get-SCConfig`  
**Priority:** High

---

## 5. Terminal Compatibility & Output Control

### 5.1 Feature Detection

| Name | Category | Description |
|------|----------|-------------|
| **Get-SCTerminalCapabilities** | Terminal | Detect and cache terminal feature support |

**Spec:**
```powershell
function Get-SCTerminalCapabilities {
    [CmdletBinding()]
    param([switch]$Force)  # bypass cache
    
    if ($script:SCCapabilities -and -not $Force) {
        return $script:SCCapabilities
    }
    
    $caps = @{
        # Color support
        TrueColor = $false
        Color256 = $false
        Color16 = $true        # assume basic ANSI
        
        # Features
        Unicode = $false
        Hyperlinks = $false    # OSC 8
        Mouse = $false
        Resize = $false
        Bracketed = $false     # bracketed paste
        
        # Measurements
        Width = 80
        Height = 24
        
        # Terminal identification
        Term = $env:TERM
        TermProgram = $env:TERM_PROGRAM
        ColorTerm = $env:COLORTERM
    }
    
    # True color detection
    if ($env:COLORTERM -in @('truecolor', '24bit') -or
        $env:TERM_PROGRAM -in @('iTerm.app', 'vscode', 'Hyper', 'Windows Terminal') -or
        $env:WT_SESSION) {
        $caps.TrueColor = $true
        $caps.Color256 = $true
    } elseif ($env:TERM -match '256color') {
        $caps.Color256 = $true
    }
    
    # Unicode detection
    $encoding = [Console]::OutputEncoding
    $caps.Unicode = $encoding.WebName -eq 'utf-8' -or $encoding -is [System.Text.UTF8Encoding]
    
    # Also check locale
    if (-not $caps.Unicode) {
        $lang = $env:LANG ?? $env:LC_ALL ?? ''
        $caps.Unicode = $lang -match 'UTF-8|utf8'
    }
    
    # Window size
    try {
        $caps.Width = $Host.UI.RawUI.WindowSize.Width
        $caps.Height = $Host.UI.RawUI.WindowSize.Height
    } catch { }
    
    # Hyperlink support (OSC 8)
    $caps.Hyperlinks = $caps.Term -match 'iterm|kitty|wezterm|foot' -or
                       $env:TERM_PROGRAM -in @('iTerm.app', 'WezTerm')
    
    $script:SCCapabilities = $caps
    return $caps
}
```

**Fallback configuration:**
```jsonc
{
  "terminal": {
    "forceCapabilities": {
      "trueColor": null,      // null = auto-detect, true/false = override
      "unicode": null,
      "hyperlinks": false
    },
    "fallbacks": {
      "noUnicode": {
        "symbols": {
          "success": "[OK]",
          "error": "[X]",
          "bullet": "*"
        }
      },
      "noColor": {
        "useTextMarkers": true   // e.g., "**bold**", "_italic_"
      }
    }
  }
}
```

**Dependencies:** None (core feature)  
**Priority:** High

---

### 5.2 Output Modes

| Name | Category | Description |
|------|----------|-------------|
| **OutputModes** | Terminal | Plain, JSON, and quiet modes for different contexts |

**Spec:**
```powershell
# Activation methods (priority order)
# 1. Parameter: Show-SCMenu -OutputMode Plain
# 2. Environment: $env:SHELL_CONTROLS_OUTPUT = 'json'
# 3. Config: { "output": { "mode": "auto" } }
# 4. Detection: NO_COLOR env var, piped output, non-interactive

function Get-SCOutputMode {
    # Check explicit override
    if ($script:SCOutputModeOverride) { return $script:SCOutputModeOverride }
    
    # Check environment
    $envMode = $env:SHELL_CONTROLS_OUTPUT
    if ($envMode -in @('plain','json','quiet','auto')) { return $envMode }
    
    # Check NO_COLOR standard
    if ($env:NO_COLOR -ne $null) { return 'plain' }
    
    # Check if output is piped
    if (-not [Console]::IsOutputRedirected -eq $false) { return 'plain' }
    
    # Check config
    $config = Get-SCConfig
    return $config.output.mode ?? 'auto'
}

function Set-SCOutputMode {
    param(
        [ValidateSet('auto','plain','json','quiet')]
        [string]$Mode
    )
    $script:SCOutputModeOverride = $Mode
}
```

**Mode behaviors:**

| Mode | Colors | Unicode | Interactive | Returns |
|------|--------|---------|-------------|---------|
| auto | detect | detect | yes | varies |
| plain | no | ascii | yes | strings |
| json | no | yes | no* | objects |
| quiet | no | no | no* | objects |

*Non-interactive modes return immediately with defaults or throw on required input

**JSON output example:**
```powershell
# With -OutputMode Json
$result = Show-SCMenu -Title "Choose" -Options @('A','B','C') -OutputMode Json

# Returns:
# {
#   "component": "Show-SCMenu",
#   "timestamp": "2025-01-23T10:30:00Z",
#   "result": {
#     "selected": "B",
#     "index": 1,
#     "cancelled": false
#   }
# }
```

**Dependencies:** `Get-SCConfig`, `Get-SCTerminalCapabilities`  
**Priority:** High

---

### 5.3 Output Capture / Logging

| Name | Category | Description |
|------|----------|-------------|
| **OutputCapture** | Terminal | Buffer rendered output for testing or replay |

**Spec:**
```powershell
function Enable-SCOutputCapture {
    param(
        [switch]$IncludeInput,     # Also capture user input
        [switch]$IncludeTimings    # Record render timestamps
    )
    
    $script:SCOutputCapture = @{
        Enabled = $true
        Buffer = [System.Collections.Generic.List[object]]::new()
        IncludeInput = $IncludeInput
        IncludeTimings = $IncludeTimings
        StartTime = [datetime]::UtcNow
    }
}

function Disable-SCOutputCapture {
    $script:SCOutputCapture.Enabled = $false
}

function Get-SCCapturedOutput {
    param(
        [switch]$AsString,      # Join all lines
        [switch]$StripAnsi,     # Remove ANSI codes
        [switch]$Clear          # Clear buffer after returning
    )
    
    $buffer = $script:SCOutputCapture.Buffer
    
    if ($StripAnsi) {
        $buffer = $buffer | ForEach-Object {
            if ($_.Line) { $_.Line = $_.Line -replace '\x1b\[[0-9;]*m', '' }
            $_
        }
    }
    
    if ($AsString) {
        $result = ($buffer | ForEach-Object { $_.Line }) -join "`n"
    } else {
        $result = $buffer.ToArray()
    }
    
    if ($Clear) { $script:SCOutputCapture.Buffer.Clear() }
    
    return $result
}

# Internal: called by all Write-SC* functions
function Write-SCCapturedLine {
    param([string]$Line, [string]$Component)
    
    if ($script:SCOutputCapture.Enabled) {
        $entry = @{ Line = $Line; Component = $Component }
        if ($script:SCOutputCapture.IncludeTimings) {
            $entry.Offset = ([datetime]::UtcNow - $script:SCOutputCapture.StartTime).TotalMilliseconds
        }
        $script:SCOutputCapture.Buffer.Add($entry)
    }
}
```

**Testing usage:**
```powershell
Describe "Show-SCCard" {
    It "renders title in border" {
        Enable-SCOutputCapture
        Show-SCCard -Title "Test" -Body "Content" | Out-Null
        $output = Get-SCCapturedOutput -AsString -StripAnsi
        Disable-SCOutputCapture
        
        $output | Should -Match '─ Test ─'
    }
}
```

**Dependencies:** None  
**Priority:** Medium

---

## 6. Extensibility & Composition

### 6.1 Custom Component Convention

| Name | Category | Description |
|------|----------|-------------|
| **ComponentConvention** | Extensibility | Standard pattern for user-defined components |

**Spec:**
```powershell
# Convention: functions prefixed with Show-SC*, Read-SC*, or Write-SC*
# should follow this pattern:

function Show-SCCustomWidget {
    [CmdletBinding()]
    param(
        # Required: component-specific params
        [Parameter(Mandatory)]
        [string]$Data,
        
        # Standard layout params (copy from StandardLayoutParams)
        [int]$MaxWidth,
        [string]$Padding,
        [string]$Align,
        
        # Standard output params
        [switch]$PassThru,
        
        # Theme overrides
        [string]$Color,
        [string]$BorderStyle
    )
    
    # 1. Resolve theme values
    $theme = Get-SCTheme
    $actualColor = Resolve-SCColor ($Color ?? $theme.components.customWidget.color ?? 'primary')
    
    # 2. Build content using helpers
    $lines = @()
    $lines += Format-SCText $Data -Color $actualColor
    
    # 3. Apply layout
    $formatted = Format-SCLayout -Lines $lines -MaxWidth $MaxWidth -Padding $Padding -Align $Align
    
    # 4. Check output mode
    $mode = Get-SCOutputMode
    if ($mode -eq 'json') {
        return @{ component = 'Show-SCCustomWidget'; data = $Data; lines = $formatted }
    }
    
    # 5. Return or write
    if ($PassThru) {
        return $formatted
    }
    
    # 6. Fire hooks
    Invoke-SCHook -Event OnBeforeRender -Component 'Show-SCCustomWidget' -Context @{ Data = $Data }
    
    $formatted | ForEach-Object { 
        Write-SCCapturedLine -Line $_ -Component 'Show-SCCustomWidget'
        Write-Host $_
    }
    
    Invoke-SCHook -Event OnAfterRender -Component 'Show-SCCustomWidget' -Context @{ Lines = $formatted }
}
```

**Exposed helpers for custom components:**
```powershell
# In src/pwsh/core/Helpers.ps1 - exported for user components
Get-SCTheme                  # Current theme object
Get-SCConfig                 # Current config object
Get-SCColor [name]           # Resolve color name to ANSI
Get-SCSymbol [name]          # Resolve symbol name to character
Get-SCBorder [style]         # Get border character set
Get-SCSpacing [token]        # Resolve spacing token to int
Format-SCText [text]         # Apply ANSI formatting
Format-SCLayout [lines]      # Apply alignment/padding
Get-SCOutputMode             # Current output mode
Get-SCTerminalCapabilities   # Terminal feature flags
Invoke-SCHook                # Fire lifecycle hooks
Write-SCCapturedLine         # Add to capture buffer
```

**Dependencies:** Core helpers  
**Priority:** High

---

### 6.2 Pluggable Themes

| Name | Category | Description |
|------|----------|-------------|
| **ThemeLoading** | Extensibility | Load themes from filesystem or URL with validation |

**Spec:**
```powershell
function Import-SCTheme {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ParameterSetName='Path')]
        [string]$Path,
        
        [Parameter(Mandatory, ParameterSetName='Uri')]
        [uri]$Uri,
        
        [Parameter(ParameterSetName='Uri')]
        [switch]$TrustSource,     # Skip checksum verification
        
        [string]$Name,            # Override theme name
        [switch]$SetActive,       # Immediately activate
        [switch]$Persistent       # Add to config for auto-load
    )
    
    # Load content
    if ($Path) {
        $content = Get-Content $Path -Raw
    } else {
        $response = Invoke-RestMethod -Uri $Uri -ErrorAction Stop
        $content = $response | ConvertTo-Json -Depth 10
    }
    
    $theme = $content | ConvertFrom-Json -AsHashtable
    
    # Validate against schema
    $validation = Test-SCThemeSchema -Theme $theme
    if (-not $validation.Valid) {
        throw "Invalid theme: $($validation.Errors -join '; ')"
    }
    
    # Determine name
    $themeName = $Name ?? $theme.meta.name ?? [System.IO.Path]::GetFileNameWithoutExtension($Path)
    
    # Save to themes directory
    $themesDir = Join-Path (Get-SCConfigDir) 'themes'
    if (-not (Test-Path $themesDir)) { New-Item -ItemType Directory -Path $themesDir | Out-Null }
    
    $themePath = Join-Path $themesDir "$themeName.json"
    $content | Set-Content $themePath
    
    # Register
    $script:SCCustomThemes[$themeName] = $theme
    
    if ($SetActive) { Set-SCTheme -Name $themeName }
    
    if ($Persistent) {
        $config = Get-SCConfig
        if ($config.customThemes -notcontains $themePath) {
            $config.customThemes += $themePath
            Save-SCConfig $config
        }
    }
    
    return @{ Name = $themeName; Path = $themePath }
}

function Test-SCThemeSchema {
    param([hashtable]$Theme)
    
    $errors = @()
    
    # Required fields
    if (-not $Theme.colors) { $errors += "Missing 'colors' section" }
    if (-not $Theme.colors.base) { $errors += "Missing 'colors.base' section" }
    
    # Validate color format
    foreach ($key in $Theme.colors.base.Keys) {
        $val = $Theme.colors.base[$key]
        if ($val -notmatch '^#[0-9a-fA-F]{6}$' -and $val -notmatch '^\$') {
            $errors += "Invalid color format for 'colors.base.$key': $val"
        }
    }
    
    # Validate symbol references
    if ($Theme.symbols) {
        foreach ($key in $Theme.symbols.Keys) {
            $val = $Theme.symbols[$key]
            if ($val.Length -gt 4) {  # reasonable limit for symbols
                $errors += "Symbol '$key' too long (max 4 chars)"
            }
        }
    }
    
    return @{ Valid = $errors.Count -eq 0; Errors = $errors }
}
```

**Config for custom themes:**
```jsonc
{
  "theme": "my-custom",
  "customThemes": [
    "~/.config/shell-controls/themes/my-custom.json",
    "https://example.com/themes/corporate.json"
  ],
  "themeSearchPaths": [
    "~/.config/shell-controls/themes",
    "/usr/share/shell-controls/themes"
  ]
}
```

**Dependencies:** `Get-SCConfig`, JSON Schema validation  
**Priority:** Medium

---

### 6.3 Reusable Snippets / Templates

| Name | Category | Description |
|------|----------|-------------|
| **StatusLine** | Extensibility | Compact multi-segment status display |

**Spec:**
```powershell
function Show-SCStatusLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable[]]$Segments,
        # Segment: @{ Text='OK'; Color='success'; Icon='success'; Bold=$true }
        
        [string]$Separator = ' │ ',
        [ValidateSet('left','center','right','spread')]
        [string]$Align = 'left',
        
        [switch]$PassThru
    )
    
    $parts = foreach ($seg in $Segments) {
        $icon = if ($seg.Icon) { (Get-SCSymbol $seg.Icon) + ' ' } else { '' }
        $text = $icon + $seg.Text
        Format-SCText $text -Color ($seg.Color ?? 'muted') -Bold:$seg.Bold
    }
    
    $line = $parts -join (Format-SCText $Separator -Color 'muted')
    
    if ($PassThru) { return $line }
    Write-Host $line
}

# Usage
Show-SCStatusLine -Segments @(
    @{ Text='main'; Icon='branch'; Color='info' }
    @{ Text='3 modified'; Icon='warning'; Color='warning' }
    @{ Text='Build passing'; Icon='success'; Color='success' }
)
# Output: ⎇ main │ ⚠ 3 modified │ ✓ Build passing
```

**Dependencies:** `Get-SCSymbol`, `Format-SCText`  
**Priority:** High

---

| Name | Category | Description |
|------|----------|-------------|
| **ConfirmDialog** | Extensibility | Standardized destructive action confirmation |

**Spec:**
```powershell
function Show-SCConfirmDialog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [string]$Message,
        
        [string[]]$Details,        # Bullet list of what will happen
        
        [ValidateSet('info','warning','danger')]
        [string]$Severity = 'warning',
        
        [string]$ConfirmText,      # If set, user must type this to confirm
        [string]$ConfirmLabel = "Type '{0}' to confirm",
        
        [switch]$DefaultNo
    )
    
    $colors = @{ info = 'info'; warning = 'warning'; danger = 'danger' }
    $icons = @{ info = 'info'; warning = 'warning'; danger = 'error' }
    
    Show-SCCard -Title $Title -BorderColor $colors[$Severity] -Body {
        if ($Message) { Write-SCText $Message }
        if ($Details) {
            ''
            foreach ($d in $Details) {
                Write-SCText "  $(Get-SCSymbol 'bullet') $d" -Color 'muted'
            }
        }
    }
    
    if ($ConfirmText) {
        ''
        $input = Read-SCInput -Prompt ($ConfirmLabel -f $ConfirmText)
        return $input -eq $ConfirmText
    }
    
    return Read-SCConfirm -Prompt "Are you sure?" -Default:(-not $DefaultNo)
}

# Usage
$confirmed = Show-SCConfirmDialog -Title "Delete Repository" -Severity danger -Details @(
    "All branches will be deleted"
    "This cannot be undone"
    "34 commits will be lost"
) -ConfirmText "delete-myrepo"
```

**Dependencies:** `Show-SCCard`, `Read-SCInput`, `Read-SCConfirm`, `Get-SCSymbol`  
**Priority:** Medium

---

| Name | Category | Description |
|------|----------|-------------|
| **TwoColumnLayout** | Extensibility | Side-by-side content with consistent widths |

**Spec:**
```powershell
function Show-SCColumns {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Left,
        
        [Parameter(Mandatory)]
        [scriptblock]$Right,
        
        [ValidateRange(0.1, 0.9)]
        [double]$LeftRatio = 0.5,
        
        [string]$Gap = 'sm',
        [string]$Divider,          # Character for vertical divider, or $null for none
        
        [switch]$PassThru
    )
    
    $termWidth = $Host.UI.RawUI.WindowSize.Width
    $gapSize = Get-SCSpacing $Gap
    $dividerSize = if ($Divider) { 1 } else { 0 }
    
    $leftWidth = [Math]::Floor(($termWidth - $gapSize - $dividerSize) * $LeftRatio)
    $rightWidth = $termWidth - $leftWidth - $gapSize - $dividerSize
    
    # Render each side with constrained width
    $leftLines = & $Left | ForEach-Object { $_.PadRight($leftWidth).Substring(0, $leftWidth) }
    $rightLines = & $Right | ForEach-Object { $_.PadRight($rightWidth).Substring(0, $rightWidth) }
    
    # Normalize line counts
    $maxLines = [Math]::Max($leftLines.Count, $rightLines.Count)
    $leftLines = $leftLines + @(''.PadRight($leftWidth)) * ($maxLines - $leftLines.Count)
    $rightLines = $rightLines + @(''.PadRight($rightWidth)) * ($maxLines - $rightLines.Count)
    
    # Combine
    $output = for ($i = 0; $i -lt $maxLines; $i++) {
        $div = if ($Divider) { Format-SCText $Divider -Color 'muted' } else { '' }
        $leftLines[$i] + (' ' * $gapSize) + $div + $rightLines[$i]
    }
    
    if ($PassThru) { return $output }
    $output | ForEach-Object { Write-Host $_ }
}

# Usage
Show-SCColumns -LeftRatio 0.4 -Divider '│' -Left {
    Show-SCCard -Title "Config" -Body $configSummary -PassThru
} -Right {
    Show-SCTable -Data $recentLogs -PassThru
}
```

**Dependencies:** `Get-SCSpacing`, `Format-SCText`  
**Priority:** Low

---

## 7. Testing, Docs & DX

### 7.1 Testability

| Name | Category | Description |
|------|----------|-------------|
| **TestMode** | Testing/Docs | Simulate user input and capture output without console interaction |

**Spec:**
```powershell
function Enable-SCTestMode {
    param(
        [hashtable]$MockInputs = @{},   # Component -> response queue
        [switch]$CaptureOutput
    )
    
    $script:SCTestMode = @{
        Enabled = $true
        MockInputs = $MockInputs
        InputIndex = @{}   # Track position in each queue
    }
    
    if ($CaptureOutput) { Enable-SCOutputCapture }
}

function Disable-SCTestMode {
    $script:SCTestMode = @{ Enabled = $false }
    Disable-SCOutputCapture
}

function Get-SCMockInput {
    param([string]$Component, [string]$Prompt)
    
    if (-not $script:SCTestMode.Enabled) { return $null }
    
    $queue = $script:SCTestMode.MockInputs[$Component]
    if (-not $queue) { throw "No mock input configured for $Component" }
    
    $index = $script:SCTestMode.InputIndex[$Component] ?? 0
    if ($index -ge $queue.Count) { throw "Mock input exhausted for $Component" }
    
    $script:SCTestMode.InputIndex[$Component] = $index + 1
    return $queue[$index]
}

# Usage in component (e.g., Show-SCMenu)
function Show-SCMenu {
    # ... setup ...
    
    # Check test mode
    $mockResult = Get-SCMockInput -Component 'Show-SCMenu' -Prompt $Title
    if ($null -ne $mockResult) {
        return $Options[$mockResult]  # mockResult is index
    }
    
    # ... normal interactive flow ...
}
```

**Test example:**
```powershell
Describe "Show-SCMenu" {
    It "returns selected option" {
        Enable-SCTestMode -MockInputs @{
            'Show-SCMenu' = @(1)  # Select second option
        } -CaptureOutput
        
        $result = Show-SCMenu -Title "Pick" -Options @('A','B','C')
        
        $result | Should -Be 'B'
        
        $output = Get-SCCapturedOutput -AsString
        $output | Should -Match 'Pick'
        $output | Should -Match 'A'
        
        Disable-SCTestMode
    }
}
```

**Dependencies:** Output capture system  
**Priority:** High

---

### 7.2 Help and Discovery

| Name | Category | Description |
|------|----------|-------------|
| **Get-SCHelp** | Testing/Docs | Programmatic access to component metadata |

**Spec:**
```powershell
function Get-SCComponent {
    [CmdletBinding()]
    param(
        [string]$Name,           # Filter by name pattern
        [string]$Category,       # 'display', 'input', 'layout', 'util'
        [switch]$List            # Summary list only
    )
    
    # Component manifest (could be generated or hand-maintained)
    $manifest = @(
        @{
            Name = 'Show-SCMenu'
            Category = 'input'
            Synopsis = 'Interactive single/multi-select menu'
            Parameters = @(
                @{ Name='Title'; Type='string'; Required=$false; Description='Menu title' }
                @{ Name='Options'; Type='string[]'; Required=$true; Description='Menu options' }
                @{ Name='MultiSelect'; Type='switch'; Description='Allow multiple selections' }
                # ...
            )
            Examples = @(
                @{ Code = "Show-SCMenu -Title 'Pick' -Options @('A','B')"; Description = 'Basic usage' }
            )
            ThemeKeys = @('components.menu.activeColor', 'components.menu.indicator')
        }
        # ... more components
    )
    
    $filtered = $manifest
    if ($Name) { $filtered = $filtered | Where-Object { $_.Name -like "*$Name*" } }
    if ($Category) { $filtered = $filtered | Where-Object { $_.Category -eq $Category } }
    
    if ($List) {
        return $filtered | Select-Object Name, Category, Synopsis
    }
    
    return $filtered
}

function Show-SCComponentHelp {
    param([string]$Name)
    
    $comp = Get-SCComponent -Name $Name | Select-Object -First 1
    if (-not $comp) { throw "Component not found: $Name" }
    
    Show-SCCard -Title $comp.Name -Body {
        Write-SCText $comp.Synopsis -Color 'caption'
        ''
        Write-SCText "Category: $($comp.Category)" -Color 'muted'
        ''
        Write-SCText "Parameters:" -Color 'heading'
        foreach ($p in $comp.Parameters) {
            $req = if ($p.Required) { " (required)" } else { "" }
            Write-SCText "  -$($p.Name) [$($p.Type)]$req" -Color 'code'
            Write-SCText "    $($p.Description)" -Color 'muted'
        }
    }
}
```

**Theme inspection:**
```powershell
function Get-SCTheme {
    param(
        [switch]$List,           # List available themes
        [switch]$AsHashtable,    # Return raw hashtable
        [string]$Key             # Get specific key path
    )
    
    if ($List) {
        $builtin = @('default', 'dracula', 'catppuccin', 'nord')
        $custom = $script:SCCustomThemes.Keys
        return @{ Builtin = $builtin; Custom = $custom }
    }
    
    $theme = $script:ActiveTheme
    
    if ($Key) {
        foreach ($segment in $Key -split '\.') {
            $theme = $theme[$segment]
        }
        return $theme
    }
    
    if ($AsHashtable) { return $theme }
    return [PSCustomObject]$theme
}

function Get-SCConfig {
    param(
        [switch]$Schema,     # Return JSON Schema for config
        [switch]$Defaults,   # Return default values only
        [string]$Key
    )
    
    if ($Schema) {
        return Get-Content (Join-Path $PSScriptRoot 'config.schema.json') | ConvertFrom-Json
    }
    
    # ... normal config loading
}
```

**Dependencies:** Module structure  
**Priority:** Medium

---

### 7.3 Documentation Generation

| Name | Category | Description |
|------|----------|-------------|
| **Build-SCDocs** | Testing/Docs | Generate documentation from code and manifests |

**Spec:**
```powershell
function Build-SCDocs {
    [CmdletBinding()]
    param(
        [ValidateSet('Markdown', 'MAML', 'JSON')]
        [string]$Format = 'Markdown',
        
        [string]$OutputPath = './docs',
        
        [switch]$IncludePrivate,    # Include internal functions
        [switch]$IncludeExamples    # Run examples and capture output
    )
    
    $components = Get-SCComponent
    
    switch ($Format) {
        'Markdown' {
            # Generate index.md
            $index = @"
# Shell-Controls Reference

## Components

| Name | Category | Description |
|------|----------|-------------|
"@
            foreach ($c in $components) {
                $index += "| [$($c.Name)](./$($c.Name).md) | $($c.Category) | $($c.Synopsis) |`n"
            }
            $index | Set-Content (Join-Path $OutputPath 'index.md')
            
            # Generate per-component docs
            foreach ($c in $components) {
                $doc = @"
# $($c.Name)

$($c.Synopsis)

## Parameters

"@
                foreach ($p in $c.Parameters) {
                    $doc += @"
### -$($p.Name)

- **Type:** ``$($p.Type)``
- **Required:** $($p.Required)

$($p.Description)

"@
                }
                
                if ($c.Examples -and $IncludeExamples) {
                    $doc += "`n## Examples`n`n"
                    foreach ($ex in $c.Examples) {
                        $doc += "### $($ex.Description)`n`n"
                        $doc += "``````powershell`n$($ex.Code)`n```````n`n"
                        
                        # Optionally capture output
                        if ($IncludeExamples) {
                            Enable-SCOutputCapture
                            try {
                                Invoke-Expression $ex.Code | Out-Null
                                $output = Get-SCCapturedOutput -AsString -StripAnsi
                                $doc += "Output:`n``````text`n$output`n```````n`n"
                            } catch { }
                            Disable-SCOutputCapture
                        }
                    }
                }
                
                $doc | Set-Content (Join-Path $OutputPath "$($c.Name).md")
            }
        }
        
        'JSON' {
            $components | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $OutputPath 'components.json')
        }
        
        'MAML' {
            # Use platyPS or similar for MAML generation
            # ...
        }
    }
}
```

**Minimal manifest file** (`src/pwsh/manifest.psd1`):
```powershell
@{
    Components = @(
        @{
            Name = 'Show-SCMenu'
            Category = 'input'
            Synopsis = 'Interactive single/multi-select menu'
            File = 'components/Menu.ps1'
            Function = 'Show-SCMenu'
            ThemeKeys = @('components.menu.*')
            ConfigKeys = @('behavior.menu.*')
        }
        # ...
    )
    Version = '1.0.0'
    MinPowerShellVersion = '7.0'
}
```

**Dependencies:** `Get-SCComponent`, output capture  
**Priority:** Low

---

## Summary Matrix

| ID | Name | Category | Priority |
|----|------|----------|----------|
| 1.1 | BorderStyles | Theme | High |
| 1.2 | Spacing Tokens | Theme | Medium |
| 1.3 | Set-SCTheme -Override | Theme | High |
| 1.4 | SemanticColorMap | Theme | Medium |
| 1.5 | AccessibilityMode | Theme | Medium |
| 2.1 | Show-SCCard | Component | High |
| 2.2 | Show-SCStack | Component | Medium |
| 2.3 | Show-SCGrid | Component | Medium |
| 2.4 | Show-SCTabs | Component | Low |
| 2.5 | StandardLayoutParams | Component | High |
| 2.6 | ResponsiveRules | Component | Low |
| 3.1 | Read-SCDate | Input | Medium |
| 3.2 | Read-SCUrl/Email | Input | Medium |
| 3.3 | Show-SCForm | Input | High |
| 3.4 | Autocomplete | Input | Medium |
| 4.1 | KeybindingSchema | Keybindings | Medium |
| 4.2 | EventHooks | Hooks | Medium |
| 4.3 | BehaviorConfig | Hooks | High |
| 5.1 | TerminalCapabilities | Terminal | High |
| 5.2 | OutputModes | Terminal | High |
| 5.3 | OutputCapture | Terminal | Medium |
| 6.1 | ComponentConvention | Extensibility | High |
| 6.2 | ThemeLoading | Extensibility | Medium |
| 6.3 | StatusLine | Extensibility | High |
| 6.4 | ConfirmDialog | Extensibility | Medium |
| 6.5 | TwoColumnLayout | Extensibility | Low |
| 7.1 | TestMode | Testing/Docs | High |
| 7.2 | Get-SCComponent | Testing/Docs | Medium |
| 7.3 | Build-SCDocs | Testing/Docs | Low |