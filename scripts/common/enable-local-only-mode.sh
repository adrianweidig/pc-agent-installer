#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../bash/agent-installer-common.sh
source "$SCRIPT_DIR/../bash/agent-installer-common.sh"
ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"

if [[ "$(git -C "$ROOT" remote | wc -l | tr -d ' ')" != "0" ]]; then
  echo "Local-only-Modus wird nicht aktiviert, solange Git-Remotes vorhanden sind. Remote nicht automatisch entfernen." >&2
  exit 1
fi

cat > "$ROOT/repo-mode.yaml" <<'YAML'
repo_mode: local-only
visibility_required: no_remote
allowed_to_write_hosts: true
allowed_to_document_sensitive_context: true
allowed_to_store_plaintext_secrets: false
YAML

echo "Local-only-Modus aktiviert. Push bleibt verboten, bis ein privater Remote geprüft wurde."
