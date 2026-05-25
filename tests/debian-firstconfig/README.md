# Debian-Erstkonfigurations-Testsuite

Diese Testsuite prüft den Debian-nahen Erstkonfigurationspfad des Templates in einem isolierten Debian-Container. Der Host wird nicht konfiguriert: Das Docker-Image enthält eine Kopie des Repositorys, die Tests erzeugen pro Lauf eine weitere Container-interne Arbeitskopie und simulieren dort einen `local-only`-Operational-Kontext.

## Ausführen

Aus einer WSL-Shell im Repository:

```bash
bash tests/debian-firstconfig/run-tests.sh
```

Aus PowerShell, wenn Docker nur in WSL verfügbar ist:

```powershell
wsl.exe -- bash -lc 'cd /mnt/e/Codex_Workspace/repos/pc-agent-installer && bash tests/debian-firstconfig/run-tests.sh'
```

## Schutzmodell

- Kein `sudo` auf dem Host.
- Keine Paketinstallation auf dem Host.
- Kein privilegierter Container; für Firewall-Tests erhält der Container gezielt `NET_ADMIN`.
- Keine Host-Netzwerkports.
- Keine schreibbaren Host-Mounts für die getestete Repo-Kopie.
- Artefakte werden erst nach dem Containerlauf per `docker cp` in `tests/debian-firstconfig/` übertragen.
- Testcontainer und lokal benanntes Testimage werden standardmäßig entfernt.
- Der getestete `local-only`-Modus entsteht ausschließlich in der Containerkopie.

## Geprüfte Bereiche

- Docker-Build und Debian-Basisumgebung.
- Erkannte Debian- und Erstkonfigurations-Einstiegspunkte.
- `first-run-config.sh` über `collect-baseline.sh`.
- vollständiger Debian-Apply-Flow über `apply-debian-firstconfig.sh`.
- Zustand vor, nach dem ersten Lauf und nach dem zweiten Lauf.
- Idempotenz über zweiten Lauf im selben Containerzustand.
- Reproduzierbarkeit über zwei frische Container-interne Arbeitskopien.
- Pakete, APT-Quellen, Benutzer, Gruppen, Rechte, Dienste, Netzwerk, Locale und Härtungssignale.
- Statische Grenzen, wenn systemd oder Codex CLI im Container nicht verfügbar sind.

## Artefakte

Der Lauf erzeugt unter anderem:

```text
tests/debian-firstconfig/artifacts/container-build.log
tests/debian-firstconfig/artifacts/pytest.log
tests/debian-firstconfig/artifacts/first-run.log
tests/debian-firstconfig/artifacts/second-run.log
tests/debian-firstconfig/artifacts/system-before.txt
tests/debian-firstconfig/artifacts/system-after-first-run.txt
tests/debian-firstconfig/artifacts/system-after-second-run.txt
tests/debian-firstconfig/reports/debian-firstconfig-report.md
```

Die Dateien werden redigiert, bevor sie im Repository-Verzeichnis landen.
