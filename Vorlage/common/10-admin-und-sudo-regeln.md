---
id: COMMON-10-ADMIN-UND-SUDO-REGELN
title: Admin- und Sudo-Regeln
platform: any
environment: any
area: common
requires_admin: true
risk: mittel
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - common
---

# Admin- und Sudo-Regeln

## Zweck
Diese Vorlage beschreibt den verbindlichen Vollzugriff-Startkontext für echte Erstkonfigurationen.

PC Agent Installer ist als Systemadministrator-Ersatz für die initiale Grundkonfiguration gedacht. Dafür muss der Agent mit den Rechten laufen, die ein Administrator für Paketmanager, Benutzer, Gruppen, Dienste, Firewall, Sicherheitsrichtlinien und Systemdateien hätte. Fehlen diese Rechte, ist der Lauf kein vollständiger Erstkonfigurationslauf.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Nutzer vorab klar informieren, dass der Agent mit Administrator-, root-, sudo- oder Runtime-Adminrechten handeln kann.
- Vollzugriff-Profil vor systemwirksamen Änderungen explizit bestätigen.
- Wenn der Prozess nicht mit ausreichenden Rechten läuft, keine Paketmanager-, Firewall-, Dienst-, Benutzer-, Gruppen-, Registry-, Launchd-, systemd-, Docker-, Podman-, Kubernetes- oder WSL-Änderungen ausführen.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Vor systemwirksamen Änderungen aktuellen Infrastruktur-Snapshot und Soll-Ist-Abgleich prüfen.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.

## Plattformrechte

| Plattform | Mindestkontext für echte Ersteinrichtung |
| --- | --- |
| Windows | Erhöhte Administrator-Sitzung für UAC-geschützte Bereiche, Windows Features, Dienste, Firewall, Registry, systemweite Programme und Richtlinien |
| Linux | root oder freigegebener sudo-Kontext für Paketmanager, systemd, Firewall, Benutzer, Gruppen, SSH, Kernel-/Treiber- und Sicherheitskonfiguration |
| Debian/Ubuntu | root/sudo plus explizite Apply-Freigabe, zum Beispiel `PC_AGENT_ALLOW_SYSTEM_CHANGES=true` |
| RHEL/Fedora/Arch | root/sudo für `dnf`, `rpm-ostree`, `pacman`, Repositories, firewalld/nftables, systemd und Benutzerverwaltung |
| macOS | Administrator-Konto mit gezielten `sudo`-Aktionen für Homebrew/MacPorts, Firewall, LaunchAgents/LaunchDaemons und Sicherheitsfunktionen |
| WSL | root/sudo innerhalb der Distribution; Windows-seitige WSL-, Netzwerk- oder Docker-Integration braucht zusätzlich Windows-Adminfreigabe |
| Container | root oder passende Runtime-Rechte im Container; Host-Mounts, Ports, Volumes und Daemon-Konfiguration bleiben eigene Freigabeentscheidungen |

## Ablauf
1. Nutzerhinweis ausgeben: Der Installer ist für Vollzugriff-Ersteinrichtung konzipiert.
2. Plattform- und Host-Kontext erkennen.
3. Tatsächliche Rechte prüfen, zum Beispiel Administratorstatus, `id -u`, sudo-Fähigkeit, Container-Capabilities oder Runtime-Zugriff.
4. Wenn Rechte fehlen: keine systemwirksamen Änderungen ausführen, Blockade dokumentieren und passenden Start mit Vollzugriff-Profil nennen.
5. Relevante Baseline-Dateien unter hosts/<HOSTNAME>/baseline/ prüfen oder erzeugen.
6. Sollzustand, Risiken und Rollback-Pfad dokumentieren.
7. Geplante Änderung unter hosts/<HOSTNAME>/changes/ dokumentieren.
8. Falls `rollback_required: true`, Rollback-Datei unter `hosts/<HOSTNAME>/rollback/` anlegen.
9. Validierung ausführen und Ergebnis im Change-Eintrag festhalten.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- dokumentierter Rechtekontext und Ergebnis der Vollzugriff-Prüfung.
- dokumentierte Nutzerfreigabe oder dokumentierte Blockade.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
