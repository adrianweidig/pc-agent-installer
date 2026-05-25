# Codex-Root-Profil

## Zweck

Die vollständige Ersteinrichtung eines PCs oder Servers braucht absolute Systemrechte. Codex muss dafür in einer geprüften privaten Operational-Kopie oder einem `local-only`-Klon mit einem Root- beziehungsweise Admin-Profil gestartet werden. Dieses Profil ist die vorgesehene Betriebsart für echte Ersteinrichtung, nicht nur ein optionaler Expertenmodus.

Ohne dieses Profil darf der Agent nur analysieren, Baselines erzeugen oder eine Blockade dokumentieren. Er darf keine Firewall, Paketmanager, Dienste, Benutzer, Gruppen oder Sicherheitsrichtlinien verändern.

## Hinweis an den Nutzer

Vor dem Start muss der Nutzer ausdrücklich verstehen:

- Der Agent handelt mit Administrator-, root- oder sudo-Rechten.
- Der Agent darf Pakete installieren, Dienste ändern, Firewall-Regeln setzen und Systemdateien schreiben.
- Der Agent arbeitet nur im bestätigten Operational- oder `local-only`-Kontext.
- Vor jeder systemwirksamen Änderung gelten Erststart-Konfiguration, Infrastruktur-Snapshot, Soll-Ist-Abgleich, Rollback und Validierung.

## Plattformprofile

| Plattform | Geeigneter Start |
| --- | --- |
| Windows | Codex aus einer erhöhten Administrator-Shell starten, wenn Windows Features, Dienste, Firewall, Registry, Benutzer, Gruppen oder systemweite Programme betroffen sind |
| Linux | Codex als root starten oder in einer Umgebung, in der sudo bewusst freigegeben und nicht interaktiv blockiert ist |
| Debian/Ubuntu | root/sudo plus explizite Apply-Freigabe über `PC_AGENT_ALLOW_SYSTEM_CHANGES=true` |
| RHEL/Fedora/Arch | root/sudo mit Zugriff auf den jeweiligen Paketmanager und Dienstmanager |
| macOS | Administrator-Konto mit gezielter sudo-Fähigkeit für Homebrew/MacPorts, Firewall, LaunchAgents/LaunchDaemons und Sicherheitsfunktionen |
| WSL | root/sudo in der Distribution; Windows-seitige Integrationen zusätzlich aus Administrator-Kontext bewerten |
| Container | root oder notwendige Capabilities innerhalb des Containers; Host-Runtime-Änderungen separat freigeben |

## Start im Debian-Container

Für isolierte Debian-E2E-Tests kann Codex im Container so gestartet werden:

```bash
cd /workspace/pc-agent-installer-local-e2e
codex exec \
  --dangerously-bypass-approvals-and-sandbox \
  --skip-git-repo-check \
  "Lies AGENTS.md und starte die vollständige Debian-Ersteinrichtung nach Repository-Regeln."
```

Dieser Modus ist nur vertretbar, wenn die Umgebung extern isoliert ist, zum Beispiel ein Wegwerfcontainer oder eine bewusst freigegebene Test-VM.

## Start mit Profil

Wenn ein lokales Codex-Profil genutzt wird, muss es äquivalent zu diesem Sicherheitsumfang sein:

- Arbeitsverzeichnis ist die private Operational-Kopie oder der `local-only`-Klon.
- Dateisystemzugriff erlaubt Systemänderungen in der Zielumgebung.
- Approval-Policy blockiert den automatisierten Testlauf nicht.
- Der Prozess läuft als root oder über eine bewusst freigegebene sudo-/Admin-Sitzung.

Ein Profil ohne diese Rechte ist für echte Ersteinrichtung ungeeignet. Der Agent muss das als Blockade melden.

## Debian-Apply-Befehl

Nach Erststart-Konfiguration und Baseline kann der Agent die Debian-Ersteinrichtung über das Repo-Werkzeug ausführen:

```bash
PC_AGENT_ALLOW_SYSTEM_CHANGES=true bash scripts/bash/apply-debian-firstconfig.sh
```

Der Befehl schreibt Change-, Baseline-, Log- und Rollback-Artefakte unter `hosts/<HOSTNAME>/`.
