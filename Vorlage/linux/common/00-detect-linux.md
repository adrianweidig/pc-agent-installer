---
id: LINUX-COMMON-00-DETECT-LINUX
title: Linux erkennen
platform: linux
environment: native
area: linux/common
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - linux/common
---

# Linux erkennen

## Zweck
Diese Vorlage beschreibt den generischen Soll-Prozess für $area.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Zwischen Analyseprofil und echter Ersteinrichtung unterscheiden.
- Für echte Linux-Ersteinrichtung muss Codex als root oder mit bewusst freigegebenem sudo-Kontext laufen.
- Ohne root/sudo nur Erkennung, Baseline und Blockadebericht durchführen.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.

## Ablauf
1. Plattform- und Host-Kontext erkennen.
2. root-Status, sudo-Fähigkeit, init-System und Paketmanager erfassen.
3. Wenn Paketmanager, Repositories, systemd, Firewall, SSH, Benutzer, Gruppen, Kernel, Treiber oder Sicherheitsrichtlinien geändert werden sollen, Vollzugriff-Profil nach `Vorlage/common/10-admin-und-sudo-regeln.md` voraussetzen.
4. Relevante Baseline-Dateien unter hosts/<HOSTNAME>/baseline/ prüfen oder erzeugen.
5. Geplante Änderung unter hosts/<HOSTNAME>/changes/ dokumentieren.
6. Falls `rollback_required: true`, Rollback-Datei unter `hosts/<HOSTNAME>/rollback/` anlegen.
7. Validierung ausführen und Ergebnis im Change-Eintrag festhalten.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- root-/sudo-Status und Startprofil.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
