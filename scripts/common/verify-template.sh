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

echo "==> Bash-i18n testen"
bash "$ROOT/scripts/common/test-i18n.sh"

echo "==> Produktkomponenten-i18n validieren"
bash "$ROOT/scripts/common/validate-product-i18n.sh" "$ROOT"

echo "==> Deutsche UTF-8-Umlaute prüfen"
umlaut_pattern='(^|[^[:alnum:]_])(fuer|Fuer|fuehrt|Fuehrt|pruefen|Pruefen|prueft|Prueft|pruefung|Pruefung|geprueft|Geprueft|Aenderung|Aenderungen|aendern|aendert|bestaetigen|Bestaetigen|bestaetigt|Bestaetigt|beruecksichtigen|Beruecksichtigen|beruecksichtigt|Beruecksichtigt|zuruecksetzen|Zuruecksetzen|zurueckgesetzt|Zurueckgesetzt|ueberschreiben|Ueberschreiben|ueberschreibt|Ueberschreibt|koennen|Koennen|moeglich|Moeglich|ermoeglichen|Ermoeglichen|ermoeglicht|Ermoeglicht|vollstaendig|Vollstaendig|vollstaendige|Vollstaendige|geloescht|Geloescht|loeschen|Loeschen|loeschung|Loeschung|Datentraeger|Geraeteverschluesselung|Verschluesselung|Schluessel|Unterstuetzung|Oberflaeche|Konfliktloesung)([^[:alnum:]_]|$)'
if command -v rg >/dev/null 2>&1; then
  if rg -n --hidden -S "$umlaut_pattern" -g '*.md' -g '*.ps1' -g '*.sh' -g '*.yml' -g '*.yaml' -g '*.txt' -g '!.git/**' -g '!scripts/common/verify-template.*' "$ROOT"; then
    echo "ASCII-Umlaut-Schreibweisen in deutschem Text gefunden." >&2
    exit 1
  elif [[ "$?" -gt 1 ]]; then
    echo "rg Umlaut-Scan fehlgeschlagen." >&2
    exit 1
  fi
else
  if find "$ROOT" \( -path "$ROOT/.git" -o -path "$ROOT/LICENSE" \) -prune -o \
      -type f \( -name '*.md' -o -name '*.ps1' -o -name '*.sh' -o -name '*.yml' -o -name '*.yaml' -o -name '*.txt' \) ! -path "$ROOT/scripts/common/verify-template.*" \
      -print0 | xargs -0 grep -I -E "$umlaut_pattern"; then
    echo "ASCII-Umlaut-Schreibweisen in deutschem Text gefunden." >&2
    exit 1
  fi
fi

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
