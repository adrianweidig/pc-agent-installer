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
- Zwischen Analyseprofil und echter Ersteinrichtung unterscheiden.
- Für echte macOS-Ersteinrichtung muss Codex in einem Administrator-Kontext mit gezielter sudo-Fähigkeit laufen.
- Ohne Administrator-/sudo-Kontext nur Erkennung, Baseline und Blockadebericht durchführen.
- Keine systemwirksamen Änderungen während der reinen Erkennung durchführen.

## Baseline erfassen
Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- macOS-Version und Build
- Hardwarearchitektur
- aktiver Nutzerkontext
- installierte Paketmanager wie Homebrew oder MacPorts
- relevante Sicherheitsfunktionen: Gatekeeper, XProtect, Firewall, FileVault
- vorhandene Sicherheits- oder Backup-Tools
- Administratorstatus und sudo-Fähigkeit, ohne Passwörter oder Schlüsselbunddaten zu erfassen

## Ablauf
1. Plattform über `uname`, `sw_vers` und verfügbare Systemwerkzeuge erkennen.
2. Repo-Modus prüfen.
3. Hostdaten nur in bestätigtem `operational`- oder `local-only`-Modus dokumentieren.
4. Wenn Paketmanager, Firewall, LaunchAgents/LaunchDaemons, Sicherheitsfunktionen, Benutzer, Gruppen oder systemweite Profile geändert werden sollen, Vollzugriff-Profil nach `Vorlage/common/10-admin-und-sudo-regeln.md` voraussetzen.
5. Keine Admin-Änderungen während der reinen Erkennung durchführen.

## Erwartete Nachweise
- macOS-Baseline im passenden Host-Unterordner.
- Administrator-/sudo-Status und Startprofil.
- Keine sensiblen Nutzer- oder Schlüsselbunddaten.
- Abschlussstatus mit offenen Sicherheitsentscheidungen.
