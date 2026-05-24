#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-swarm-baseline.md}"
{
  echo "# Docker Swarm Baseline"
  for cmd in "docker info --format '{{.Swarm.LocalNodeState}}'" "docker node ls" "docker service ls" "docker stack ls" "docker secret ls"; do
    echo
    echo "## $cmd"
    echo '```text'
    bash -lc "$cmd" 2>&1 || true
    echo '```'
  done
  echo
  echo "Secret-Werte werden nicht exportiert."
} > "$OUT"
echo "Erfasst: $OUT"
