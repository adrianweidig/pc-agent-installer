[CmdletBinding()]
param([string]$OutputPath = 'docker-baseline.md')

$commands = @(
    'docker version',
    'docker info',
    'docker ps -a',
    'docker images',
    'docker network ls',
    'docker volume ls'
)
$parts = @('# Docker Baseline')
foreach ($cmd in $commands) {
    $parts += "`n## $cmd`n```text"
    try { $parts += (Invoke-Expression $cmd | Out-String) } catch { $parts += $_.Exception.Message }
    $parts += '```'
}
$parts -join "`n" | Out-File -FilePath $OutputPath -Encoding utf8
Write-Host "Erfasst: $OutputPath"
