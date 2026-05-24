---
id: WSL-COMMON-80-PROGRAMMEMPFEHLUNGEN
title: WSL Programmempfehlungen
platform: linux
environment: wsl
area: wsl/common
requires_admin: false
risk: niedrig
approval_required: true
rollback_required: false
idempotent: true
applies_to:
  - wsl/common
---

# WSL Programmempfehlungen

## Zweck

WSL ist primär ein Linux-Backend für CLI-, Entwicklungs-, Automations-, Container- und KI-nahe Workflows. Der Agent darf WSL nicht wie einen normalen Desktop-PC behandeln.

## Sinnvolle Kategorien

- Git, curl, wget, jq, unzip und vergleichbare CLI-Basistools.
- Compiler- und Build-Werkzeuge passend zur Distribution.
- Python, Node.js, Go, Rust, Java oder andere SDKs nur nach Nutzer- oder Projektprofil.
- Shell-Konfiguration und sichere SSH-Nutzung.
- Docker-CLI nur passend zum gewählten Windows-/WSL-Docker-Modell.
- CUDA-, GPU- oder KI-Tooling nur, wenn Hardware und Zielprofil dazu passen.

## Nicht sinnvoll als Default

- Messenger, Social-Apps und WhatsApp in WSL.
- Cleaner wie CCleaner oder BleachBit als Desktop-Ersatz.
- ein zweiter Docker-Daemon, wenn Docker Desktop mit WSL-Integration bereits gewünscht oder vorhanden ist.
- GUI-Apps ohne ausdrücklichen Wunsch nach Linux-GUI-Anwendungen.

## Ableitung aus Nutzerbeschreibung

Bei `Ich bin Entwickler`, `KI`, `Data Science`, `Homelab` oder ähnlichen Formulierungen darf der Agent WSL-Toolchains vorschlagen. Bei Alltagsprofilen soll WSL nur berücksichtigt werden, wenn es im Erststart explizit gewählt wurde.

## Validierung

- `wsl --list --verbose` auf Windows-Seite dokumentiert.
- Distribution und Paketmanager in WSL erkannt.
- Paketquelle dokumentiert.
- Windows- und WSL-Pfade werden nicht vermischt.
- Docker-Kontext klar benannt, falls Docker beteiligt ist.
