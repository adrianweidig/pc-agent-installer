---
id: CONTAINER-HARDWARE-NVIDIA-20-DOCKER-GPU-RUNTIME
title: Docker GPU Runtime erfassen
platform: any
environment: container
area: container/hardware/nvidia
requires_admin: true
risk: mittel
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - container/hardware/nvidia
---

# Docker GPU Runtime erfassen

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
