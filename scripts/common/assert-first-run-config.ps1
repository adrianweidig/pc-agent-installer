[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$HostName = $env:COMPUTERNAME
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}
if (-not $HostName) { $HostName = [System.Net.Dns]::GetHostName() }

$configPath = Join-Path $RepoRoot (Join-Path 'hosts' (Join-Path $HostName 'state/first-run-config.yaml'))
if ((Test-Path -LiteralPath $configPath) -and (Select-String -LiteralPath $configPath -Pattern '^\s*completed:\s*true\s*$' -Quiet)) {
    Write-Host "Erststart-Konfiguration vorhanden: $configPath"
    exit 0
}

$message = @"
ERSTSTART-KONFIGURATION NICHT ABGESCHLOSSEN

Der Agent darf noch keine Host-Baseline, Sicherheitsänderung, Installation oder Systemänderung ausführen.

Bitte zuerst ausführen:
  ./scripts/common/first-run-config.ps1

Agentischer Startsatz:
  Codex, starte die Agenten-Konfiguration für meinen PC.

Danach diesen Schritt erneut starten.
"@
Write-Error $message
exit 12
