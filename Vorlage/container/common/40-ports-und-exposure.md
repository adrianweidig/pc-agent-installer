---
id: CONTAINER-COMMON-40-PORTS-UND-EXPOSURE
title: Container Ports und Exposure erfassen
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

# Container Ports und Exposure erfassen

## Zweck
Diese Vorlage beschreibt, wie veröffentlichte Container-Ports, Bind-Adressen und Netzwerk-Exposure bewertet werden.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Portänderungen sind systemwirksam und können Dienste unerreichbar oder öffentlich erreichbar machen.
- `0.0.0.0` und `::` gelten als bewusst zu begründende Exposition.
- Lokale Entwicklungsdienste sollen bevorzugt an `127.0.0.1` binden.

## Bewertung

Gute Muster:

- lokale Dashboards, Datenbanken und Entwicklerdienste binden an `127.0.0.1`
- LAN- oder Internet-Exposure ist mit Zweck, Nutzerkreis und Firewall-Kontext dokumentiert
- Reverse Proxies, TLS und Authentifizierung sind bewusst geplant
- nicht benötigte Ports sind nicht veröffentlicht

Anti-Pattern:

- Datenbanken, Admin-Dashboards oder Debug-Server auf `0.0.0.0`
- Portainer, Jupyter, Datenbanken oder KI-Dienste ohne Authentifizierung im LAN
- Ports aus alten Compose-Dateien bleiben nach Projektende aktiv
- Host-Firewall und Container-Ports werden getrennt bewertet, obwohl sie zusammenwirken

## Ablauf

1. Veröffentlichte Ports und Bind-Adressen aggregiert erfassen.
2. Dienstklasse bestimmen: lokal, LAN, öffentlich, unbekannt.
3. Für `0.0.0.0`- oder `::`-Bindings Zweck und Schutzmaßnahmen prüfen.
4. Änderungen an Port-Mappings nur mit Freigabe und Validierung planen.
5. Nach Änderung Erreichbarkeit und Nicht-Erreichbarkeit gezielt prüfen.

## Erwartete Nachweise
- Portmatrix mit Dienstklasse.
- Begründung für alle nicht lokalen Bindings.
- Firewall- und Reverse-Proxy-Kontext, falls vorhanden.
- Validierung über lokale und, wenn nötig, externe Erreichbarkeit.
