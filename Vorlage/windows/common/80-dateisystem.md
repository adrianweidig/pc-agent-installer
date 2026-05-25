---
id: WINDOWS-COMMON-80-DATEISYSTEM
title: Windows Dateisystem erfassen
platform: windows
environment: native
area: windows/common
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - windows/common
---

# Windows Dateisystem erfassen

## Zweck
Diese Vorlage beschreibt, wie Datenträger, Dateisysteme, Speicherplatz und Workspace-Eignung unter Windows bewertet werden.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Reparaturen, Formatierungen, Verschlüsselung, Laufwerksbereinigung und Datei-Löschungen sind systemwirksam.
- Kein Cleanup, solange Nutzdaten-, Backup-, Workspace-, Volume- oder Rollback-Relevanz unklar ist.
- Laufwerks- und Pfadangaben in öffentlichen Artefakten verallgemeinern.

## Baseline erfassen

Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- Volumes mit Dateisystem, Typ, Health-Status, Operational-Status und freiem Speicher
- physische Datenträger mit Medien- und Health-Status
- Workspace-Laufwerke und wichtige Datenbereiche
- BitLocker- oder Geräteverschlüsselungsstatus
- Hinweise auf exFAT, Wechseldatenträger, Reparaturbedarf oder sehr wenig freien Speicher

## Bewertung

Gute Muster:

- dauerhafte Arbeitsdaten liegen auf gesunden NTFS- oder ReFS-Volumes
- mobile Geräte nutzen BitLocker oder eine bewusst dokumentierte Alternative
- Workspaces sind Git-basiert und nicht durch dauerhafte lokale Kopien ersetzt
- vor großen Updates oder Cleanup existiert ein Backup- oder Rollback-Plan

Anti-Pattern:

- Entwickler- oder Agenten-Workspace auf einem Volume mit Warn- oder Reparaturstatus
- dauerhafte Arbeitsdaten auf exFAT, wenn Rechte, Journaling oder robuste Git-Nutzung wichtig sind
- Verschlüsselung aktivieren, bevor Recovery-Key und Backup geklärt sind
- alte Arbeitskopien, Containerdaten oder Backups löschen, ohne Git-/Remote- und Nutzdatenprüfung

## Ablauf

1. Volumes und physische Datenträger erfassen.
2. Workspace- und Nutzdatenbereiche identifizieren.
3. Dateisystem und Health-Status bewerten.
4. Verschlüsselungsempfehlung nur als Empfehlung dokumentieren.
5. Cleanup- oder Migrationsvorschläge erst nach Soll-Ist-Abgleich formulieren.

## Erwartete Nachweise
- Baseline oder Report im passenden Host-Unterordner.
- Liste auffälliger Datenträger- oder Dateisystemrisiken.
- Backup-, Recovery-Key- oder Migrationsentscheidung.
- Keine Löschung ohne dokumentierte Datenklassifikation und Rollback-Grenze.
