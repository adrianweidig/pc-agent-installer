---
id: COMMON-13-INTERAKTIVE-SICHERHEITSENTSCHEIDUNGEN
title: Interaktive Sicherheitsentscheidungen
platform: any
environment: any
area: common
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - common
---

# Interaktive Sicherheitsentscheidungen

## Zweck
Diese Vorlage definiert den Frage-Antwort-Standard für Sicherheitsmaßnahmen. Ein Agent soll sinnvolle Schutzmaßnahmen anbieten, aber normale Nutzer-PCs nicht durch ungefragte Härtung blockieren.

## Grundregel
Wenn eine Maßnahme Programme, Downloads, Webseiten, Games, Entwicklerwerkzeuge, KI-Tools, lokale Dienste oder Paketmanager stören kann, muss der Agent zuerst eine konkrete Entscheidung abfragen und die Folgen erklären.

## Antwortschema
Jede Frage soll drei sichere Antworten anbieten:

- `Ja`: Maßnahme umsetzen, mit Baseline, Change-Eintrag, Rollback und Validierung.
- `Nein`: Maßnahme nicht umsetzen und Grund knapp dokumentieren.
- `Später`: Maßnahme als offene optionale Entscheidung dokumentieren.

## Standardfragen

### Kostenloser AV-/Malware-Schutz

Frage:

```text
Möchtest du einen kostenlosen, sinnvollen Malware-Scanner einrichten, der normale Installationen und Alltagsnutzung möglichst nicht blockiert?
```

Empfohlene Einordnung:

- Windows: Microsoft Defender als Default beibehalten; ClamAV nur als optionaler On-Demand-Zweitscanner.
- Linux: ClamAV optional für Downloads, Austauschordner, Mail-/Dateiserver oder Windows-Dateien; FreshClam-Updates per Service oder Timer.
- WSL: Windows Defender schützt die Windows-Seite; ClamAV in WSL nur optional für Linux-Dateien oder Austauschordner.
- macOS: eingebaute Schutzmechanismen beibehalten; ClamAV optional für On-Demand-Scans.

### Automatische Signaturupdates

Frage:

```text
Soll der Malware-Scanner seine Signaturen automatisch aktualisieren?
```

Default: `Ja`, wenn der Scanner installiert wird und ein offizieller Update-Dienst oder Timer verfügbar ist.

Rollback: Dienst oder Timer deaktivieren, Paket entfernen nur nach gesonderter Freigabe.

### DNS- oder Host-Blocklisten

Frage:

```text
Möchtest du eine blockadearme DNS- oder Host-Blockliste gegen Malware, Phishing, Werbung und Tracking testen?
```

Default: `Später` oder Pilotmodus. Erst Browser, Downloads, Store, Paketmanager, Messenger, Games und häufig genutzte Dienste testen.

### IP-Firewall-Blocklisten

Frage:

```text
Möchtest du eine IP-Firewall-Blockliste testen? Diese kann legitime Dienste, CDNs, Games, Updates oder Cloud-Dienste stören.
```

Default: `Nein` für normale Nutzer-PCs. IP-Listen sind eher für Router, Server oder exponierte Dienste geeignet.

### Backup vor Härtung

Frage:

```text
Soll vor riskanter Härtung ein Wiederherstellungspunkt, Snapshot oder Backup geprüft werden?
```

Default: `Ja`, wenn die Plattform es unterstützt.

## Dokumentation
Der Agent dokumentiert:

- gestellte Fragen,
- Antwort,
- Begründung,
- umgesetzte Änderung,
- nicht umgesetzte optionale Maßnahmen,
- Rollback,
- Validierung der normalen Nutzung.
