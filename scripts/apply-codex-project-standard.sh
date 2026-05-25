#!/usr/bin/env bash
set -euo pipefail

target="${1:-.}"
root="$(cd "$target" && pwd)"

created=()
skipped=()

make_dir() {
  local dir="$1"
  if [[ ! -d "$root/$dir" ]]; then
    mkdir -p "$root/$dir"
    created+=("$dir/")
  else
    skipped+=("$dir/")
  fi
}

write_if_missing() {
  local file="$1"
  local content="$2"
  if [[ -e "$root/$file" ]]; then
    skipped+=("$file")
    return
  fi
  mkdir -p "$(dirname "$root/$file")"
  printf '%s\n' "$content" > "$root/$file"
  created+=("$file")
}

make_dir ".github/workflows"
make_dir ".github/ISSUE_TEMPLATE"
make_dir "docs/assets"
make_dir "scripts"

write_if_missing ".editorconfig" "root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.ps1]
charset = utf-8-bom
end_of_line = crlf
indent_size = 4

[*.md]
trim_trailing_whitespace = false"

write_if_missing ".gitattributes" "* text=auto eol=lf
*.sh text eol=lf
*.ps1 text eol=crlf
*.md text eol=lf
*.yml text eol=lf
*.yaml text eol=lf"

write_if_missing ".gitignore" ".env
.env.*
*.log
*.tmp
.cache/
__pycache__/
*.pyc
.DS_Store
Thumbs.db"

write_if_missing "README.md" "# Projektstart

Dieses Projekt wurde für eine strukturierte Codex-Bearbeitung vorbereitet.

Beschreibe hier nur belegbare Projektinformationen: Zweck, Installation, Nutzung, Entwicklung, Tests, Build, Security, Support und Lizenzstatus."

write_if_missing "AGENTS.md" "# AGENTS.md

## Projektregeln

- Vor Änderungen den Projektzustand und vorhandene Konventionen prüfen.
- Bestehende Inhalte und Nutzeränderungen bewahren.
- Keine Secrets, Tokens, privaten Schlüssel oder vertraulichen Daten erzeugen oder offenlegen.
- Keine öffentlichen APIs, Dateiformate oder Standardwerte ohne fachlichen Grund ändern.
- Textdateien als UTF-8 schreiben; deutsche Fließtexte nutzen echte Umlaute statt ASCII-Umschreibungen mit `ue`, `oe` oder `ae`.
- GitHub Actions, Release-Artefakte und Docker/GHCR bei passenden Projektänderungen mitdenken.
- Nach Änderungen passende Tests, Lints, Builds oder Smoke-Checks ausführen."

write_if_missing "SECURITY.md" "# Security Policy

Bitte poste keine sensiblen Schwachstellendetails öffentlich als Issue.

Wenn kein privater Meldeweg eingerichtet ist, dokumentiere in der Maintainer-Checkliste, wie dieser eingerichtet werden soll. Diese Datei gibt keine Sicherheitsgarantie."

write_if_missing "CONTRIBUTING.md" "# Contributing

Beiträge sollen klein, nachvollziehbar und passend zum Projektumfang sein.

Prüfe vor einem Pull Request die vorhandenen Entwicklungs-, Test- und Build-Befehle. Sicherheitsrelevante Hinweise gehören nicht in öffentliche Issues."

write_if_missing "CODE_OF_CONDUCT.md" "# Code of Conduct

Arbeite respektvoll, sachlich und lösungsorientiert. Technische Kritik bezieht sich auf Inhalte, nicht auf Personen. Veröffentliche keine privaten Informationen oder Secrets."

write_if_missing "SUPPORT.md" "# Support

Nutze Issues für reproduzierbare Fehler, konkrete Fragen und Verbesserungsvorschläge.

Teile keine Secrets, privaten Pfade, internen Infrastrukturdetails oder unredigierten Logs in öffentlichen Tickets."

write_if_missing "CHANGELOG.md" "# Changelog

## Unreleased

- Projektstruktur für professionelle Codex-Bearbeitung vorbereitet."

write_if_missing "docs/MAINTAINER_CHECKLIST.md" "# Maintainer-Checkliste

- Lizenzstatus prüfen.
- Repository-Beschreibung und Topics setzen.
- Branch Protection und Required Status Checks konfigurieren.
- Privaten Sicherheitsmeldeweg einrichten.
- Social Preview hochladen, wenn ein geeignetes Bild vorhanden ist.
- Release- und Tag-Strategie festlegen.
- GHCR-Sichtbarkeit prüfen, wenn Docker Images veröffentlicht werden."

write_if_missing "docs/CI_CD.md" "# CI/CD

CI soll nur Befehle ausführen, die im Projekt wirklich vorhanden oder sicher ableitbar sind.

Release-Artefakte dürfen als Actions-Artefakte erzeugt werden. Echte GitHub Releases und Tags benötigen eine bewusste Maintainer-Entscheidung."

write_if_missing "docs/RELEASE_PROCESS.md" "# Release-Prozess

Vor einem Release: Arbeitsbaum prüfen, Tests und Builds ausführen, Changelog aktualisieren und sicherstellen, dass keine Secrets oder lokalen Artefakte enthalten sind.

Tags und GitHub Releases werden nur erstellt, wenn eine klare Release-Strategie vorliegt."

write_if_missing ".github/workflows/ci.yml" "name: CI

on:
  pull_request:
    branches:
      - main
      - master
  push:
    branches:
      - main
      - master
  workflow_dispatch:

permissions:
  contents: read

jobs:
  repository-health:
    name: Repository health
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Check core files
        shell: bash
        run: |
          test -f README.md
          test -f .gitignore
          test -d docs"

write_if_missing ".github/workflows/release-artifact.yml" "name: Release artifact

on:
  push:
    branches:
      - main
      - master
  workflow_dispatch:

permissions:
  contents: read

jobs:
  archive:
    name: Build repository archive
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Build artifact metadata
        id: meta
        shell: bash
        run: |
          repo_name=\"\${GITHUB_REPOSITORY##*/}\"
          branch_name=\"\${GITHUB_REF_NAME//\\//-}\"
          short_sha=\"\${GITHUB_SHA::12}\"
          archive_name=\"\${repo_name}-\${branch_name}-\${short_sha}.zip\"
          root_dir=\"\${repo_name}-\${short_sha}\"
          echo \"archive_name=\${archive_name}\" >> \"\$GITHUB_OUTPUT\"
          echo \"root_dir=\${root_dir}\" >> \"\$GITHUB_OUTPUT\"

      - name: Create ZIP from current commit
        shell: bash
        run: |
          git archive --format=zip --output=\"\${{ steps.meta.outputs.archive_name }}\" --prefix=\"\${{ steps.meta.outputs.root_dir }}/\" HEAD

      - name: Create release notes
        shell: bash
        run: |
          {
            echo \"# Repository Artifact\"
            echo
            echo \"Repository: \${GITHUB_REPOSITORY}\"
            echo \"Branch: \${GITHUB_REF_NAME}\"
            echo \"Commit: \${GITHUB_SHA}\"
            echo \"Short SHA: \${GITHUB_SHA::12}\"
            echo \"Event: \${GITHUB_EVENT_NAME}\"
            echo \"Actor: \${GITHUB_ACTOR}\"
            echo \"UTC: \$(date -u +'%Y-%m-%dT%H:%M:%SZ')\"
            echo \"Archive: \${{ steps.meta.outputs.archive_name }}\"
            echo
            last_tag=\"\$(git describe --tags --abbrev=0 2>/dev/null || true)\"
            if [[ -n \"\$last_tag\" ]]; then
              echo \"## Changes since \$last_tag\"
              git log --oneline \"\$last_tag..HEAD\"
            else
              echo \"## Recent commits\"
              git log --oneline -10
            fi
          } > release-notes.md

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: \${{ steps.meta.outputs.archive_name }}
          path: |
            \${{ steps.meta.outputs.archive_name }}
            release-notes.md"

write_if_missing ".github/dependabot.yml" "version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly"

write_if_missing ".github/ISSUE_TEMPLATE/config.yml" "blank_issues_enabled: false"

write_if_missing ".github/ISSUE_TEMPLATE/bug_report.yml" "name: Fehlerbericht
description: Reproduzierbaren Fehler melden.
title: \"[Bug] \"
labels:
  - bug
body:
  - type: textarea
    id: current
    attributes:
      label: Ist-Zustand
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Erwartetes Verhalten
    validations:
      required: true
  - type: textarea
    id: reproduction
    attributes:
      label: Reproduktion
    validations:
      required: true"

write_if_missing ".github/ISSUE_TEMPLATE/feature_request.yml" "name: Verbesserungsvorschlag
description: Konkrete Verbesserung vorschlagen.
title: \"[Feature] \"
labels:
  - enhancement
body:
  - type: textarea
    id: goal
    attributes:
      label: Ziel
    validations:
      required: true
  - type: textarea
    id: proposal
    attributes:
      label: Vorschlag
    validations:
      required: true"

write_if_missing ".github/ISSUE_TEMPLATE/documentation.yml" "name: Dokumentation
description: Dokumentationsproblem melden.
title: \"[Docs] \"
labels:
  - documentation
body:
  - type: textarea
    id: location
    attributes:
      label: Fundstelle
    validations:
      required: true
  - type: textarea
    id: problem
    attributes:
      label: Problem
    validations:
      required: true"

write_if_missing ".github/PULL_REQUEST_TEMPLATE.md" "## Zusammenfassung

## Checks

- [ ] Relevante Tests, Lints oder Builds ausgeführt
- [ ] Keine Secrets oder vertraulichen Daten enthalten
- [ ] Dokumentation bei Bedarf aktualisiert

## Hinweise für Reviewer"

echo "Codex-Projektstandard angewendet auf: $root"
echo
echo "Erstellt:"
printf '  %s\n' "${created[@]:-keine}"
echo
echo "Übersprungen:"
printf '  %s\n' "${skipped[@]:-keine}"
echo
echo "Keine Commits, Pushes, Tags, Releases oder Veröffentlichungen wurden ausgeführt."
