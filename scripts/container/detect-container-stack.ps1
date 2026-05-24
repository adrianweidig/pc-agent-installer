[CmdletBinding()]
param()

$docker = [bool](Get-Command docker -ErrorAction SilentlyContinue)
$compose = $false
$swarm = $false
if ($docker) {
    try { docker compose version *> $null; $compose = $true } catch {}
    try {
        $swarmState = docker info --format '{{.Swarm.LocalNodeState}}' 2>$null
        $swarm = $swarmState -and $swarmState -ne 'inactive'
    } catch {}
}

[ordered]@{
    detected_at = (Get-Date).ToString('o')
    docker = $docker
    docker_compose = $compose
    docker_swarm = [bool]$swarm
    kubernetes = [bool](Get-Command kubectl -ErrorAction SilentlyContinue)
    podman = [bool](Get-Command podman -ErrorAction SilentlyContinue)
    nvidia_container_runtime = [bool](Get-Command nvidia-ctk -ErrorAction SilentlyContinue)
} | ConvertTo-Json -Depth 4
