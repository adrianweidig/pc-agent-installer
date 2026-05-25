---
id: LINUX-COMMON-33-PROGRAMMEMPFEHLUNGEN
title: Linux Programmempfehlungen
platform: linux
environment: native
area: linux/common
requires_admin: false
risk: niedrig
approval_required: true
rollback_required: false
idempotent: true
applies_to:
  - linux/common
---

# Linux Programmempfehlungen

## Zweck

Diese Vorlage beschreibt sinnvolle Linux-Programme anhand von Distribution, Desktop-Umgebung und Nutzerbeschreibung. Der Agent darf nicht von einer einheitlichen Linux-Zielgruppe ausgehen.

## Distributionen und Quellen

- Ubuntu, Debian, Linux Mint: `apt` und grafische Softwareverwaltung zuerst; Flatpak/Flathub optional für Desktop-Apps.
- Fedora: `dnf` und GNOME Software zuerst; Flatpak/Flathub ist für Desktop-Apps oft passend.
- Arch und EndeavourOS: `pacman` zuerst; AUR nur bewusst und nicht als Default für normale Nutzer.
- openSUSE: `zypper` und Discover/GNOME Software zuerst.
- Server und Minimalinstallationen: keine Desktop-Apps empfehlen, wenn keine GUI vorhanden ist.

Drittquellen werden nur empfohlen, wenn Herkunft, Signatur, Release-Kompatibilität und Updatepfad klar sind. Ein Repository für eine andere Distributionsversion ist ein Risiko, bis der Maintainer die Kompatibilität bewusst bestätigt.

## Profilbasierte Empfehlungen

| Profil | Sinnvolle Kategorien |
| --- | --- |
| normaler Desktop-Nutzer | Browser, Passwortmanager, Office, PDF, Medienplayer, Archivtools, Backup |
| Entwickler | Git, Editor, Compiler/Build-Tools, Sprache-SDKs, Docker oder Podman |
| Creator | OBS Studio, VLC, GIMP/Krita oder vergleichbare Tools |
| Privacy-orientiert | Paketquellen minimieren, datensparsame Browser-Profile, lokale Office-/Notiztools |
| Admin/Homelab | SSH, Netzwerktools, Container, Monitoring, Backup |

Messenger wie WhatsApp sollen auf Linux bevorzugt als Web-App/PWA behandelt werden, wenn keine offizielle Distribution über die genutzte Paketquelle eindeutig verfügbar ist.

## Wartung und Cleaner

Der Agent nutzt zuerst Paketmanager-Funktionen für Updates, Autoremove und Cache-Prüfung. BleachBit oder vergleichbare Cleaner sind nur optional und nur mit Vorschau sinnvoll.

Vor Update- oder Cleanup-Empfehlungen prüft der Agent Paketquellen, ausstehende Updates, belegten Speicher und ob Container-, Datenbank- oder Entwickler-Caches betroffen wären.

Nicht als Default:

- aggressive Cache-Löschung
- Autostart- oder Browserprofil-Löschung
- Drittanbieter-Repositories ohne klare Begründung
- Desktop-Apps auf Servern

## Validierung

- Distribution und Paketmanager erkannt.
- Paketquelle und Paketname dokumentiert.
- Drittquellen und Release-Kompatibilität bewertet.
- Nutzerentscheidung dokumentiert.
- Paketmanager bleibt funktionsfähig.
- Desktop-Apps werden nur bei vorhandenem Desktop-Profil empfohlen.
