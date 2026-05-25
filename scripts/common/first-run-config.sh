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
configuration_mode="first-run"
if [[ -f "$CONFIG_PATH" ]]; then
  configuration_mode="reconfigure"
fi

yaml_bool_default() {
  local key="$1" default="$2" value
  value=""
  if [[ -f "$CONFIG_PATH" ]]; then
    value="$(grep -E "^[[:space:]]+${key}:[[:space:]]*(true|false)[[:space:]]*$" "$CONFIG_PATH" | tail -n 1 | sed -E 's/.*:[[:space:]]*//; s/[[:space:]]*$//' || true)"
  fi
  case "$value" in
    true|false) printf '%s\n' "$value" ;;
    *) printf '%s\n' "$default" ;;
  esac
}

yaml_string_default() {
  local key="$1" default="$2" value
  value=""
  if [[ -f "$CONFIG_PATH" ]]; then
    value="$(sed -n -E "s/^[[:space:]]*${key}:[[:space:]]*\"(.*)\"[[:space:]]*$/\1/p" "$CONFIG_PATH" | tail -n 1 || true)"
  fi
  if [[ -n "$value" ]]; then
    printf '%s\n' "$value" | sed 's/\\"/"/g'
  else
    printf '%s\n' "$default"
  fi
}

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

ask_text() {
  local prompt="$1" default="$2" answer
  if [[ -n "$default" ]]; then
    printf '%s [%s] ' "$prompt" "$default" >&2
  else
    printf '%s ' "$prompt" >&2
  fi
  read -r answer || answer=""
  if [[ -z "$answer" ]]; then printf '%s\n' "$default"; else printf '%s\n' "$answer"; fi
}

echo "AGENTEN-KONFIGURATION"
if [[ "$configuration_mode" == "reconfigure" ]]; then
  echo "Bestehende Werte werden als Defaults genutzt. Leere Antworten behalten sie bei."
else
  echo "Vor Abschluss dieser Konfiguration führt der Agent keine Host-Arbeit aus."
fi

person_description="$(ask_text 'Beschreibe dich kurz für sinnvolle Programmempfehlungen, z. B. "Ich bin Entwickler":' "$(yaml_string_default person_description '')")"
allow_baseline="$(ask_yes_no 'Host-Baseline erfassen und dokumentieren?' "$(yaml_bool_default allow_baseline true)")"
allow_security_recommendations="$(ask_yes_no 'Usability-first Sicherheitsempfehlungen anzeigen?' "$(yaml_bool_default allow_security_recommendations true)")"
allow_package_recommendations="$(ask_yes_no 'Kostenlose, aktuelle Tools und Updates empfehlen?' "$(yaml_bool_default allow_package_recommendations true)")"
allow_update_maintenance="$(ask_yes_no 'Betriebssystem-, App- und Paketupdates prüfen?' "$(yaml_bool_default allow_update_maintenance true)")"
allow_package_source_audit="$(ask_yes_no 'Paketquellen, Stores und Dritt-Repositories prüfen?' "$(yaml_bool_default allow_package_source_audit true)")"
allow_disk_health_review="$(ask_yes_no 'Datenträgerzustand, Dateisystem und Speicherplatz prüfen?' "$(yaml_bool_default allow_disk_health_review true)")"
allow_encryption_recommendations="$(ask_yes_no 'Geräteverschlüsselung prüfen und empfehlen?' "$(yaml_bool_default allow_encryption_recommendations true)")"
allow_security_exception_review="$(ask_yes_no 'Security-Ausnahmen wie AV-Exclusions prüfen?' "$(yaml_bool_default allow_security_exception_review true)")"
allow_startup_service_review="$(ask_yes_no 'Autostart, Dienste und Hintergrundprozesse bewerten?' "$(yaml_bool_default allow_startup_service_review true)")"
allow_workspace_hygiene_review="$(ask_yes_no 'Workspace-Hygiene, Backups und Duplikate prüfen?' "$(yaml_bool_default allow_workspace_hygiene_review true)")"
allow_developer_toolchain_review="$(ask_yes_no 'Entwickler-Toolchains und Paketmanager bewerten?' "$(yaml_bool_default allow_developer_toolchain_review true)")"
allow_container_exposure_review="$(ask_yes_no 'Container-Ports, Volumes und Secrets prüfen?' "$(yaml_bool_default allow_container_exposure_review true)")"
allow_optional_av="$(ask_yes_no 'Optionalen kostenlosen On-Demand-Malware-Scanner anbieten?' "$(yaml_bool_default allow_optional_av false)")"
allow_blocklist_pilot="$(ask_yes_no 'DNS-/Host-Blocklisten nur im Pilotmodus anbieten?' "$(yaml_bool_default allow_blocklist_pilot false)")"
allow_firewall_ip_blocklists="$(ask_yes_no 'IP-Firewall-Blocklisten als riskante Option anbieten?' "$(yaml_bool_default allow_firewall_ip_blocklists false)")"
windows_wsl_backend="$(yaml_bool_default windows_wsl_backend false)"
windows_wsl_with_docker="$(yaml_bool_default windows_wsl_with_docker false)"
windows_portainer_ui="$(yaml_bool_default windows_portainer_ui false)"
windows_wsl_recommendations="$(yaml_bool_default windows_wsl_recommendations false)"
if [[ "${OS:-}" == "Windows_NT" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
  windows_wsl_backend="$(ask_yes_no 'Windows/WSL: WSL-Backend für Linux-Tools vorbereiten oder berücksichtigen?' "$windows_wsl_backend")"
  if [[ "$windows_wsl_backend" == "true" ]]; then
    windows_wsl_with_docker="$(ask_yes_no 'Windows/WSL: Docker mit WSL-Unterstützung einplanen?' "$windows_wsl_with_docker")"
    if [[ "$windows_wsl_with_docker" == "true" ]]; then
      windows_portainer_ui="$(ask_yes_no 'Windows/WSL: Portainer CE als Docker-Verwaltungsoberfläche empfehlen?' "$windows_portainer_ui")"
    else
      windows_portainer_ui=false
    fi
    windows_wsl_recommendations=true
  else
    windows_wsl_with_docker=false
    windows_portainer_ui=false
    windows_wsl_recommendations=false
  fi
fi
require_confirmation_for_system_changes="$(ask_yes_no 'Vor systemwirksamen Änderungen immer bestätigen lassen?' "$(yaml_bool_default require_confirmation_for_system_changes true)")"
note="$(ask_text 'Optionale Notiz für den Agenten:' "$(yaml_string_default note '')")"
person_description="$(printf '%s' "$person_description" | agent_redact | sed 's/"/\\"/g')"
note="$(printf '%s' "$note" | agent_redact | sed 's/"/\\"/g')"

cat > "$CONFIG_PATH" <<YAML
completed: true
configured_at: "$(date -Iseconds)"
configured_by: "first-run-config.sh"
configuration_mode: "$configuration_mode"
ui: "shell"
host: "$HOSTNAME_VALUE"
user_context:
  person_description: "$person_description"
preferences:
  allow_baseline: $allow_baseline
  allow_security_recommendations: $allow_security_recommendations
  allow_package_recommendations: $allow_package_recommendations
  allow_update_maintenance: $allow_update_maintenance
  allow_package_source_audit: $allow_package_source_audit
  allow_disk_health_review: $allow_disk_health_review
  allow_encryption_recommendations: $allow_encryption_recommendations
  allow_security_exception_review: $allow_security_exception_review
  allow_startup_service_review: $allow_startup_service_review
  allow_workspace_hygiene_review: $allow_workspace_hygiene_review
  allow_developer_toolchain_review: $allow_developer_toolchain_review
  allow_container_exposure_review: $allow_container_exposure_review
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
