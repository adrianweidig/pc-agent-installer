#!/usr/bin/env bash
set -euo pipefail
docker_available=false
compose_available=false
swarm_active=false
kubernetes_available=false
podman_available=false
nvidia_available=false

if command -v docker >/dev/null 2>&1; then
  docker_available=true
  if docker compose version >/dev/null 2>&1; then compose_available=true; fi
  if [[ "$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || true)" != "inactive" ]]; then swarm_active=true; fi
fi
if command -v kubectl >/dev/null 2>&1; then kubernetes_available=true; fi
if command -v podman >/dev/null 2>&1; then podman_available=true; fi
if command -v nvidia-ctk >/dev/null 2>&1 || command -v nvidia-smi >/dev/null 2>&1; then nvidia_available=true; fi

printf '{"detected_at":"%s","docker":%s,"docker_compose":%s,"docker_swarm":%s,"kubernetes":%s,"podman":%s,"nvidia_container_runtime":%s}\n' \
  "$(date -Iseconds)" "$docker_available" "$compose_available" "$swarm_active" "$kubernetes_available" "$podman_available" "$nvidia_available"
