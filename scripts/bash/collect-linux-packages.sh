#!/usr/bin/env bash
set -euo pipefail
if command -v dpkg >/dev/null 2>&1; then
  dpkg-query -W
elif command -v rpm >/dev/null 2>&1; then
  rpm -qa
elif command -v pacman >/dev/null 2>&1; then
  pacman -Q
elif command -v brew >/dev/null 2>&1; then
  brew list --versions
elif command -v port >/dev/null 2>&1; then
  port installed
elif command -v pkgutil >/dev/null 2>&1; then
  pkgutil --pkgs
else
  echo "Kein unterstützter Paketmanager gefunden"
fi
