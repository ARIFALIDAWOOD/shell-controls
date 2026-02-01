# Shell-Controls

Interactive CLI framework for beautiful, intuitive shell runners (PowerShell 7+).

## What's New in v2.0.0

- **Theme v2**: Semantic tokens, text styles, spacing system, multiple border styles
- **Layout System**: Responsive breakpoints, alignment, overflow handling (truncate/wrap/ellipsis)
- **Output Modes**: Normal, plain, JSON, quiet modes for CI/scripting compatibility
- **New Components**: Card, Stack, Grid layouts with PassThru support
- **Form System**: Multi-field forms, multi-step wizards with validation
- **Validation Library**: Email, URL, date, number, regex, custom validators
- **Test Infrastructure**: Mock inputs, output capture for automated testing
- **Accessibility**: High-contrast theme, NO_COLOR support, ASCII fallbacks

## API Reference

**[docs/API.md](docs/API.md)** — Full reference: all commands, parameters, config, and examples.

```powershell
Get-Command -Module Shell-Controls   # list exported functions (~150 commands)
Get-Help Show-SCMenu -Full           # inline help
```

## Features

### Themes
- Built-in: Catppuccin, Dracula, Nord, Default, **High-Contrast**
- Runtime overrides: `Set-SCTheme -Override @{ "colors.primary" = "#FF0000" }`
- Semantic colors, spacing system, border styles

### UI Components
- **Text**: Styled text, headers, gradients, lines
- **Display**: Banners, panels, tables, trees, **cards**
- **Layout**: **Stack**, **Grid**, columns with responsive breakpoints
- All components support `-PassThru` for piping and testing

### Menus & Selection
- Single/multi-select, radio, paginated
- Customizable keybindings per context

### Input & Validation
- **Basic**: Text, password, confirm, choice, number, path
- **Typed**: Date (with format), URL (with scheme validation), Email (with domain filtering)
- **Autocomplete**: `Read-SCInputWithSuggest` with prefix/contains/fuzzy modes
- **Validation**: Required, regex, range, length, type validators, custom scripts

### Forms & Wizards
```powershell
$result = Show-SCForm -Title "Create User" -Fields @(
    (New-SCFormField -Name "username" -Type "text" -Required)
    (New-SCFormField -Name "email" -Type "email" -Required)
    (New-SCFormField -Name "role" -Type "select" -Options @('admin','user','guest'))
)
```

### Progress & Process
- Progress bar, spinner, countdown, task runner
- Start process, parallel execution, watch

### Output Modes
```powershell
# CI-friendly plain output
$env:SHELL_CONTROLS_OUTPUT = 'plain'

# Respect NO_COLOR standard
$env:NO_COLOR = '1'

# JSON output for scripting
Set-SCOutputMode -Mode 'json'
```

### Test Mode
```powershell
Enable-SCTestMode -InputQueue @("test@example.com", "password123")
$result = Show-SCForm -Fields $fields  # Uses mock inputs
Disable-SCTestMode
```

## Quick Start

```powershell
Import-Module ./src/pwsh/Shell-Controls.psd1 -Force
Initialize-ShellControls -ThemeName catppuccin

# Basic output
Write-SCSuccess "Operation completed"
Write-SCError "Something went wrong"

# Banner (optional: Install-Module Figlet for richer ASCII fonts)
Show-SCBanner -Text "MyApp" -Subtitle "v2.0.0"

# Card layout
Show-SCCard -Title "Status" -Body "All systems operational" -Footer "Updated: $(Get-Date)"

# Grid of cards
Show-SCGrid -Columns 2 -Children {
    Show-SCCard -Title "CPU" -Body "45%" -PassThru
    Show-SCCard -Title "Memory" -Body "62%" -PassThru
}
```

## Install

**PowerShell (Windows / PowerShell 7):**

```powershell
./install.ps1
```

**Bash (Linux/macOS):**

```bash
./install.sh
```

### Basic setup (PowerShell)

One-time setup to trust PSGallery and optionally install Figlet for richer ASCII banners:

```powershell
# Trust PSGallery (avoids "untrusted repository" prompt)
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Optional: Figlet for Show-SCBanner / Write-Figlet (use -AllowClobber if Pansies conflicts with Write-Host)
Install-Module Figlet -Scope CurrentUser -AllowClobber -Force
```

## Project Structure

```
shell-controls/
├── config/
│   ├── shell-controls.config.json
│   └── themes/ (default, dracula, catppuccin, nord, high-contrast)
├── docs/
│   └── API.md
├── src/pwsh/
│   ├── Shell-Controls.psd1
│   ├── Shell-Controls.psm1
│   ├── core/
│   │   ├── TestMode.ps1      # Test infrastructure
│   │   ├── Terminal.ps1      # Capability detection
│   │   ├── OutputMode.ps1    # Output modes
│   │   ├── Theme.ps1         # Theme v2
│   │   ├── Layout.ps1        # Layout system
│   │   ├── Validation.ps1    # Validators
│   │   ├── Form.ps1          # Forms & wizards
│   │   ├── Keybindings.ps1   # Key contexts
│   │   ├── Hooks.ps1         # Event hooks
│   │   ├── UI.ps1, Menu.ps1, Input.ps1, ...
│   │   └── Progress.ps1, Spinner.ps1, Table.ps1, ...
│   └── components/
│       ├── Card.ps1, Stack.ps1, Grid.ps1  # New
│       └── Banner.ps1, Panel.ps1, Tree.ps1, StatusBar.ps1
├── examples/
└── tests/
    ├── TestMode.Tests.ps1
    ├── Validation.Tests.ps1
    ├── Form.Tests.ps1
    ├── Layout.Tests.ps1
    └── Core.Tests.ps1, UI.Tests.ps1, Menu.Tests.ps1
```

## Running Tests

```powershell
# Run all tests
Invoke-Pester -Path ./tests/*.Tests.ps1

# Run specific test file
Invoke-Pester -Path ./tests/Validation.Tests.ps1
```

## License

MIT
