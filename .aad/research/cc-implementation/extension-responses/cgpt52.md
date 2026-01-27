### Summary (what you’ll get if you implement these)
- A **Theme v2** schema that controls not just colors, but **borders, spacing/density, typography-like emphasis, and responsive rules**.
- A small **layout engine** (stack/grid/tabs/card/tooltip) that’s responsive to terminal size and supports **alignment/max-width/padding/margin/overflow** consistently.
- A **typed input + validation + forms/wizards** layer with autocomplete, reusable validators, and predictable error UX.
- A next-level **keybinding system** (contexts + chords), plus **hooks/events** (resize, cancel, before/after render).
- Robust **terminal capability detection**, **output modes** (ansi/plain/json/quiet), and **output capture** for tests/replay.
- A clean **extensibility model**: user-defined components, pluggable themes (path/URL), and reusable snippet templates.

---

## 1) Theme Schema v2 (layout + borders + emphasis)

### Idea 1
1. **Name** – ThemeSchemaV2.LayoutBordersSpacing  
2. **Category** – Theme  
3. **Description** – Extend theme JSON beyond colors to include border characters, spacing/density, max-width defaults, and lightweight “shadow” simulation. This makes components consistent without per-component hardcoding.  
4. **Spec** – Add these keys to theme JSON (paths, type, example, effect):

| Key path | Type | Example | Rendering effect |
|---|---:|---|---|
| `theme.version` | number | `2` | Enables v2 parsing + validation. |
| `layout.maxWidth` | number \| null | `120` | Components clamp to this width unless overridden. |
| `layout.align` | `"left"\|"center"\|"right"` | `"center"` | Default alignment when rendering blocks narrower than terminal. |
| `spacing.unit` | number | `1` | Base unit for padding/margins/gaps (in character cells). |
| `spacing.density` | `"compact"\|"comfortable"\|"spacious"` | `"comfortable"` | Multiplies derived padding/gap defaults. |
| `spacing.gap` | number | `1` | Default vertical gap between stacked elements. |
| `borders.style` | `"ascii"\|"square"\|"rounded"\|"heavy"\|"double"\|"none"` | `"rounded"` | Selects border char set used by panels/cards/tables. |
| `borders.chars` | object | see below | Exact chars for corners/lines; overrides `style` preset. |
| `borders.color` | string token | `"tokens.border"` | Border color token resolved via token system. |
| `effects.shadow.enabled` | boolean | `true` | If true, draw a 1-col/1-row shadow using shade chars. |
| `effects.shadow.x` / `y` | number | `1`, `1` | Shadow offset in cells. |
| `effects.shadow.char` | string | `"░"` | Shadow glyph (fallback to `"."` in ASCII mode). |
| `effects.shadow.color` | string token | `"tokens.shadow"` | Shadow color. |

Example `borders.chars`:
```json
{
  "tl": "╭", "tr": "╮", "bl": "╰", "br": "╯",
  "h": "─", "v": "│",
  "t": "┬", "b": "┴", "l": "├", "r": "┤",
  "x": "┼"
}
```

Implementation sketch (core):
- `src/pwsh/core/Theme.ps1`: `Get-SCTheme`, `Resolve-SCToken`, `Get-SCBorderChars`
- `src/pwsh/core/Layout.ps1`: `Resolve-SCLayoutDefaults` uses `layout.*` + `spacing.*`
- Components call `Resolve-SCLayoutDefaults -Component 'Panel' -Layout $Layout`

5. **Dependencies** – Existing theme loader; ANSI style writer; any existing panel/table border drawing utilities.  
6. **Priority** – **Must-have**

---

### Idea 2
1. **Name** – ThemeSemanticTokens  
2. **Category** – Theme  
3. **Description** – Introduce semantic tokens like `heading`, `caption`, `code`, and `link` so components stop referencing raw palette keys directly. This makes theme swapping and accessibility far easier.  
4. **Spec** – Add a `tokens` and `textStyles` block:

```json
{
  "tokens": {
    "fg": "#e6e6e6",
    "muted": "#a0a0a0",
    "border": "#3a3a3a",
    "shadow": "#00000080",
    "primary": "#8be9fd",
    "success": "#50fa7b",
    "warning": "#f1fa8c",
    "danger":  "#ff5555",
    "link": "#8be9fd"
  },
  "textStyles": {
    "heading": { "fg": "tokens.fg", "bold": true },
    "caption": { "fg": "tokens.muted", "dim": true },
    "code":    { "fg": "tokens.fg", "bg": "#202020", "inverse": false },
    "link":    { "fg": "tokens.link", "underline": true },
    "error":   { "fg": "tokens.danger", "bold": true }
  }
}
```

Define a “style object” contract:
- allowed flags: `bold, dim, italic, underline, inverse`
- colors: `fg, bg` accept hex OR token references (dot paths)

Core API:
- `Get-SCStyle -Name heading` returns resolved `{fg,bg,flags...}`
- `Write-SCText -Text "Title" -Style heading`

Migration pattern:
- Keep `colors.*` for backward compatibility
- In v2, map old `colors.primary` → `tokens.primary` if `tokens.primary` missing

5. **Dependencies** – Style resolver, theme loader, existing `Write-SC*` functions.  
6. **Priority** – **Must-have**

---

### Idea 3
1. **Name** – RuntimeThemeOverridesAndSnippets  
2. **Category** – Theme  
3. **Description** – Allow runtime patching of the active theme with dot-path overrides and “snippet merge” files. Great for per-script tweaks without forking themes.  
4. **Spec** – New API:

```powershell
# Dot-path overrides (hashtable)
Set-SCTheme -Override @{
  'tokens.primary' = '#ff0000'
  'textStyles.heading.underline' = $true
  'borders.style' = 'heavy'
}

# Merge a JSON snippet (file or raw JSON)
Set-SCTheme -MergePath "$HOME/.config/shell-controls/theme-snippets/my-ci.json"
Set-SCTheme -MergeJson '{ "tokens": { "primary": "#00ff00" } }'
```

Override rules:
- Dot-path assignment overwrites scalars/objects at that path.
- Merge JSON uses deep-merge:
  - objects merge recursively
  - arrays replace by default, unless `merge.arrayMode = "concat"` exists in snippet

Snippet file format (recommended):
```json
{
  "name": "my-ci-overrides",
  "appliesTo": ["default", "dracula", "*"],
  "merge": { "tokens": { "primary": "#00ff00" }, "effects": { "shadow": { "enabled": false } } }
}
```

Core functions:
- `Set-SCTheme` stores `$script:SCThemeActive`
- `Merge-SCObjectDeep -Base $Theme -Patch $Patch`
- `Set-SCObjectPath -Object $Theme -Path 'a.b.c' -Value 123`

5. **Dependencies** – Theme loader, JSON parse (`ConvertFrom-Json`), deep merge helper.  
6. **Priority** – **High**

---

### Idea 4
1. **Name** – HighContrastAccessibilityPreset  
2. **Category** – Theme  
3. **Description** – A built-in “high contrast” preset that adjusts colors, disables low-legibility effects, increases spacing, and avoids ambiguous glyphs—enabled via config, env var, or auto-detect hints.  
4. **Spec** – Config + theme additions:

Config:
```json
{
  "ui": {
    "accessibility": {
      "highContrast": "auto",   // "auto" | true | false
      "reduceMotion": "auto",   // disables spinners/gradients
      "preferAscii": "auto",    // avoid box-drawing for limited fonts
      "minContrastRatio": 7.0
    }
  }
}
```

Theme preset block:
```json
{
  "presets": {
    "highContrast": {
      "tokens": {
        "fg": "#ffffff",
        "muted": "#ffffff",
        "border": "#ffffff",
        "shadow": "#00000000",
        "primary": "#00ffff",
        "danger": "#ff0000",
        "warning": "#ffff00",
        "success": "#00ff00",
        "link": "#00ffff"
      },
      "effects": { "shadow": { "enabled": false } },
      "spacing": { "density": "spacious", "gap": 2 },
      "borders": { "style": "ascii" }
    }
  }
}
```

Auto-detect (best-effort; never block rendering if unknown):
- If `$env:SC_HIGH_CONTRAST=1` → enable
- Else if config `highContrast=true` → enable
- Else if `highContrast="auto"`:
  - if `$env:WT_ACCESSIBILITY` (or similar) exists → enable (best-effort hook)
  - if `Get-SCCapabilities` says no truecolor → prefer higher-contrast token mapping

Implementation:
- `Resolve-SCTheme -Preset 'highContrast'` deep-merges preset into active theme.
- If `reduceMotion` true → spinners become static “…” and progress becomes percentage only.

5. **Dependencies** – Theme presets + deep merge, terminal capability detection.  
6. **Priority** – **High**

---

## 2) Components & Layouts (consistent layout primitives)

### Idea 5
1. **Name** – ShowSCCard  
2. **Category** – Component  
3. **Description** – A “card” is a panel variant with optional header/footer, subtle border, and default padding. Used for summaries, status blocks, and grouped content.  
4. **Spec** – New component: `src/pwsh/components/Show-SCCard.ps1`

Signature:
```powershell
Show-SCCard `
  -Title "Build Summary" `
  -Body { Write-SCText "All checks passed" -Style success } `
  -Footer { Write-SCText "Press Enter to continue" -Style caption } `
  -Style "card" `
  -Layout @{ Padding = 1; Margin = 1; MaxWidth = 100; Align = 'center' } `
  -PassThru
```

Rules:
- Card width = `min(terminalWidth, layout.maxWidth, layout.MaxWidth)`; then apply margin.
- Default padding uses theme: `components.card.padding` or `spacing.unit`.
- If `-Body` is scriptblock, capture output via render-tree (see “OutputCapture” idea) or via a `Write-SCRenderNode` system.

New theme keys (optional):
```json
{
  "components": {
    "card": {
      "borderStyle": "rounded",
      "borderToken": "tokens.border",
      "titleStyle": "textStyles.heading",
      "footerStyle": "textStyles.caption",
      "padding": 1
    }
  }
}
```

5. **Dependencies** – Panel/border renderer; theme token resolver; layout helper.  
6. **Priority** – **High**

---

### Idea 6
1. **Name** – ShowSCStack  
2. **Category** – Component  
3. **Description** – A vertical/horizontal layout primitive that composes multiple renderables with consistent gaps and alignment. This becomes the backbone for forms, dashboards, and summaries.  
4. **Spec** – `src/pwsh/components/Show-SCStack.ps1`

Signature:
```powershell
Show-SCStack -Direction Vertical -Gap 1 -Align Center -Items @(
  { Show-SCBanner -Text "Deploy" },
  { Show-SCCard -Title "Targets" -Body { Show-SCTable ... } },
  { Show-SCProgress -Activity "Uploading" }
) -Layout @{ MaxWidth = 120 }
```

Parameters:
- `-Direction` (`Vertical`|`Horizontal`)
- `-Gap` (int; default theme `spacing.gap`)
- `-Align` (`Left`|`Center`|`Right`) for each child block
- `-Items` array of scriptblocks or render nodes
- `-Wrap` (for horizontal stack): if true, wraps to next line when width exceeded

Minimal layout logic (pseudo):
```powershell
$children = Resolve-SCRenderables $Items
if ($Direction -eq 'Vertical') { place each child on new lines with $Gap }
else { measure child widths; place left-to-right; wrap if -Wrap }
```

Theme keys:
- `components.stack.gapDefault`
- `components.stack.wrapDefault`

5. **Dependencies** – Render-tree measurement (`Measure-SCRenderNode`), terminal width.  
6. **Priority** – **High**

---

### Idea 7
1. **Name** – ShowSCGridResponsive  
2. **Category** – Component  
3. **Description** – A grid layout that automatically chooses column count based on terminal width and theme breakpoints. Perfect for “cards in a dashboard” layouts.  
4. **Spec** – `src/pwsh/components/Show-SCGrid.ps1`

Signature:
```powershell
Show-SCGrid -Items $cards -MinColWidth 28 -Gap 2 -Columns Auto -Layout @{ MaxWidth = 140 }
```

Parameters:
- `-Columns` (`Auto` or int)
- `-MinColWidth` (int)
- `-Gap` (int)
- `-RowGap` (int; default = `Gap`)
- `-Overflow` (`Wrap`|`Truncate`|`StackFallback`)

Auto columns algorithm:
```powershell
$w = Get-SCTerminalSize().Width
$max = [math]::Floor( ($w + $Gap) / ($MinColWidth + $Gap) )
$cols = [math]::Max(1, $max)
```

Responsive theme control:
```json
{
  "responsive": {
    "breakpoints": { "sm": 80, "md": 120, "lg": 160 },
    "grid": {
      "sm": { "columns": 1, "gap": 1 },
      "md": { "columns": 2, "gap": 2 },
      "lg": { "columns": 3, "gap": 2 }
    }
  }
}
```

5. **Dependencies** – Terminal size function; render node measurement; stack fallback.  
6. **Priority** – **Medium** (high value, slightly more work)

---

### Idea 8
1. **Name** – ShowSCTabsInteractive  
2. **Category** – Component  
3. **Description** – Interactive tabs let you switch between multiple panels/views without leaving the runner. Useful for “Details / Logs / Config” displays.  
4. **Spec** – `src/pwsh/components/Show-SCTabs.ps1`

Signature:
```powershell
Show-SCTabs -Tabs @(
  @{ Id='summary'; Title='Summary'; Content={ Show-SCCard ... } },
  @{ Id='logs';    Title='Logs';    Content={ Show-SCScrollView -Lines $logLines } },
  @{ Id='json';    Title='JSON';    Content={ Show-SCCodeBlock -Language 'json' -Text $raw } }
) -DefaultTabId 'summary' -Keymap 'tabs'
```

Parameters:
- `-Tabs` array of `{Id, Title, Content}`
- `-DefaultTabId`
- `-PersistSelectionKey` (string; saves last tab in config state)
- `-Keymap` (context name for keybindings)

Keys (defaults):
- Left/Right: switch tab
- `1..9`: jump to tab index
- `Esc`: cancel (fires hook)
- `Enter`: accept/exit (optional)

Theme keys:
```json
{ "components": { "tabs": { "activeStyle": "textStyles.heading", "inactiveStyle": "textStyles.caption" } } }
```

5. **Dependencies** – Keybinding contexts; rerender loop; optional scroll view.  
6. **Priority** – **Medium**

---

### Idea 9
1. **Name** – TooltipPopover  
2. **Category** – Component  
3. **Description** – A lightweight tooltip/popover used by autocomplete, inline help, and validation errors. Anchors near cursor or at bottom.  
4. **Spec** – `src/pwsh/components/Show-SCTooltip.ps1`

Signature:
```powershell
Show-SCTooltip -Text "Use --force to override" -Anchor Cursor -Placement Below -MaxWidth 50 -TimeoutMs 0
```

Parameters:
- `-Text` or `-Content` scriptblock
- `-Anchor` (`Cursor`|`Bottom`|`Top`)
- `-Placement` (`Above`|`Below`|`Right`|`Left`)
- `-MaxWidth`
- `-TimeoutMs` (0 = persistent until next render)

Fallback behavior:
- If terminal doesn’t support cursor positioning → render as a normal panel beneath current line.

Theme keys:
- `components.tooltip.borderStyle`, `components.tooltip.style`

5. **Dependencies** – Cursor positioning (ANSI), capability detection, panel renderer.  
6. **Priority** – **Medium**

---

### Idea 10
1. **Name** – UnifiedLayoutOptions  
2. **Category** – Component  
3. **Description** – Standardize `-Layout` across components so alignment/max-width/padding/margin/overflow work the same everywhere and can be theme-configured.  
4. **Spec** – Create `src/pwsh/core/Layout.ps1` and adopt this schema:

`-Layout` hashtable keys:
- `Padding` (int or `[t,r,b,l]`)
- `Margin` (int or `[t,r,b,l]`)
- `Align` (`Left|Center|Right`)
- `MaxWidth` (int|null)
- `MinWidth` (int|null)
- `Overflow` (`Wrap|Truncate|Scroll|Hide`) default varies by component

Theme defaults:
```json
{
  "components": {
    "defaults": {
      "layout": { "align": "left", "maxWidth": 120, "overflow": "truncate" },
      "padding": 1,
      "margin": 0
    },
    "table": { "layout": { "overflow": "scroll" } }
  }
}
```

Resolution rules:
1) explicit `-Layout` wins  
2) component-specific theme defaults  
3) `components.defaults`  
4) `layout.*` global theme defaults

5. **Dependencies** – Theme v2; measurement utilities.  
6. **Priority** – **Must-have**

---

### Idea 11
1. **Name** – ResponsiveRulesEngine  
2. **Category** – Component  
3. **Description** – Encode responsive behavior in theme/config: wrap vs truncate, hide low-priority UI, switch from grid→stack, and adjust padding at small widths.  
4. **Spec** – Add `responsive.rules` array:

```json
{
  "responsive": {
    "rules": [
      { "maxWidth": 80, "set": { "spacing.density": "compact", "effects.shadow.enabled": false } },
      { "maxWidth": 80, "set": { "components.table.layout.overflow": "scroll" } },
      { "maxWidth": 60, "set": { "components.banner.variant": "minimal" } }
    ]
  }
}
```

Core:
- `Resolve-SCResponsiveTheme -Theme $Theme -Width (Get-SCTerminalSize).Width` applies matching `set` patches in order.

Component-specific responsive flags:
- `Show-SCHeader -HideSubtitleBelowWidth 70`
- `Show-SCTable -AutoScrollBelowWidth 90`
- `Show-SCGrid -StackBelowWidth 70`

5. **Dependencies** – Theme patch merge; terminal size detection.  
6. **Priority** – **High**

---

## 3) Input, Validation & Forms

### Idea 12
1. **Name** – TypedInputValidators  
2. **Category** – Input  
3. **Description** – Add first-class input types (date/time/duration/email/url/json) with consistent validation, parsing, and error presentation.  
4. **Spec** – Extend `Read-SCInput`:

```powershell
Read-SCInput -Prompt "Start date" -Type Date -Format 'yyyy-MM-dd' -Required
Read-SCInput -Prompt "Timeout" -Type Duration -Min '00:00:05' -Max '00:10:00'
Read-SCInput -Prompt "Webhook URL" -Type Url -Schemes @('https') -Required
Read-SCInput -Prompt "Metadata JSON" -Type Json -ReturnObject
```

Type rules (implementation-level):
- **Date**: parse via `[DateTime]::ParseExact($s,$Format,$null)`; allow `today`, `tomorrow` if `-AllowNatural` switch.
- **Time**: parse `HH:mm` or `HH:mm:ss`.
- **Duration**: support `hh:mm:ss` plus short forms `5m`, `1h30m` (custom parser); return `[TimeSpan]`.
- **Email**: regex + optional `System.Net.Mail.MailAddress` constructor check.
- **Url**: `[Uri]` parse; enforce schemes list if provided.
- **Json**: `ConvertFrom-Json`; on error show message + highlight approximate position if possible.

Standard error UX:
- Print an error line styled `textStyles.error`
- Keep cursor in input; don’t exit component
- Expose `-ValidationMode` (`Inline|Tooltip|Panel`) default from theme/config

5. **Dependencies** – Key reading loop; tooltip/panel; `ConvertFrom-Json`.  
6. **Priority** – **High**

---

### Idea 13
1. **Name** – ValidationContractAndLibrary  
2. **Category** – Input  
3. **Description** – Create reusable validators so forms and single inputs share logic (required, min/max, regex, custom).  
4. **Spec** – Validator object schema:

```powershell
$validators = @(
  New-SCValidator Required
  New-SCValidator Regex -Pattern '^\w+$' -Message 'Only letters, numbers, underscore'
  New-SCValidator Script -ScriptBlock { param($value) $value -in @('dev','prod') } -Message 'Must be dev or prod'
)
```

Core:
- `Test-SCValue -Value $v -Validators $validators` returns:
```powershell
[pscustomobject]@{ IsValid=$false; Errors=@("..."); NormalizedValue=$nv }
```

Configurable messages:
- theme `messages.validation.required = "This field is required."`

5. **Dependencies** – Typed input work; consistent error rendering.  
6. **Priority** – **Medium**

---

### Idea 14
1. **Name** – ShowSCFormWizard  
2. **Category** – Input  
3. **Description** – A form/wizard helper that renders multiple fields, supports steps (back/next), shows a summary, and returns a typed hashtable (or calls `-OnSubmit`).  
4. **Spec** – New component: `src/pwsh/components/Show-SCForm.ps1`

Field schema (hashtable or PSCustomObject):
```powershell
$fields = @(
  @{ Name='env'; Label='Environment'; Type='Radio'; Options=@('dev','prod'); Required=$true },
  @{ Name='start'; Label='Start date'; Type='Date'; Format='yyyy-MM-dd'; Default='today' },
  @{ Name='timeout'; Label='Timeout'; Type='Duration'; Default='5m'; Validate=@( New-SCValidator Min -Value '00:00:05' ) }
)

Show-SCForm -Title "Deploy" -Fields $fields -Steps @(
  @{ Id='basic'; Fields=@('env','start') },
  @{ Id='limits'; Fields=@('timeout') }
) -OnSubmit {
  param($values, $context)
  # $values is ordered hashtable with normalized typed values
}
```

Behavior:
- Step UI shows progress: `Step 1/2`
- `Back` allowed except on first
- `Next` validates only fields in current step
- `Submit` validates all, then returns `$values` (unless `-OnSubmit` provided)
- Optional `-ShowSummary` shows a final read-only review screen

Keybindings context: `form`
- Enter: next/submit
- Esc: cancel
- Shift+Tab / Tab: prev/next field

Theme keys:
- `components.form.labelStyle`, `components.form.errorStyle`, `components.form.requiredMark` (`"*"`)

5. **Dependencies** – Stack/layout; typed inputs; keybinding contexts.  
6. **Priority** – **High**

---

### Idea 15
1. **Name** – AutocompleteSuggestionsEngine  
2. **Category** – Input  
3. **Description** – Add autocomplete to `Read-SCInput` and `Read-SCPath` with pluggable suggestion sources (static list, filesystem, scriptblock/API), a small UI, and configurable keybindings.  
4. **Spec** – Extend input functions:

```powershell
Read-SCInput -Prompt "Branch" -Suggest @('main','develop','release/*') -SuggestMode Prefix
Read-SCInput -Prompt "User" -SuggestScript { param($text) Invoke-RestMethod ... | % name }
Read-SCPath -Prompt "Config file" -SuggestMode Files -Root $PWD -Extensions @('.json')
```

Parameters:
- `-Suggest` (array)
- `-SuggestScript` (scriptblock returning array)
- `-SuggestMode` (`Prefix|Contains|FzfLike`)
- `-SuggestMax` (default 8)
- `-SuggestDebounceMs` (default 150 for API calls)
- `-SuggestUi` (`Inline|Tooltip|Panel`) default from config

UI rules:
- Show list under input; highlight current; Up/Down moves; Tab accepts; Enter submits.
- If terminal lacks cursor addressing → fall back to “Panel” suggestion list rendered below.

Keybindings (config):
```json
{
  "keybindings": {
    "input": {
      "complete": "Tab",
      "suggestNext": "DownArrow",
      "suggestPrev": "UpArrow",
      "suggestAccept": "Enter",
      "suggestCancel": "Esc"
    }
  }
}
```

5. **Dependencies** – Key reading; tooltip/panel; capability detection; optional debounce timer.  
6. **Priority** – **High**

---

## 4) Keybindings, Hooks & Behavior

### Idea 16
1. **Name** – KeybindingContextsAndChords  
2. **Category** – Keybindings  
3. **Description** – Upgrade keybindings to support contexts (global/menu/input/form/tabs) and multi-key chords (e.g., `Ctrl+K Ctrl+C`).  
4. **Spec** – Config schema:

```json
{
  "keybindings": {
    "global": {
      "help": "F1",
      "cancel": "Esc",
      "quit": "Ctrl+C"
    },
    "menu": {
      "up": "UpArrow",
      "down": "DownArrow",
      "toggle": "Spacebar",
      "submit": "Enter"
    },
    "chords": {
      "toggleComment": ["Ctrl+K", "Ctrl+C"]
    },
    "settings": {
      "chordTimeoutMs": 800
    }
  }
}
```

Core:
- `Resolve-SCKeymap -Context 'menu'` merges `global` + `menu`
- Chord recognizer:
  - store partial chord state + timestamp
  - if next key within timeout matches sequence → emit action
  - else reset state and treat first key normally

5. **Dependencies** – Existing key read loop(s); config loader.  
6. **Priority** – **High**

---

### Idea 17
1. **Name** – ActionRegistry  
2. **Category** – Keybindings  
3. **Description** – Standardize actions (`copy`, `paste`, `clear`, `help`, `cancel`, `submit`, `pageUp`, etc.) via a registry so components reuse the same action names and keymaps.  
4. **Spec** – Core file: `src/pwsh/core/Actions.ps1`

```powershell
Register-SCAction -Name 'cancel' -Description 'Cancel current interaction'
Register-SCAction -Name 'submit' -Description 'Submit selection/input'
Register-SCAction -Name 'help'   -Description 'Show help overlay'
```

Components use:
```powershell
$action = Read-SCAction -Context 'menu'
switch ($action) {
  'submit' { ... }
  'cancel' { ... }
}
```

Add `Get-SCActions` for discovery/docs.

5. **Dependencies** – Keybinding contexts; discovery tooling.  
6. **Priority** – **Medium**

---

### Idea 18
1. **Name** – HooksLifecycleAndResize  
2. **Category** – Hooks  
3. **Description** – Add event hooks at predictable lifecycle points: before/after render, after selection, on cancel, and on terminal resize. Enables analytics, logging, and dynamic UI changes.  
4. **Spec** – Runtime registration API:

```powershell
Register-SCHook -Event OnBeforeRender -Scope Global -ScriptBlock { param($ctx) $ctx.Debug = $true }
Register-SCHook -Event OnAfterSelect  -Scope Component -Id $menuId -ScriptBlock { param($ctx,$sel) Write-Verbose "Selected $sel" }
Register-SCHook -Event OnResize       -Scope Global -ScriptBlock { param($ctx,$size) $ctx.NeedsRerender = $true }
```

Config-driven hook loading (JSON points to ps1):
```json
{
  "hooks": {
    "OnCancel": [
      { "script": "~/.config/shell-controls/hooks.ps1", "function": "OnSCCancel" }
    ]
  }
}
```

Hook payloads:
- `OnBeforeRender($context, $renderNode)`
- `OnAfterRender($context, $renderNode)`
- `OnAfterSelect($context, $selection)`
- `OnCancel($context, $reason)`
- `OnResize($context, @{ Width=..., Height=... })`

Resize detection:
- Poll `Get-SCTerminalSize` each input loop iteration; if changed, fire `OnResize`.

5. **Dependencies** – Render loop; terminal size; config loader that can dot-source scripts safely.  
6. **Priority** – **High**

---

### Idea 19
1. **Name** – ConfigDrivenSafetyAndAudit  
2. **Category** – Hooks  
3. **Description** – Add behavior toggles like “confirm destructive actions,” “confirm before exit,” and an optional audit log of user choices.  
4. **Spec** – Config:

```json
{
  "behavior": {
    "confirmDestructiveActions": true,
    "confirmBeforeExit": false,
    "auditLog": {
      "enabled": true,
      "path": "~/.local/state/shell-controls/audit.log",
      "format": "jsonl"
    }
  }
}
```

Usage pattern:
- Components that delete/overwrite call:
```powershell
if (Test-SCDestructive -Action 'delete' -Target $path) {
  if (Confirm-SCAction -Text "Delete $path?" -Danger) { ... }
}
```

Audit log entry (JSONL):
```json
{"ts":"2026-01-23T18:22:01Z","component":"Show-SCMenu","action":"select","value":"prod","runner":"deploy.ps1"}
```

5. **Dependencies** – Confirm dialog snippet (see snippets idea), file IO, hooks/action registry.  
6. **Priority** – **Medium**

---

## 5) Terminal Compatibility & Output Control

### Idea 20
1. **Name** – TerminalCapabilitiesDetectionAndFallback  
2. **Category** – Terminal  
3. **Description** – Detect ANSI, truecolor, Unicode/box drawing, cursor addressing, and reduce features gracefully when missing. Avoid “broken UI” in limited shells.  
4. **Spec** – Core: `src/pwsh/core/Terminal.ps1`

```powershell
$caps = Get-SCCapabilities
# returns:
@{
  Ansi = $true
  TrueColor = $true
  Unicode = $true
  CursorAddressing = $true
  Mouse = $false
  ResizeEvents = $false
}
```

Heuristics (practical + non-blocking):
- `Ansi`: `$Host.UI.SupportsVirtualTerminal` when available; else assume on non-Windows; allow override `SC_FORCE_ANSI=1/0`.
- `TrueColor`: `$env:COLORTERM -match 'truecolor|24bit'` OR `$env:WT_SESSION` present; override `SC_TRUECOLOR=1/0`.
- `Unicode`: test if box glyph round-trips with output encoding; else `false`.
- `CursorAddressing`: if ANSI and not in “dumb” terminal (`$env:TERM -eq 'dumb'`) → true.

Fallback policy:
- If no ANSI → force `output.mode=plain`, disable gradients, disable cursor moves.
- If no Unicode → use ASCII border set, simpler symbols.
- If no truecolor → map hex to nearest 16-color / 256-color (add `Convert-SCHexToAnsi256`).

5. **Dependencies** – Output mode system; theme token mapping; border presets.  
6. **Priority** – **Must-have**

---

### Idea 21
1. **Name** – OutputModesPlainJsonQuiet  
2. **Category** – Terminal  
3. **Description** – A unified output mode switch that changes every component behavior: full ANSI UI, plain text, structured JSON, or quiet mode. Critical for CI and scripting.  
4. **Spec** – Config + env + CLI convention:

Config:
```json
{ "output": { "mode": "ansi" } }   // "ansi"|"plain"|"json"|"quiet"
```

Env override:
- `SC_OUTPUT_MODE=plain|json|quiet|ansi`

Runtime:
```powershell
Set-SCOutputMode -Mode Json
```

Component contract:
- Every interactive component returns a structured object (even in ANSI mode), but:
  - **ansi**: renders UI + returns object
  - **plain**: renders minimal text (no ANSI/cursor), returns object
  - **json**: *does not render UI*; returns object only (or writes JSON if used as CLI runner)
  - **quiet**: renders nothing; returns object

Example return object from menu:
```powershell
[pscustomobject]@{
  Component = 'Menu'
  Selected = @('dev','prod')
  SelectedIndexes = @(0,1)
  Cancelled = $false
}
```

5. **Dependencies** – Central output mode getter; all components respect it.  
6. **Priority** – **High**

---

### Idea 22
1. **Name** – OutputCaptureReplayBuffer  
2. **Category** – Terminal  
3. **Description** – Optional capture of “what would be rendered” for testing, snapshots, and replay in bug reports—without requiring a real terminal.  
4. **Spec** – API:

```powershell
Enable-SCOutputCapture -Mode RenderNodes   # or 'AnsiStrings'|'PlainStrings'
... run UI ...
$buf = Get-SCCaptureBuffer
Disable-SCOutputCapture
```

Capture buffer structure:
- If `RenderNodes`: array of render trees (PSCustomObject nodes)
- If `AnsiStrings`: array of strings containing ANSI sequences
- If `PlainStrings`: array of plain lines

Implementation approach (minimal invasive):
- Route all writes through `Write-SC*` functions.
- In `Write-SCRender`, if capture enabled:
  - append to buffer
  - optionally skip actual writing if `-CaptureOnly`

Add `Export-SCCapture -Path test.snap.json` for snapshot tests.

5. **Dependencies** – Centralized rendering pipeline (`Write-SCText`, `Write-SCPanel`, etc.); pass-through render node representation.  
6. **Priority** – **High**

---

## 6) Extensibility & Composition

### Idea 23
1. **Name** – CustomComponentContractRenderNodes  
2. **Category** – Extensibility  
3. **Description** – Let user scripts build “Shell-Controls style” components by returning render nodes that the core renderer can measure, align, and output consistently.  
4. **Spec** – Define a render node convention:

```powershell
New-SCRenderNode -Type 'panel' -Props @{
  Title = "Hello"
  Style = "card"
  Layout = @{ Padding=1; MaxWidth=60 }
} -Children @(
  New-SCRenderNode -Type 'text' -Props @{ Text="World"; Style="textStyles.caption" }
)
```

Core API:
- `New-SCRenderNode`
- `Measure-SCRenderNode -Width $w`
- `Render-SCRenderNode -Width $w -Capabilities $caps`

User component example:
```powershell
function Show-MyWidget {
  param([string]$Name)
  New-SCRenderNode -Type 'card' -Props @{ Title="Widget"; } -Children @(
    New-SCRenderNode -Type 'text' -Props @{ Text="Name: $Name"; Style='textStyles.code' }
  )
}
```

5. **Dependencies** – Render-tree renderer + measurement; theme tokens/styles.  
6. **Priority** – **High**

---

### Idea 24
1. **Name** – PluggableThemesImportPathUrl  
2. **Category** – Extensibility  
3. **Description** – Load themes from disk (and optionally URL), validate schema/version, and allow overriding bundled themes by name with precedence rules.  
4. **Spec** – Commands:

```powershell
Import-SCTheme -Path "~/.config/shell-controls/themes/mytheme.json" -Name "mytheme"
Import-SCTheme -Uri  "https://example.com/theme.json" -Name "corp"
Get-SCTheme -List
Set-SCTheme -Name "corp"
```

Precedence:
1) runtime `Set-SCTheme -Override/-Merge*`
2) user themes (`~/.config/.../themes`)
3) project-local themes (`./.shell-controls/themes`)
4) bundled themes

Validation:
- Require `name`, `version`, and either `tokens` or legacy `colors`
- If invalid: warn + refuse to activate; keep current theme

Optional: `Export-SCThemeSchema -Path theme.schema.json` (basic JSON schema) for editor tooling.

5. **Dependencies** – JSON loader; optional HTTP (`Invoke-RestMethod`); schema validator (lightweight).  
6. **Priority** – **Medium**

---

### Idea 25
1. **Name** – ReusableSnippetsTemplates  
2. **Category** – Extensibility  
3. **Description** – Provide a small set of reusable UI “snippets” that standardize common flows across scripts: confirm dialog, status line, two-column layout.  
4. **Spec** – Add these functions (components or helpers):

**A) Confirm dialog**
```powershell
Confirm-SCAction -Text "Delete all artifacts?" -Danger -DefaultNo
# returns $true/$false
```
Theme keys: `components.confirm.*` (danger style, button styles)

**B) Status line (sticky footer)**
```powershell
Show-SCStatusLine -Left { "Env: $env" } -Right { (Get-Date).ToString("T") } -RefreshMs 250
```
Behavior: re-render line at bottom using cursor save/restore if supported; else prints periodically.

**C) Two-column layout**
```powershell
Show-SCTwoColumn -Left { Show-SCMenu ... } -Right { Show-SCPanel ... } -Split 0.4 -Gap 2
```
Responsive: below width breakpoint → stack vertically.

5. **Dependencies** – Layout engine; cursor addressing; responsive rules.  
6. **Priority** – **High**

---

## 7) Testing, Docs & Developer Experience

### Idea 26
1. **Name** – TestModePassThruNoInputProviders  
2. **Category** – Testing/Docs  
3. **Description** – Make interactive components testable by returning render trees (`-PassThru`), supporting a dry-run mode, and allowing injected input providers for deterministic tests.  
4. **Spec** – Standard switches across interactive components:
- `-PassThru` → return render node(s) + result object
- `-NoInput` → do not read `[Console]`; use defaults or first options
- `-InputProvider` scriptblock → supplies key events

Example:
```powershell
$result = Show-SCMenu -Options @('a','b') -NoInput -PassThru
# $result.RenderTree + $result.Selected
```

Injected key stream:
```powershell
$keys = @('DownArrow','Enter')
Show-SCMenu -Options ... -InputProvider { $script:keys[0]; $script:keys = $script:keys[1..]; }
```

Pester-friendly:
- `Enable-SCOutputCapture -Mode RenderNodes`
- snapshot compare `Export-SCCapture` output

5. **Dependencies** – Output capture; key handling abstraction.  
6. **Priority** – **Must-have**

---

### Idea 27
1. **Name** – DiscoveryCommandsThemeConfigComponents  
2. **Category** – Testing/Docs  
3. **Description** – Add “tell me what exists and how to use it” commands that return structured objects (and render nicely) for discovery and tooling.  
4. **Spec** – Commands:

**A) Themes**
```powershell
Get-SCTheme -List
# returns objects: Name, Version, Source (Bundled/User/Project/Url), IsActive, Path
```

**B) Config schema**
```powershell
Get-SCConfig -Schema -As Json
# returns JSON schema-like object, including defaults and descriptions
```

**C) Components catalog**
```powershell
Show-SCComponents
# renders a table of component commands + synopsis + key params
Get-SCComponents
# returns structured list for docs generator
```

Implementation:
- Maintain a small manifest: `src/pwsh/components/components.manifest.json`
  - name, function, category, synopsis, examples, theme keys used

5. **Dependencies** – Manifest file; comment-based help introspection optional.  
6. **Priority** – **High**

---

### Idea 28
1. **Name** – GeneratedDocsMarkdownFromManifest  
2. **Category** – Testing/Docs  
3. **Description** – Generate Markdown docs for themes/config/components from a manifest and comment-based help, keeping docs accurate as features evolve.  
4. **Spec** – Build script: `tools/generate-docs.ps1`

Outputs:
- `docs/components.md` (table + per-component sections)
- `docs/config.md` (schema, defaults, examples)
- `docs/themes.md` (tokens/styles list + theme gallery list)

Generation sources:
1) `components.manifest.json`
2) `Get-Help <function> -Full` (comment-based help)
3) `Get-SCConfig -Schema` output
4) `Export-SCThemeSchema` output

Include:
- signature
- parameter descriptions
- config keys and defaults
- theme keys used by component

5. **Dependencies** – Manifest + discovery commands; build pipeline.  
6. **Priority** – **Medium**

---

# Quick wins (≤5, high impact / low risk)
1. **RuntimeThemeOverridesAndSnippets** (Idea 3) – immediate value, minimal refactor.  
2. **UnifiedLayoutOptions** (Idea 10) – reduces future component complexity drastically.  
3. **OutputModesPlainJsonQuiet** (Idea 21) – makes Shell-Controls CI/script-friendly overnight.  
4. **TypedInputValidators** (Idea 12) – quickly upgrades UX and reliability for runners.  
5. **DiscoveryCommandsThemeConfigComponents** (Idea 27) – huge DX improvement with small surface area.

---

# Defer list (valuable, but not worth it yet)
- **Full mouse support** (click menus, hover tooltips): great, but high complexity + terminal variance.  
- **True VT resize events** (platform-specific event handling): polling is good enough initially.  
- **Remote theme gallery/registry** (search, install, update): do later once schema stabilizes.  
- **Rich text editor input** (multi-line with syntax highlighting): powerful but a whole project by itself.  
- **Complex constraint-based layout engine** (like CSS flexbox): keep it simple with Stack/Grid + responsive rules.

--- 

If you implement only four things first—**Theme v2 tokens/styles + unified layout + output modes + capture/test mode**—everything else becomes much easier to add without redesigning the core.