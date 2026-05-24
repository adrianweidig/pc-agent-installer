#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <owner/template-repo> <owner/private-repo>" >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI gh ist nicht verfügbar." >&2
  exit 1
fi

gh repo create "$2" --template "$1" --private --clone
