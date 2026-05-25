---
id: MACOS-COMMON-32-KLASSISCHE-SICHERHEITSEINSTELLUNGEN
title: Klassische macOS-Sicherheitseinstellungen
platform: macos
environment: native
area: macos/common
requires_admin: true
risk: mittel
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - macos/common
---

# Klassische macOS-Sicherheitseinstellungen

## Zweck
Diese Vorlage beschreibt blockadearme Sicherheitssettings für normale macOS-Nutzer-PCs. Ziel ist zusätzlicher Schutz, ohne Browser, Downloads, Entwicklerwerkzeuge, App-Installationen, Paketmanager oder KI-Tools unnötig zu blockieren.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Hostdaten in öffentlichen oder ungeprüften Repositories speichern.
- Keine Klartext-Secrets oder Schlüsselbundinhalte erfassen.
- Vor systemwirksamen Änderungen Baseline, Change und Rollback dokumentieren.
- Interaktive Entscheidungen nach `Vorlage/common/13-interaktive-sicherheitsentscheidungen.md` stellen.

## Baseline erfassen
Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- macOS-Version und Patchstand
- Gatekeeper-Status
- XProtect-/Systemschutzstatus, soweit sicher abfragbar
- Firewall-Status
- FileVault-Status
- Paketmanager: Homebrew, MacPorts oder keiner
- Homebrew-Taps oder Drittquellen, wenn vorhanden
- installierte Sicherheits- und Backup-Tools
- Login Items mit Sicherheitsrelevanz

## Usability-first Defaults
Empfohlen und in der Regel blockadearm:

- macOS und Apps aktuell halten.
- Gatekeeper und eingebaute Schutzmechanismen aktiv lassen.
- Firewall prüfen und nur bewusst ändern.
- FileVault empfehlen, aber vor Aktivierung Recovery-Key- und Backup-Frage klären.
- Homebrew- und Drittquellen auf Herkunft, Aktualität und Notwendigkeit prüfen.
- Login Items nicht pauschal entfernen, sondern nach Nutzen und Hersteller bewerten.
- ClamAV optional als On-Demand-Zweitscanner anbieten.
- DNS-/Host-Blocklisten nur im Pilotmodus testen.

## ClamAV-Entscheidung
Frage:

```text
Möchtest du ClamAV als kostenlosen On-Demand-Malware-Scanner installieren und automatische Signaturupdates einrichten?
```

Default: `Später`, wenn kein konkreter Austauschordner-, Download- oder Mail-/Dateiserver-Scanbedarf besteht.

Wenn der Nutzer zustimmt:

- offizielle ClamAV-Pakete oder seriösen Paketmanager prüfen,
- FreshClam-Konfiguration und Update-Routine einrichten,
- keine aggressive Echtzeitblockade als Default aktivieren,
- Scanpfade gezielt wählen.

## Blocklisten-Entscheidung
Frage:

```text
Möchtest du eine DNS- oder Host-Blockliste im Pilotmodus testen?
```

Default: `Später`. Erst Browser, App Store, Paketmanager, Developer Tools, Cloud-Sync und häufig genutzte Apps prüfen.

IP-Firewall-Blocklisten sind für normale macOS-Desktops kein Default.

## Quellen, Ausnahmen und Login Items

Anti-Pattern:

- Homebrew-Taps oder Casks ohne Herkunftsprüfung
- FileVault-Aktivierung ohne Recovery-Key-Plan
- Login Items oder LaunchAgents blind löschen
- Security-Ausnahmen für ganze Benutzer- oder Entwicklungsbereiche ohne Ablaufdatum

## Validierung
Nach Änderungen prüfen:

- Browser und Downloads funktionieren.
- App Store oder Softwareupdates funktionieren.
- Homebrew oder MacPorts funktionieren, sofern vorhanden.
- Entwicklerwerkzeuge und KI-Tools starten weiterhin.
- Firewall- oder Blocklistenänderungen sind deaktivierbar.

## Erwartete Nachweise
- macOS-Baseline im passenden Host-Unterordner.
- Gestellte Sicherheitsfragen und Antworten.
- ClamAV-/FreshClam-Status, falls installiert.
- Blocklistenstatus, falls getestet.
- Rollback-Pfad und Validierung normaler Nutzung.
