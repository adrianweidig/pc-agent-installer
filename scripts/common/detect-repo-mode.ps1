[CmdletBinding()]
param([string]$RepoRoot)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

. (Join-Path $PSScriptRoot '..\powershell\AgentInstaller.Common.ps1')
Get-AgentRepoGuard -RepoRoot $RepoRoot | ConvertTo-Json -Depth 5
