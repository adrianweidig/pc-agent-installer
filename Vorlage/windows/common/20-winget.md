---
id: WINDOWS-COMMON-20-WINGET
title: WinGet erfassen
platform: windows
environment: native
area: windows/common
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - windows/common
---

# WinGet erfassen

## Zweck
Diese Vorlage beschreibt, wie der Agent `winget` als Windows-Paketmanager prüft. Ziel ist ein nachvollziehbarer Update- und Quellenstatus, keine automatische Masseninstallation.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Im öffentlichen Template keine Hostdaten speichern.
- `winget upgrade --all`, Installationen, Deinstallationen und Quellenänderungen sind systemwirksam und brauchen Freigabe, Change-Eintrag, Soll-Ist-Abgleich und Rollback-Grenze.
- Paketquellen, Paket-IDs und Herausgeber prüfen, bevor Software empfohlen wird.

## Baseline erfassen

In einer privaten oder lokalen Operational-Struktur dokumentieren:

- ob `winget` verfügbar ist
- aktive `winget`-Quellen mit Name, Argument und Vertrauensbewertung
- ausstehende Updates als Anzahl und betroffene Kategorien
- auffällige Drittquellen oder Quellen mit unklarem Zweck
- wichtige Pakete mit Quelle, Paket-ID, installierter Version und verfügbarer Version

Rohdaten mit Pfaden, Kontonamen oder möglichen Tokens werden redigiert.

## Bewertung

Gute Muster:

- `msstore` und `winget` als nachvollziehbare Standardquellen
- Updates werden regelmäßig geprüft
- Paket-IDs werden vor Installation mit `winget show` verifiziert
- zusätzliche Quellen sind dokumentiert und begründet

Anti-Pattern:

- unbekannte oder nicht mehr benötigte Quellen bleiben aktiv
- Programme werden über Download-Portale installiert, obwohl Store oder `winget` verfügbar sind
- Massenupdates ohne Liste der betroffenen Programme und Neustartrisiko
- Paketquellen werden geändert, ohne vorherige und nachherige Ausgabe zu dokumentieren

## Ablauf

1. Repo-Modus und Operational-Kontext prüfen.
2. `winget --version`, `winget source list` und `winget upgrade` erfassen.
3. Zusätzliche Quellen bewerten und nicht automatisch entfernen.
4. Ausstehende Updates nach Risiko gruppieren: Browser/Security, Entwickler-Tools, Alltagsapps, Treiber-nahe Tools.
5. Nutzerentscheidung für Update-Bündel einholen.
6. Nach Updates betroffene Programme und `winget upgrade` erneut prüfen.

## Erwartete Nachweise
- Baseline oder Report im passenden Host-Unterordner.
- Quellenliste mit Bewertung.
- Update-Liste oder begründete Nichtausführung.
- Nutzerfreigabe für jede Installation, Deinstallation oder Massenaktualisierung.
- Validierung, dass Store, Browser, Downloads und betroffene Programme weiter funktionieren.
