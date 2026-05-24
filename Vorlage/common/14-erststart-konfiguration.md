---
id: COMMON-14-ERSTSTART-KONFIGURATION
title: Erststart-Konfiguration
platform: any
environment: any
area: common
requires_admin: false
risk: niedrig
approval_required: true
rollback_required: false
idempotent: true
applies_to:
  - common
---

# Erststart-Konfiguration

## Zweck
Diese Vorlage erzwingt eine nutzerfreundliche Erstkonfiguration, bevor ein Agent Hostdaten erfasst, Sicherheitsmaßnahmen empfiehlt, Pakete installiert oder systemwirksame Änderungen vorbereitet.

## Grundregel
Der Agent darf vor abgeschlossener Erststart-Konfiguration nicht arbeiten. Er muss stattdessen klar melden:

```text
Die Konfiguration für den Erststart ist noch nicht abgeschlossen.
Bitte zuerst die Erststart-Konfiguration ausführen.
```

## Interaktion
Windows bevorzugt den PowerShell-Dialog:

```powershell
./scripts/common/first-run-config.ps1
```

Linux, WSL und macOS nutzen den Shell-Dialog:

```bash
bash ./scripts/common/first-run-config.sh
```

Wenn kein GUI-Fenster verfügbar ist, muss der Agent auf Terminal-Fragen zurückfallen, statt Host-Arbeit ohne Konfiguration zu starten.

## Mindestfragen
Die Erststart-Konfiguration fragt mindestens:

- Darf der Agent eine Host-Baseline erfassen?
- Darf der Agent usability-first Sicherheitsempfehlungen anzeigen?
- Darf der Agent kostenlose, aktuelle Tools und Updates empfehlen?
- Darf der Agent optionale AV-/Malware-Scanner anbieten?
- Darf der Agent DNS-/Host-Blocklisten im Pilotmodus anbieten?
- Darf der Agent IP-Firewall-Blocklisten als riskante Option anbieten?
- Soll vor systemwirksamen Änderungen immer eine Bestätigung verlangt werden?

## Nachweis
Die Antwort wird unter `hosts/<HOSTNAME>/state/first-run-config.yaml` dokumentiert. Diese Datei enthält nur Präferenzen und keine Klartext-Secrets.

## Pflichtprüfung
Vor Host-Arbeit muss eine der Prüfungen erfolgreich sein:

```powershell
./scripts/common/assert-first-run-config.ps1
```

```bash
bash ./scripts/common/assert-first-run-config.sh
```
