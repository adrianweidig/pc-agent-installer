#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../bash/agent-installer-common.sh
source "$SCRIPT_DIR/../bash/agent-installer-common.sh"
# shellcheck source=i18n.sh
source "$SCRIPT_DIR/i18n.sh"

ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"
HOSTNAME_VALUE="${HOSTNAME:-$(hostname)}"
agent_assert_host_write_allowed "$ROOT" >/dev/null

HOST_ROOT="$ROOT/hosts/$HOSTNAME_VALUE"
FIRST_RUN_CONFIG="$HOST_ROOT/state/first-run-config.yaml"
HOST_YAML="$HOST_ROOT/host.yaml"
BASELINE_ROOT="$HOST_ROOT/baseline"
LAST_RUN="$HOST_ROOT/state/last-run.yaml"
missing=()

for path in "$FIRST_RUN_CONFIG" "$HOST_YAML" "$BASELINE_ROOT" "$LAST_RUN"; do
  if [[ ! -e "$path" ]]; then missing+=("$path"); fi
done

if [[ -f "$FIRST_RUN_CONFIG" ]] && ! grep -Eq '^[[:space:]]*completed:[[:space:]]*true[[:space:]]*$' "$FIRST_RUN_CONFIG"; then
  missing+=("$FIRST_RUN_CONFIG completed:true")
fi

baseline_file_count=0
if [[ -d "$BASELINE_ROOT" ]]; then
  baseline_file_count="$(find "$BASELINE_ROOT" -type f | wc -l | tr -d ' ')"
  if [[ "$baseline_file_count" == "0" ]]; then
    missing+=("$BASELINE_ROOT enthält keine Baseline-Dateien")
  fi
fi

if [[ "${#missing[@]}" -gt 0 ]]; then
  printf '{\n'
  printf '  "ok": false,\n'
  printf '  "host": "%s",\n' "$HOSTNAME_VALUE"
  printf '  "host_root": "%s",\n' "$HOST_ROOT"
  printf '  "baseline_file_count": %s,\n' "$baseline_file_count"
  printf '  "missing": [\n'
  for i in "${!missing[@]}"; do
    comma=","
    [[ "$i" == "$((${#missing[@]} - 1))" ]] && comma=""
    printf '    "%s"%s\n' "${missing[$i]//\"/\\\"}" "$comma"
  done
  printf '  ],\n'
  printf '  "required_next_step": "%s"\n' "$(agent_msg snapshot_missing_next)"
  printf '}\n'
  agent_msg snapshot_missing_error >&2
  exit 20
fi

cat <<JSON
{
  "ok": true,
  "host": "$HOSTNAME_VALUE",
  "host_root": "$HOST_ROOT",
  "first_run_config": "$FIRST_RUN_CONFIG",
  "host_yaml": "$HOST_YAML",
  "baseline_file_count": $baseline_file_count,
  "required_next_step": "$(agent_msg snapshot_ok_next)"
}
JSON
