#!/usr/bin/env bash
set -euo pipefail
if command -v ufw >/dev/null 2>&1; then ufw status verbose; elif command -v firewall-cmd >/dev/null 2>&1; then firewall-cmd --list-all; elif command -v nft >/dev/null 2>&1; then nft list ruleset; else echo "Keine bekannte Firewall-CLI gefunden"; fi
