---
id: PROFILES-SERVER-00-DETECT-SERVER
title: Server-Profil erkennen
platform: any
environment: any
area: profiles/server
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - profiles/server
---

# Server-Profil erkennen

## Zweck
Diese Vorlage beschreibt den generischen Soll-Prozess für $area.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.

## Ablauf
1. Plattform- und Host-Kontext erkennen.
2. Relevante Baseline-Dateien unter hosts/<HOSTNAME>/baseline/ prüfen oder erzeugen.
3. Geplante Änderung unter hosts/<HOSTNAME>/changes/ dokumentieren.
4. Falls `rollback_required: true`, Rollback-Datei unter `hosts/<HOSTNAME>/rollback/` anlegen.
5. Validierung ausführen und Ergebnis im Change-Eintrag festhalten.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
