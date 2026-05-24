# Klassische Sicherheitseinstellungen für normale Nutzer-PCs

## Zielbild

Dieses Template geht bei normalen Nutzer-PCs davon aus, dass der Rechner weiterhin möglichst alles aus dem Internet nutzen können soll: Browser, Downloads, Games, Tools, Messenger, Cloud-Sync, Entwicklerwerkzeuge, KI-Tools, portable Apps und gelegentlich auch Spezialsoftware.

Sicherheit soll deshalb standardmäßig nach diesem Prinzip umgesetzt werden:

1. Keine unnötigen Blockaden.
2. Keine nicht nachvollziehbaren Tuning- oder Debloat-Eingriffe.
3. Erst eingebaute Betriebssystemfunktionen sauber aktivieren.
4. Kostenlose, seriöse Zusatztools nur empfehlen, wenn sie echten Nutzen bringen.
5. Riskante oder störanfällige Härtung nur optional, testweise und rollbackfähig.

## Grundregeln

- Installiere nach Möglichkeit die aktuellste stabile Version über den offiziellen Store, `winget`, Herstellerseite oder Paketmanager.
- Vermeide dubiose Download-Portale, Bundle-Installer und angebliche Driver-Updater.
- Installiere keine zweite Echtzeit-Antivirus-Lösung parallel zu Microsoft Defender, wenn kein konkreter Grund vorliegt.
- Ändere keine DNS-, Firewall-, Browser- oder Exploit-Regeln so streng, dass normale Internetnutzung regelmäßig bricht.
- Dokumentiere jede systemwirksame Änderung in einer privaten oder lokalen Operational-Struktur, nicht im öffentlichen Template.
- Lege vor riskanten Änderungen einen Rollback-Pfad fest.

## Empfohlener Basisschutz

### Windows Security

Für Windows-10- und Windows-11-Nutzer ist Microsoft Defender der Standard-Basisschutz. Er ist kostenlos, integriert, updatefähig und verursacht in der Regel weniger Kompatibilitätsprobleme als zusätzliche Security-Suites.

Sinnvoll zu prüfen oder zu aktivieren:

- Echtzeitschutz
- Cloudbasierter Schutz
- Automatische Beispielübermittlung, sofern der Nutzer zustimmt
- Manipulationsschutz
- SmartScreen für Microsoft Edge und Apps
- Reputation-based Protection
- Firewall für private und öffentliche Netzwerke
- automatische Windows-Updates
- automatische Microsoft-Store-App-Updates

Nur vorsichtig und testweise:

- Controlled Folder Access
- strikte Exploit-Protection-Ausnahmen
- harte Firewall-Ausgangsregeln
- blockierende DNS-Filter
- App-Control-Regeln wie WDAC oder AppLocker

Diese Maßnahmen können legitime Programme, Spiele, Updater, Entwicklerwerkzeuge oder KI-Tools stören und gehören deshalb nicht in den blockadefreien Default.

### Browser

Empfohlen ist ein aktueller Browser aus offizieller Quelle. Sinnvolle kostenlose Ergänzungen:

- Passwortmanager-Integration oder ein seriöser Passwortmanager mit kostenlosem Plan
- Werbe- und Tracking-Schutz nur so konfigurieren, dass Webseiten weiter funktionieren
- HTTPS-only-Modus nur aktivieren, wenn der Nutzer mit gelegentlichen Warnseiten umgehen kann
- Downloads nicht blind ausführen; SmartScreen oder Browser-Warnungen ernst nehmen

Mögliche kostenlose Tools:

- Bitwarden Free als Passwortmanager
- uBlock Origin oder uBlock Origin Lite, je nach Browser-Unterstützung
- Microsoft Defender Browser Protection nur, wenn für den verwendeten Browser sinnvoll verfügbar

### Updates

Der wichtigste klassische Schutz ist ein aktueller Patch-Stand.

Windows:

```powershell
winget upgrade
winget upgrade --all
```

Vor automatischen Massenupdates sollte ein Agent prüfen:

- ob `winget` verfügbar ist
- welche Pakete aktualisiert würden
- ob kritische Arbeitsprogramme betroffen sind
- ob Neustarts zu erwarten sind

Linux:

```bash
sudo apt update
sudo apt upgrade
```

oder der passende Paketmanager der Distribution. Distribution und Paketmanager müssen vorher erkannt werden.

### Konten und Anmeldung

Empfohlen:

- normaler Nutzeraccount für Alltagsarbeit
- Adminrechte nur bei Bedarf
- Windows Hello, PIN oder starkes Passwort
- Microsoft- oder Dienstkonten mit MFA, wenn sinnvoll
- keine Passwortwiederverwendung
- keine Klartext-Passwortlisten im Dateisystem

Nicht als Default erzwingen:

- täglicher Standardnutzer ohne jede Admin-Möglichkeit, wenn der Nutzer regelmäßig Software installiert
- aggressive Sperr- und Timeout-Regeln, die Alltagsnutzung stören

### Backup und Wiederherstellung

Ohne Backup ist Security unvollständig. Für normale PCs ist ein einfaches, zuverlässiges Backup wichtiger als komplexe Härtung.

Empfehlenswert:

- Windows-Dateiversionsverlauf oder ein anderes nachvollziehbares Datei-Backup
- OneDrive, Nextcloud, Seafile oder ein vergleichbarer Sync nur für geeignete Daten
- regelmäßige Wiederherstellungsprüfung
- Wiederherstellungspunkt vor riskanten Systemänderungen, sofern Windows-Systemschutz aktiv ist

Ransomware-Schutz darf normale Arbeitsordner nicht ungetestet blockieren.

## Kostenlose Zusatztools mit geringem Blockaderisiko

Diese Tools können empfohlen werden, sollen aber nicht blind installiert werden:

| Bereich | Tool-Beispiele | Nutzen | Default |
| --- | --- | --- | --- |
| Passwortmanager | Bitwarden Free, KeePassXC | starke, eindeutige Passwörter | empfehlen, Nutzer entscheidet |
| Browser-Schutz | uBlock Origin, uBlock Origin Lite | weniger Werbung und Tracking | empfehlen, nicht erzwingen |
| On-Demand-Malware-Scan | Malwarebytes Free | Zweitmeinung ohne permanenten Echtzeitschutz | optional |
| Software-Updates | `winget` | zentrale Aktualisierung vieler Apps | prüfen und dokumentieren |
| Datei-Integrität | Windows Defender Offline Scan | Prüfung bei Verdacht | nur bei Anlass |

Keine Standardempfehlung:

- Registry-Cleaner
- Driver-Updater von Drittanbietern
- aggressive System-Cleaner
- kostenlose VPNs unbekannter Anbieter
- mehrere gleichzeitige Echtzeit-Antivirus-Produkte
- pauschale Telemetrie- oder Dienst-Deaktivierung ohne Nebenwirkungsprüfung

## Agentenablauf für normale PCs

1. Repo-Modus und Sichtbarkeit prüfen.
2. Betriebssystem, Version, Edition und Nutzerkontext erkennen.
3. Baseline erfassen: Defender, Firewall, Updates, Browser, installierte Programme, Autostart, lokale Admins.
4. Nur sichere Defaults direkt empfehlen.
5. Jede störanfällige Maßnahme als optional markieren.
6. Vor Installation oder Aktivierung prüfen, ob das Tool kostenlos, aktuell und aus offizieller Quelle verfügbar ist.
7. Änderung mit Rollback und Validierung dokumentieren.
8. Nach der Änderung normale Nutzung kurz gegenprüfen: Browser, Downloads, Updates, Store, häufig genutzte Apps.

## Frage-Antwort-Standard

Sicherheitsmaßnahmen mit Installations-, Dienst-, Firewall-, DNS- oder Blocklist-Wirkung werden nicht stillschweigend umgesetzt. Der Agent stellt eine konkrete Frage, erklärt den Tradeoff und dokumentiert die Antwort.

Standardantworten:

- `Ja`: umsetzen, dokumentieren, validieren und Rollback-Pfad anlegen.
- `Nein`: nicht umsetzen und als bewusste Entscheidung dokumentieren.
- `Später`: nicht umsetzen, aber als offene optionale Maßnahme notieren.

Beispiel AV:

```text
Möchtest du einen kostenlosen, sinnvollen Malware-Scanner einrichten, der normale Installationen und Alltagsnutzung möglichst nicht blockiert?
```

Empfohlene Defaults:

- Windows: Microsoft Defender bleibt der primäre Echtzeitschutz; ClamAV nur optional als On-Demand-Zweitscanner.
- Linux: ClamAV optional für Downloads, Austauschordner, Mail-/Dateiserver oder Windows-Dateien.
- WSL: Windows Defender schützt die Windows-Seite; ClamAV in WSL nur bei konkretem Scanbedarf.
- macOS: eingebaute Schutzmechanismen beibehalten; ClamAV optional für On-Demand-Scans.

Wenn ClamAV installiert wird, soll der Agent FreshClam-Signaturupdates über den passenden Dienst, Timer oder eine dokumentierte Update-Routine einrichten, sofern die Plattform das zuverlässig unterstützt.

## Betriebssystem-Matrix

| Fähigkeit | Windows | Linux | WSL | macOS |
| --- | --- | --- | --- | --- |
| Baseline | Windows Security, Firewall, Updates, installierte Programme | Distribution, Paketmanager, Firewall, Dienste | WSL-Version, Distribution, Mounts, Paketmanager | Systemversion, Gatekeeper/XProtect, Firewall, Paketmanager |
| Primärer Schutz | Microsoft Defender | Paketupdates, Firewall, Berechtigungen | Windows Defender plus Linux-Paketpflege | eingebaute Apple-Schutzmechanismen |
| Kostenloser Zusatzscanner | ClamAV optional on-demand | ClamAV optional on-demand oder daemonbasiert | ClamAV nur optional in der Distribution | ClamAV optional on-demand |
| Signaturupdates | FreshClam-Dienst nur bei ClamAV | FreshClam-Service oder Timer | FreshClam-Service oder Timer nur bei systemd | FreshClam nach Installationsweg |
| Blocklisten | DNS-/Host-Pilot bevorzugt | DNS-/Host-Pilot bevorzugt | meist Windows-seitig sinnvoller | DNS-/Host-Pilot bevorzugt |
| IP-Firewall-Listen | nicht Default | eher Server/Router | nur bei exponierten Diensten | nicht Default |

## Blocklisten und Firewall-Blacklists

Blocklisten können sinnvoll sein, sind aber eine der häufigsten Quellen für unerwartete Nebenwirkungen. Für normale Nutzer-PCs gilt:

1. DNS- oder Host-Blocklisten zuerst testen.
2. Leichte oder normale Profile bevorzugen.
3. Allowlist und Rollback vorbereiten.
4. IP-Firewall-Listen nicht global als Default aktivieren.
5. Nach Aktivierung Browser, Downloads, Updates, Store, Paketmanager, Git, Cloud-Sync, Games und KI-Tools prüfen.

Sinnvolle öffentliche Quellen für Pilotbetrieb:

- HaGeZi DNS Blocklists für DNS-basierte Profile von leicht bis aggressiv.
- StevenBlack hosts als konsolidierte Host-Datei mit Varianten.
- URLhaus für Malware-URL-Intelligence, eher für Tools und Security-Integrationen als für blinde Desktop-Firewall-Regeln.
- FireHOL IP Lists oder Spamhaus DROP/EDROP nur bewusst für IP-basierte Firewall-Szenarien, vor allem Router, Server oder exponierte Dienste.

Der Agent darf keine Blockliste als "muss immer blockiert werden" behandeln. Jede Liste kann False Positives enthalten oder legitime Dienste stören.

## Nicht-Ziele

- keine maximale Härtung auf Kosten der Nutzbarkeit
- keine Enterprise-Sicherheitsrichtlinien für normale Privat-PCs als Default
- keine pauschale Blockade von Skripten, Downloads, Entwicklertools oder KI-Tools
- keine Installation proprietärer Security-Suites ohne ausdrückliche Entscheidung
- keine Speicherung von Passwörtern, Tokens oder Lizenzschlüsseln

## Manuelle Entscheidungen

Der Nutzer oder Maintainer entscheidet pro Host:

- ob ein Passwortmanager eingerichtet werden soll
- ob ein Browser-Blocker genutzt wird
- ob Controlled Folder Access testweise aktiviert wird
- ob DNS-Filter gewünscht sind
- ob lokale Adminrechte reduziert werden sollen
- welches Backup-Ziel verwendet wird
- ob optionale On-Demand-Scanner installiert werden

## Quellen für Maintainer

- ClamAV-Dokumentation: `https://docs.clamav.net/`
- ClamAV Services: `https://docs.clamav.net/manual/Usage/Services.html`
- ClamAV Signature Management: `https://docs.clamav.net/manual/Usage/SignatureManagement.html`
- HaGeZi DNS Blocklists: `https://github.com/hagezi/dns-blocklists`
- StevenBlack hosts: `https://github.com/StevenBlack/hosts`
- URLhaus von abuse.ch und Spamhaus: `https://urlhaus.abuse.ch/`
- FireHOL IP Lists: `https://iplists.firehol.org/`
- Spamhaus Blocklists: `https://www.spamhaus.org/blocklists/`
