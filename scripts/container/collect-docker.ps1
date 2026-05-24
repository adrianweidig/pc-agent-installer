[CmdletBinding()]
param([string]$OutputPath = 'docker-baseline.md')

$commands = @(
    @{ Title = 'docker version'; FilePath = 'docker'; ArgumentList = @('version') },
    @{ Title = 'docker info'; FilePath = 'docker'; ArgumentList = @('info') },
    @{ Title = 'docker ps -a'; FilePath = 'docker'; ArgumentList = @('ps', '-a') },
    @{ Title = 'docker images'; FilePath = 'docker'; ArgumentList = @('images') },
    @{ Title = 'docker network ls'; FilePath = 'docker'; ArgumentList = @('network', 'ls') },
    @{ Title = 'docker volume ls'; FilePath = 'docker'; ArgumentList = @('volume', 'ls') }
)
$parts = @('# Docker Baseline')
foreach ($cmd in $commands) {
    $parts += "`n## $($cmd.Title)`n```text"
    try { $parts += (& $cmd.FilePath @($cmd.ArgumentList) 2>&1 | Out-String) } catch { $parts += $_.Exception.Message }
    $parts += '```'
}
$parts -join "`n" | Out-File -FilePath $OutputPath -Encoding utf8
Write-Host "Erfasst: $OutputPath"
