---
id: LINUX-DEBIAN-COMMON-20-APT-SOURCES
title: APT Sources erfassen
platform: linux
environment: native
area: linux/debian/common
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - linux/debian/common
---

# APT Sources erfassen

## Zweck
Diese Vorlage beschreibt, wie APT-Quellen auf Debian-, Ubuntu- und verwandten Systemen bewertet werden. Ziel ist ein distributionspassender, signierter und wartbarer Paketquellenzustand.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Quellenänderungen, Keyring-Änderungen und Paketupdates sind systemwirksam.
- Keine Drittquelle übernehmen, deren Release nicht zur Distribution passt, ohne bewusste Kompatibilitätsentscheidung.
- Keine Keys über unsichere Muster wie globale, unklare Trust-Stores hinzufügen.

## Baseline erfassen

Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- Distribution, Version und Codename aus `/etc/os-release`
- Dateien unter `/etc/apt/sources.list` und `/etc/apt/sources.list.d/`, redigiert um private Mirror-Details
- Suites und Releases pro Quelle
- `signed-by`-Keyrings und Herkunft
- ausstehende Updates als Anzahl und betroffene Kategorien

## Bewertung

Gute Muster:

- Distributionsquellen passen zum erkannten Codename
- Drittquellen nutzen dedizierte Keyrings und `signed-by`
- Backports, Security und Updates sind nachvollziehbar getrennt
- Quellenänderungen haben Rollback durch gesicherte Quelldateien

Anti-Pattern:

- Drittquelle zeigt auf `bookworm`, während das System `trixie` nutzt, oder vergleichbare Release-Mismatches
- `stable`, `testing` oder `unstable` werden gemischt, ohne Pinning und Begründung
- globale Keys oder alte `apt-key`-Muster ohne klare Herkunft
- Paketupdates werden ausgeführt, bevor Quellenkonflikte bewertet sind

## Ablauf

1. Distribution und Codename erkennen.
2. APT-Quellen und Keyrings erfassen.
3. Release-Kompatibilität und Drittquellen bewerten.
4. `apt update` nur ausführen, wenn der Nutzer Paketmanager-Zugriff erlaubt hat.
5. Korrekturen an Quellen nur mit Change-Eintrag und gesicherter Rücknahme planen.

## Erwartete Nachweise
- Baseline oder Report im passenden Host-Unterordner.
- Liste der Quellen mit Release-Bewertung.
- dokumentierte Update- und Konfliktentscheidung.
- Rollback-Pfad für jede Quellenänderung.
