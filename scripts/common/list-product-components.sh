#!/usr/bin/env bash
set -euo pipefail

ROOT="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
LANGUAGE="${1:-de}"
LANGUAGES_FILE="$ROOT/i18n/languages.tsv"
COMPONENTS_FILE="$ROOT/i18n/product-components.tsv"

normalize_language() {
  printf '%s' "$1" | tr '[:upper:]_' '[:lower:]-'
}

normalized="$(normalize_language "$LANGUAGE")"
selected="de"
while IFS=$'\t' read -r code _native _english _role; do
  [[ "$code" == "code" ]] && continue
  lower_code="$(normalize_language "$code")"
  if [[ "$normalized" == "$lower_code" || "$normalized" == "$lower_code"-* ]]; then
    selected="$code"
    break
  fi
done < "$LANGUAGES_FILE"
case "$normalized" in
  zh|zh-cn|zh-hans) selected="zh-Hans" ;;
esac

IFS=$'\t' read -r -a header < "$COMPONENTS_FILE"
selected_index=-1
for i in "${!header[@]}"; do
  if [[ "${header[$i]}" == "$selected" ]]; then
    selected_index="$i"
    break
  fi
done
if [[ "$selected_index" -lt 0 ]]; then
  echo "Sprache nicht im Produktkomponenten-Katalog: $selected" >&2
  exit 1
fi

awk -F '\t' -v idx="$((selected_index + 1))" -v lang="$selected" '
  NR == 1 { next }
  {
    component = $1
    field = $2
    value = $idx
    order[++line_count] = component "/" field
    values[component "/" field] = value
    if (!(component in seen_component)) {
      seen_component[component] = 1
      component_order[++component_count] = component
    }
  }
  END {
    printf "# Product components (%s)\n\n", lang
    printf "| id | name | summary |\n"
    printf "| --- | --- | --- |\n"
    for (i = 1; i <= component_count; i++) {
      component = component_order[i]
      printf "| `%s` | %s | %s |\n", component, values[component "/name"], values[component "/summary"]
    }
  }
' "$COMPONENTS_FILE"
