---
id: CONTAINER-COMMON-33-VOLUMES
title: Container Volumes erfassen
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

# Container Volumes erfassen

## Zweck
Diese Vorlage beschreibt, wie Container-Volumes und Bind-Mounts vor Änderungen, Updates oder Cleanup bewertet werden.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Keine Volumes löschen, prunen oder migrieren, solange Datenklasse und Besitzer unklar sind.
- Bind-Mount-Pfade können private Hostinformationen enthalten und werden in öffentlichen Artefakten verallgemeinert.
- Datenbanken, Uploads, Modelle, Caches und Secret-Dateien getrennt behandeln.

## Klassifikation

Der Agent klassifiziert jedes Volume oder jeden Bind-Mount mindestens als:

- Nutzdaten
- Datenbank oder Index
- Cache oder temporärer Arbeitsbereich
- Modell-, Medien- oder Artefaktspeicher
- Secret- oder Konfigurationspfad
- Build-Artefakt
- unbekannt

`unbekannt` bedeutet: nicht löschen.

## Ablauf

1. Runtime und Container erfassen.
2. Volumes und Bind-Mounts den betroffenen Services zuordnen.
3. Datenklasse, Backup-Relevanz und Wiederherstellbarkeit bewerten.
4. Cleanup-Kandidaten nur mit Begründung und Freigabe markieren.
5. Vor Migration oder Löschung Backup- oder Exportpfad dokumentieren.

## Erwartete Nachweise
- Volume-Liste mit Datenklasse.
- Zuordnung zu Service oder Compose-Projekt.
- Backup-, Export- oder bewusste Nicht-Löschentscheidung.
- Rollback-Grenze, falls Daten nicht vollständig wiederherstellbar sind.
