#!/usr/bin/env bash
set -euo pipefail

kernel_name="$(uname -s 2>/dev/null || printf unknown)"
os="linux"
environment="native"
if [[ "$kernel_name" == "Darwin" ]]; then
  os="macos"
elif grep -qi microsoft /proc/version 2>/dev/null; then
  environment="wsl"
fi
hostname_value="$(hostname 2>/dev/null || printf unknown)"
arch_value="$(uname -m 2>/dev/null || printf unknown)"
kernel_value="$(uname -r 2>/dev/null || printf unknown)"
distribution="unknown"
version_id=""
family="unknown"
pretty_name=""
macos_product_version=""
macos_build_version=""

if [[ "$os" == "macos" ]]; then
  macos_product_version="$(sw_vers -productVersion 2>/dev/null || printf '')"
  macos_build_version="$(sw_vers -buildVersion 2>/dev/null || printf '')"
elif [[ -f /etc/os-release ]]; then
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

printf '{"detected_at":"%s","os":"%s","environment":"%s","hostname":"%s","architecture":"%s","kernel":"%s","linux":{"family":"%s","distribution":"%s","version_id":"%s","pretty_name":"%s"},"macos":{"product_version":"%s","build_version":"%s"},"root":%s}\n' \
  "$(date -Iseconds)" "$os" "$environment" "$hostname_value" "$arch_value" "$kernel_value" "$family" "$distribution" "$version_id" "$pretty_name" "$macos_product_version" "$macos_build_version" "$(if [[ "$(id -u)" == "0" ]]; then echo true; else echo false; fi)"
