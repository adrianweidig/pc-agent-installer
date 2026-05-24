#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../bash/agent-installer-common.sh
source "$SCRIPT_DIR/../bash/agent-installer-common.sh"

ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"
HOSTNAME_VALUE="${HOSTNAME:-$(hostname)}"
CONFIG_PATH="$ROOT/hosts/$HOSTNAME_VALUE/state/first-run-config.yaml"

if [[ -f "$CONFIG_PATH" ]] && grep -Eq '^[[:space:]]*completed:[[:space:]]*true[[:space:]]*$' "$CONFIG_PATH"; then
  echo "Erststart-Konfiguration vorhanden: $CONFIG_PATH"
  exit 0
fi

cat >&2 <<EOF
ERSTSTART-KONFIGURATION NICHT ABGESCHLOSSEN

Der Agent darf noch keine Host-Baseline, Sicherheitsänderung, Installation oder Systemänderung ausführen.

Bitte zuerst ausführen:
  bash ./scripts/common/first-run-config.sh

Danach diesen Schritt erneut starten.
EOF
exit 12
