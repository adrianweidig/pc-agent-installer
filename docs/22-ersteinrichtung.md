# Vollständige Ersteinrichtung

## Zielbild

PC Agent Installer soll einen echten Systemadministrator für die initiale Grundkonfiguration eines frisch installierten PCs oder Servers ersetzen. Der Nutzer installiert das Betriebssystem und startet danach den Agenten in einer geprüften privaten Operational-Kopie oder einem `local-only`-Klon.

Der Agent führt nicht nur Inventarisierung aus. Eine Plattform gilt erst als erstkonfiguriert, wenn ein dokumentierter Sollzustand umgesetzt, geprüft und rollbackfähig dokumentiert wurde.

## Vollzugriff-Hinweis

Vor echter Ersteinrichtung muss der Nutzer klar informiert werden:

- Der Agent benötigt absolute Systemrechte.
- Unter Windows handelt er als Administrator.
- Unter Linux handelt er als root oder über sudo.
- Unter macOS handelt er mit Administratorrechten und gezielten `sudo`-Aktionen.
- In WSL, Containern oder Serverprofilen gelten die jeweiligen root-, sudo- oder Runtime-Rechte.

Ohne diese Rechte kann der Agent Firewall, Paketmanager, Dienste, Benutzer, Gruppen, Sicherheitsrichtlinien und Systempakete nicht vollständig einrichten. Dann darf er nur vorbereiten, analysieren oder eine Blockade dokumentieren.

Für Codex-Läufe ist dafür ein passendes Root-/Admin-Profil oder eine als root gestartete isolierte Umgebung erforderlich. Details stehen in [docs/23-codex-root-profil.md](23-codex-root-profil.md).

Vollzugriff ist trotzdem keine Blankofreigabe. Vor Installationen, Dienständerungen, Firewall-Regeln, Löschungen, Paketmanager-Aktionen oder Sicherheitsrichtlinien braucht der Agent Erststart-Konfiguration, Infrastruktur-Snapshot, Soll-Ist-Abgleich, Risiko- und Duplikatprüfung, Rollback-Pfad und Nutzerfreigabe.

## Mindestumfang

Eine vollständige Ersteinrichtung muss pro Betriebssystem mindestens diese Bereiche behandeln:

| Bereich | Erwartung |
| --- | --- |
| Paketquellen und Updates | Offizielle Quellen prüfen, Paketmanager funktionsfähig machen, Update-Strategie dokumentieren |
| Basispakete | OS-spezifische Standardwerkzeuge installieren oder begründet auslassen |
| Benutzer und Gruppen | Nutzer, Admin-/sudo-Rechte, Gruppenmitgliedschaften und Login-Shells prüfen oder einrichten |
| Rechte und Policy | sudoers, UAC, Dateirechte, umask und sensible Pfade bewerten |
| Firewall und Netzwerk | Firewall aktivieren oder Zielzustand begründen, offene Ports und Exposure prüfen |
| Dienste | notwendige Dienste aktivieren, unnötige Dienste identifizieren, Startverhalten dokumentieren |
| Sicherheit | Plattformschutz, Updates, SSH, Paketquellen, Secrets, Ausnahmen und Härtung prüfen |
| Programme | profilabhängige Tools installieren oder als Vorschlag mit Freigabe vorbereiten |
| Rollback | Änderungen mit Rückbaupfad dokumentieren |
| Validierung | Umsetzung mit konkreten Tests nachweisen |

## OS-übergreifende Regel aus dem Debian-Test

Der Debian-E2E-Lauf hat eine Grundannahme bestätigt: Baseline-Erfassung ist nicht genug. Der Installer kann nur dann als Ersteinrichtungs-Agent bewertet werden, wenn er im Zielsystem wirklich mit den notwendigen Vollrechten läuft und dadurch Paketmanager, Benutzer, Gruppen, Dienste, Firewall und Sicherheitsrichtlinien tatsächlich ändern kann.

Diese Regel gilt für alle Plattformen:

- Ein Analyseprofil darf Zustand erfassen und Lücken dokumentieren.
- Ein Vollzugriff-Profil ist Pflicht, sobald die Ersteinrichtung umgesetzt werden soll.
- Wenn Vollzugriff fehlt, muss der Agent den Lauf als blockiert markieren.
- Eingeschränkte Testumgebungen wie Container, WSL oder CI müssen ihre Grenzen ausdrücklich ausweisen.
- Ein erfolgreicher Skript-Exit ersetzt keine OS-spezifische Zustandsprüfung.

## Plattform-Mindestziele

### Windows

Für Windows bedeutet vollständige Ersteinrichtung mindestens:

- Codex in erhöhter Administrator-Sitzung starten, wenn systemweite Änderungen geplant sind.
- Windows-Version, Edition, Aktivierungs- und Update-Kontext erfassen.
- Windows Update, Microsoft Store oder `winget` als Installationspfade prüfen.
- Benutzer, lokale Gruppen, UAC-Kontext und Administratorrechte bewerten.
- Windows Defender, Firewall-Profile, Netzwerkprofile und Basis-Sicherheitsrichtlinien prüfen.
- Windows Features, Dienste, Autostart und Registry-Änderungen nur mit Soll-Ist-Abgleich durchführen.
- Programme profilabhängig und bevorzugt aus offiziellen Quellen installieren oder vorschlagen.
- Rollback für Features, Dienste, Firewall-Regeln, Registry-Änderungen und installierte Pakete dokumentieren.

### Linux allgemein

Für Linux außerhalb spezieller Familien bedeutet vollständige Ersteinrichtung mindestens:

- Codex als root oder mit bewusst freigegebenem sudo-Kontext starten.
- Distribution, init-System, Paketmanager, Repositories und Signaturstatus erfassen.
- Updates, Basispakete, Shell-Umgebung, SSH, Firewall und Zeit/Locale-Konfiguration umsetzen oder begründet auslassen.
- Benutzer, Gruppen, sudoers, Home-Verzeichnisse, Login-Shells und sensible Dateirechte prüfen.
- systemd-Units, fehlgeschlagene Dienste, offene Ports, SUID/SGID-Dateien und welt-schreibbare Pfade bewerten.
- Familien-spezifische Paketmanager wie `apt`, `dnf`, `pacman` oder `rpm-ostree` nicht generisch vermischen.

## Debian-Mindestziel

Für Debian bedeutet vollständige Ersteinrichtung mindestens:

- APT-Quellen und Signaturstatus prüfen.
- `apt update` und Update-Bereitschaft prüfen.
- Basispakete für Administration, Diagnose, Netzwerk, Git und Shell-Umgebung definieren.
- Benutzer, Gruppen, sudo-Konfiguration und Home-Verzeichnisse prüfen oder einrichten.
- SSH-Konfiguration prüfen, besonders Root-Login und Passwort-Authentifizierung.
- Firewall-Zielzustand definieren, zum Beispiel `ufw` oder `nftables`, und aktivieren, wenn freigegeben.
- systemd-Dienste und fehlgeschlagene Units prüfen.
- Locale, Zeitzone, Hostname und globale Environment-Dateien prüfen.
- SUID/SGID, welt-schreibbare Pfade und sensible Dateien bewerten.
- Jede Änderung in `hosts/<HOSTNAME>/changes/` mit Rollback-Hinweis dokumentieren.

Wenn ein Test nur Baseline-Dateien erzeugt, ist Debian noch nicht vollständig erstkonfiguriert.

Der generische Apply-Einstieg liegt unter `scripts/bash/apply-debian-firstconfig.sh`. Er darf nur im bestätigten Operational- oder `local-only`-Kontext und mit ausdrücklicher Freigabe über `PC_AGENT_ALLOW_SYSTEM_CHANGES=true` laufen.

### RHEL, Fedora, Rocky und AlmaLinux

Für RHEL-nahe Systeme bedeutet vollständige Ersteinrichtung mindestens:

- Codex als root oder mit sudo starten.
- `dnf`, Repositories, Modulstreams, GPG-Keys und Paketquellen prüfen.
- Basispakete, `firewalld` oder `nftables`, SELinux-Status, SSH und systemd-Dienste bewerten.
- Benutzer, Gruppen, sudoers und Policy-Ausnahmen dokumentieren.
- Bei immutable Varianten wie Fedora Silverblue keine klassischen Paketannahmen treffen und `rpm-ostree` gesondert behandeln.

### Arch Linux

Für Arch bedeutet vollständige Ersteinrichtung mindestens:

- Codex als root oder mit sudo starten.
- `pacman.conf`, Mirrorlist, Signaturen, Keyring und Updatefähigkeit prüfen.
- Basispakete, Benutzer, Gruppen, sudoers, systemd, Firewall und SSH konfigurieren.
- AUR nur nach ausdrücklicher Freigabe nutzen und nie als Standardquelle für Basissicherheit behandeln.

### macOS

Für macOS bedeutet vollständige Ersteinrichtung mindestens:

- Codex in einem Administrator-Konto mit gezielter sudo-Fähigkeit starten.
- macOS-Version, Hardwarearchitektur, Gatekeeper, XProtect, Firewall, FileVault und Updatezustand erfassen.
- Homebrew oder MacPorts nur verwenden, wenn vorhanden oder ausdrücklich freigegeben.
- Benutzer, Gruppen, Login Items, LaunchAgents/LaunchDaemons und systemweite Profile prüfen.
- Sicherheitsänderungen an FileVault, Firewall, Datenschutzrechten oder MDM-nahen Bereichen nur mit dokumentierter Nutzerentscheidung durchführen.

### WSL

Für WSL bedeutet vollständige Ersteinrichtung mindestens:

- root/sudo innerhalb der Distribution prüfen.
- Distribution, Paketmanager, DNS, Netzwerk, Windows-Mounts und Interop-Kontext erfassen.
- Klar trennen, ob Änderungen nur die Distribution oder Windows-seitige WSL-Konfiguration betreffen.
- Windows-seitige WSL-, Docker-, Netzwerk- oder Portainer-Änderungen nur mit Windows-Administratorfreigabe planen.
- Container- oder Docker-Zugriffe aus WSL gesondert als Runtime-Rechte bewerten.

### Container und Orchestrierung

Für Containerumgebungen bedeutet vollständige Ersteinrichtung mindestens:

- root-, Capability- und Runtime-Kontext dokumentieren.
- Host-Mounts, Volumes, Netzwerke, Ports, Secrets und Images vor Änderungen erfassen.
- Container-interne Änderungen von Host-, Daemon-, Compose-, Swarm- oder Kubernetes-Änderungen trennen.
- Privilegierte Container, Host-Netzwerk, schreibbare Host-Mounts und Secret-Mounts nur nach ausdrücklicher Freigabe nutzen.
- Bei systemd-losen Containern Diensttests als eingeschränkt markieren und Unit-Dateien statisch prüfen.

## Bewertungskriterium

Ein Lauf ist nicht erfolgreich abgeschlossen, nur weil Skripte ohne Fehler enden. Erfolgreich ist er erst, wenn:

1. der Nutzer Vollzugriff bewusst verstanden und freigegeben hat,
2. der OS-spezifische Sollzustand dokumentiert ist,
3. der Ist-Zustand geprüft wurde,
4. die notwendigen Systemänderungen umgesetzt wurden,
5. Idempotenz geprüft wurde,
6. Sicherheits- und Dienstzustand geprüft wurden,
7. Rollback-Pfade dokumentiert sind,
8. der Abschlussbericht klar sagt, was umgesetzt, ausgelassen oder blockiert wurde.

## Konsequenz für Tests

Tests dürfen Baseline-Erfassung als funktionsfähig markieren, aber nicht als vollständige Ersteinrichtung bewerten. Eine Testsuite muss explizit ausweisen, ob sie nur Guard-, Baseline- oder Readiness-Tests ausführt oder ob sie die tatsächliche OS-Ersteinrichtung mit Paket-, Benutzer-, Dienst-, Firewall- und Sicherheitsänderungen prüft.
