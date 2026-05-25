---
id: COMMON-14-ERSTSTART-KONFIGURATION
title: Erststart-Konfiguration
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

# Erststart- und Agenten-Konfiguration

## Zweck
Diese Vorlage erzwingt eine nutzerfreundliche Agenten-Konfiguration, bevor ein Agent Hostdaten erfasst, Sicherheitsmaßnahmen empfiehlt, Pakete installiert oder systemwirksame Änderungen vorbereitet.

## Grundregel
Der Agent darf vor abgeschlossener Erststart-Konfiguration keine Host-Arbeit ausführen. Wenn der Nutzer keine Konfiguration starten will, muss er klar melden:

```text
Die Konfiguration für den Erststart ist noch nicht abgeschlossen.
Bitte zuerst die Erststart-Konfiguration ausführen.
```

Wenn der Nutzer dagegen Formulierungen wie `starte die Erstkonfiguration`, `starte die Agenten-Konfiguration für meinen PC`, `konfiguriere diesen PC` oder `öffne die Konfiguration erneut` nutzt, muss der Agent die Konfigurationsumgebung selbst starten oder den sicheren Operational-Kontext dafür herstellen.

## Agentischer Einstieg

Der Nutzer soll keine Skriptliste abarbeiten müssen. Der Agent liest `AGENTS.md`, prüft Repo-Modus, Sichtbarkeit und Git-Status und entscheidet danach:

- In einem öffentlichen oder ungeprüften `template`-Repository werden keine Hostdaten geschrieben.
- Für echte PC-Konfiguration wird eine private Operational-Kopie oder ein `local-only`-Klon genutzt.
- Erst in einem erlaubten Operational-Kontext wird `first-run-config.*` als Werkzeug gestartet.
- Eine bestehende Konfiguration wird als Vorbelegung behandelt und darf erneut geöffnet werden.

Die Skripte sind Werkzeuge. Die Entscheidung, ob und wann sie genutzt werden, trifft der Agent anhand dieser Vorlage und der übrigen Markdown-Regeln.

## Interaktion
Windows bevorzugt den PowerShell-Dialog:

```powershell
./scripts/common/first-run-config.ps1
```

Linux, WSL und macOS nutzen den Shell-Dialog:

```bash
bash ./scripts/common/first-run-config.sh
```

Wenn kein GUI-Fenster verfügbar ist, muss der Agent auf Terminal-Fragen zurückfallen, statt Host-Arbeit ohne Konfiguration zu starten.

## Mindestfragen
Die Erststart-Konfiguration fragt mindestens:

- Wie beschreibt sich der Nutzer kurz, damit der Agent sinnvolle Programm- und Umgebungsempfehlungen ableiten kann?
- Darf der Agent eine Host-Baseline erfassen?
- Darf der Agent usability-first Sicherheitsempfehlungen anzeigen?
- Darf der Agent kostenlose, aktuelle Tools und Updates empfehlen?
- Darf der Agent optionale AV-/Malware-Scanner anbieten?
- Darf der Agent DNS-/Host-Blocklisten im Pilotmodus anbieten?
- Darf der Agent IP-Firewall-Blocklisten als riskante Option anbieten?
- Windows: Soll ein WSL-Backend für Linux-Tools, Entwickler- oder KI-Workflows vorbereitet werden?
- Windows: Wenn WSL gewünscht ist, soll Docker mit WSL-Unterstützung eingeplant werden?
- Windows: Wenn Docker gewünscht ist, soll Portainer CE als kostenlose Docker-Verwaltungsoberfläche empfohlen werden?
- Soll vor systemwirksamen Änderungen immer eine Bestätigung verlangt werden?

## Nachweis
Die Antwort wird unter `hosts/<HOSTNAME>/state/first-run-config.yaml` dokumentiert. Diese Datei enthält nur Präferenzen und keine Klartext-Secrets.

Bei erneuter Ausführung nutzt der Agent vorhandene Werte als Defaults. Dadurch können Nutzer Optionen aktivieren, deaktivieren oder die Nutzerbeschreibung aktualisieren, ohne eine neue Umgebung aufzubauen.

Wenn WSL gewählt wurde, muss der Agent zusätzlich die WSL-Vorlagen berücksichtigen. Wenn Docker oder Portainer gewählt wurde, muss der Agent zusätzlich die Container-Vorlagen berücksichtigen. Docker und Portainer dürfen nicht unabhängig von WSL als Pflichtkomponenten behandelt werden.

Die Nutzerbeschreibung ist ein Hinweis für Empfehlungen, keine automatische Installationsfreigabe. Der Agent muss daraus Profile ableiten und Programmvorschläge nach `Vorlage/common/15-programm-und-installationsempfehlungen.md` vorbereiten.

## Schalter-Semantik

Konfigurationswerte wirken als Präferenz-Schalter:

- Aktivierte Optionen erlauben Empfehlungen, Prüfungen oder später freigegebene Arbeiten.
- Deaktivierte Optionen sperren künftige Empfehlungen oder Vorbereitungen.
- Deaktivierung ist kein automatischer Rollback.

Wenn eine deaktivierte Option bereits systemwirksam umgesetzt wurde, muss der Agent Change-Einträge, Rollback-Dateien, Baseline, Soll-Ist-Abgleich und Nutzdatenrisiko prüfen. Erst danach darf er einen Rückbau vorschlagen oder ausführen.

## Pflichtprüfung
Vor Host-Arbeit muss eine der Prüfungen erfolgreich sein:

```powershell
./scripts/common/assert-first-run-config.ps1
```

```bash
bash ./scripts/common/assert-first-run-config.sh
```
