#!/usr/bin/env bash
set -euo pipefail

agent_repo_root() {
  local start="${1:-$PWD}"
  local current
  current="$(cd "$start" && pwd)"
  while [[ "$current" != "/" ]]; do
    if [[ -d "$current/.git" ]]; then
      printf '%s\n' "$current"
      return 0
    fi
    current="$(dirname "$current")"
  done
  printf '%s\n' "$start"
}

agent_repo_mode() {
  local root="$1"
  if [[ -f "$root/repo-mode.yaml" ]]; then
    awk -F: '/^[[:space:]]*repo_mode:/ {gsub(/[ "]/,"",$2); print $2; found=1} END {if (!found) print "template"}' "$root/repo-mode.yaml"
  else
    printf 'template\n'
  fi
}

agent_visibility_required() {
  local root="$1"
  if [[ -f "$root/repo-mode.yaml" ]]; then
    awk -F: '/^[[:space:]]*visibility_required:/ {gsub(/[ "]/,"",$2); print $2; found=1} END {if (!found) print "public"}' "$root/repo-mode.yaml"
  else
    printf 'public\n'
  fi
}

agent_detect_repo_guard() {
  local root="$1"
  local mode visibility_required remote_count visibility visibility_checked is_private push_allowed allowed gh_json repo_name
  mode="$(agent_repo_mode "$root")"
  visibility_required="$(agent_visibility_required "$root")"
  remote_count="$(git -C "$root" remote 2>/dev/null | wc -l | tr -d ' ')"
  visibility="unknown"
  visibility_checked=false
  is_private=false
  repo_name=""
  if [[ "$remote_count" == "0" ]]; then
    visibility="no_remote"
    visibility_checked=true
  elif command -v gh >/dev/null 2>&1; then
    if gh_json="$(cd "$root" && gh repo view --json isPrivate,visibility,nameWithOwner 2>/dev/null)"; then
      visibility_checked=true
      if printf '%s' "$gh_json" | grep -q '"isPrivate":true'; then is_private=true; visibility="private"; fi
      if printf '%s' "$gh_json" | grep -q '"visibility":"PUBLIC"'; then visibility="public"; fi
      repo_name="$(printf '%s' "$gh_json" | sed -n 's/.*"nameWithOwner":"\([^"]*\)".*/\1/p')"
    fi
  fi
  if [[ "$visibility_checked" != "true" && "$remote_count" != "0" && -n "${GITHUB_TOKEN:-}" ]] && command -v curl >/dev/null 2>&1; then
    remote_url="$(git -C "$root" remote get-url origin 2>/dev/null || true)"
    owner_repo=""
    case "$remote_url" in
      *github.com*) owner_repo="$(printf '%s' "$remote_url" | sed -E 's#.*github.com[:/]([^/]+/[^ ]+)$#\1#; s#\.git$##')" ;;
    esac
    if [[ -n "$owner_repo" ]]; then
      api_json="$(curl -fsS \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/${owner_repo}" 2>/dev/null || true)"
      if [[ -n "$api_json" ]]; then
        visibility_checked=true
        repo_name="$(printf '%s' "$api_json" | sed -n 's/.*"full_name":[[:space:]]*"\([^"]*\)".*/\1/p')"
        if printf '%s' "$api_json" | grep -q '"private":[[:space:]]*true'; then
          is_private=true
          visibility="private"
        else
          visibility="public"
        fi
      fi
    fi
  fi
  allowed=false
  push_allowed=false
  if [[ "$mode" == "operational" && "$visibility_checked" == "true" && "$is_private" == "true" ]]; then
    allowed=true
    push_allowed=true
  elif [[ "$mode" == "local-only" && "$visibility_checked" == "true" && "$visibility" == "no_remote" ]]; then
    allowed=true
  fi
  if [[ "$mode" == "template" ]]; then
    allowed=false
    push_allowed=false
  fi
  printf '{"repo_mode":"%s","visibility_required":"%s","visibility_checked":%s,"visibility":"%s","github_repo":"%s","allowed_to_write_hosts":%s,"allowed_to_document_sensitive_context":%s,"allowed_to_store_plaintext_secrets":false,"push_allowed":%s}\n' \
    "$mode" "$visibility_required" "$visibility_checked" "$visibility" "$repo_name" "$allowed" "$allowed" "$push_allowed"
}

agent_assert_host_write_allowed() {
  local root="$1" guard
  guard="$(agent_detect_repo_guard "$root")"
  if printf '%s' "$guard" | grep -q '"allowed_to_write_hosts":true'; then
    printf '%s\n' "$guard"
    return 0
  fi
  cat >&2 <<EOF
WARNUNG:
Dieses Repository ist nicht als sicherer Hostdaten-Zielort bestätigt.
Hostdaten, Infrastrukturinformationen, Secrets, Tokens, private Pfade und sicherheitskritische Konfigurationen werden hier nicht dokumentiert.

Sichere Optionen:
1. Private GitHub-Kopie aus Template erzeugen.
2. Lokales Git-Repo ohne Remote verwenden und local-only aktivieren.
3. Abbrechen.
EOF
  return 10
}

agent_redact() {
  sed -E \
    -e 's/((password|passwd|pwd|secret|token|api[_-]?key|credential|private[_-]?key)[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/(Authorization:[[:space:]]*Bearer[[:space:]]+)[^[:space:]]+/\1[REDACTED]/Ig'
}
