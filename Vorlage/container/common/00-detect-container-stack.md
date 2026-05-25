---
id: CONTAINER-COMMON-00-DETECT-CONTAINER-STACK
title: Container-Stack erkennen
platform: any
environment: container
area: container/common
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - container/common
---

# Container-Stack erkennen

## Zweck
Diese Vorlage beschreibt den generischen Soll-Prozess für $area.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Zwischen Analyseprofil und echter Container- oder Runtime-Ersteinrichtung unterscheiden.
- Für Änderungen innerhalb eines Containers muss Codex mit den dort nötigen root- oder Capability-Rechten laufen.
- Für Runtime-, Daemon-, Host-Mount-, Volume-, Netzwerk-, Port-, Kubernetes- oder Orchestrator-Änderungen sind passende Host- oder Cluster-Adminrechte nötig.
- Ohne passende Rechte nur Erkennung, Baseline und Blockadebericht durchführen.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.

## Ablauf
1. Plattform- und Host-Kontext erkennen.
2. Runtime, root-/Capability-Kontext, Host-Mounts, Netzwerke, Ports, Volumes und Orchestrator-Kontext erfassen.
3. Wenn Containerzustand, Runtime-Konfiguration, Daemon, Ports, Volumes, Netzwerke, Secrets, Compose, Swarm oder Kubernetes geändert werden sollen, Vollzugriff-Profil nach `Vorlage/common/10-admin-und-sudo-regeln.md` voraussetzen.
4. Relevante Baseline-Dateien unter hosts/<HOSTNAME>/baseline/ prüfen oder erzeugen.
5. Geplante Änderung unter hosts/<HOSTNAME>/changes/ dokumentieren.
6. Falls `rollback_required: true`, Rollback-Datei unter `hosts/<HOSTNAME>/rollback/` anlegen.
7. Validierung ausführen und Ergebnis im Change-Eintrag festhalten.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- root-/Capability-, Runtime- und Adminstatus.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
