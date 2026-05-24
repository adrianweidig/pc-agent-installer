#!/usr/bin/env bash
set -euo pipefail
if command -v dpkg >/dev/null 2>&1; then dpkg-query -W; elif command -v rpm >/dev/null 2>&1; then rpm -qa; elif command -v pacman >/dev/null 2>&1; then pacman -Q; else echo "Kein unterstützter Paketmanager gefunden"; fi
