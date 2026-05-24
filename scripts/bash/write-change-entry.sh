#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent-installer-common.sh
source "$SCRIPT_DIR/agent-installer-common.sh"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <area> <summary>" >&2
  exit 2
fi

ROOT="$(agent_repo_root "$SCRIPT_DIR")"
HOSTNAME_VALUE="${HOSTNAME:-$(hostname)}"
AREA="$1"
SUMMARY="$2"
agent_assert_host_write_allowed "$ROOT" >/dev/null
HOST_ROOT="$ROOT/hosts/$HOSTNAME_VALUE"
mkdir -p "$HOST_ROOT/changes"
DATE="$(date +%F)"
COUNT="$(find "$HOST_ROOT/changes" -maxdepth 1 -name "$DATE*.md" | wc -l | tr -d ' ')"
SEQ="$(printf '%04d' "$((COUNT + 1))")"
SLUG="$(printf '%s' "$AREA" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g')"
PATH_OUT="$HOST_ROOT/changes/${DATE}_${SEQ}_${SLUG}.md"

cat > "$PATH_OUT" <<MD
# Änderung: $SUMMARY

## Metadaten
- Datum: $DATE
- Hostname: $HOSTNAME_VALUE
- Bereich: $AREA
- Ebene: System
- Risiko: niedrig
- Adminrechte erforderlich: nein
- Nutzerfreigabe erforderlich: nein
- Status: geplant

## Ausgangszustand
Noch zu dokumentieren.

## Infrastruktur-Snapshot
Noch zu dokumentieren. Vor Vollzug `assert-infrastructure-snapshot.sh` ausführen oder aktuelle Baseline erzeugen.

## Zielzustand
Noch zu dokumentieren.

## Soll-Ist-Abgleich
- Soll: Noch zu dokumentieren.
- Ist: Noch zu dokumentieren.
- Abweichung: Noch zu dokumentieren.

## Duplikatprüfung
Noch zu dokumentieren. Prüfen, ob Software, Dienst, Paketquelle, Container, Port, Volume, WSL-Distribution oder Konfiguration bereits existiert.

## Lösch- und Seiteneffektprüfung
Noch zu dokumentieren. Unklare Nutzdaten, Volumes, Secrets, Projektordner und aktive Workspaces nicht löschen.

## Änderung
Noch nicht ausgeführt.

## Ort der Änderung
Noch zu dokumentieren.

## Ausgeführte Befehle
\`\`\`bash
# Noch keine Befehle dokumentiert.
\`\`\`

## Betroffene Dateien
- Noch zu dokumentieren.

## Prüfung
Noch zu dokumentieren.

## Rollback
Noch zu dokumentieren.

## Risiken und Hinweise
Keine Klartext-Secrets aufnehmen.
MD

echo "Change-Eintrag erzeugt: $PATH_OUT"
