---
id: MACOS-COMMON-33-PROGRAMMEMPFEHLUNGEN
title: macOS Programmempfehlungen
platform: macos
environment: native
area: macos/common
requires_admin: false
risk: niedrig
approval_required: true
rollback_required: false
idempotent: true
applies_to:
  - macos/common
---

# macOS Programmempfehlungen

## Zweck

Diese Vorlage beschreibt sinnvolle macOS-Programme anhand der Nutzerbeschreibung. Der Agent unterscheidet Alltagsnutzer, Entwickler, Creator und Admin-/Homelab-Profile.

## Quellen

Bevorzugte Quellen:

1. App Store
2. Homebrew und Homebrew Cask für Entwickler und Power-User
3. offizielle Herstellerseite

Homebrew ist für Entwickler sehr sinnvoll, aber nicht für jeden Alltagsnutzer zwingend nötig.

## Profilbasierte Empfehlungen

| Profil | Sinnvolle Kategorien |
| --- | --- |
| normaler Nutzer | Browser, Passwortmanager, Office/PDF, Medienplayer, Messenger/Web-Apps, Backup |
| Entwickler | Xcode Command Line Tools, Homebrew, Git, Terminal, Editor/IDE, Sprache-SDKs |
| Creator | OBS Studio, VLC, Bild-/Audio-/Video-Tools, große-Dateien-Backup |
| Büro/Studium | Office, PDF, Kalender, Videokonferenz, Cloud-Sync |
| Admin/Homelab | SSH, Terminal, Container- oder Remote-Tools, Netzwerkdiagnose |

WhatsApp soll als offizielle App oder Web-App/PWA vorgeschlagen werden, nicht als inoffizieller Wrapper.

## Wartung und Cleaner

macOS-Speicherverwaltung, App-Deinstallation und Systemupdates bleiben der Default. Cleaner- oder Uninstaller-Tools dürfen nur optional empfohlen werden, wenn der Nutzer eine manuelle Oberfläche dafür will.

Nicht als Default:

- aggressive System-Cleaner
- Kernel-/System-Erweiterungen ohne klaren Zweck
- Login-Item-Entfernung ohne Vorschau
- automatische Löschung von Browser- oder App-Daten

## Validierung

- App Store, Homebrew oder Herstellerquelle dokumentiert.
- Nutzerentscheidung dokumentiert.
- App startet oder meldet Version.
- Systemupdates und normale App-Nutzung bleiben möglich.
