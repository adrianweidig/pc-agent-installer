#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-podman-baseline.md}"
{
  echo "# Podman Baseline"
  for cmd in "podman version" "podman info" "podman ps -a" "podman images" "podman network ls" "podman volume ls" "podman pod ls"; do
    echo
    echo "## $cmd"
    echo '```text'
    bash -lc "$cmd" 2>&1 || true
    echo '```'
  done
} > "$OUT"
echo "Erfasst: $OUT"
