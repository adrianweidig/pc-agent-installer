#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
missing=0
for path in AGENTS.md README.md LICENSE repo-mode.yaml schemas/host.schema.yaml scripts/common/detect-repo-mode.sh hosts/.gitkeep; do
  if [[ ! -e "$ROOT/$path" ]]; then
    echo "Fehlt: $path" >&2
    missing=1
  fi
done
if find "$ROOT/hosts" -mindepth 1 -maxdepth 1 ! -name .gitkeep | grep -q .; then
  echo "hosts/ enthält Hostdaten; Template muss leer bleiben." >&2
  missing=1
fi
count="$(find "$ROOT/Vorlage" -type f -name '*.md' | wc -l | tr -d ' ')"
echo "template_file_count=$count"
exit "$missing"
