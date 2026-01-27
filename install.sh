#!/usr/bin/env bash
# Install Shell-Controls for bash (copies config; pwsh module is used via Import-Module from repo or install.ps1)

set -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Shell-Controls root: $ROOT"
echo "PowerShell module: $ROOT/src/pwsh/Shell-Controls.psd1"
echo "Use: Import-Module $ROOT/src/pwsh/Shell-Controls.psd1 -Force"
echo "Or run install.ps1 with pwsh for user module install."
