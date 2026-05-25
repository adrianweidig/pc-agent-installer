#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
LANGUAGES_FILE="$ROOT/i18n/languages.tsv"
COMPONENTS_FILE="$ROOT/i18n/product-components.tsv"
required_languages=(de en es fr it pt nl pl tr ru zh-Hans ja)
errors=0

fail() {
  echo "$1" >&2
  errors=1
}

[[ -f "$LANGUAGES_FILE" ]] || fail "Datei fehlt: i18n/languages.tsv"
[[ -f "$COMPONENTS_FILE" ]] || fail "Datei fehlt: i18n/product-components.tsv"
[[ "$errors" -eq 0 ]] || exit 1

language_header="$(sed -n '1p' "$LANGUAGES_FILE")"
[[ "$language_header" == $'code\tnative_name\tenglish_name\trole' ]] || fail "i18n/languages.tsv hat einen ungültigen Header."

mapfile -t language_codes < <(awk -F '\t' 'NR > 1 && NF == 4 { print $1 }' "$LANGUAGES_FILE")
if [[ "${#language_codes[@]}" -lt 10 ]]; then
  fail "Es müssen mindestens zehn Produktsprachen definiert sein."
fi

for required in "${required_languages[@]}"; do
  found=0
  for code in "${language_codes[@]}"; do
    [[ "$code" == "$required" ]] && found=1
  done
  [[ "$found" -eq 1 ]] || fail "Pflichtsprache fehlt in i18n/languages.tsv: $required"
done

duplicate_language="$(printf '%s\n' "${language_codes[@]}" | sort | uniq -d | head -n 1)"
[[ -z "$duplicate_language" ]] || fail "Doppelter Sprachcode in i18n/languages.tsv: $duplicate_language"

awk -F '\t' '
  NR > 1 {
    if (NF != 4) {
      printf "Ungültige Spaltenzahl in i18n/languages.tsv:%d\n", NR > "/dev/stderr"
      bad = 1
    }
    for (i = 1; i <= NF; i++) {
      if ($i == "") {
        printf "Leerer Wert in i18n/languages.tsv:%d\n", NR > "/dev/stderr"
        bad = 1
      }
    }
    if ($1 !~ /^[a-z][a-z](-[A-Za-z]+)?$/) {
      printf "Ungültiger Sprachcode in i18n/languages.tsv:%d\n", NR > "/dev/stderr"
      bad = 1
    }
  }
  END { exit bad ? 1 : 0 }
' "$LANGUAGES_FILE" || errors=1

component_header="$(sed -n '1p' "$COMPONENTS_FILE")"
IFS=$'\t' read -r -a component_header_cols <<< "$component_header"
expected_columns=$((2 + ${#language_codes[@]}))
if [[ "${#component_header_cols[@]}" -ne "$expected_columns" ]]; then
  fail "i18n/product-components.tsv Header passt nicht zur Sprachliste."
fi
[[ "${component_header_cols[0]:-}" == "component_id" && "${component_header_cols[1]:-}" == "field" ]] || fail "i18n/product-components.tsv muss mit component_id und field beginnen."

for code in "${language_codes[@]}"; do
  found=0
  for header_code in "${component_header_cols[@]}"; do
    [[ "$header_code" == "$code" ]] && found=1
  done
  [[ "$found" -eq 1 ]] || fail "Sprache fehlt im Produktkomponenten-Header: $code"
done

awk -F '\t' -v expected="$expected_columns" '
  NR == 1 { next }
  {
    if (NF != expected) {
      printf "Ungültige Spaltenzahl in i18n/product-components.tsv:%d\n", NR > "/dev/stderr"
      bad = 1
      next
    }
    if ($1 !~ /^[a-z0-9_]+$/) {
      printf "Ungültige Produktkomponenten-ID in Zeile %d: %s\n", NR, $1 > "/dev/stderr"
      bad = 1
    }
    if ($2 != "name" && $2 != "summary") {
      printf "Ungültiges Feld in Zeile %d: %s\n", NR, $2 > "/dev/stderr"
      bad = 1
    }
    key = $1 "/" $2
    if (seen[key]) {
      printf "Doppelter Produktkomponenten-Eintrag: %s\n", key > "/dev/stderr"
      bad = 1
    }
    seen[key] = 1
    components[$1] = 1
    for (i = 3; i <= NF; i++) {
      if ($i == "") {
        printf "Leere Übersetzung in Zeile %d, Spalte %d\n", NR, i > "/dev/stderr"
        bad = 1
      }
    }
  }
  END {
    for (component in components) {
      if (!seen[component "/name"]) {
        printf "Produktkomponente ohne name: %s\n", component > "/dev/stderr"
        bad = 1
      }
      if (!seen[component "/summary"]) {
        printf "Produktkomponente ohne summary: %s\n", component > "/dev/stderr"
        bad = 1
      }
      count++
    }
    printf "product_language_count=%d\n", expected - 2
    printf "product_component_count=%d\n", count
    exit bad ? 1 : 0
  }
' "$COMPONENTS_FILE" || errors=1

exit "$errors"
