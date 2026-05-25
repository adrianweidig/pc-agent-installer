#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../bash/agent-installer-common.sh
source "$SCRIPT_DIR/../bash/agent-installer-common.sh"
# shellcheck source=i18n.sh
source "$SCRIPT_DIR/i18n.sh"

ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"
HOSTNAME_VALUE="${HOSTNAME:-$(hostname)}"
CONFIG_PATH="$ROOT/hosts/$HOSTNAME_VALUE/state/first-run-config.yaml"

if [[ -f "$CONFIG_PATH" ]] && grep -Eq '^[[:space:]]*completed:[[:space:]]*true[[:space:]]*$' "$CONFIG_PATH"; then
  printf "$(agent_msg first_run_present)\n" "$CONFIG_PATH"
  exit 0
fi

cat >&2 <<EOF
$(agent_msg first_run_missing_title)

$(agent_msg first_run_missing_body)

$(agent_msg first_run_missing_run)
  bash ./scripts/common/first-run-config.sh

$(agent_msg first_run_missing_prompt)
  Codex, starte die Agenten-Konfiguration für meinen PC.

$(agent_msg first_run_missing_retry)
EOF
exit 12
