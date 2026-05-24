#!/usr/bin/env bash
set -euo pipefail

os="linux"
environment="native"
if grep -qi microsoft /proc/version 2>/dev/null; then environment="wsl"; fi
hostname_value="$(hostname 2>/dev/null || printf unknown)"
arch_value="$(uname -m 2>/dev/null || printf unknown)"
kernel_value="$(uname -r 2>/dev/null || printf unknown)"
distribution="unknown"
version_id=""
family="unknown"
pretty_name=""

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  distribution="${ID:-unknown}"
  version_id="${VERSION_ID:-}"
  pretty_name="${PRETTY_NAME:-}"
  case " ${ID_LIKE:-} ${ID:-} " in
    *debian*|*ubuntu*) family="debian" ;;
    *rhel*|*fedora*|*rocky*|*almalinux*) family="rhel" ;;
    *arch*) family="arch" ;;
  esac
fi

printf '{"detected_at":"%s","os":"%s","environment":"%s","hostname":"%s","architecture":"%s","kernel":"%s","linux":{"family":"%s","distribution":"%s","version_id":"%s","pretty_name":"%s"},"root":%s}\n' \
  "$(date -Iseconds)" "$os" "$environment" "$hostname_value" "$arch_value" "$kernel_value" "$family" "$distribution" "$version_id" "$pretty_name" "$(if [[ "$(id -u)" == "0" ]]; then echo true; else echo false; fi)"
