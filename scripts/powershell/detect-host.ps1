[CmdletBinding()]
param()

& (Join-Path $PSScriptRoot 'detect-platform.ps1')
