[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$HostName = $env:COMPUTERNAME
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}
. (Join-Path $PSScriptRoot 'i18n.ps1')
$agentLanguage = Resolve-AgentLanguage
if (-not $HostName) { $HostName = [System.Net.Dns]::GetHostName() }

$configPath = Join-Path $RepoRoot (Join-Path 'hosts' (Join-Path $HostName 'state/first-run-config.yaml'))
if ((Test-Path -LiteralPath $configPath) -and (Select-String -LiteralPath $configPath -Pattern '^\s*completed:\s*true\s*$' -Quiet)) {
    Write-Host ((Get-AgentText -Key 'first_run_present' -Language $agentLanguage) -f $configPath)
    exit 0
}

$message = @"
$(Get-AgentText -Key 'first_run_missing_title' -Language $agentLanguage)

$(Get-AgentText -Key 'first_run_missing_body' -Language $agentLanguage)

$(Get-AgentText -Key 'first_run_missing_run' -Language $agentLanguage)
  ./scripts/common/first-run-config.ps1

$(Get-AgentText -Key 'first_run_missing_prompt' -Language $agentLanguage)
  Codex, starte die Agenten-Konfiguration für meinen PC.

$(Get-AgentText -Key 'first_run_missing_retry' -Language $agentLanguage)
"@
Write-Error $message
exit 12
