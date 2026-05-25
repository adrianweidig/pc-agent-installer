---
id: WSL-COMMON-00-DETECT-WSL
title: WSL erkennen
platform: linux
environment: wsl
area: wsl/common
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - wsl/common
---

# WSL erkennen

## Zweck
Diese Vorlage beschreibt den generischen Soll-Prozess für $area.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Zwischen Analyseprofil und echter WSL-Ersteinrichtung unterscheiden.
- Für Änderungen innerhalb der Distribution muss Codex mit root- oder sudo-Rechten in der Distribution laufen.
- Für Windows-seitige WSL-, Netzwerk-, Docker- oder Portainer-Integration ist zusätzlich eine bewusst freigegebene Windows-Administrator-Sitzung nötig.
- Ohne passende Rechte nur Erkennung, Baseline und Blockadebericht durchführen.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.

## Ablauf
1. Plattform- und Host-Kontext erkennen.
2. root-/sudo-Status in der Distribution und Windows-Integrationsgrenzen dokumentieren.
3. Wenn Paketmanager, Dienste, Firewall, Benutzer, Gruppen, WSL-Konfiguration, Docker-Integration oder Windows-Mounts geändert werden sollen, Vollzugriff-Profil nach `Vorlage/common/10-admin-und-sudo-regeln.md` voraussetzen.
4. Relevante Baseline-Dateien unter hosts/<HOSTNAME>/baseline/ prüfen oder erzeugen.
5. Geplante Änderung unter hosts/<HOSTNAME>/changes/ dokumentieren.
6. Falls `rollback_required: true`, Rollback-Datei unter `hosts/<HOSTNAME>/rollback/` anlegen.
7. Validierung ausführen und Ergebnis im Change-Eintrag festhalten.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- root-/sudo-Status der Distribution und Windows-Adminbedarf, falls Windows-Integration betroffen ist.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
