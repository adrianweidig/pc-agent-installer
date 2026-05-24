# Erststart-Konfiguration

## Ziel

Der PC Agent Installer soll für sehr unterschiedliche Nutzer funktionieren: normale Nutzer, Power-User und Entwickler. Deshalb muss der Agent vor echter Host-Arbeit zuerst eine verständliche Erststart-Konfiguration öffnen.

Ohne abgeschlossene Erststart-Konfiguration darf der Agent keine Host-Baseline, Installation, Sicherheitsänderung, Firewall-Regel, Blockliste oder andere systemwirksame Arbeit starten.

## Nutzerfluss

1. Nutzer erstellt eine private oder lokale Operational-Kopie.
2. Nutzer startet die Erststart-Konfiguration.
3. Der Agent zeigt ein Fenster oder einen Terminal-Dialog.
4. Der Nutzer wählt aus, was der Agent grundsätzlich darf.
5. Die Auswahl wird unter `hosts/<HOSTNAME>/state/first-run-config.yaml` gespeichert.
6. Erst danach darf der Agent Host-Arbeit ausführen.

## Windows

Windows nutzt bevorzugt einen PowerShell-Dialog:

```powershell
./scripts/common/first-run-config.ps1
```

Wenn kein GUI-Fenster verfügbar ist, fällt das Skript auf Terminal-Fragen zurück.

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

Wenn die Prüfung fehlschlägt, muss der Agent abbrechen und melden, dass die Konfiguration für den Erststart noch nicht abgeschlossen ist.

## Abgefragte Entscheidungen

- Host-Baseline erfassen und dokumentieren
- usability-first Sicherheitsempfehlungen anzeigen
- kostenlose, aktuelle Tools und Updates empfehlen
- optionalen kostenlosen On-Demand-Malware-Scanner anbieten
- DNS-/Host-Blocklisten nur im Pilotmodus anbieten
- IP-Firewall-Blocklisten als riskante Option anbieten
- vor systemwirksamen Änderungen immer bestätigen lassen

## Sicherheitsgrenzen

- Die Erststart-Konfiguration speichert keine Passwörter, Tokens oder Lizenzschlüssel.
- Hostdaten werden nur in bestätigtem `operational`- oder `local-only`-Modus geschrieben.
- Das öffentliche Template bleibt frei von Hostdaten.
- Die gespeicherten Präferenzen sind kein Freifahrtschein für destruktive Änderungen; systemwirksame Änderungen brauchen weiterhin Baseline, Rollback und Validierung.
