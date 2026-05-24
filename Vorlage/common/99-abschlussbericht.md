---
id: COMMON-99-ABSCHLUSSBERICHT
title: Abschlussbericht
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

# Abschlussbericht

## Zweck
Diese Vorlage beschreibt den generischen Abschlussbericht für Agentenläufe auf Windows, Linux, WSL, macOS, Container-Umgebungen und Profilen.

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
- erkannte Plattform und verwendete Vorlagen.
- umgesetzte, nicht umgesetzte und zurückgestellte Frage-Antwort-Entscheidungen.
- Sicherheits-, AV-, Update-, Firewall- und Blocklistenstatus, sofern geprüft.
- Rollback-Pfade für systemwirksame Änderungen.
- Validierung normaler Nutzung für betroffene Betriebssysteme.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
