---
id: CONTAINER-COMMON-50-SECRETS-POLICY
title: Container Secrets Policy
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

# Container Secrets Policy

## Zweck
Diese Vorlage beschreibt, wie der Agent Container-Secrets erkennt, dokumentiert und schützt, ohne Klartextwerte zu speichern.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Keine rohen Env-Dumps, `docker inspect`-Ausgaben, Compose-Dateien oder Logs speichern, wenn sie Secret-Werte enthalten könnten.
- Secret-Funde nur nach Art, Zweck, Speicherortklasse und Rotationsbedarf dokumentieren.
- Wenn echte Werte sichtbar wurden, Rotation oder Revocation als manuellen Folgeschritt markieren.

## Bewertung

Gute Muster:

- Docker Secrets, Kubernetes Secrets, externe Secret Stores oder geschützte Env-Dateien werden referenziert
- `.env`-Dateien bleiben aus Git ausgeschlossen
- Secret-Variablen sind nach Zweck und Rotation dokumentiert, nicht nach Wert
- lokale Testwerte sind klar von produktiven Werten getrennt

Anti-Pattern:

- API-Keys, Tokens, Datenbankpasswörter oder Shared Secrets in Compose-Dateien
- Secret-Werte in Container-Env, die über Inspect-Befehle sichtbar sind
- Logs oder Reports enthalten komplette Environment-Variablen
- produktive Secrets werden in Test-Stacks wiederverwendet

## Ablauf

1. Nur Secret-Indikatoren erfassen, keine Werte.
2. Quellenklasse dokumentieren: Env, Datei, Runtime-Secret, Vault, Kubernetes, unbekannt.
3. Risiko bewerten: lokal-test, lokal-privat, geteilt, produktiv, unbekannt.
4. Für sichtbare oder breit verfügbare Secrets Rotation empfehlen.
5. Template-Verbesserungen nur generisch dokumentieren.

## Erwartete Nachweise
- Secret-Inventar ohne Werte.
- Liste bewusst redigierter oder nicht gespeicherter Rohdaten.
- Rotations- oder Migrationsentscheidung.
- Bestätigung, dass öffentliche Dateien keine Secret-Werte enthalten.
