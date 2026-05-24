---
id: COMMON-00-AGENT-REGELN
title: Agent-Regeln
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

# Agent-Regeln

## Zweck
Diese Vorlage beschreibt den generischen Soll-Prozess für $area.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.
- Betriebssystemspezifische Fähigkeiten nur über passende Vorlagen ausführen: Windows, Linux, WSL und macOS müssen jeweils einen vergleichbaren Baseline-, Sicherheits-, Rollback- und Report-Pfad haben.
- Sicherheitsmaßnahmen mit Blockade-, Installations-, Dienst-, Firewall-, DNS- oder Blocklist-Wirkung brauchen eine dokumentierte Frage-Antwort-Entscheidung.

## Ablauf
1. Plattform- und Host-Kontext erkennen.
2. Passende Vorlagen auswählen: `Vorlage/windows`, `Vorlage/linux`, `Vorlage/wsl` oder `Vorlage/macos`.
3. Relevante Baseline-Dateien unter hosts/<HOSTNAME>/baseline/ prüfen oder erzeugen.
4. Geplante Änderung unter hosts/<HOSTNAME>/changes/ dokumentieren.
5. Falls `rollback_required: true`, Rollback-Datei unter `hosts/<HOSTNAME>/rollback/` anlegen.
6. Validierung ausführen und Ergebnis im Change-Eintrag festhalten.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- verwendete Betriebssystem- und Common-Vorlagen.
- gestellte Fragen und Antworten, falls interaktive Sicherheitsentscheidungen betroffen waren.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
