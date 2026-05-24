[CmdletBinding()]
param([string]$OutputPath = 'container-baseline.md')

try {
    $collectorOutput = & {
        docker info --format "{{.Swarm.LocalNodeState}}"
    }
    $collectorOutput | Out-File -FilePath $OutputPath -Encoding utf8
} catch {
    $_.Exception.Message | Out-File -FilePath $OutputPath -Encoding utf8
}
Write-Host "Erfasst: $OutputPath"
