#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <command> [--approved]" >&2
  exit 2
fi
COMMAND="$1"
APPROVED="${2:-}"
if [[ "true" == "true" && "$APPROVED" != "--approved" ]]; then
  echo "rollback-step benötigt explizite Freigabe mit --approved." >&2
  exit 1
fi
echo "Führe rollback-step aus: $COMMAND"
bash -lc "$COMMAND"
