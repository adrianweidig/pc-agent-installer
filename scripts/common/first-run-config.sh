#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../bash/agent-installer-common.sh
source "$SCRIPT_DIR/../bash/agent-installer-common.sh"

ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"
HOSTNAME_VALUE="${HOSTNAME:-$(hostname)}"
agent_assert_host_write_allowed "$ROOT" >/dev/null

HOST_ROOT="$ROOT/hosts/$HOSTNAME_VALUE"
mkdir -p "$HOST_ROOT/state"
CONFIG_PATH="$HOST_ROOT/state/first-run-config.yaml"
if [[ -f "$CONFIG_PATH" ]] && grep -Eq '^[[:space:]]*completed:[[:space:]]*true[[:space:]]*$' "$CONFIG_PATH"; then
  echo "Erststart-Konfiguration ist bereits abgeschlossen: $CONFIG_PATH"
  exit 0
fi

ask_yes_no() {
  local prompt="$1" default="$2" answer suffix
  if [[ "$default" == "true" ]]; then suffix="[J/n]"; else suffix="[j/N]"; fi
  while true; do
    printf '%s %s ' "$prompt" "$suffix" >&2
    read -r answer || answer=""
    if [[ -z "$answer" ]]; then printf '%s\n' "$default"; return 0; fi
    case "$answer" in
      j|J|ja|Ja|JA|y|Y|yes|Yes|YES) printf 'true\n'; return 0 ;;
      n|N|nein|Nein|NEIN|no|No|NO) printf 'false\n'; return 0 ;;
      *) echo "Bitte mit Ja oder Nein antworten." >&2 ;;
    esac
  done
}

echo "ERSTSTART-KONFIGURATION"
echo "Vor Abschluss dieser Konfiguration fuehrt der Agent keine Host-Arbeit aus."

allow_baseline="$(ask_yes_no 'Host-Baseline erfassen und dokumentieren?' true)"
allow_security_recommendations="$(ask_yes_no 'Usability-first Sicherheitsempfehlungen anzeigen?' true)"
allow_package_recommendations="$(ask_yes_no 'Kostenlose, aktuelle Tools und Updates empfehlen?' true)"
allow_optional_av="$(ask_yes_no 'Optionalen kostenlosen On-Demand-Malware-Scanner anbieten?' false)"
allow_blocklist_pilot="$(ask_yes_no 'DNS-/Host-Blocklisten nur im Pilotmodus anbieten?' false)"
allow_firewall_ip_blocklists="$(ask_yes_no 'IP-Firewall-Blocklisten als riskante Option anbieten?' false)"
windows_wsl_backend=false
windows_wsl_with_docker=false
windows_portainer_ui=false
windows_wsl_recommendations=false
if [[ "${OS:-}" == "Windows_NT" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
  windows_wsl_backend="$(ask_yes_no 'Windows/WSL: WSL-Backend fuer Linux-Tools vorbereiten oder beruecksichtigen?' false)"
  if [[ "$windows_wsl_backend" == "true" ]]; then
    windows_wsl_with_docker="$(ask_yes_no 'Windows/WSL: Docker mit WSL-Unterstuetzung einplanen?' false)"
    if [[ "$windows_wsl_with_docker" == "true" ]]; then
      windows_portainer_ui="$(ask_yes_no 'Windows/WSL: Portainer CE als Docker-Verwaltungsoberflaeche empfehlen?' false)"
    fi
    windows_wsl_recommendations=true
  fi
fi
require_confirmation_for_system_changes="$(ask_yes_no 'Vor systemwirksamen Aenderungen immer bestaetigen lassen?' true)"
printf 'Optionale Notiz fuer den Agenten: ' >&2
read -r note || note=""
note="$(printf '%s' "$note" | agent_redact | sed 's/"/\\"/g')"

cat > "$CONFIG_PATH" <<YAML
completed: true
configured_at: "$(date -Iseconds)"
configured_by: "first-run-config.sh"
ui: "shell"
host: "$HOSTNAME_VALUE"
preferences:
  allow_baseline: $allow_baseline
  allow_security_recommendations: $allow_security_recommendations
  allow_package_recommendations: $allow_package_recommendations
  allow_optional_av: $allow_optional_av
  allow_blocklist_pilot: $allow_blocklist_pilot
  allow_firewall_ip_blocklists: $allow_firewall_ip_blocklists
  windows_wsl_backend: $windows_wsl_backend
  windows_wsl_with_docker: $windows_wsl_with_docker
  windows_portainer_ui: $windows_portainer_ui
  windows_wsl_recommendations: $windows_wsl_recommendations
  require_confirmation_for_system_changes: $require_confirmation_for_system_changes
note: "$note"
YAML

echo "Erststart-Konfiguration gespeichert: $CONFIG_PATH"
