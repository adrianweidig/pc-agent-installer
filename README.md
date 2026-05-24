# PC Agent Installer

PC Agent Installer ist ein Template für dokumentierte, reproduzierbare und rollbackfähige Rechner-Einrichtung mit Codex oder anderen lokalen Agenten. Das Repository trennt generische Vorlagen und Skripte von echten Hostdaten, damit ein öffentliches Template nutzbar bleibt, ohne private Infrastrukturinformationen zu speichern.

## Status

- Aktueller Modus: `template`, siehe `repo-mode.yaml`.
- Hostdaten sind in diesem Modus gesperrt.
- `hosts/` bleibt im Template leer und enthält nur `.gitkeep`.
- Die PowerShell- und Bash-Guard-Skripte prüfen vor Host-Schreibzugriffen Modus und Sichtbarkeit.

## Betriebsmodi

- `template`: Öffentliches Template. Keine Hostdaten, keine sensiblen Kontextdaten.
- `operational`: Privates Remote-Repository. Hostdaten und Secret-Referenzen sind erlaubt, Klartext-Secrets bleiben verboten.
- `local-only`: Lokales Git-Repository ohne Remote. Hostdaten sind erlaubt, Push erst nach erneuter Sichtbarkeitsprüfung.

## Arbeitsmodell

Das Projekt ist so gedacht, dass Codex generische Template-Änderungen im öffentlichen Repository pflegen kann, während echte Rechner- und Hostdaten in einem getrennten privaten oder lokalen Operational-Workspace bleiben.

- Offizielle Änderungen: Vorlagen, Skripte, Schemas, Dokumentation, Beispiele, Lizenz- und Sicherheitsregeln im öffentlichen Template.
- Private Änderungen: Host-Baselines, lokale Infrastruktur, Secret-Referenzen, Testzustände und maschinenspezifische Änderungen in einem privaten `operational`-Repo oder `local-only`-Klon.
- Lokale Codex-Aufgaben: nicht als Prompt oder Projektauftrag im öffentlichen Repo speichern; nur generische, wiederverwendbare Regeln in `AGENTS.md` und Dokumentation übernehmen.

## Projektstruktur

- `AGENTS.md`: verbindliche Arbeitsregeln für Codex und andere Agenten.
- `Vorlage/`: numerisch sortierte Aufgaben-Vorlagen für Windows, Linux, WSL, Container und Hardwareprofile.
- `scripts/common/`: Repo-Modus, Sichtbarkeitsprüfung, Template-Validierung und Moduswechsel.
- `scripts/powershell/` und `scripts/bash/`: Host-Erkennung, Baseline- und Änderungsdokumentation.
- `scripts/container/`: Container-, Compose-, Swarm-, Kubernetes-, Podman- und NVIDIA-Erkennung.
- `schemas/`: YAML-Schemas für Host-, Baseline-, Change-, Rollback- und Repo-Modus-Daten.
- `docs/`: Konzept-, Sicherheits-, Betriebs- und Lizenzdokumentation.
- `examples/`: sichere Beispielartefakte ohne echte Hostdaten.
- `private.example/`: Beispiele für private Konfigurationen und Secret-Referenzen.
- `hosts/`: Zielordner für Hostdaten in sicheren Operational- oder Local-only-Repositories.

## Voraussetzungen

- Git
- PowerShell für Windows-Workflows
- Bash für Linux-, WSL- und Unix-nahe Workflows
- Optional: GitHub CLI `gh`, wenn Remote-Sichtbarkeit über GitHub geprüft oder eine private Kopie erstellt werden soll

Es gibt keinen Paketmanager, keine externen Laufzeitabhängigkeiten und keinen klassischen Build-Schritt.

## Schnellstart

Repo-Modus prüfen:

```powershell
./scripts/common/detect-repo-mode.ps1
```

```bash
./scripts/common/detect-repo-mode.sh
```

Template validieren:

```powershell
./scripts/common/verify-template.ps1
```

```bash
bash ./scripts/common/verify-template.sh
```

Host-Schreibrechte prüfen:

```powershell
./scripts/common/assert-private-repo.ps1
```

```bash
./scripts/common/assert-private-repo.sh
```

Im `template`-Modus schlägt `assert-private-repo` absichtlich fehl. Das schützt vor versehentlichem Schreiben von Hostdaten in ein öffentliches oder ungeprüftes Repository.

## Private Nutzung

Private Operational-Kopie über GitHub CLI erzeugen:

```powershell
./scripts/common/create-private-copy.ps1 -Template owner/pc-agent-installer -Destination user/pc-agent-installer-private
```

Lokalen Operational-Modus ohne Remote aktivieren:

```powershell
./scripts/common/enable-local-only-mode.ps1
```

Danach kann eine Host-Baseline erzeugt werden:

```powershell
./scripts/powershell/collect-baseline.ps1
```

## Entwicklung und Prüfung

Vor Änderungen:

```powershell
git status --short --branch
./scripts/common/detect-repo-mode.ps1
```

Nach Template-Änderungen:

```powershell
./scripts/common/verify-template.ps1
```

Zusätzlich sinnvoll:

```bash
bash ./scripts/common/detect-repo-mode.sh
bash ./scripts/common/verify-template.sh
```

Es gibt aktuell keinen Paketmanager, Build-Schritt, Typecheck oder klassischen Unit-Test-Runner. Die relevanten Projektchecks sind in `verify-template.*` gebündelt: Guard-Skripte, Template-Validierung, Skript-Syntax, Encoding, Secret-Scan und Git-Diff-Prüfung.

## Dokumentation

Die zentrale Startdokumentation ist diese README. Vertiefende Dokumente bleiben bewusst getrennt:

- `docs/00-konzept.md`
- `docs/01-public-template-vs-private-operational-repo.md`
- `docs/03-repo-visibility-guard.md`
- `docs/05-secrets-policy.md`
- `docs/08-rollback-konzept.md`
- `docs/11-lizenzmodell.md`
- `docs/12-codex-arbeitsmodell.md`
- `docs/13-test-und-validierungsmodell.md`
- `docs/99-faq.md`

## Codex- und Agenten-Hinweise

Agenten müssen zuerst `AGENTS.md` lesen, danach Repo-Modus und Sichtbarkeit prüfen. Im `template`-Modus sind nur generische Template-, Dokumentations-, Skript- und Hygieneänderungen erlaubt. Echte Hostnamen, private Pfade, produktive Infrastrukturdetails, Secret-Werte und sensible lokale Kontexte dürfen nicht dokumentiert werden.

Der saubere Zustand dieses Repositorys soll bei jeder späteren Codex-Aufgabe erhalten bleiben: kleine Diffs, keine destruktiven Git-Befehle, keine ungeprüften Hostdaten, Template-Validierung nach relevanten Änderungen und klare Trennung zwischen sicheren Änderungen und prüfpflichtigen Punkten.

## Lizenz

Das öffentliche Template steht unter Apache License 2.0, siehe `LICENSE` und `NOTICE`. Private Operational-Repositories, Hostdaten, lokale Infrastrukturinformationen und Nutzerinhalte, die aus dem Template entstehen, sind nicht Teil des öffentlichen Upstream-Projekts.
