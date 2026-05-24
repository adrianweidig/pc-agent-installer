[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$HostName = $env:COMPUTERNAME
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

. (Join-Path $PSScriptRoot 'AgentInstaller.Common.ps1')
$guard = Assert-AgentHostWriteAllowed -RepoRoot $RepoRoot
if (-not $HostName) { $HostName = [System.Net.Dns]::GetHostName() }
$hostRoot = New-AgentHostTree -RepoRoot $RepoRoot -HostName $HostName
$now = (Get-Date).ToString('o')
$platform = & (Join-Path $PSScriptRoot 'detect-platform.ps1') | ConvertFrom-Json

$hostYaml = @"
host_id: $HostName
hostname: $HostName
created_at: $now
last_seen_at: $now
repo:
  mode: $($guard.repo_mode)
  visibility_checked: $($guard.visibility_checked.ToString().ToLowerInvariant())
  visibility: $($guard.visibility)
  allowed_to_write_hosts: $($guard.allowed_to_write_hosts.ToString().ToLowerInvariant())
platform:
  os: $($platform.os)
  environment: $($platform.environment)
  version: $(ConvertTo-AgentYamlScalar $platform.windows.version)
  edition: $(ConvertTo-AgentYamlScalar $platform.windows.caption)
  architecture: $(ConvertTo-AgentYamlScalar $platform.architecture)
hardware:
  profile: $(ConvertTo-AgentYamlScalar $platform.hardware_profile)
container:
  docker: $([bool](Get-Command docker -ErrorAction SilentlyContinue)).ToString().ToLowerInvariant()
  docker_compose: false
  docker_swarm: false
  kubernetes: $([bool](Get-Command kubectl -ErrorAction SilentlyContinue)).ToString().ToLowerInvariant()
  podman: $([bool](Get-Command podman -ErrorAction SilentlyContinue)).ToString().ToLowerInvariant()
  nvidia_container_runtime: $([bool](Get-Command nvidia-ctk -ErrorAction SilentlyContinue)).ToString().ToLowerInvariant()
template_paths_used:
  - Vorlage/common
  - Vorlage/windows/common
"@
Write-AgentUtf8 -Path (Join-Path $hostRoot 'host.yaml') -Content $hostYaml

$system = @"
# System-Baseline

- Erfasst am: $now
- Hostname: $HostName
- Repo-Modus: $($guard.repo_mode)
- Repo-Sichtbarkeit: $($guard.visibility)
- Betriebssystem: $($platform.os)
- Architektur: $($platform.architecture)
- PowerShell: $($platform.powershell)
- Admin: $($platform.admin)
"@
Write-AgentUtf8 -Path (Join-Path $hostRoot 'baseline/system.md') -Content $system
Write-AgentUtf8 -Path (Join-Path $hostRoot 'baseline/hardware.md') -Content "# Hardware-Baseline`n`nProfil: $($platform.hardware_profile)"
Write-AgentUtf8 -Path (Join-Path $hostRoot 'baseline/security.md') -Content "# Sicherheits-Baseline`n`nKlartext-Secrets wurden nicht erfasst."
Write-AgentUtf8 -Path (Join-Path $hostRoot 'security/secret-references.md') -Content "# Secret-Referenzen`n`nNoch keine Secret-Referenzen dokumentiert."
Write-AgentUtf8 -Path (Join-Path $hostRoot 'security/secret-references.yaml') -Content "secrets: []"
Write-AgentUtf8 -Path (Join-Path $hostRoot 'state/last-run.yaml') -Content "last_run_at: $now`nstatus: baseline_collected"

try { systeminfo | Out-File -FilePath (Join-Path $hostRoot 'baseline/raw/systeminfo.txt') -Encoding utf8 } catch {}
try { Get-Service | Sort-Object Name | Out-String | Out-File -FilePath (Join-Path $hostRoot 'baseline/services.md') -Encoding utf8 } catch {}
try { Get-NetIPConfiguration | Out-String | Out-File -FilePath (Join-Path $hostRoot 'baseline/network.md') -Encoding utf8 } catch {}
try { Get-NetFirewallRule | Select-Object DisplayName,Enabled,Direction,Action,Profile | Out-String | Out-File -FilePath (Join-Path $hostRoot 'baseline/firewall.md') -Encoding utf8 } catch {}
try { Get-ChildItem Env: | Sort-Object Name | ForEach-Object { "$($_.Name)=[REDACTED]" } | Out-File -FilePath (Join-Path $hostRoot 'baseline/environment.md') -Encoding utf8 } catch {}

Write-Host "Baseline erzeugt: $hostRoot"
