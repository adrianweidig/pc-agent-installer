#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <command> [--approved]" >&2
  exit 2
fi
COMMAND="$1"
APPROVED="${2:-}"
if [[ "false" == "true" && "$APPROVED" != "--approved" ]]; then
  echo "validate-step benötigt explizite Freigabe mit --approved." >&2
  exit 1
fi
echo "Führe validate-step aus: $COMMAND"
bash -lc "$COMMAND"
