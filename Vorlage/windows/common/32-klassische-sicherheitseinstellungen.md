---
id: WINDOWS-COMMON-32-KLASSISCHE-SICHERHEITSEINSTELLUNGEN
title: Klassische Windows-Sicherheitseinstellungen
platform: windows
environment: native
area: windows/common
requires_admin: true
risk: mittel
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - windows/common
---

# Klassische Windows-Sicherheitseinstellungen

## Zweck
Diese Vorlage beschreibt einen usability-first Prozess für klassische Sicherheitssettings auf normalen Windows-Nutzer-PCs. Ziel ist zusätzlicher Schutz ohne unnötige Blockaden für Browser, Downloads, Store, Games, Entwicklerwerkzeuge, KI-Tools und alltägliche Internetnutzung.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Hostdaten in öffentlichen oder ungeprüften Repositories speichern.
- Keine Klartext-Secrets, Passwörter, Lizenzschlüssel oder privaten Tokens erfassen.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.
- Blockierende Härtung nicht als Default aktivieren, sondern nur ausdrücklich, testweise und rollbackfähig.

## Baseline erfassen
Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- Windows-Version, Edition und Patchstand
- Microsoft-Defender-Status
- Defender-Signaturstand und Echtzeitschutz
- SmartScreen- und reputation-based-protection-Status
- Firewall-Status für Domain, Private und Public Profile
- Windows-Update-Status
- Microsoft-Store-App-Update-Status, falls prüfbar
- BitLocker- oder Geräteverschlüsselungsstatus
- Defender-Ausnahmen nach Breite und Zweck, ohne private Pfade öffentlich zu dokumentieren
- lokale Administratoren
- aktive Browser
- installierte Security-Tools
- Autostart-Einträge mit Sicherheitsrelevanz

## Usability-first Defaults
Empfohlen und in der Regel blockadearm:

- Windows Update aktiv halten.
- Microsoft Defender als primären Echtzeitschutz nutzen.
- Cloudbasierten Defender-Schutz prüfen oder aktivieren, wenn der Nutzer zustimmt.
- Manipulationsschutz prüfen oder aktivieren.
- SmartScreen und reputation-based protection aktiv halten.
- Windows Firewall für alle Profile aktiv halten.
- Eingehende Verbindungen standardmäßig blockieren, sofern keine bekannte Ausnahme nötig ist.
- Defender-Ausnahmen eng, zweckgebunden und überprüfbar halten.
- Geräteverschlüsselung empfehlen, wenn Gerätetyp, Backup und Recovery-Key-Prozess dazu passen.
- WinGet und Microsoft Store für aktuelle App-Versionen nutzen.
- Passwortmanager mit kostenlosem Plan empfehlen, aber nicht ohne Nutzerentscheidung einrichten.
- Browser-Blocker wie uBlock Origin oder uBlock Origin Lite empfehlen, aber nicht hart erzwingen.

## Optionale Maßnahmen mit Blockaderisiko
Diese Maßnahmen nur nach ausdrücklicher Entscheidung, Pilotprüfung und Rollback-Pfad:

- Controlled Folder Access
- blockierende DNS-Filter
- harte ausgehende Firewall-Regeln
- WDAC, AppLocker oder vergleichbare App-Control-Regeln
- aggressive Exploit-Protection-Ausnahmen
- pauschales Deaktivieren von Diensten, Telemetrie oder Skriptfunktionen
- zusätzliche Echtzeit-Antivirus-Suiten
- pauschale Defender-Ausnahmen für ganze Benutzer-, System- oder Programmdatenbereiche
- Aktivierung von BitLocker ohne Recovery-Key- und Backup-Freigabe

## Kostenlose Tool-Empfehlungen
Der Agent darf kostenlose Tools empfehlen, aber nicht blind installieren:

- Bitwarden Free oder KeePassXC für Passwörter.
- uBlock Origin oder uBlock Origin Lite für Browser-Schutz.
- Malwarebytes Free als On-Demand-Zweitmeinung, nicht als zusätzlicher permanenter Echtzeitschutz.
- ClamAV als optionaler On-Demand-Zweitscanner, nicht als Ersatz für Microsoft Defender auf normalen Windows-PCs.
- `winget` für nachvollziehbare Updates aus bekannten Quellen.

Vor jeder Empfehlung prüfen:

- offizielle Quelle oder Paketmanager-ID
- aktuellste stabile Version verfügbar
- kostenlos nutzbar
- keine Bundle- oder Adware-Hinweise aus der Quelle erkennbar
- keine erwartete Blockade normaler Nutzung

## Frage-Antwort-Entscheidungen
Stelle blockierende oder installierende Sicherheitsmaßnahmen nach `Vorlage/common/13-interaktive-sicherheitsentscheidungen.md`.

### Kostenloser Malware-Scanner

Frage:

```text
Möchtest du einen kostenlosen, sinnvollen Malware-Scanner ergänzen, der normale Installationen und Alltagsnutzung möglichst nicht blockiert?
```

Empfohlene Antwortlogik:

- Default: Microsoft Defender als primären Echtzeitschutz beibehalten.
- Optional: ClamAV nur als On-Demand-Zweitscanner installieren.
- Nicht empfohlen: zweites permanentes Echtzeit-AV parallel zu Defender ohne konkreten Grund.

Wenn ClamAV installiert wird:

- offizielle Quelle oder seriöse Paketquelle prüfen,
- Signaturupdates mit FreshClam einrichten,
- unter Windows `freshclam` und bei Bedarf `clamd` als Dienst nur nach Zustimmung installieren,
- Scanpfade gezielt wählen, statt die komplette Alltagsnutzung zu blockieren.

### Blocklisten

Frage:

```text
Möchtest du eine DNS- oder Host-Blockliste gegen Malware, Phishing, Werbung und Tracking im Pilotmodus testen?
```

Empfohlene Antwortlogik:

- Default: Pilotmodus statt dauerhafter Sofortaktivierung.
- DNS-/Host-Blocklisten sind für normale PCs meist blockadearmer als IP-Firewall-Listen.
- HaGeZi Light/Normal oder StevenBlack base sind geeignete Startpunkte, wenn der Nutzer Blocklisten testen möchte.
- IP-Firewall-Blocklisten nur separat testen, weil sie CDNs, Games, Updates, Cloud-Dienste oder Paketquellen brechen können.

## Ablauf
1. Plattform- und Host-Kontext erkennen.
2. Repo-Modus mit `scripts/common/detect-repo-mode.*` prüfen.
3. Wenn Hostdaten geschrieben werden sollen, private oder lokale Operational-Struktur bestätigen.
4. Baseline unter `hosts/<HOSTNAME>/baseline/` dokumentieren.
5. Geplante Änderung unter `hosts/<HOSTNAME>/changes/` dokumentieren.
6. Rollback-Datei unter `hosts/<HOSTNAME>/rollback/` anlegen.
7. Nur blockadearme Defaults direkt umsetzen.
8. Optionale Maßnahmen mit Blockaderisiko separat markieren und nicht zusammen mit Basismaßnahmen bündeln.
9. Validierung ausführen.

## Validierung
Nach Änderungen prüfen:

- Windows Security zeigt keine kritischen Warnungen.
- Browser öffnen normale Webseiten.
- Downloads funktionieren.
- Windows Update oder Microsoft Store ist nicht blockiert.
- `winget upgrade` ist ausführbar, sofern `winget` vorhanden ist.
- Häufig genutzte Programme starten weiterhin.
- Firewall-Regeln enthalten keine unerklärten harten Blockaden.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- Liste der geprüften Sicherheitseinstellungen.
- Liste empfohlener, aber nicht automatisch installierter Tools.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Rollback-Pfad für jede systemwirksame Änderung.
- Abschlussstatus mit verbleibenden optionalen Entscheidungen.
