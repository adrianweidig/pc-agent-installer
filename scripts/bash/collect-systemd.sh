#!/usr/bin/env bash
set -euo pipefail
if command -v systemctl >/dev/null 2>&1; then systemctl list-unit-files; else echo "systemctl nicht verfügbar"; fi
