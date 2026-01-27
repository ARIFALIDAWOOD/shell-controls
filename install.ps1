#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Install Shell-Controls module for current user.
#>

$ErrorActionPreference = 'Stop'
$modName = 'Shell-Controls'
$src = Join-Path $PSScriptRoot "src\pwsh"
$dest = Join-Path $env:USERPROFILE "Documents\PowerShell\Modules\$modName"

if (-not (Test-Path $src)) {
    Write-Error "Source not found: $src"
}

$destDir = Join-Path $dest "1.0.0"
New-Item -ItemType Directory -Path $destDir -Force | Out-Null

Copy-Item -Path (Join-Path $src "*.ps*") -Destination $destDir -Force
Copy-Item -Path (Join-Path $src "core") -Destination (Join-Path $destDir "core") -Recurse -Force
Copy-Item -Path (Join-Path $src "components") -Destination (Join-Path $destDir "components") -Recurse -Force

$configDest = Join-Path $destDir "config"
New-Item -ItemType Directory -Path $configDest -Force | Out-Null
Copy-Item -Path (Join-Path $PSScriptRoot "config\*") -Destination $configDest -Recurse -Force

Write-Host "Installed $modName to $destDir"
Write-Host "Use: Import-Module $modName -Force"
