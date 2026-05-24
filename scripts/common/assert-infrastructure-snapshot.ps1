[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$HostName = $env:COMPUTERNAME
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

. (Join-Path $PSScriptRoot '..\powershell\AgentInstaller.Common.ps1')
$guard = Assert-AgentHostWriteAllowed -RepoRoot $RepoRoot
if (-not $HostName) { $HostName = [System.Net.Dns]::GetHostName() }

$hostRoot = Join-Path $RepoRoot (Join-Path 'hosts' $HostName)
$firstRunConfig = Join-Path $hostRoot 'state/first-run-config.yaml'
$hostYaml = Join-Path $hostRoot 'host.yaml'
$baselineRoot = Join-Path $hostRoot 'baseline'
$lastRun = Join-Path $hostRoot 'state/last-run.yaml'

$missing = [System.Collections.Generic.List[string]]::new()
foreach ($path in @($firstRunConfig, $hostYaml, $baselineRoot, $lastRun)) {
    if (-not (Test-Path -LiteralPath $path)) { $missing.Add($path) }
}

if ((Test-Path -LiteralPath $firstRunConfig) -and -not (Select-String -LiteralPath $firstRunConfig -Pattern '^\s*completed:\s*true\s*$' -Quiet)) {
    $missing.Add("$firstRunConfig completed:true")
}

$baselineFiles = @()
if (Test-Path -LiteralPath $baselineRoot) {
    $baselineFiles = @(Get-ChildItem -LiteralPath $baselineRoot -File -Recurse -ErrorAction SilentlyContinue)
    if ($baselineFiles.Count -eq 0) { $missing.Add("$baselineRoot enthält keine Baseline-Dateien") }
}

$result = [ordered]@{
    ok = ($missing.Count -eq 0)
    repo_mode = $guard.repo_mode
    visibility = $guard.visibility
    host = $HostName
    host_root = $hostRoot
    first_run_config = $firstRunConfig
    host_yaml = $hostYaml
    baseline_file_count = $baselineFiles.Count
    missing = @($missing)
    required_next_step = if ($missing.Count -eq 0) {
        'Soll-Ist-Abgleich im Change-Eintrag dokumentieren, dann Änderung nur mit Freigabe ausführen.'
    } else {
        'Erststart-Konfiguration und aktuelle Baseline ausführen, danach Soll-Ist-Abgleich dokumentieren.'
    }
}

$result | ConvertTo-Json -Depth 4
if (-not $result.ok) {
    Write-Error @"
Aktueller Infrastruktur-Snapshot fehlt oder ist unvollständig.
Der Agent darf im Vollzugriff keine Installation, Löschung, Dienst-, Firewall-, Container- oder Paketmanager-Änderung ausführen, bevor die aktuelle Umgebung geprüft und ein Soll-Ist-Abgleich dokumentiert wurde.

Empfohlener nächster Schritt:
  ./scripts/powershell/collect-baseline.ps1
"@
    exit 20
}
