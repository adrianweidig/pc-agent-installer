#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ARTIFACTS_DIR="$SCRIPT_DIR/artifacts"
REPORTS_DIR="$SCRIPT_DIR/reports"
IMAGE_NAME="${PC_AGENT_DEBIAN_FIRSTCONFIG_IMAGE:-pc-agent-installer-debian-firstconfig:local}"
CONTAINER_NAME="${PC_AGENT_DEBIAN_FIRSTCONFIG_CONTAINER:-pc-agent-installer-debian-firstconfig-$$}"
RUNTIME="${PC_AGENT_CONTAINER_RUNTIME:-docker}"

redact_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  sed -E -i \
    -e 's/(password|passwd|pwd|secret|token|api[_-]?key|credential|private[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:]]+/[REDACTED_SENSITIVE_VALUE]/Ig' \
    -e 's/Authorization:[[:space:]]*Bearer[[:space:]]+[^[:space:]]+/Authorization Bearer [REDACTED]/Ig' \
    "$file"
}

cleanup() {
  if [[ "${PC_AGENT_KEEP_DEBIAN_FIRSTCONFIG_CONTAINER:-false}" != "true" ]]; then
    "$RUNTIME" rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  fi
  if [[ "${PC_AGENT_KEEP_DEBIAN_FIRSTCONFIG_IMAGE:-false}" != "true" ]]; then
    "$RUNTIME" rmi "$IMAGE_NAME" >/dev/null 2>&1 || true
  fi
}

case "$(uname -s)" in
  Linux) ;;
  *)
    echo "Diese Testsuite muss in einer Linux- oder WSL-Shell laufen." >&2
    exit 2
    ;;
esac

if [[ "$RUNTIME" != "docker" && "$RUNTIME" != "podman" ]]; then
  echo "Nicht unterstützte Containerlaufzeit: $RUNTIME" >&2
  exit 2
fi

if ! command -v "$RUNTIME" >/dev/null 2>&1; then
  echo "Containerlaufzeit nicht gefunden: $RUNTIME" >&2
  exit 2
fi

if ! "$RUNTIME" info >/dev/null 2>&1; then
  echo "Containerlaufzeit ist nicht nutzbar: $RUNTIME" >&2
  exit 2
fi

mkdir -p "$ARTIFACTS_DIR" "$REPORTS_DIR"
rm -f "$ARTIFACTS_DIR"/*.log "$ARTIFACTS_DIR"/*.txt "$ARTIFACTS_DIR"/*.json "$REPORTS_DIR"/*.md

trap cleanup EXIT

"$RUNTIME" build -f "$SCRIPT_DIR/Dockerfile" -t "$IMAGE_NAME" "$ROOT" >"$ARTIFACTS_DIR/container-build.log" 2>&1
redact_file "$ARTIFACTS_DIR/container-build.log"

"$RUNTIME" rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
"$RUNTIME" create \
  --name "$CONTAINER_NAME" \
  --hostname debian-firstconfig-ci \
  --network bridge \
  --cap-add NET_ADMIN \
  --security-opt no-new-privileges \
  "$IMAGE_NAME" \
  python3 -m pytest -q tests/debian-firstconfig >"$ARTIFACTS_DIR/container-create.log" 2>&1
redact_file "$ARTIFACTS_DIR/container-create.log"

set +e
"$RUNTIME" start -a "$CONTAINER_NAME" >"$ARTIFACTS_DIR/pytest.log" 2>&1
test_status=$?
set -e
redact_file "$ARTIFACTS_DIR/pytest.log"

"$RUNTIME" cp "$CONTAINER_NAME:/test-output/." "$SCRIPT_DIR" >/dev/null 2>&1 || true

while IFS= read -r file; do
  redact_file "$file"
done < <(find "$ARTIFACTS_DIR" "$REPORTS_DIR" -type f \( -name '*.log' -o -name '*.txt' -o -name '*.json' -o -name '*.md' \))

exit "$test_status"
