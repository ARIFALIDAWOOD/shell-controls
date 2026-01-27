<#
.SYNOPSIS
    Interactive menu system for Shell-Controls
#>

function Show-SCMenu {
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

    $menuItems = $Items | ForEach-Object {
        if ($_ -is [string]) {
            @{ Name = $_; Description = $null; Disabled = $false; Icon = $null }
        } elseif ($_ -is [hashtable]) {
            @{
                Name        = $_.Name ?? $_.Label ?? $_.Text ?? $_
                Description = $_.Description ?? $_.Desc ?? $null
                Disabled    = $_.Disabled ?? $false
                Icon        = $_.Icon ?? $null
            }
        } else {
            @{ Name = $_.ToString(); Description = $null; Disabled = $false; Icon = $null }
        }
    }

    $selectedIndex = [Math]::Min($DefaultIndex, [Math]::Max(0, $menuItems.Count - 1))
    $startIndex = 0
    $displayCount = if ($PageSize -gt 0) { [Math]::Min($PageSize, $menuItems.Count) } else { $menuItems.Count }
    if ($displayCount -le 0) { $displayCount = $menuItems.Count }

    $primaryColor = Get-SCColor -Name "primary"
    $mutedColor = Get-SCColor -Name "muted"
    $accentColor = Get-SCColor -Name "accent"
    $textColor = Get-SCColor -Name "text"
    $pointer = Get-SCSymbol -Name "pointer"
    $box = Get-SCSymbol -Name "boxRounded"
    if (-not $box -or $box -isnot [hashtable]) {
        $box = @{ topLeft = "╭"; topRight = "╮"; bottomLeft = "╰"; bottomRight = "╯"; horizontal = "─"; vertical = "│" }
    }

    $script:menuRendered = $false
    $script:lastMenuHeight = 0

    [Console]::CursorVisible = $false

    try {
        while ($true) {
            if ($PageSize -gt 0 -and $menuItems.Count -gt 0) {
                if ($selectedIndex -lt $startIndex) { $startIndex = $selectedIndex }
                elseif ($selectedIndex -ge $startIndex + $displayCount) { $startIndex = [Math]::Max(0, $selectedIndex - $displayCount + 1) }
            }

            if ($script:menuRendered) {
                try {
                    [Console]::SetCursorPosition(0, [Console]::CursorTop - $script:lastMenuHeight)
                    for ($i = 0; $i -lt $script:lastMenuHeight; $i++) {
                        [Console]::WriteLine((" " * [Math]::Max(1, [Console]::WindowWidth)))
                    }
                    [Console]::SetCursorPosition(0, [Console]::CursorTop - $script:lastMenuHeight)
                } catch { }
            }

            $linesRendered = 0

            if ($Title) {
                Write-SCText ""
                $linesRendered++
                if ($Style -eq 'boxed' -and $box) {
                    $titleWidth = [Math]::Max($Title.Length + 4, 40)
                    $h = if ($box['horizontal']) { $box['horizontal'] } else { "─" }
                    Write-SCText -Text "$($box['topLeft'])$($h * ($titleWidth - 2))$($box['topRight'])" -Color $primaryColor
                    Write-SCText -Text "$($box['vertical']) $Title$(' ' * ($titleWidth - $Title.Length - 3))$($box['vertical'])" -Color $primaryColor -Bold
                    Write-SCText -Text "$($box['bottomLeft'])$($h * ($titleWidth - 2))$($box['bottomRight'])" -Color $primaryColor
                    $linesRendered += 3
                } else {
                    Write-SCText -Text $Title -Color $primaryColor -Bold
                    $linesRendered++
                }
            }

            if ($Description) {
                Write-SCText -Text "  $Description" -Color $mutedColor
                $linesRendered++
            }

            Write-SCText ""
            $linesRendered++

            $endIdx = [Math]::Min($startIndex + $displayCount - 1, $menuItems.Count - 1)
            $visibleItems = @($menuItems[$startIndex..$endIdx])
            $visibleIndex = 0

            foreach ($item in $visibleItems) {
                $actualIndex = $startIndex + $visibleIndex
                $isSelected = ($actualIndex -eq $selectedIndex)
                $isDisabled = $item.Disabled

                $prefix = if ($isSelected) { "  $pointer " } else { "    " }
                $itemText = $item.Name
                $icon = if ($item.Icon) { "$($item.Icon) " } else { "" }

                $color = if ($isDisabled) { $mutedColor } elseif ($isSelected) { $accentColor } else { $textColor }
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

            if ($PageSize -gt 0 -and $menuItems.Count -gt $PageSize) {
                Write-SCText ""
                $linesRendered++
                $up = Get-SCSymbol -Name 'arrowUp'; $dn = Get-SCSymbol -Name 'arrowDown'
                if (-not $up) { $up = "↑" }; if (-not $dn) { $dn = "↓" }
                Write-SCText -Text "  $up$dn ($($selectedIndex + 1)/$($menuItems.Count))" -Color $mutedColor
                $linesRendered++
            }

            if ($ShowHelp) {
                Write-SCText ""
                $linesRendered++
                $helpText = "  ↑/↓ Navigate  •  Enter Select"
                if ($AllowCancel) { $helpText += "  •  Esc Cancel" }
                Write-SCText -Text $helpText -Color $mutedColor
                $linesRendered++
            }

            $script:menuRendered = $true
            $script:lastMenuHeight = $linesRendered

            $key = [Console]::ReadKey($true)

            switch ($key.Key) {
                'UpArrow' {
                    do {
                        $selectedIndex = ($selectedIndex - 1 + $menuItems.Count) % [Math]::Max(1, $menuItems.Count)
                    } while ($menuItems[$selectedIndex].Disabled -and $menuItems.Count -gt 1)
                }
                'DownArrow' {
                    do {
                        $selectedIndex = ($selectedIndex + 1) % [Math]::Max(1, $menuItems.Count)
                    } while ($menuItems[$selectedIndex].Disabled -and $menuItems.Count -gt 1)
                }
                'Home' {
                    $selectedIndex = 0
                    while ($selectedIndex -lt $menuItems.Count - 1 -and $menuItems[$selectedIndex].Disabled) { $selectedIndex++ }
                }
                'End' {
                    $selectedIndex = $menuItems.Count - 1
                    while ($selectedIndex -gt 0 -and $menuItems[$selectedIndex].Disabled) { $selectedIndex-- }
                }
                'Enter' {
                    if (-not $menuItems[$selectedIndex].Disabled) {
                        [Console]::CursorVisible = $true
                        $script:menuRendered = $false
                        Write-SCText ""
                        if ($ReturnIndex) { return $selectedIndex }
                        return $Items[$selectedIndex]
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

            if ($key.KeyChar -eq 'j') {
                do {
                    $selectedIndex = ($selectedIndex + 1) % [Math]::Max(1, $menuItems.Count)
                } while ($menuItems[$selectedIndex].Disabled -and $menuItems.Count -gt 1)
            } elseif ($key.KeyChar -eq 'k') {
                do {
                    $selectedIndex = ($selectedIndex - 1 + $menuItems.Count) % [Math]::Max(1, $menuItems.Count)
                } while ($menuItems[$selectedIndex].Disabled -and $menuItems.Count -gt 1)
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

    $menuItems = $Items | ForEach-Object {
        if ($_ -is [string]) { @{ Name = $_; Disabled = $false } }
        else { @{ Name = $_.Name ?? $_.ToString(); Disabled = $_.Disabled ?? $false } }
    }

    $selected = @{}
    foreach ($i in $DefaultSelected) { $selected[$i] = $true }

    $currentIndex = 0
    $startIndex = 0
    $displayCount = if ($PageSize -gt 0) { [Math]::Min($PageSize, $menuItems.Count) } else { $menuItems.Count }
    if ($displayCount -le 0) { $displayCount = $menuItems.Count }

    $primaryColor = Get-SCColor -Name "primary"
    $successColor = Get-SCColor -Name "success"
    $mutedColor = Get-SCColor -Name "muted"
    $textColor = Get-SCColor -Name "text"
    $pointer = Get-SCSymbol -Name "pointer"
    $checkboxOn = Get-SCSymbol -Name "checkboxOn"
    $checkboxOff = Get-SCSymbol -Name "checkboxOff"
    if (-not $checkboxOn) { $checkboxOn = "☑" }; if (-not $checkboxOff) { $checkboxOff = "☐" }

    $script:multiSelectRendered = $false
    $script:lastMultiSelectHeight = 0
    [Console]::CursorVisible = $false

    try {
        while ($true) {
            if ($PageSize -gt 0) {
                if ($currentIndex -lt $startIndex) { $startIndex = $currentIndex }
                elseif ($currentIndex -ge $startIndex + $displayCount) { $startIndex = [Math]::Max(0, $currentIndex - $displayCount + 1) }
            }

            if ($script:multiSelectRendered) {
                try {
                    [Console]::SetCursorPosition(0, [Console]::CursorTop - $script:lastMultiSelectHeight)
                    for ($i = 0; $i -lt $script:lastMultiSelectHeight; $i++) {
                        [Console]::WriteLine((" " * [Math]::Max(1, [Console]::WindowWidth)))
                    }
                    [Console]::SetCursorPosition(0, [Console]::CursorTop - $script:lastMultiSelectHeight)
                } catch { }
            }

            $linesRendered = 0
            if ($Title) { Write-SCText ""; Write-SCText -Text $Title -Color $primaryColor -Bold; $linesRendered += 2 }
            if ($Description) { Write-SCText -Text "  $Description" -Color $mutedColor; $linesRendered++ }
            Write-SCText ""; $linesRendered++

            $endIdx = [Math]::Min($startIndex + $displayCount - 1, $menuItems.Count - 1)
            $visibleItems = @($menuItems[$startIndex..$endIdx])
            $vi = 0
            foreach ($item in $visibleItems) {
                $actualIndex = $startIndex + $vi
                $isSelected = ($actualIndex -eq $currentIndex)
                $isChecked = $selected.ContainsKey($actualIndex)
                $cursor = if ($isSelected) { $pointer } else { " " }
                $checkbox = if ($isChecked) { $checkboxOn } else { $checkboxOff }
                $checkColor = if ($isChecked) { $successColor } else { $mutedColor }
                $color = if ($item.Disabled) { $mutedColor } elseif ($isSelected) { $primaryColor } else { $textColor }
                $reset = Get-AnsiReset
                $cursorAnsi = ConvertTo-AnsiColor -HexColor $primaryColor
                $checkAnsi = ConvertTo-AnsiColor -HexColor $checkColor
                $textAnsi = ConvertTo-AnsiColor -HexColor $color
                [Console]::WriteLine("  ${cursorAnsi}${cursor}${reset} ${checkAnsi}${checkbox}${reset} ${textAnsi}$($item.Name)${reset}")
                $linesRendered++
                $vi++
            }

            Write-SCText ""
            Write-SCText -Text "  Selected: $($selected.Count)  |  Space: Toggle  •  Enter: Confirm  •  A: All  •  N: None" -Color $mutedColor
            $linesRendered += 2

            $script:multiSelectRendered = $true
            $script:lastMultiSelectHeight = $linesRendered

            $key = [Console]::ReadKey($true)

            switch ($key.Key) {
                'UpArrow' { $currentIndex = ($currentIndex - 1 + $menuItems.Count) % [Math]::Max(1, $menuItems.Count) }
                'DownArrow' { $currentIndex = ($currentIndex + 1) % [Math]::Max(1, $menuItems.Count) }
                'Spacebar' {
                    if (-not $menuItems[$currentIndex].Disabled) {
                        if ($selected.ContainsKey($currentIndex)) { $selected.Remove($currentIndex) }
                        else {
                            if ($MaxSelection -eq 0 -or $selected.Count -lt $MaxSelection) { $selected[$currentIndex] = $true }
                        }
                    }
                }
                'Enter' {
                    if ($selected.Count -ge $MinSelection) {
                        [Console]::CursorVisible = $true
                        $script:multiSelectRendered = $false
                        Write-SCText ""
                        $indices = $selected.Keys | Sort-Object
                        if ($ReturnIndices) { return $indices }
                        return $indices | ForEach-Object { $Items[$_] }
                    }
                }
                'Escape' {
                    [Console]::CursorVisible = $true
                    $script:multiSelectRendered = $false
                    return $null
                }
            }

            if ($key.KeyChar -eq 'a' -or $key.KeyChar -eq 'A') {
                for ($i = 0; $i -lt $menuItems.Count; $i++) {
                    if (-not $menuItems[$i].Disabled) {
                        if ($MaxSelection -eq 0 -or $selected.Count -lt $MaxSelection) { $selected[$i] = $true }
                    }
                }
            } elseif ($key.KeyChar -eq 'n' -or $key.KeyChar -eq 'N') { $selected.Clear() }
        }
    } finally {
        [Console]::CursorVisible = $true
        $script:multiSelectRendered = $false
    }
}

function Show-SCRadioSelect {
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
        [switch]$AllowCancel
    )

    Show-SCMenu -Title $Title -Items $Items -Description $Description -DefaultIndex $DefaultIndex -ReturnIndex:$ReturnIndex -AllowCancel:$AllowCancel -Style simple
}

function Show-SCPaginated {
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
        [int]$PageSize = 10,

        [Parameter()]
        [switch]$ReturnIndex,

        [Parameter()]
        [switch]$AllowCancel
    )

    Show-SCMenu -Title $Title -Items $Items -Description $Description -DefaultIndex $DefaultIndex -ReturnIndex:$ReturnIndex -PageSize $PageSize -AllowCancel:$AllowCancel
}
