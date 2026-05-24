#!/usr/bin/env bash
set -euo pipefail
if command -v systemctl >/dev/null 2>&1; then
  systemctl list-unit-files
elif command -v launchctl >/dev/null 2>&1; then
  launchctl list
else
  echo "systemctl oder launchctl nicht verfügbar"
fi
