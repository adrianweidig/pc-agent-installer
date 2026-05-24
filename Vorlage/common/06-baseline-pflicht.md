---
id: COMMON-06-BASELINE-PFLICHT
title: Baseline-Pflicht
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

# Baseline-Pflicht

## Zweck
Diese Vorlage beschreibt den generischen Soll-Prozess für $area.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Vor systemwirksamen Änderungen aktuelle Infrastruktur prüfen und Soll-Ist-Abgleich dokumentieren.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.

## Ablauf
1. Plattform- und Host-Kontext erkennen.
2. `assert-infrastructure-snapshot.*` ausführen.
3. Wenn Snapshot fehlt oder unvollständig ist, aktuelle Baseline erzeugen.
4. Relevante Baseline-Dateien unter hosts/<HOSTNAME>/baseline/ prüfen.
5. Soll-Zustand, Ist-Zustand, Duplikate und Löschrisiko dokumentieren.
6. Geplante Änderung unter hosts/<HOSTNAME>/changes/ dokumentieren.
7. Falls `rollback_required: true`, Rollback-Datei unter `hosts/<HOSTNAME>/rollback/` anlegen.
8. Validierung ausführen und Ergebnis im Change-Eintrag festhalten.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- Soll-Ist-Abgleich mit Duplikat- und Löschrisikoprüfung.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
