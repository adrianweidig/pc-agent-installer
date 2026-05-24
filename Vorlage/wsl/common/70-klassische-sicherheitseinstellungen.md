---
id: WSL-COMMON-70-KLASSISCHE-SICHERHEITSEINSTELLUNGEN
title: Klassische WSL-Sicherheitseinstellungen
platform: linux
environment: wsl
area: wsl/common
requires_admin: false
risk: mittel
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - wsl/common
---

# Klassische WSL-Sicherheitseinstellungen

## Zweck
Diese Vorlage beschreibt blockadearme Sicherheitssettings für WSL-Distributionen. WSL ist Teil eines Windows-Nutzer-PCs; deshalb dürfen Maßnahmen in WSL weder die Windows-Seite noch die Linux-Entwicklungsumgebung unnötig blockieren.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Hostdaten in öffentlichen oder ungeprüften Repositories speichern.
- Keine Klartext-Secrets erfassen.
- Windows- und WSL-Grenzen getrennt dokumentieren.
- Interaktive Entscheidungen nach `Vorlage/common/13-interaktive-sicherheitsentscheidungen.md` stellen.

## Baseline erfassen
Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- WSL-Version und Distribution
- Paketmanager und Update-Status
- Mounts zwischen Windows und WSL
- Netzwerkmodus und exponierte Ports
- installierte Sicherheits- oder Scan-Tools
- systemd-Verfügbarkeit in der Distribution
- relevante Entwicklungsdienste

## Usability-first Defaults
Empfohlen:

- Windows Defender auf der Windows-Seite als Hauptschutz berücksichtigen.
- WSL-Pakete über den Distributionspaketmanager aktuell halten.
- Keine harte Firewall innerhalb von WSL aktivieren, wenn Windows Firewall und WSL-Netzwerkmodus bereits die Grenze bilden.
- ClamAV nur optional für Linux-Dateien, Downloads oder Austauschordner installieren.
- FreshClam-Updates nur dann als Dienst oder Timer aktivieren, wenn systemd verfügbar ist und der Nutzer zustimmt.

## ClamAV-Entscheidung
Frage:

```text
Möchtest du ClamAV innerhalb dieser WSL-Distribution installieren, um Linux-Dateien oder Austauschordner on-demand zu scannen?
```

Default: `Später`, wenn Windows Defender aktiv ist und kein konkreter Scanbedarf besteht.

Wenn der Nutzer zustimmt:

- Paketnamen anhand der Distribution ermitteln.
- Signaturupdate mit FreshClam einrichten.
- Bei systemd-Verfügbarkeit FreshClam-Dienst oder Timer nutzen.
- Ohne systemd einen manuellen oder dokumentierten Update-Befehl verwenden.
- Kein On-Access-Scanning als Default aktivieren.

## Blocklisten-Entscheidung
Frage:

```text
Möchtest du DNS- oder Host-Blocklisten in WSL separat testen, obwohl Windows-seitige Browser und DNS-Einstellungen meist wichtiger sind?
```

Default: `Nein` oder `Später` für normale WSL-Entwicklungsumgebungen.

IP-Firewall-Blocklisten in WSL sind nur sinnvoll, wenn die Distribution exponierte Dienste betreibt. Für normale Entwicklung können sie Paketmanager, Registries, Git, Container und KI-Tooling stören.

## Validierung
Nach Änderungen prüfen:

- `apt`, `dnf`, `pacman` oder der passende Paketmanager funktioniert.
- Git, SSH, Paketregistries und Container-Tools funktionieren.
- Windows-Dateisystem-Mounts sind weiter erreichbar.
- Windows-Browser und Windows-Downloads sind nicht betroffen.
- WSL-Dienste starten weiterhin.

## Erwartete Nachweise
- WSL-Baseline im passenden Host-Unterordner.
- Gestellte Sicherheitsfragen und Antworten.
- ClamAV-/FreshClam-Status, falls installiert.
- Blocklistenstatus, falls getestet.
- Rollback-Pfad und Validierung normaler Nutzung.
