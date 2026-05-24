---
id: WINDOWS-COMMON-34-PROGRAMMEMPFEHLUNGEN
title: Windows Programmempfehlungen
platform: windows
environment: native
area: windows/common
requires_admin: false
risk: niedrig
approval_required: true
rollback_required: false
idempotent: true
applies_to:
  - windows/common
---

# Windows Programmempfehlungen

## Zweck

Diese Vorlage beschreibt sinnvolle Windows-Programme anhand der Nutzerbeschreibung. Sie ist keine Installationsliste. Der Agent schlägt Kategorien vor, prüft vorhandene Software und fragt gezielt nach.

## Quellen

Bevorzugte Quellen:

1. Microsoft Store
2. `winget`
3. offizielle Herstellerseite

Vor einer Installation mit `winget` muss der Agent Paket-ID, Quelle und Herausgeber prüfen:

```powershell
winget search <Suchbegriff>
winget show <Paket-ID>
```

## Profilbasierte Empfehlungen

| Profil | Sinnvolle Kategorien |
| --- | --- |
| normaler Nutzer | Browser, Passwortmanager, PDF, Office, Medienplayer, 7-Zip, Messenger/Web-Apps, Backup |
| Entwickler | Windows Terminal, Git, VS Code oder andere IDE, PowerShell, Sprache-SDKs, WSL, Docker mit WSL |
| Creator | OBS Studio, VLC, Bild-/Audio-/Video-Tools, Backup für große Dateien |
| Gamer | Spieleplattformen nur nach Wunsch, Voice-Tools, GPU-Treiberprüfung, keine aggressiven Cleaner |
| Büro/Studium | Office, PDF, Scanner/OCR, Cloud-Sync, Kalender, Videokonferenz |

WhatsApp soll bevorzugt als Web-App/PWA oder offizielle App empfohlen werden, je nachdem was der Nutzer möchte. Der Agent darf Messenger nicht ungefragt installieren.

## Wartung und Cleaner

Windows-Speicheroptimierung, Datenträgerbereinigung, App-Deinstallation und Defender bleiben die ersten Wartungswerkzeuge.

CCleaner oder vergleichbare Cleaner dürfen nur optional vorgeschlagen werden, wenn der Nutzer ausdrücklich eine einfache Wartungsoberfläche will. Dabei gilt:

- keine Registry-Reinigung als Default
- keine automatische Löschung von Browserdaten ohne Vorschau
- keine Driver-Updater- oder Booster-Funktionen empfehlen
- Deinstallation und Rückkehr zu Windows-Bordmitteln dokumentieren

## Validierung

- Paketmanager oder Store-Verfügbarkeit geprüft.
- Paketquelle dokumentiert.
- Nutzerentscheidung dokumentiert.
- installierte Programme starten oder melden ihre Version.
- normale Internet-, Store-, Download- und Entwickler-Nutzung bleibt möglich.
