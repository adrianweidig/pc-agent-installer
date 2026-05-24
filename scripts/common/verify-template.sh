#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

echo "==> Repo-Modus erkennen"
bash "$ROOT/scripts/common/detect-repo-mode.sh" "$ROOT"

echo "==> Template-Struktur validieren"
bash "$ROOT/scripts/common/validate-template.sh" "$ROOT"

echo "==> Bash-Skripte parsen"
while IFS= read -r file; do
  bash -n "$file"
done < <(find "$ROOT/scripts" -type f -name '*.sh')

echo "==> Secret-Pattern-Scan"
pattern='(AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{36,}|github_pat_[A-Za-z0-9_]+|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]+|-----BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----|password[[:space:]]*[:=]|passwd[[:space:]]*[:=]|api[_-]?key[[:space:]]*[:=]|secret[[:space:]]*[:=]|token[[:space:]]*[:=])'
if command -v rg >/dev/null 2>&1; then
  if rg -n --hidden -S "$pattern" -g '!LICENSE' -g '!.git/**' "$ROOT"; then
    echo "Mögliche Secret-Treffer gefunden." >&2
    exit 1
  elif [[ "$?" -gt 1 ]]; then
    echo "rg Secret-Scan fehlgeschlagen." >&2
    exit 1
  fi
else
  if grep -R -I -E "$pattern" --exclude-dir=.git --exclude=LICENSE "$ROOT"; then
    echo "Mögliche Secret-Treffer gefunden." >&2
    exit 1
  fi
fi

echo "==> Git-Diff-Whitespace prüfen"
if command -v git >/dev/null 2>&1; then
  git -C "$ROOT" diff --check
else
  echo "git nicht verfügbar, git diff --check übersprungen."
fi

echo "verify-template.sh erfolgreich."
