---
id: WSL-COMMON-60-FILESYSTEM-MOUNTS
title: WSL Filesystem Mounts erfassen
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

# WSL Filesystem Mounts erfassen

## Zweck
Diese Vorlage beschreibt, wie WSL-Mounts und Arbeitsorte bewertet werden. Ziel ist eine klare Trennung zwischen Linux-Dateisystem, Windows-Mounts und dauerhaften Arbeitsdaten.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Keine Dateien zwischen Windows und WSL verschieben oder löschen, solange Git-, Backup-, Volume- und Rechtekontext unklar ist.
- Windows-Pfade, Benutzerprofile und private Mounts in öffentlichen Artefakten verallgemeinern.
- Performance- oder Rechteprobleme nicht durch pauschales Kopieren lösen.

## Baseline erfassen

Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- WSL-Distribution und Version
- relevante Mount-Typen wie `ext4`, `9p`, `drvfs`, `overlay`
- ob Workspaces in der Distribution oder unter `/mnt/*` liegen
- Docker-/Container-Bind-Mounts mit Datenrelevanz, ohne Secret-Inhalte
- Dateisystemhinweise der Windows-Seite, wenn Windows-Mounts genutzt werden

## Bewertung

Gute Muster:

- Linux-heavy Builds und Paketmanager-Caches liegen bevorzugt im WSL-Dateisystem
- Windows-nahe Projekte können unter `/mnt/*` liegen, wenn Performance und Rechte passen
- Containerdaten und Datenbanken haben klare Volume- oder Bind-Mount-Entscheidung
- Arbeitskopien bleiben über Git und Remote-Status nachvollziehbar

Anti-Pattern:

- große Linux-Builds oder Datenbanken dauerhaft auf ungeeigneten Windows-Mounts
- Arbeit auf Windows-Volumes mit Warn- oder Reparaturstatus
- Cleanup von `/mnt/*`, Docker-Binds oder WSL-Home ohne Nutzdatenprüfung
- geheime Dateien in gemeinsam gemounteten Arbeitsbereichen ohne Secret-Policy

## Ablauf

1. Mounts und Workspace-Orte erfassen.
2. Windows- und WSL-Dateisystemzustand zusammen bewerten.
3. Performance-, Rechte- und Backup-Risiken dokumentieren.
4. Migrationen nur mit Git-/Remote-Prüfung, Backup-Entscheidung und Rollback-Grenze planen.

## Erwartete Nachweise
- Baseline oder Report im passenden Host-Unterordner.
- Mount- und Workspace-Bewertung.
- dokumentierte Empfehlung pro Arbeitsbereich.
- keine Löschung oder Migration ohne Datenklassifikation.
