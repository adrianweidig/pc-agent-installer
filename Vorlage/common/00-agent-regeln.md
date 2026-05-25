---
id: COMMON-00-AGENT-REGELN
title: Agent-Regeln
platform: any
environment: any
area: common
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - common
---

# Agent-Regeln

## Zweck
Diese Vorlage beschreibt den generischen Soll-Prozess für $area.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Vor echter Ersteinrichtung prüfen, ob Codex im passenden Vollzugriff-Profil gestartet wurde.
- Ohne Administrator-, root-, sudo- oder Runtime-Adminrechte nur Analyse, Baseline und Blockadebericht ausführen.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Vor systemwirksamen Änderungen aktuellen Infrastruktur-Snapshot prüfen oder erzeugen.
- Vor systemwirksamen Änderungen Soll-Ist-Abgleich, Duplikatprüfung und Löschrisiko dokumentieren.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.
- Betriebssystemspezifische Fähigkeiten nur über passende Vorlagen ausführen: Windows, Linux, WSL und macOS müssen jeweils einen vergleichbaren Baseline-, Sicherheits-, Rollback- und Report-Pfad haben.
- Sicherheitsmaßnahmen mit Blockade-, Installations-, Dienst-, Firewall-, DNS- oder Blocklist-Wirkung brauchen eine dokumentierte Frage-Antwort-Entscheidung.

## Ablauf
1. Plattform- und Host-Kontext erkennen.
2. Prüfen, ob die Nutzeraufgabe echte Ersteinrichtung oder nur Analyse ist.
3. Für echte Ersteinrichtung Vollzugriff-Profil nach `Vorlage/common/10-admin-und-sudo-regeln.md` und `docs/23-codex-root-profil.md` bestätigen.
4. Passende Vorlagen auswählen: `Vorlage/windows`, `Vorlage/linux`, `Vorlage/wsl`, `Vorlage/macos` oder `Vorlage/container`.
5. Aktuellen Infrastruktur-Snapshot mit `assert-infrastructure-snapshot.*` prüfen.
6. Relevante Baseline-Dateien unter hosts/<HOSTNAME>/baseline/ prüfen oder erzeugen.
7. Soll-Zustand, Ist-Zustand, Duplikate und Löschrisiko bewerten.
8. Geplante Änderung unter hosts/<HOSTNAME>/changes/ dokumentieren.
9. Falls `rollback_required: true`, Rollback-Datei unter `hosts/<HOSTNAME>/rollback/` anlegen.
10. Validierung ausführen und Ergebnis im Change-Eintrag festhalten.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- dokumentierter Startkontext: Analyseprofil oder Vollzugriff-Profil.
- verwendete Betriebssystem- und Common-Vorlagen.
- dokumentierter Soll-Ist-Abgleich mit Duplikat- und Löschrisikoprüfung.
- gestellte Fragen und Antworten, falls interaktive Sicherheitsentscheidungen betroffen waren.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
