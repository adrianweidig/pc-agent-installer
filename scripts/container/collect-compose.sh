#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-compose-baseline.md}"
{
  echo "# Docker Compose Baseline"
  echo
  echo "## Version"
  echo '```text'
  docker compose version 2>&1 || true
  echo '```'
  echo
  echo "## Compose-Dateien"
  echo '```text'
  find "${2:-.}" -type f \( -name 'compose.yaml' -o -name 'compose.yml' -o -name 'docker-compose.yaml' -o -name 'docker-compose.yml' \) 2>/dev/null
  echo '```'
  echo
  echo "Hinweis: .env-Inhalte werden nicht exportiert."
} > "$OUT"
echo "Erfasst: $OUT"
