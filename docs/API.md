# Shell-Controls API Reference

PowerShell 7+ module. Import and optionally re-initialize:

```powershell
Import-Module ./src/pwsh/Shell-Controls.psd1 -Force
Initialize-ShellControls -ThemeName catppuccin   # optional; defaults to catppuccin
```

---

## Initialization & theme

| Function | Purpose |
|----------|---------|
| `Initialize-ShellControls [-ThemeName] [-ConfigPath] [-Force]` | (Re)load config and theme. Use `-Force` to re-init. |
| `Set-SCTheme -Name <string> [-CustomTheme <hashtable>]` | Load theme by name or set custom hashtable. |
| `Get-SCTheme` | Returns current theme (colors, symbols, gradients). |
| `Get-SCColor -Name <primary\|success\|error\|...>` | Theme color hex for the given token. |
| `Get-SCSymbol -Name <string>` | Theme symbol, e.g. `check`, `pointer`, `boxRounded.topLeft`. |

**Theme names:** `default`, `dracula`, `catppuccin`, `nord`

---

## Output & text

| Function | Purpose |
|----------|---------|
| `Write-SCText -Text <string> [-Color] [-BackgroundColor] [-Bold] [-Italic] [-Underline] [-NoNewline]` | Styled line. `-Color` can be theme name or `#hex`. |
| `Write-SCLine [-Character] [-Color] [-Width]` | Horizontal rule. Default character from theme. |
| `Write-SCHeader -Text <string> [-Icon] [-Color] [-Align Left\|Center\|Right] [-WithLine]` | Heading with optional icon and rule. |
| `Write-SCSuccess -Message <string> [-NoIcon]` | ✓ Success (green). |
| `Write-SCError -Message <string> [-NoIcon]` | ✖ Error (red). |
| `Write-SCWarning -Message <string> [-NoIcon]` | ⚠ Warning (yellow). |
| `Write-SCInfo -Message <string> [-NoIcon]` | ℹ Info (cyan). |
| `Write-SCMuted -Message <string>` | Muted (gray). |
| `Write-SCGradient -Text <string> [-Colors <string[]>] [-Preset rainbow\|sunset\|ocean\|forest] [-NoNewline]` | Per-character gradient. |
| `Clear-SCScreen [-SoftClear]` | Clear console; `-SoftClear` fills with spaces. |

---

## Components

| Function | Purpose |
|----------|---------|
| `Show-SCBanner -Text <string> [-Font block\|small] [-GradientColors] [-Subtitle] [-Version] [-Centered]` | ASCII banner. `-Font`: `block`, `small`. |
| `Show-SCPanel -Content <string[]> [-Title] [-Width] [-Style rounded\|heavy\|double\|simple] [-BorderColor] [-TitleColor] [-TitleAlign] [-Padding]` | Bordered box. |
| `Show-SCTable -Data <array> [-Columns <string[]>] [-Title] [-Style simple\|rounded\|heavy\|double\|minimal] [-ColumnWidths] [-ColumnColors] [-NoHeader]` | Table; `-Data` pipelineable. |
| `Show-SCTree -Items <array> [-Title] [-Icon] [-Indent]` | Tree; items with `Name`/`Children` or strings. |
| `Show-SCStatusBar [-Left] [-Center] [-Right] [-Color]` | One-line status (left, center, right). |
| `Show-SCNotification -Message <string> [-Type info\|success\|warning\|error] [-Title] [-Dismissible]` | Styled message; `-Dismissible` waits for key. |

---

## Menus (interactive)

| Function | Purpose |
|----------|---------|
| `Show-SCMenu -Items <array> [-Title] [-Description] [-DefaultIndex] [-ReturnIndex] [-PageSize] [-ShowHelp] [-AllowCancel] [-Style simple\|boxed\|minimal]` | Arrow-key menu. Items: strings or `@{Name; Description; Disabled; Icon}`. Returns selected item or index if `-ReturnIndex`. |
| `Show-SCMultiSelect -Items <array> [-Title] [-Description] [-DefaultSelected] [-MinSelection] [-MaxSelection] [-ReturnIndices] [-PageSize]` | Checkbox multi-select. Space=toggle, A=all, N=none. |
| `Show-SCRadioSelect -Items <array> [-Title] [-Description] [-DefaultIndex] [-ReturnIndex] [-AllowCancel]` | Single choice; delegates to `Show-SCMenu`. |
| `Show-SCPaginated -Items <array> [-Title] [-Description] [-DefaultIndex] [-PageSize] [-ReturnIndex] [-AllowCancel]` | Paged `Show-SCMenu`. |

---

## Input

| Function | Purpose |
|----------|---------|
| `Read-SCInput [-Prompt] [-Default] [-Validate <scriptblock>] [-ValidationMessage] [-Required] [-Placeholder]` | Text with optional validation. |
| `Read-SCPassword [-Prompt] [-Confirm] [-MinLength] [-AsPlainText]` | Masked input; `-AsPlainText` returns string. |
| `Read-SCConfirm [-Message] [-DefaultYes] [-YesLabel] [-NoLabel]` | Y/N; returns `$true`/`$false`. |
| `Read-SCChoice -Message <string> -Choices <array> [-DefaultIndex]` | Inline left/right choice. |
| `Read-SCNumber [-Prompt] [-Min] [-Max] [-Default] [-Integer]` | Numeric with range. |
| `Read-SCPath [-Prompt] [-Type File\|Directory\|Any] [-MustExist] [-Default]` | Path with type/existence checks. |

---

## Progress & spinners

| Function | Purpose |
|----------|---------|
| `Show-SCProgress -Current <int> -Total <int> [-Label] [-Width] [-Style blocks\|line\|dots\|arrows] [-ShowPercentage] [-ShowCount] [-Color]` | Progress bar (optional in-place update). |
| `Show-SCSpinner [-Message] [-Style dots\|line\|arc\|bounce\|circle] [-Color]` | Returns object with `.Stop($success, $message)` and `.UpdateMessage($m)`. |
| `Invoke-SCWithSpinner -ScriptBlock <scriptblock> [-Message] [-SuccessMessage] [-FailureMessage] [-Style]` | Run scriptblock with spinner; returns job result. |
| `Show-SCCountdown -Seconds <int> [-Message] [-OnComplete <scriptblock>]` | Countdown; `-Message` supports `{0}` for seconds. |
| `Start-SCTasks -Tasks <array> [-Title] [-StopOnError] [-Parallel]` | `-Tasks`: `@{Name; Action <scriptblock>}` or scriptblocks. Runs in order; shows spinner per task. |

---

## Process

| Function | Purpose |
|----------|---------|
| `Start-SCProcess -Command <string> [-Arguments <string[]>] [-WorkingDirectory] [-Description] [-ShowOutput] [-PassThru]` | Start process, optionally show stdout/stderr. `-PassThru`: `{ExitCode, Output, Error, Success}`. |
| `Start-SCParallel -Processes <array> [-Title]` | `-Processes`: `@{Command; Arguments; WorkingDirectory; Description}`. Returns job results. |
| `Watch-SCProcess -Process <Diagnostics.Process> [-Message] [-PollInterval]` | Spinner + PID/mem/CPU until exit. |

---

## Config & logging

| Function | Purpose |
|----------|---------|
| `Get-SCConfig [-Key <string>]` | Full config or dotted key, e.g. `theme`, `settings.unicode`. |
| `Set-SCConfig -Key <string> -Value <object>` | Set dotted key. |
| `Write-SCLog -Message <string> [-Level Debug\|Info\|Warning\|Error] [-NoConsole] [-NoFile]` | Log; respects `Set-SCLogLevel` and `Set-SCLogFile`. |
| `Set-SCLogLevel -Level <Debug\|Info\|Warning\|Error\|None>` | Minimum level. |
| `Set-SCLogFile -Path <string>` | File to append. |

---

## Utils

| Function | Purpose |
|----------|---------|
| `Get-SCTerminalSize` | `{Width, Height, BufferWidth, BufferHeight}`. |
| `Test-SCCommand -Name <string>` | `$true` if command exists. |
| `Invoke-SCCommand -ScriptBlock <scriptblock> [-ErrorMessage] [-SuppressErrors]` | Run scriptblock; write error and return `$null` on throw. |
| `ConvertTo-SCSlug -Text <string>` | URL-style slug. |
| `Get-SCRelativePath -From <string> -To <string>` | Relative path. |
| `Format-SCDuration -Duration <TimeSpan>` | e.g. `1m 5s`, `100ms`. |
| `Get-SCEnvironmentInfo` | OS, PowerShell, user, machine, cwd, etc. |

---

## Config file

`config/shell-controls.config.json`:

- `theme` — `default`, `dracula`, `catppuccin`, `nord`
- `settings` — `unicode`, `animations`, `animationSpeed`, `sounds`, `logLevel`, `logFile`, `clearScreenOnStart`, `showBreadcrumbs`, `confirmDestructiveActions`
- `keybindings` — `up`, `down`, `select`, `back`, `quit`, `help`, `search` (arrays of key names)
- `defaults` — `menuStyle`, `progressStyle`, `spinnerStyle`, `tableStyle`

Themes in `config/themes/<name>.json`: `name`, `author`, `colors`, `symbols`, `gradients`.

---

## Minimal usage

```powershell
Import-Module ./src/pwsh/Shell-Controls.psd1 -Force

# Styled output
Write-SCSuccess "Done"
Write-SCHeader -Text "Section" -WithLine
Show-SCTable -Data @(@{A=1;B=2}) -Columns A,B

# Menu (interactive)
$choice = Show-SCMenu -Title "Pick" -Items @("One","Two","Three") -AllowCancel

# Input
$name = Read-SCInput -Prompt "Name" -Required
$ok = Read-SCConfirm -Message "Continue?"

# Spinner
Invoke-SCWithSpinner -ScriptBlock { Start-Sleep 2 } -Message "Loading..." -SuccessMessage "Ready"
```

---

## Getting help in PowerShell

```powershell
Get-Command -Module Shell-Controls
Get-Help Initialize-ShellControls -Full
Get-Help Show-SCMenu -Parameter Items
```
