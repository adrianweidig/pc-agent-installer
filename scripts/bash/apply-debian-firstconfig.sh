#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent-installer-common.sh
source "$SCRIPT_DIR/agent-installer-common.sh"

ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"
HOSTNAME_VALUE="${HOSTNAME:-$(hostname)}"
HOST_ROOT="$ROOT/hosts/$HOSTNAME_VALUE"
CHANGE_ID="${PC_AGENT_CHANGE_ID:-$(date -u +%Y-%m-%d)_0001_debian-ersteinrichtung}"
LOG_PATH="$HOST_ROOT/logs/${CHANGE_ID}.log"
ADMIN_USER="${PC_AGENT_ADMIN_USER:-pcagent}"
SSH_LISTEN_MODE="${PC_AGENT_SSH_LISTEN:-loopback}"

if [[ "$(id -u)" != "0" ]]; then
  echo "Debian-Ersteinrichtung braucht root-Rechte. Starte Codex mit einem Root-Profil oder führe den Agenten als root/sudo aus." >&2
  exit 30
fi

agent_assert_host_write_allowed "$ROOT" >/dev/null

if [[ "${PC_AGENT_ALLOW_SYSTEM_CHANGES:-}" != "true" ]]; then
  cat >&2 <<'EOF'
Systemwirksame Debian-Ersteinrichtung blockiert.

Der Nutzer muss vorab bestätigen, dass der Agent im isolierten oder privaten Operational-Kontext mit root-Rechten handeln darf.
Setze erst danach PC_AGENT_ALLOW_SYSTEM_CHANGES=true und starte den Lauf erneut.
EOF
  exit 31
fi

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
else
  echo "/etc/os-release fehlt; Debian-Erkennung nicht möglich." >&2
  exit 32
fi

case " ${ID_LIKE:-} ${ID:-} " in
  *debian*|*ubuntu*) ;;
  *)
    echo "Dieses Skript ist nur für Debian-, Ubuntu- und verwandte APT-Systeme gedacht. Erkannt: ${ID:-unknown}" >&2
    exit 33
    ;;
esac

bash "$ROOT/scripts/common/assert-first-run-config.sh" "$ROOT" >/dev/null
bash "$ROOT/scripts/common/assert-infrastructure-snapshot.sh" "$ROOT" >/dev/null

mkdir -p "$HOST_ROOT"/{baseline,changes,rollback,logs,state}
exec > >(tee -a "$LOG_PATH") 2>&1

NOW="$(date -Iseconds)"
CHANGE_PATH="$HOST_ROOT/changes/${CHANGE_ID}.md"
ROLLBACK_PATH="$HOST_ROOT/rollback/${CHANGE_ID}-rollback.sh"
ROLLBACK_META_PATH="$HOST_ROOT/rollback/${CHANGE_ID}.yaml"

packages=(
  sudo
  openssh-server
  ufw
  locales
  tzdata
  unattended-upgrades
  vim-tiny
  nano
  wget
  gnupg
  lsb-release
  bash-completion
  less
  iputils-ping
  dnsutils
  net-tools
  ca-certificates
  curl
  git
)

capture_state() {
  local suffix="$1"
  dpkg-query -W -f='${Package}\t${Version}\n' | sort > "$HOST_ROOT/baseline/dpkg-${suffix}.tsv" 2>/dev/null || true
  apt-mark showmanual | sort > "$HOST_ROOT/baseline/apt-manual-${suffix}.txt" 2>/dev/null || true
  apt-cache policy > "$HOST_ROOT/baseline/apt-policy-${suffix}.txt" 2>/dev/null || true
  find /etc/apt -maxdepth 3 -type f \( -name '*.list' -o -name '*.sources' \) -print -exec sed -n '1,160p' {} \; > "$HOST_ROOT/baseline/apt-sources-${suffix}.txt" 2>/dev/null || true
  apt list --upgradable > "$HOST_ROOT/baseline/apt-upgradable-${suffix}.txt" 2>/dev/null || true
  getent passwd | sort > "$HOST_ROOT/baseline/users-${suffix}.txt" || true
  getent group | sort > "$HOST_ROOT/baseline/groups-${suffix}.txt" || true
  ss -tulpen > "$HOST_ROOT/baseline/network-listeners-${suffix}.txt" 2>&1 || true
  if command -v sshd >/dev/null 2>&1; then sshd -T > "$HOST_ROOT/baseline/ssh-${suffix}.txt" 2>&1 || true; fi
  if command -v ufw >/dev/null 2>&1; then ufw status verbose > "$HOST_ROOT/baseline/firewall-${suffix}.md" 2>&1 || true; fi
  { locale; printf '\n--- timezone ---\n'; cat /etc/timezone 2>/dev/null || true; } > "$HOST_ROOT/baseline/locale-timezone-${suffix}.md" 2>&1 || true
}

echo "==> Debian-Ersteinrichtung gestartet: $NOW"
capture_state "before"

echo "==> APT aktualisieren"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"
if [[ "${PC_AGENT_DEBIAN_SKIP_UPGRADE:-false}" != "true" ]]; then
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
fi

echo "==> Admin-Benutzer prüfen: $ADMIN_USER"
if ! id "$ADMIN_USER" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash --groups sudo "$ADMIN_USER"
  passwd --lock "$ADMIN_USER"
else
  usermod -aG sudo "$ADMIN_USER"
  passwd --lock "$ADMIN_USER" || true
fi

echo "==> Locale und Zeitzone konfigurieren"
grep -q '^de_DE.UTF-8 UTF-8' /etc/locale.gen || printf 'de_DE.UTF-8 UTF-8\n' >> /etc/locale.gen
grep -q '^en_US.UTF-8 UTF-8' /etc/locale.gen || printf 'en_US.UTF-8 UTF-8\n' >> /etc/locale.gen
locale-gen de_DE.UTF-8 en_US.UTF-8
update-locale LANG=de_DE.UTF-8
ln -snf /usr/share/zoneinfo/Etc/UTC /etc/localtime
printf 'Etc/UTC\n' > /etc/timezone
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive tzdata

echo "==> SSH härten"
mkdir -p /etc/ssh/sshd_config.d /run/sshd
{
  if [[ "$SSH_LISTEN_MODE" == "loopback" ]]; then
    printf 'ListenAddress 127.0.0.1\n'
    printf 'ListenAddress ::1\n'
  fi
  printf 'PermitRootLogin no\n'
  printf 'PasswordAuthentication no\n'
  printf 'KbdInteractiveAuthentication no\n'
  printf 'PubkeyAuthentication yes\n'
  printf 'X11Forwarding no\n'
  printf 'AllowUsers %s\n' "$ADMIN_USER"
} > /etc/ssh/sshd_config.d/99-pc-agent-hardening.conf
sshd -t

echo "==> unattended-upgrades konfigurieren"
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

echo "==> Firewall konfigurieren"
ufw default deny incoming || true
ufw default allow outgoing || true
ufw allow OpenSSH || true
if ! ufw --force enable; then
  echo "WARNUNG: UFW konnte nicht aktiviert werden. In Containern fehlen häufig Netfilter-Capabilities." >&2
fi

echo "==> Dienste starten, soweit ohne systemd möglich"
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
  systemctl enable --now ssh || systemctl enable --now sshd || true
  systemctl enable --now unattended-upgrades || true
else
  pkill sshd >/dev/null 2>&1 || true
  /usr/sbin/sshd
fi

capture_state "after"

cat > "$ROLLBACK_PATH" <<EOF
#!/usr/bin/env bash
set -euo pipefail

echo "Rollback für Debian-Ersteinrichtung: vor Ausführung aktuellen Zustand prüfen."
if command -v ufw >/dev/null 2>&1; then
  ufw --force disable || true
  ufw delete allow OpenSSH || true
fi
pkill sshd || true
rm -f /etc/ssh/sshd_config.d/99-pc-agent-hardening.conf
rm -f /etc/apt/apt.conf.d/20auto-upgrades
if id "$ADMIN_USER" >/dev/null 2>&1; then
  deluser --remove-home "$ADMIN_USER" || true
fi
update-locale LANG=C.UTF-8 || true
ln -snf /usr/share/zoneinfo/Etc/UTC /etc/localtime
printf 'Etc/UTC\n' > /etc/timezone
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive tzdata || true
echo "Paket-Rollback muss bewusst geprüft werden; Security-Upgrades werden nicht blind zurückgedreht."
EOF
chmod +x "$ROLLBACK_PATH"

cat > "$ROLLBACK_META_PATH" <<EOF
id: debian-ersteinrichtung-${CHANGE_ID}
change_entry: hosts/$HOSTNAME_VALUE/changes/${CHANGE_ID}.md
created_at: "$NOW"
commands:
  - bash hosts/$HOSTNAME_VALUE/rollback/${CHANGE_ID}-rollback.sh
requires_approval: true
EOF

cat > "$CHANGE_PATH" <<EOF
# Änderung: Debian-Ersteinrichtung

## Metadaten
- Datum: $NOW
- Hostname: $HOSTNAME_VALUE
- Repo-Modus: local-only oder operational
- Bereich: Debian-Ersteinrichtung
- Adminrechte erforderlich: ja
- Status: ausgeführt

## Zielzustand
- Offizielle APT-Quellen geprüft und Paketlisten aktualisiert.
- Basispakete für Administration, Diagnose, SSH, Firewall, Locale und Updates installiert.
- Admin-Benutzer \`$ADMIN_USER\` vorhanden, Passwort gesperrt, Mitglied in \`sudo\`.
- SSH gehärtet: kein Root-Login, keine Passwort-Authentifizierung, Public-Key-Login für \`$ADMIN_USER\`.
- UFW restriktiv vorbereitet; Aktivierung kann in Containern an fehlenden Capabilities scheitern.
- Locale \`de_DE.UTF-8\` und \`en_US.UTF-8\`, Zeitzone \`Etc/UTC\`.
- unattended-upgrades aktiviert.

## Ausgeführte Befehle
Siehe Log: \`hosts/$HOSTNAME_VALUE/logs/${CHANGE_ID}.log\`.

## Validierung
- \`sshd -t\` erfolgreich.
- \`id $ADMIN_USER\` erfolgreich.
- Baseline vor und nach der Änderung liegt unter \`hosts/$HOSTNAME_VALUE/baseline/\`.
- Rollback-Skript liegt unter \`hosts/$HOSTNAME_VALUE/rollback/\`.

## Findings
- Firewall-Aktivierung kann in Containerumgebungen ohne Netfilter-Rechte fehlschlagen.
- systemd-Dienste können in Minimalcontainern offline sein; SSH wird dann direkt gestartet.
- Ohne Public Key ist Remote-Login für \`$ADMIN_USER\` bewusst nicht nutzbar.
EOF

printf 'last_run_at: %s\nstatus: debian_firstconfig_applied\nchange: %s\n' "$NOW" "hosts/$HOSTNAME_VALUE/changes/${CHANGE_ID}.md" > "$HOST_ROOT/state/last-run.yaml"

echo "==> Validierung"
id "$ADMIN_USER"
sshd -t
locale -a | grep -Eq 'de_DE\.utf8|de_DE.UTF-8'
grep -q 'LANG=de_DE.UTF-8' /etc/default/locale
test -x "$ROLLBACK_PATH"

echo "Debian-Ersteinrichtung abgeschlossen: $CHANGE_PATH"
