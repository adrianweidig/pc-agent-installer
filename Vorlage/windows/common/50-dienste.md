---
id: WINDOWS-COMMON-50-DIENSTE
title: Windows Dienste erfassen
platform: windows
environment: native
area: windows/common
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - windows/common
---

# Windows Dienste erfassen

## Zweck
Diese Vorlage beschreibt, wie Windows-Dienste und Autostart-nahe Hintergrundprozesse bewertet werden. Ziel ist Transparenz, nicht pauschales Tuning.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Dienständerungen, Autostart-Deaktivierungen und geplante Tasks sind systemwirksam.
- Keine Dienste pauschal deaktivieren, nur weil sie gestoppt, automatisch oder unbekannt wirken.
- Windows Update, Defender, Firewall, Store, Treiber, VPN, Backup und Sync-Dienste besonders konservativ behandeln.

## Baseline erfassen

Dokumentiere in einer privaten oder lokalen Operational-Struktur:

- Dienstanzahl nach Starttyp und Status
- automatisch gestartete, aber gestoppte Dienste als Prüfhinweis, nicht als Fehler
- Autostart-Einträge nach Quelle und Hersteller, ohne unnötige private Pfade zu veröffentlichen
- geplante Tasks mit Update-, Sync-, Security- oder Backup-Relevanz
- Remotezugriffsdienste wie RDP, SSH, WinRM oder Hersteller-Remote-Tools

## Bewertung

Gute Muster:

- bekannte Update-, Schutz- und Backup-Dienste bleiben funktionsfähig
- Autostart wird auf Nutzen, Hersteller und Nutzerprofil geprüft
- Remotezugriff ist deaktiviert oder bewusst dokumentiert
- Deaktivierungen haben Rollback und Validierung

Anti-Pattern:

- Tuning-Listen deaktivieren viele Dienste ohne Kontext
- Security-, Update- oder Store-Dienste werden für vermeintliche Performance abgeschaltet
- Autostart wird gelöscht statt zunächst deaktiviert und getestet
- Remotezugriff bleibt aktiv, obwohl kein Bedarf dokumentiert ist

## Ablauf

1. Plattform- und Nutzerprofil erkennen.
2. Dienste, Autostart und geplante Tasks erfassen.
3. Kandidaten nach Risiko gruppieren: Security/Update, Hardware/Treiber, Sync/Backup, Remotezugriff, Komforttools.
4. Nur konkrete, begründete Änderungen vorschlagen.
5. Vor Änderung Dienststatus und Starttyp sichern.
6. Nach Änderung Neustart- oder Funktionsprüfung durchführen.

## Erwartete Nachweise
- Baseline oder Report im passenden Host-Unterordner.
- begründete Kandidatenliste.
- Nutzerfreigabe und Rollback-Pfad für jede Änderung.
- Validierung von Windows Update, Defender, Store, Netzwerk, Sync und häufig genutzten Apps.
