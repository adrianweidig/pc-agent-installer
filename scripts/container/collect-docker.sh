#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-docker-baseline.md}"
{
  echo "# Docker Baseline"
  for cmd in "docker version" "docker info" "docker ps -a" "docker images" "docker network ls" "docker volume ls"; do
    echo
    echo "## $cmd"
    echo '```text'
    bash -lc "$cmd" 2>&1 || true
    echo '```'
  done
} > "$OUT"
echo "Erfasst: $OUT"
