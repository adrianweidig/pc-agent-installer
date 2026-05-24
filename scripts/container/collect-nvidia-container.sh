#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-nvidia-container-baseline.md}"
{
  echo "# NVIDIA Container Baseline"
  for cmd in "nvidia-smi" "nvidia-ctk --version" "docker info" "podman info"; do
    echo
    echo "## $cmd"
    echo '```text'
    bash -lc "$cmd" 2>&1 || true
    echo '```'
  done
} > "$OUT"
echo "Erfasst: $OUT"
