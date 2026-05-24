#!/usr/bin/env bash
set -euo pipefail
if command -v ufw >/dev/null 2>&1; then
  ufw status verbose
elif command -v firewall-cmd >/dev/null 2>&1; then
  firewall-cmd --list-all
elif command -v nft >/dev/null 2>&1; then
  nft list ruleset
elif [[ -x /usr/libexec/ApplicationFirewall/socketfilterfw ]]; then
  /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
  /usr/libexec/ApplicationFirewall/socketfilterfw --listapps 2>/dev/null || true
elif command -v pfctl >/dev/null 2>&1; then
  pfctl -s info 2>/dev/null || true
  pfctl -sr 2>/dev/null || true
else
  echo "Keine bekannte Firewall-CLI gefunden"
fi
