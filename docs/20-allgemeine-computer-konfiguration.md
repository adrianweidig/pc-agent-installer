# Allgemeine Computer-Konfiguration

## Ziel

Diese Dokumentation bündelt generische Muster, die ein Agent bei der Erstkonfiguration eines normalen Rechners prüfen soll. Sie ist keine Checkliste zum blinden Abarbeiten. Der Agent leitet aus Nutzerbeschreibung, Betriebssystem, Gerätetyp, vorhandener Software und Repo-Modus ab, welche Punkte relevant sind.

Konkrete Hostdaten gehören nur in ein bestätigtes `operational`-Repository oder einen `local-only`-Klon. Das öffentliche Template dokumentiert nur wiederverwendbare Regeln.

## Gute Muster

Diese Signale darf der Agent als positive Ausgangslage bewerten:

- eingebaute Schutzmechanismen sind aktiv: Defender oder Plattformschutz, Firewall, SmartScreen/Gatekeeper, UAC oder vergleichbare Rechtebegrenzung
- Paketmanager und Stores stammen aus offiziellen oder klar begründeten Quellen
- Updates werden regelmäßig geprüft, aber nicht ohne Freigabe massenhaft installiert
- Arbeitsdaten liegen auf einem passenden, gesunden Dateisystem mit ausreichendem freien Speicher
- Geräteverschlüsselung ist aktiv oder bewusst geplant, inklusive Recovery-Key- und Backup-Klärung
- Entwickler-Toolchains sind nachvollziehbar installiert und nicht mehrfach konkurrierend vorhanden
- WSL, Docker, Podman oder Portainer sind optionale Werkzeuge, keine Pflichtbestandteile
- Container-Ports sind lokal gebunden, wenn der Dienst nur lokal gebraucht wird
- Volumes, Datenpfade und Secrets sind vor Cleanup oder Neuinstallation klassifiziert
- Git-Workspaces sind versioniert und nicht durch dauerhafte lokale Backup-Kopien ersetzt

## Schlechte Muster

Diese Muster sind begründbar riskant und sollen dokumentiert oder vermieden werden:

- sehr breite Antivirus-, Firewall-, DNS- oder Allowlist-Ausnahmen für ganze Benutzer-, System- oder Programmdatenbereiche
- veraltete Betriebssystem-, App-, Paketmanager- oder Containerstände ohne bewusste Wartungsentscheidung
- unverschlüsselte mobile oder private Geräte ohne dokumentierte Begründung
- Entwickler-Workspaces auf beschädigten, ungeeigneten oder nicht journalingfähigen Dateisystemen
- Dritt-Repositories, deren Release nicht zur Distribution passt
- Paketquellen ohne nachvollziehbare Herkunft, Signatur, Keyring oder Updatepfad
- pauschales Deaktivieren von Diensten, Autostart, Telemetrie oder Schutzfunktionen ohne Nebenwirkungsprüfung
- global exponierte Entwicklungsdienste oder Containerports ohne Zweck, Firewall-Kontext und Validierung
- Container-Secrets in rohen Env-Dumps, Logs, Compose-Ausgaben oder Repository-Dateien
- Löschen von Volumes, Images, Paketquellen, Arbeitskopien oder Backups ohne Soll-Ist-Abgleich und Rollback-Grenze

## Erstkonfigurationsbereiche

Die Erststart-Konfiguration soll diese Bereiche als Schalter anbieten:

| Bereich | Agentenentscheidung |
| --- | --- |
| Update-Wartung | Betriebssystem, Stores, Apps, Distributionen und Container getrennt prüfen |
| Paketquellen-Audit | Herkunft, Signatur, Release-Kompatibilität und Drittquellen bewerten |
| Datenträger und Workspace | Dateisystem, Health-Status, Speicherplatz, Backup und Git-Zustand prüfen |
| Verschlüsselung | BitLocker, FileVault oder LUKS empfehlen, aber nie ohne Recovery-Key-Freigabe aktivieren |
| Security-Ausnahmen | Exclusions und Allowlisten auf Breite, Zweck und Laufzeit prüfen |
| Dienste und Autostart | Nutzen und Nebenwirkungen bewerten, nicht pauschal deaktivieren |
| Entwickler-Toolchain | Git, Shells, SDKs, Paketmanager und doppelte Laufzeitwelten prüfen |
| Container-Exposure | Ports, Volumes, Netzwerke, Secrets und Updatepfade dokumentieren |

## Betriebssystem-Verteilung

| Thema | Windows | Linux | WSL | macOS | Container |
| --- | --- | --- | --- | --- | --- |
| Updates | Windows Update, Store, `winget` | Distributionspaketmanager, Flatpak/Snap nur wenn vorhanden | eigener Distributionspaketmanager | Softwareupdate, App Store, Homebrew | Images, Basisimages, Compose-Stacks |
| Paketquellen | Store, `winget`-Quellen, Herstellerseiten | Repositories, PPAs, AUR, Flathub | Host und Distribution getrennt | App Store, Homebrew-Taps, Herstellerseiten | Registries, Image-Tags, Build-Kontext |
| Dateisystem | NTFS/ReFS, Laufwerkszustand, BitLocker | ext4/btrfs/xfs, Mounts, LUKS | ext4-Distribution vs. `/mnt/*`-Mounts | APFS, FileVault | Bind-Mounts und benannte Volumes |
| Security-Ausnahmen | Defender-Exclusions, Firewall-Regeln | AV-/Scan-Ausnahmen, Firewall | Windows Defender plus Linux-Kontext | Gatekeeper, XProtect, Firewall, Ausnahmen | Secrets, Capabilities, privilegierte Container |
| Dienste | Windows Services, Autostart | systemd, cron, user services | systemd nur wenn verfügbar | LaunchAgents, Login Items | Restart-Policy, Healthchecks |
| Exposure | Firewall, RDP, SMB, lokale Ports | SSH, Firewall, offene Ports | WSL-Netzwerk, forwarded Ports | Firewall, Sharing-Dienste | `127.0.0.1` vs. `0.0.0.0`, Ingress |

## Agentenablauf

1. Repo-Modus, Sichtbarkeit, Git-Status und offene Issues prüfen.
2. Erststart-Konfiguration prüfen oder öffnen.
3. Hostdaten nur in `operational` oder `local-only` schreiben.
4. Baseline erfassen und sensible Ausgaben redigieren.
5. Gute Muster als vorhandene Zielzustände dokumentieren.
6. Schlechte Muster nur mit konkreter Begründung markieren.
7. Generische Erkenntnisse in passende Vorlagen übertragen.
8. Vor systemwirksamen Änderungen Soll-Ist-Abgleich, Freigabe, Rollback und Validierung herstellen.

## Nicht-Ziele

- keine pauschale Masseninstallation
- keine maximale Härtung auf Kosten normaler Nutzung
- keine Speicherung von Klartext-Secrets
- keine Hostdaten im öffentlichen Template
- kein Cleanup ohne Datenklassifikation
- keine zweite Paketmanager-, Docker- oder Security-Welt ohne klare Begründung
