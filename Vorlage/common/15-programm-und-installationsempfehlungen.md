---
id: COMMON-15-PROGRAMM-UND-INSTALLATIONSEMPFEHLUNGEN
title: Programm- und Installationsempfehlungen
platform: any
environment: any
area: common
requires_admin: false
risk: niedrig
approval_required: true
rollback_required: false
idempotent: true
applies_to:
  - common
---

# Programm- und Installationsempfehlungen

## Zweck

Diese Vorlage steuert, wie der Agent aus der Erststart-Beschreibung sinnvolle Programme ableitet. Der Agent darf keine starre Standardsoftware blind installieren. Er erstellt zuerst eine profilbasierte Empfehlung und fragt jede Installation konkret ab.

## Nutzerbeschreibung

Die Erststart-Konfiguration muss eine kurze Freitextbeschreibung ermöglichen, zum Beispiel:

```text
Ich bin Entwickler und nutze KI-Tools.
```

```text
Ich nutze den PC für Büro, WhatsApp, Fotos und Online-Banking.
```

Der Agent nutzt diese Beschreibung nur als Hinweis. Sie ersetzt keine Nachfrage vor einer echten Installation.

## Ableitungsregeln

1. Betriebssystem, Gerätetyp und Paketmanager erkennen.
2. Bestehende Programme erfassen, ohne Lizenzschlüssel oder private Kontoinhalte zu speichern.
3. Nutzerbeschreibung in grobe Profile übersetzen: normaler Nutzer, Entwickler, Creator, Gamer, Büro/Studium, Privacy, Admin/Homelab, KI/Daten.
4. Nur passende Kategorien vorschlagen.
5. Pro Kategorie offizielle, kostenlose oder frei nutzbare Optionen bevorzugen.
6. Vor jeder Installation Quelle, Nutzen, Nebenwirkung und Rollback erklären.

## Grundkategorien

- Browser und Web-Apps
- Passwortmanager
- Office, PDF und Dokumente
- Medienplayer und einfache Medienwerkzeuge
- Archiv- und Dateitools
- Messenger und Kommunikation
- Entwicklerwerkzeuge
- Container, WSL oder Remote-Tools
- Backup, Sync und Wiederherstellung
- Wartung und Cleanup

## Sicherheitsgrenzen

- Keine Masseninstallation ohne Nutzerentscheidung.
- Keine Downloads aus Bundle-Portalen.
- Keine Treiber-Updater, Registry-Booster oder Systemoptimierer als Default.
- Cleaner wie CCleaner oder BleachBit nur optional, manuell und ohne aggressive Löschprofile.
- Messenger und Social-Apps nur auf Desktop-Profilen, nicht auf Servern oder Headless-Systemen.
- WSL-, Docker- oder Portainer-Empfehlungen nur über die passenden WSL- und Container-Vorlagen.

## Erwarteter Nachweis

- erkannte Nutzerbeschreibung oder Hinweis, dass keine Beschreibung angegeben wurde.
- abgeleitete Profile mit kurzer Begründung.
- vorgeschlagene Programmkategorien.
- pro vorgeschlagener Installation: Quelle, Paketmanager, Paket-ID sofern bekannt, Nutzerentscheidung und Rollback-Hinweis.

Details stehen in `docs/17-programm-und-installationsempfehlungen.md`.
