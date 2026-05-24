[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$HostName = $env:COMPUTERNAME,
    [Parameter(Mandatory = $true)][string]$Area,
    [Parameter(Mandatory = $true)][string]$Summary,
    [ValidateSet('User','System','Repo','Container','Cluster')][string]$Layer = 'System',
    [ValidateSet('niedrig','mittel','hoch')][string]$Risk = 'niedrig',
    [ValidateSet('geplant','ausgeführt','fehlgeschlagen','rückgängig gemacht')][string]$Status = 'geplant'
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

. (Join-Path $PSScriptRoot 'AgentInstaller.Common.ps1')
$guard = Assert-AgentHostWriteAllowed -RepoRoot $RepoRoot
$hostRoot = New-AgentHostTree -RepoRoot $RepoRoot -HostName $HostName
$date = Get-Date -Format 'yyyy-MM-dd'
$existing = @(Get-ChildItem -LiteralPath (Join-Path $hostRoot 'changes') -Filter "$date*.md" -ErrorAction SilentlyContinue)
$seq = ('{0:0000}' -f ($existing.Count + 1))
$slug = ($Area.ToLowerInvariant() -replace '[^a-z0-9]+','-').Trim('-')
$path = Join-Path $hostRoot "changes/$date`_$seq`_$slug.md"
$content = @"
# Änderung: $Summary

## Metadaten
- Datum: $date
- Hostname: $HostName
- Repo-Modus: $($guard.repo_mode)
- Repo-Sichtbarkeit geprüft: $($guard.visibility_checked)
- Bereich: $Area
- Ebene: $Layer
- Risiko: $Risk
- Adminrechte erforderlich: nein
- Nutzerfreigabe erforderlich: nein
- Status: $Status

## Ausgangszustand
Noch zu dokumentieren.

## Infrastruktur-Snapshot
Noch zu dokumentieren. Vor Vollzug `assert-infrastructure-snapshot.ps1` ausführen oder aktuelle Baseline erzeugen.

## Zielzustand
Noch zu dokumentieren.

## Soll-Ist-Abgleich
- Soll: Noch zu dokumentieren.
- Ist: Noch zu dokumentieren.
- Abweichung: Noch zu dokumentieren.

## Duplikatprüfung
Noch zu dokumentieren. Prüfen, ob Software, Dienst, Paketquelle, Container, Port, Volume, WSL-Distribution oder Konfiguration bereits existiert.

## Lösch- und Seiteneffektprüfung
Noch zu dokumentieren. Unklare Nutzdaten, Volumes, Secrets, Projektordner und aktive Workspaces nicht löschen.

## Änderung
Noch nicht ausgeführt.

## Ort der Änderung
Noch zu dokumentieren.

## Ausgeführte Befehle
````powershell
# Noch keine Befehle dokumentiert.
````

## Betroffene Dateien
- Noch zu dokumentieren.

## Prüfung
Noch zu dokumentieren.

## Rollback
Noch zu dokumentieren.

## Risiken und Hinweise
Keine Klartext-Secrets aufnehmen.
"@
Write-AgentUtf8 -Path $path -Content $content
Write-Host "Change-Eintrag erzeugt: $path"
