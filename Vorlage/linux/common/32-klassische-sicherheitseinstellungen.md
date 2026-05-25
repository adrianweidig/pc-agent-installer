---
id: LINUX-COMMON-32-KLASSISCHE-SICHERHEITSEINSTELLUNGEN
title: Klassische Linux-Sicherheitseinstellungen
platform: linux
environment: native
area: linux/common
requires_admin: true
risk: mittel
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - linux/common
---

# Klassische Linux-Sicherheitseinstellungen

## Zweck
Diese Vorlage beschreibt blockadearme Sicherheitssettings für normale Linux-Nutzer-PCs. Ziel ist zusätzlicher Schutz, ohne Paketmanager, Browser, Downloads, Entwicklungsumgebungen, Container, Games oder KI-Tools unnötig zu blockieren.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Hostdaten in öffentlichen oder ungeprüften Repositories speichern.
- Keine Klartext-Secrets erfassen.
- Vor Paketinstallation, Dienstaktivierung oder Firewall-Regel Baseline, Change und Rollback dokumentieren.
- Interaktive Entscheidungen nach `Vorlage/common/13-interaktive-sicherheitsentscheidungen.md` stellen.

## Baseline erfassen
Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- Distribution, Version und Paketmanager
- Kernel- und Update-Status
- aktive Firewall-Lösung: `ufw`, `firewalld`, `nftables`, `iptables`
- aktive Sicherheitsdienste
- installierte AV-/Malware-Scanner
- aktive DNS-Konfiguration
- wichtige Paketquellen und Dritt-Repositories
- Verschlüsselungs- und Mount-Status für relevante Datenbereiche
- Scanner-, Firewall- oder Paketmanager-Ausnahmen
- Autostart-/Systemd-Dienste mit Sicherheitsrelevanz

## Usability-first Defaults
Empfohlen und in der Regel blockadearm:

- Distribution über den offiziellen Paketmanager aktuell halten.
- Paketquellen, Dritt-Repositories und Release-Kompatibilität prüfen.
- Firewall aktivieren, wenn sie noch nicht aktiv ist und keine bekannten Dienste gebrochen werden.
- Eingehende Verbindungen restriktiv behandeln; ausgehende Verbindungen nicht pauschal blockieren.
- ClamAV als optionalen On-Demand-Scanner für Downloads, Austauschordner und Windows-Dateien anbieten.
- FreshClam-Signaturupdates als Service oder Timer aktivieren, wenn ClamAV installiert wird.
- Browser-Blocker und DNS-Blocklisten nur im Pilotmodus testen.
- LUKS oder distributionsspezifische Verschlüsselung für mobile/private Systeme empfehlen, aber nicht ohne Recovery- und Backup-Plan aktivieren.

## ClamAV-Entscheidung
Frage:

```text
Möchtest du ClamAV als kostenlosen On-Demand-Malware-Scanner installieren und automatische Signaturupdates aktivieren?
```

Empfohlene Umsetzung, wenn der Nutzer zustimmt:

- Debian/Ubuntu: `clamav`, optional `clamav-daemon`, `clamav-freshclam`
- Fedora/RHEL-Familie: Paketnamen der Distribution prüfen; EPEL nur nach bewusster Entscheidung verwenden
- Arch-Familie: `clamav` aus den offiziellen Repositories prüfen
- Signaturupdates über `clamav-freshclam.service`, `clamav-freshclam.timer` oder distributionsspezifischen FreshClam-Dienst aktivieren
- On-Access-Scanning nur separat und zunächst notify-only testen

Rollback:

- FreshClam-Dienst oder Timer deaktivieren
- ClamAV-Dienste stoppen
- Pakete nur nach gesonderter Freigabe entfernen

## Blocklisten-Entscheidung
Frage:

```text
Möchtest du eine DNS- oder Host-Blockliste im Pilotmodus testen, bevor sie dauerhaft aktiviert wird?
```

Empfohlene Reihenfolge:

1. Browser-Erweiterung oder lokaler DNS-Resolver mit leichtem Profil.
2. DNS-/Host-Blocklisten wie HaGeZi Light/Normal oder StevenBlack base nur mit Allowlist und Rollback.
3. IP-Firewall-Blocklisten nur für exponierte Dienste, Router oder Serverprofile, nicht als Default für normale Desktops.

Validierung:

- Browser öffnet normale Webseiten.
- Paketmanager funktioniert.
- Git, Container-Registry, Store, Cloud-Sync und häufig genutzte Dienste funktionieren.
- Blocklist-Update ist nachvollziehbar und deaktivierbar.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- Gestellte Sicherheitsfragen und Antworten.
- Liste installierter oder bewusst nicht installierter Tools.
- Paketquellen- und Release-Bewertung.
- Verschlüsselungs- oder Backup-Entscheidung.
- Dienststatus für FreshClam oder alternative Update-Mechanismen.
- Firewall- und Blocklistenstatus.
- Rollback-Pfad und Validierung normaler Nutzung.
