---
id: MACOS-COMMON-00-DETECT-MACOS
title: macOS erkennen
platform: macos
environment: native
area: macos/common
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - macos/common
---

# macOS erkennen

## Zweck
Diese Vorlage beschreibt den generischen Soll-Prozess zur Erkennung eines macOS-Hosts.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Hostdaten in öffentlichen oder ungeprüften Repositories speichern.
- Keine Klartext-Secrets erfassen.
- Keine systemwirksamen Änderungen während der reinen Erkennung durchführen.

## Baseline erfassen
Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- macOS-Version und Build
- Hardwarearchitektur
- aktiver Nutzerkontext
- installierte Paketmanager wie Homebrew oder MacPorts
- relevante Sicherheitsfunktionen: Gatekeeper, XProtect, Firewall, FileVault
- vorhandene Sicherheits- oder Backup-Tools

## Ablauf
1. Plattform über `uname`, `sw_vers` und verfügbare Systemwerkzeuge erkennen.
2. Repo-Modus prüfen.
3. Hostdaten nur in bestätigtem `operational`- oder `local-only`-Modus dokumentieren.
4. Keine Admin-Änderungen durchführen.

## Erwartete Nachweise
- macOS-Baseline im passenden Host-Unterordner.
- Keine sensiblen Nutzer- oder Schlüsselbunddaten.
- Abschlussstatus mit offenen Sicherheitsentscheidungen.
