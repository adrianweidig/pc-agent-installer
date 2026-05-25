# Erststart- und Agenten-Konfiguration

## Ziel

Der PC Agent Installer soll für sehr unterschiedliche Nutzer funktionieren: normale Nutzer, Power-User und Entwickler. Deshalb muss der Agent vor echter Host-Arbeit zuerst eine verständliche Agenten-Konfiguration öffnen.

Ohne abgeschlossene Erststart-Konfiguration darf der Agent keine Host-Baseline, Installation, Sicherheitsänderung, Firewall-Regel, Blockliste oder andere systemwirksame Arbeit starten.

## Nutzerfluss

Der Nutzer soll keine Skriptliste auswendig kennen. Diese Aufforderungen reichen als Startsignal:

```text
Codex, in diesem Verzeichnis starte die Erstkonfiguration.
Codex, starte die Agenten-Konfiguration für meinen PC.
Codex, öffne die Agenten-Konfiguration erneut und deaktiviere Portainer.
```

Der Agent muss dann:

1. `AGENTS.md` und `Vorlage/common/00-agent-regeln.md` lesen.
2. Repo-Modus, Sichtbarkeit und Git-Status prüfen.
3. Bei öffentlichem oder ungeprüftem Template keine Hostdaten schreiben.
4. Falls Hostdaten nötig sind, eine private Operational-Kopie oder einen `local-only`-Klon nutzen.
5. Die Agenten-Konfiguration per passendem Werkzeug öffnen.
6. Die Auswahl unter `hosts/<HOSTNAME>/state/first-run-config.yaml` speichern.
7. Danach anhand der gespeicherten Präferenzen, Baseline und Vorlagen entscheiden, welche Schritte sinnvoll und freigabepflichtig sind.

Wenn die Datei bereits existiert, wird sie als Vorbelegung genutzt. Die Konfiguration ist damit nicht nur Erststart, sondern auch Folgekonfiguration.

## Windows

Windows nutzt bevorzugt einen PowerShell-Dialog. Der Agent startet ihn, wenn die Regeln und der Repo-Modus Host-Schreibzugriff erlauben:

```powershell
./scripts/common/first-run-config.ps1
```

Wenn kein GUI-Fenster verfügbar ist, fällt das Werkzeug auf Terminal-Fragen zurück.

## Linux, WSL und macOS

Unix-nahe Umgebungen nutzen den Shell-Dialog:

```bash
bash ./scripts/common/first-run-config.sh
```

## Pflichtprüfung

Vor Host-Arbeit muss der Agent prüfen:

```powershell
./scripts/common/assert-first-run-config.ps1
```

```bash
bash ./scripts/common/assert-first-run-config.sh
```

Wenn die Prüfung fehlschlägt und der Nutzer nicht gerade die Konfiguration starten will, muss der Agent abbrechen und melden, dass die Konfiguration für den Erststart noch nicht abgeschlossen ist. Wenn der Nutzer die Konfiguration starten oder ändern will, ist `first-run-config.*` der nächste sinnvolle Schritt.

## Abgefragte Entscheidungen

- kurze Nutzerbeschreibung, z. B. `Ich bin Entwickler`, `Ich nutze den PC für Büro und WhatsApp` oder `Ich spiele und streame`
- Host-Baseline erfassen und dokumentieren
- usability-first Sicherheitsempfehlungen anzeigen
- kostenlose, aktuelle Tools und Updates empfehlen
- Betriebssystem-, App- und Paketupdates prüfen
- Paketquellen, Stores und Dritt-Repositories auf Plausibilität prüfen
- Datenträgerzustand, Dateisystem, Speicherplatz und Workspace-Eignung bewerten
- Geräteverschlüsselung wie BitLocker, FileVault oder LUKS empfehlen
- Security-Ausnahmen wie Antivirus-Exclusions, Allowlisten und Firewall-Ausnahmen prüfen
- Autostart, Dienste und Hintergrundprozesse bewerten
- Workspace-Hygiene, lokale Backups, Duplikate und veraltete Arbeitskopien prüfen
- Entwickler-Toolchains, Paketmanager und parallele Laufzeitumgebungen bewerten
- Container-Ports, Volumes, Netzwerke und Secret-Referenzen prüfen
- optionalen kostenlosen On-Demand-Malware-Scanner anbieten
- DNS-/Host-Blocklisten nur im Pilotmodus anbieten
- IP-Firewall-Blocklisten als riskante Option anbieten
- Windows: WSL-Backend für Linux-Tools vorbereiten
- Windows: Docker mit WSL-Unterstützung einplanen
- Windows: Portainer CE als Docker-Verwaltungsoberfläche empfehlen
- vor systemwirksamen Änderungen immer bestätigen lassen

## Schalter und Rücknahme

Alle Entscheidungen sind Präferenz-Schalter für den Agenten:

- `true` erlaubt Empfehlungen, Prüfungen oder später freigegebene Arbeiten in diesem Bereich.
- `false` deaktiviert künftige Empfehlungen oder Vorbereitungen in diesem Bereich.
- Eine Deaktivierung rollt vorhandene Änderungen nicht automatisch zurück.

Wenn der Nutzer eine Option deaktiviert, deren Wirkung bereits umgesetzt wurde, muss der Agent den tatsächlichen Zustand prüfen. Dafür nutzt er vorhandene Change-Einträge, Rollback-Dateien, Baseline-Daten, Paketmanager-, Dienst-, Container- oder Firewall-Zustand und den Soll-Ist-Abgleich. Erst danach darf er einen Rückbau planen oder ausführen.

Beispiele:

- Docker-Empfehlungen deaktivieren bedeutet zunächst: keine neuen Docker-Schritte vorbereiten.
- Wenn Docker bereits installiert oder Container vorhanden sind, muss der Agent Volumes, Daten, Dienste und Abhängigkeiten prüfen, bevor er eine Entfernung vorschlägt.
- WSL wieder aktivieren bedeutet: WSL-Vorlagen erneut berücksichtigen, aber nichts ohne Baseline, Freigabe und Rollback installieren.

## Windows-Zusatzkomponenten

Die Windows-Erstkonfiguration fragt WSL, Docker und Portainer abhängig voneinander ab:

1. WSL kann als optionales Backend für Linux-Tools, Entwickler-Workflows, KI-Stacks und Container-nahe Aufgaben gewählt werden.
2. Docker wird nur sinnvoll angeboten, wenn WSL gewählt wurde.
3. Portainer CE wird nur sinnvoll angeboten, wenn Docker gewählt wurde.

Wenn WSL gewählt wurde, muss der Agent zusätzlich die WSL-Vorlagen und WSL-Empfehlungen berücksichtigen. Bei Docker oder Portainer müssen zusätzlich die Container-Vorlagen berücksichtigt werden. Die Baseline dokumentiert dies über `template_paths_used` und `windows_optional_components` in `hosts/<HOSTNAME>/host.yaml`.

Keine dieser Optionen installiert automatisch Software. Sie erlaubt dem Agenten nur, passende Empfehlungen, Prüfungen und spätere freigegebene Installationsschritte vorzubereiten. Vor einer tatsächlichen Änderung bleiben Baseline, Frage-Antwort-Entscheidung, Rollback und Validierung Pflicht.

## Nutzerbeschreibung und Programmempfehlungen

Die Erststart-Konfiguration speichert unter `user_context.person_description` eine kurze, vom Nutzer formulierte Beschreibung. Der Agent nutzt sie, um Zielgruppenprofile abzuleiten und passende Programmkategorien vorzuschlagen.

Beispiele:

- `Ich bin Entwickler` führt zu Vorschlägen für Git, Terminal, Editor, SDKs, WSL oder Container, aber nicht automatisch zu Gaming- oder Messenger-Apps.
- `Ich nutze den PC für Büro, WhatsApp und Fotos` führt zu alltagstauglichen Vorschlägen wie Browser/Web-Apps, Passwortmanager, Office/PDF, Medien und Backup.
- `Ich spiele und streame` führt zu Vorschlägen für Spieleplattformen, Voice, OBS und GPU-Prüfung, aber nicht zu Server- oder Homelab-Tools.

Die Beschreibung ist keine Installationsfreigabe. Sie steuert nur, welche Vorschläge der Agent priorisiert. Details stehen in `docs/17-programm-und-installationsempfehlungen.md`.

## Allgemeine Computerkonfiguration

Die Erststart-Konfiguration soll auch wiederverwendbare Muster aus echten Rechnern erfassen, ohne Hostdetails ins öffentliche Template zu schreiben. Gute Muster können als Zielzustände übernommen werden, schlechte Muster nur mit Begründung als Anti-Pattern.

Der Agent bewertet insbesondere:

- aktive eingebaute Schutzmechanismen
- gesunde und geeignete Datenträger für Arbeitsdaten
- nachvollziehbare Update- und Paketquellenpflege
- schmale, zweckgebundene Security-Ausnahmen
- passende Verschlüsselung mit Recovery-Key-Plan
- klare Trennung zwischen Windows, WSL, Linux, macOS und Container-Stacks
- lokale statt globale Container-Exposition, wenn Dienste nur lokal gebraucht werden
- Secret-Referenzen statt roher Env-, Log- oder Credential-Dumps

Die generischen Regeln stehen in `docs/20-allgemeine-computer-konfiguration.md`.

## Sicherheitsgrenzen

- Die Erststart-Konfiguration speichert keine Passwörter, Tokens oder Lizenzschlüssel.
- Hostdaten werden nur in bestätigtem `operational`- oder `local-only`-Modus geschrieben.
- Das öffentliche Template bleibt frei von Hostdaten.
- Die gespeicherten Präferenzen sind kein Freifahrtschein für destruktive Änderungen; systemwirksame Änderungen brauchen weiterhin Baseline, Rollback und Validierung.
- Persistentes Agenten-Memory darf auf diese Konfigurationsumgebung verweisen, ersetzt aber keine aktuelle Repo-, Sichtbarkeits- und Host-Schreibrechteprüfung.
