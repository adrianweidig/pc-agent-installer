#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
missing=0
for path in \
  AGENTS.md \
  README.md \
  LICENSE \
  repo-mode.yaml \
  .github/ISSUE_TEMPLATE/bug_report.yml \
  .github/ISSUE_TEMPLATE/feature_request.yml \
  .github/ISSUE_TEMPLATE/documentation.yml \
  .github/ISSUE_TEMPLATE/config.yml \
  .github/PULL_REQUEST_TEMPLATE.md \
  .github/workflows/validate.yml \
  .github/workflows/release-artifact.yml \
  docs/CODEX_NEW_PROJECT_STANDARD.md \
  docs/CI_CD.md \
  docs/19-template-upstream-sync.md \
  scripts/apply-codex-project-standard.sh \
  schemas/host.schema.yaml \
  schemas/repo-mode.schema.yaml \
  scripts/common/detect-repo-mode.ps1 \
  scripts/common/detect-repo-mode.sh \
  scripts/common/first-run-config.ps1 \
  scripts/common/first-run-config.sh \
  scripts/common/assert-first-run-config.ps1 \
  scripts/common/assert-first-run-config.sh \
  scripts/common/assert-infrastructure-snapshot.ps1 \
  scripts/common/assert-infrastructure-snapshot.sh \
  scripts/common/verify-template.ps1 \
  scripts/common/verify-template.sh \
  scripts/common/sync-template-upstream.ps1 \
  scripts/common/sync-template-upstream.sh \
  scripts/powershell/collect-baseline.ps1 \
  scripts/bash/collect-baseline.sh \
  scripts/container/detect-container-stack.ps1 \
  scripts/container/detect-container-stack.sh \
  hosts/.gitkeep; do
  if [[ ! -e "$ROOT/$path" ]]; then
    echo "Fehlt: $path" >&2
    missing=1
  fi
done
if find "$ROOT/hosts" -mindepth 1 -maxdepth 1 ! -name .gitkeep | grep -q .; then
  echo "hosts/ enthält Hostdaten; Template muss leer bleiben." >&2
  missing=1
fi
count="$(find "$ROOT/Vorlage" -type f -name '*.md' | wc -l | tr -d ' ')"
echo "template_file_count=$count"
while IFS= read -r file; do
  first_line="$(sed -n '1p' "$file")"
  if [[ "$first_line" != "---" ]]; then
    echo "Frontmatter fehlt: $file" >&2
    missing=1
    continue
  fi
  frontmatter="$(awk 'NR == 1 { next } /^---$/ { exit } { print }' "$file")"
  for field in id title platform environment area requires_admin risk approval_required rollback_required idempotent applies_to; do
    if ! grep -Eq "^${field}:" <<< "$frontmatter"; then
      echo "Frontmatter-Feld fehlt: $file:$field" >&2
      missing=1
    fi
  done
  if grep -q $'\rollback_required' "$file"; then
    echo "Beschädigtes rollback_required-Token: $file" >&2
    missing=1
  fi
done < <(find "$ROOT/Vorlage" -type f -name '*.md')
exit "$missing"
