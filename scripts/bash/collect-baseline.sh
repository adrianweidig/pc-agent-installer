#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent-installer-common.sh
source "$SCRIPT_DIR/agent-installer-common.sh"
ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"
HOSTNAME_VALUE="${HOSTNAME:-$(hostname)}"
agent_assert_host_write_allowed "$ROOT" >/dev/null

HOST_ROOT="$ROOT/hosts/$HOSTNAME_VALUE"
mkdir -p "$HOST_ROOT"/{baseline/raw,changes,rollback,security,container/docker,container/compose,container/swarm,container/kubernetes,container/podman,logs,state}
NOW="$(date -Iseconds)"
PLATFORM_JSON="$("$SCRIPT_DIR/detect-platform.sh")"

cat > "$HOST_ROOT/host.yaml" <<YAML
host_id: $HOSTNAME_VALUE
hostname: $HOSTNAME_VALUE
created_at: $NOW
last_seen_at: $NOW
repo:
  mode: local-or-operational
  visibility_checked: true
  allowed_to_write_hosts: true
platform:
  os: linux
  environment: $(printf '%s' "$PLATFORM_JSON" | sed -n 's/.*"environment":"\([^"]*\)".*/\1/p')
  architecture: "$(uname -m)"
template_paths_used:
  - Vorlage/common
  - Vorlage/linux/common
YAML

cat > "$HOST_ROOT/baseline/system.md" <<MD
# System-Baseline

- Erfasst am: $NOW
- Hostname: $HOSTNAME_VALUE
- Kernel: $(uname -a)
- Root: $(if [[ "$(id -u)" == "0" ]]; then echo ja; else echo nein; fi)
MD

cp /etc/os-release "$HOST_ROOT/baseline/raw/os-release.txt" 2>/dev/null || true
mount > "$HOST_ROOT/baseline/filesystem.md" 2>/dev/null || true
ip addr > "$HOST_ROOT/baseline/network.md" 2>/dev/null || true
systemctl list-unit-files > "$HOST_ROOT/baseline/services.md" 2>/dev/null || true
env | agent_redact > "$HOST_ROOT/baseline/environment.md"
cat > "$HOST_ROOT/security/secret-references.yaml" <<'YAML'
secrets: []
YAML
printf 'last_run_at: %s\nstatus: baseline_collected\n' "$NOW" > "$HOST_ROOT/state/last-run.yaml"
echo "Baseline erzeugt: $HOST_ROOT"
