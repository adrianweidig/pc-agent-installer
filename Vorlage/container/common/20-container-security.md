---
id: CONTAINER-COMMON-20-CONTAINER-SECURITY
title: Container Security erfassen
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

# Container Security erfassen

## Zweck
Diese Vorlage beschreibt, wie Container-Stacks auf normalen Workstations und lokalen Entwicklerumgebungen bewertet werden. Ziel ist kontrollierte lokale Nutzung statt ungeprüfter Exposition.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Keine rohen `docker inspect`-, Env-, Compose- oder Log-Ausgaben speichern, wenn sie Secrets enthalten könnten.
- Container-, Image-, Volume-, Netzwerk- und Portänderungen sind systemwirksam.
- Volumes und Bind-Mounts vor Cleanup als Nutzdaten, Cache, Build-Artefakt oder Secret-Kontext klassifizieren.

## Baseline erfassen

Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- Runtime: Docker, Podman, containerd oder Kubernetes-Kontext
- Anzahl laufender und gestoppter Container
- Images, Volumes und Netzwerke als Anzahl und Klassifikation
- veröffentlichte Ports nach Bind-Adresse
- Compose-Projekte und Arbeitsverzeichnisse ohne Secret-Dumps
- Restart-Policies, privilegierte Container, Capabilities und GPU-/Device-Nutzung

## Bewertung

Gute Muster:

- lokale Dienste binden an `127.0.0.1`, wenn kein LAN-Zugriff nötig ist
- Compose-Projekte haben nachvollziehbare Dateien und Projektgrenzen
- Volumes sind vor Updates und Cleanup klassifiziert
- Secrets werden über Secret-Mechanismen, Dateien mit passenden Rechten oder externe Stores referenziert
- Images und Basisimages werden regelmäßig geprüft

Anti-Pattern:

- `0.0.0.0`-Bindings für reine Entwicklungsdienste
- Secrets in Env-Dumps, Compose-Dateien, Logs oder Repository-Dateien
- unklassifizierte Volumes löschen oder prune-Befehle blind ausführen
- Container laufen privilegiert oder mit Host-Netzwerk ohne dokumentierten Zweck
- `latest` ohne Update- und Rollback-Strategie für wichtige Dienste

## Ablauf

1. Runtime und Operational-Kontext prüfen.
2. Aggregierte Container-, Port-, Volume- und Image-Baseline erfassen.
3. Secret-haltige Ausgaben vermeiden oder redigieren.
4. Risiken nach Exposure, Datenverlust, Secret-Leak und Update-Drift gruppieren.
5. Änderungen nur mit Nutzerfreigabe, Rollback-Grenze und Validierung planen.

## Erwartete Nachweise
- Baseline oder Report im passenden Host-Unterordner.
- Port-, Volume-, Secret- und Image-Bewertung.
- Liste bewusst nicht gespeicherter sensibler Rohdaten.
- Rollback-Pfad für jede systemwirksame Änderung.
