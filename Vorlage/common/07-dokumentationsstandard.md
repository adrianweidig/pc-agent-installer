---
id: COMMON-07-DOKUMENTATIONSSTANDARD
title: Dokumentationsstandard
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

# Dokumentationsstandard

## Zweck
Diese Vorlage beschreibt den generischen Soll-Prozess für $area.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.
- Neue oder geänderte Textdateien als UTF-8 schreiben.
- Deutsche Fließtexte mit echten Umlauten schreiben; ASCII-Umschreibungen mit `ue`, `oe` oder `ae` nur in technischen Tokens, Pfaden, IDs oder externen Originalzitaten belassen.

## Ablauf
1. Plattform- und Host-Kontext erkennen.
2. Relevante Baseline-Dateien unter hosts/<HOSTNAME>/baseline/ prüfen oder erzeugen.
3. Geplante Änderung unter hosts/<HOSTNAME>/changes/ dokumentieren.
4. Falls `rollback_required: true`, Rollback-Datei unter `hosts/<HOSTNAME>/rollback/` anlegen.
5. Validierung ausführen und Ergebnis im Change-Eintrag festhalten.
6. Nach Dokumentationsänderungen `verify-template.*` ausführen, damit Encoding und Umlaut-Regeln geprüft werden.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
