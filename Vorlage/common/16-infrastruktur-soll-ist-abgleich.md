---
id: COMMON-16-INFRASTRUKTUR-SOLL-IST-ABGLEICH
title: Infrastruktur-Soll-Ist-Abgleich
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

# Infrastruktur-Soll-Ist-Abgleich

## Zweck

Diese Vorlage ist eine harte Sicherheitsgrenze für Vollzugriff-Agenten. Vor jeder systemwirksamen Änderung muss der Agent die aktuelle Umgebung prüfen, den gewünschten Zielzustand formulieren und Ist gegen Soll vergleichen.

Vollzugriff bedeutet nur, dass der Agent technisch handeln kann. Es bedeutet nicht, dass er ohne aktuelle Infrastrukturprüfung installieren, löschen, stoppen, überschreiben, migrieren oder bereinigen darf.

## Pflicht vor jeder Änderung

Vor Installationen, Deinstallationen, Löschungen, Updates, Dienständerungen, Firewall-Regeln, DNS-/Blocklisten, Container-Aktionen, WSL-/Docker-/Portainer-Arbeit, Paketmanager-Aktionen oder Cleanup muss der Agent:

1. Erststart-Konfiguration prüfen.
2. Aktuelle Baseline oder Infrastruktur-Snapshot prüfen.
3. Wenn Snapshot fehlt oder offensichtlich veraltet ist, Baseline neu erfassen.
4. Soll-Zustand in einem Change-Eintrag dokumentieren.
5. Ist-Zustand aus Baseline, Paketmanager, Diensten, Containern, Dateien und vorhandenen Konfigurationen ableiten.
6. Duplikatprüfung durchführen: existiert das Ziel bereits, gibt es äquivalente Software, Services, Ports, Container, Volumes oder Paketquellen?
7. Lösch- und Seiteneffektprüfung durchführen: welche Dateien, Dienste, Pakete, Container, Volumes, Netzwerkregeln, Autostarts oder Nutzerprofile könnten betroffen sein?
8. Nur die minimale Änderung planen.
9. Rollback-Grenzen dokumentieren.
10. Nutzerfreigabe einholen, wenn die Änderung systemwirksam ist.

## Pflichtbefehle

PowerShell:

```powershell
./scripts/common/assert-first-run-config.ps1
./scripts/common/assert-infrastructure-snapshot.ps1
```

Bash:

```bash
bash ./scripts/common/assert-first-run-config.sh
bash ./scripts/common/assert-infrastructure-snapshot.sh
```

Wenn einer dieser Checks fehlschlägt, darf der Agent keine systemwirksame Änderung ausführen.

## Soll-Ist-Fragen

Der Agent muss vor dem Vollzug mindestens diese Fragen beantworten:

- Was ist der gewünschte Zielzustand?
- Was ist aktuell bereits installiert, aktiviert, konfiguriert oder vorhanden?
- Ist das Ziel bereits vollständig oder teilweise erreicht?
- Gibt es eine konfliktärmere Alternative zur Neuinstallation?
- Welche vorhandenen Daten, Volumes, Profile oder Konfigurationen könnten betroffen sein?
- Welche konkrete Änderung ist minimal notwendig?
- Wie wird validiert, dass normale Nutzung weiterhin funktioniert?
- Wie wird die Änderung zurückgenommen, ohne Nutzdaten zu löschen?

## Keine-Duplikate-Regel

Der Agent darf nichts erneut installieren oder parallel einrichten, wenn eine gleichwertige funktionsfähige Komponente bereits vorhanden ist. Beispiele:

- keinen zweiten Paketmanager ohne Grund,
- keinen zweiten Docker-Daemon ohne erklärten Kontext,
- keine zweite Echtzeit-AV-Lösung,
- keine zweite Portainer-Instanz auf anderem Port ohne Bedarf,
- keine doppelte App-Installation über Store und Paketmanager,
- keine parallelen WSL-Distributionen ohne Zweck,
- keine doppelten Autostart- oder Dienstdefinitionen.

## Keine-Löschung-ohne-Kontext-Regel

Der Agent darf nichts löschen oder bereinigen, solange nicht klar ist, ob es aktuelle Nutzdaten, aktive Infrastruktur oder Rollback-relevante Daten enthält.

Besonders geschützt:

- Nutzerprofile und Dokumente,
- Docker-Volumes,
- WSL-Distributionen,
- Datenbank-, Seafile-, RAG-, KI- und Projektverzeichnisse,
- Secret-Stores und Credential-Manager,
- SSH-, GPG- und Zertifikatsmaterial,
- Paketmanager- und Container-Konfigurationen,
- lokale Repositories und aktive Codex-Workspaces.

## Erwarteter Nachweis

Jeder Change-Eintrag muss enthalten:

- aktueller Infrastruktur-Snapshot oder Baseline-Verweis,
- Soll-Zustand,
- Ist-Zustand,
- Soll-Ist-Bewertung,
- Duplikatprüfung,
- Lösch- und Seiteneffektprüfung,
- Minimaländerung,
- Validierung,
- Rollback-Grenzen.
