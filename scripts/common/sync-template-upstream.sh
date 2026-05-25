#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
TEMPLATE_REMOTE_NAME="${TEMPLATE_REMOTE_NAME:-template}"
TEMPLATE_REMOTE_URL="${TEMPLATE_REMOTE_URL:-https://github.com/adrianweidig/pc-agent-installer.git}"
TEMPLATE_BRANCH="${TEMPLATE_BRANCH:-main}"
NO_COMMIT="${NO_COMMIT:-false}"

mode="$(bash "$SCRIPT_DIR/detect-repo-mode.sh" "$ROOT" | sed -n 's/.*"repo_mode":"\([^"]*\)".*/\1/p')"
if [[ "$mode" == "template" ]]; then
  echo "Dieses Skript ist für private operational- oder local-only-Klone gedacht. Im Template-Repo normales git pull origin main verwenden." >&2
  exit 10
fi

if [[ -n "$(git -C "$ROOT" status --porcelain)" ]]; then
  echo "Arbeitsbaum ist nicht sauber. Bitte zuerst private Änderungen committen oder bewusst beiseitelegen." >&2
  exit 11
fi

repo_mode_path="$ROOT/repo-mode.yaml"
protected_repo_mode=""
if [[ -f "$repo_mode_path" ]]; then
  protected_repo_mode="$(cat "$repo_mode_path")"
fi

if ! git -C "$ROOT" remote get-url "$TEMPLATE_REMOTE_NAME" >/dev/null 2>&1; then
  git -C "$ROOT" remote add "$TEMPLATE_REMOTE_NAME" "$TEMPLATE_REMOTE_URL"
elif [[ "$(git -C "$ROOT" remote get-url "$TEMPLATE_REMOTE_NAME")" != "$TEMPLATE_REMOTE_URL" ]]; then
  git -C "$ROOT" remote set-url "$TEMPLATE_REMOTE_NAME" "$TEMPLATE_REMOTE_URL"
fi

git -C "$ROOT" fetch "$TEMPLATE_REMOTE_NAME" "$TEMPLATE_BRANCH" --tags
target_ref="$TEMPLATE_REMOTE_NAME/$TEMPLATE_BRANCH"
current="$(git -C "$ROOT" rev-parse HEAD)"
target="$(git -C "$ROOT" rev-parse "$target_ref")"
if [[ "$current" == "$target" ]]; then
  echo "Bereits auf aktuellem Template-Stand: $target_ref"
  exit 0
fi

set +e
git -C "$ROOT" merge --no-ff --no-commit "$target_ref"
merge_exit="$?"
set -e

if [[ -n "$protected_repo_mode" && -f "$repo_mode_path" && "$(cat "$repo_mode_path")" != "$protected_repo_mode" ]]; then
  printf '%s\n' "$protected_repo_mode" > "$repo_mode_path"
  git -C "$ROOT" add repo-mode.yaml
  echo "repo-mode.yaml wurde auf den privaten Operational-Modus zurückgesetzt."
fi

unmerged="$(git -C "$ROOT" diff --name-only --diff-filter=U)"
if [[ "$merge_exit" != "0" || -n "$unmerged" ]]; then
  cat >&2 <<'MESSAGE'
Template-Merge braucht manuelle Konfliktlösung.

Regeln:
- repo-mode.yaml muss operational oder local-only bleiben.
- hosts/ und private Secret-Referenzen nicht aus dem Template überschreiben.
- Nach der Konfliktlösung: git add <dateien> und git commit.
MESSAGE
  exit 20
fi

if [[ "$NO_COMMIT" == "true" ]]; then
  echo "Template-Merge ist vorbereitet, aber noch nicht committed."
  exit 0
fi

if [[ -z "$(git -C "$ROOT" diff --cached --name-only)" ]]; then
  echo "Keine Template-Änderungen zu committen."
  exit 0
fi

git -C "$ROOT" commit -m "chore: synchronisiere template-upstream"
echo "Template-Sync abgeschlossen. Push ins private origin bei Bedarf mit: git push origin main"
