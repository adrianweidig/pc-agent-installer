#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=i18n.sh
source "$SCRIPT_DIR/i18n.sh"

[[ "$(agent_resolve_language)" == "de" ]]
[[ "$(agent_resolve_language "en-US" "de")" == "en" ]]
[[ "$(agent_resolve_language "" "en_GB")" == "en" ]]
[[ "$(AGENT_LANGUAGE=de agent_msg allow_update_maintenance)" == *"prüfen"* ]]
[[ "$(AGENT_LANGUAGE=en agent_msg allow_update_maintenance)" == "Check operating system, app, and package updates?" ]]
[[ "$(AGENT_LANGUAGE=fr agent_msg allow_update_maintenance)" == *"prüfen"* ]]

echo "test-i18n.sh erfolgreich."
