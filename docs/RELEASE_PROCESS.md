# Release-Prozess

Dieses Repository hat ein Changelog und eine initiale Version `0.1.0`. Aktuelle Veröffentlichungen entstehen automatisiert nach erfolgreicher Template-Validierung auf `main`.

## Vor einem Release

1. Arbeitsbaum prüfen:

   ```powershell
   git status --short --branch
   ```

2. Template-Modus und Sichtbarkeit prüfen:

   ```powershell
   ./scripts/common/detect-repo-mode.ps1
   ```

3. Standardchecks ausführen:

   ```powershell
   ./scripts/common/verify-template.ps1
   ```

   ```bash
   bash ./scripts/common/verify-template.sh
   ```

4. Sicherstellen, dass `repo-mode.yaml` weiterhin `template` ist.
5. Sicherstellen, dass `hosts/` im öffentlichen Template nur `.gitkeep` enthält.
6. `CHANGELOG.md` aktualisieren.
7. Prüfen, dass keine Secrets, Hostdaten oder privaten Pfade enthalten sind.

## Versionierung

Solange kein formales Versionierungsschema beschlossen ist, sollten Releases klein und nachvollziehbar bleiben. Eine semantische Versionierung kann sinnvoll sein, sobald sich stabile Nutzerflüsse oder Skriptverträge herausgebildet haben.

## Automatischer GitHub Release

Der Workflow `.github/workflows/release-artifact.yml` erstellt nach jedem erfolgreichen `Validate template`-Lauf auf `main` einen GitHub Release.

Der Release enthält:

- einen eindeutigen Tag im Format `release-<short-sha>`
- ein ZIP aus dem geprüften Commit
- eine angehängte `release-notes.md`
- dieselben Release Notes als Release-Beschreibung
- eine Zusammenfassung der wichtigsten Änderungen seit dem vorherigen Tag
- eine vollständige Liste aller bis dahin enthaltenen Commits
- technische Metadaten zu Commit, Branch, Event, Actor und Workflow-Run

Der Workflow nutzt `actions/checkout`, die GitHub CLI und Python-Standardbibliothek auf dem GitHub-Runner. Er benötigt keine zusätzlichen Secrets und erzeugt keine Docker Images, Package Releases oder produktiven Deployments.

## Manueller GitHub Release

Der Workflow kann per `workflow_dispatch` manuell neu gestartet werden. Optional kann dabei ein konkreter Commit-SHA angegeben werden.

Manuelle Releases außerhalb dieses Workflows sollten nur genutzt werden, wenn eine besondere Maintainer-Entscheidung dokumentiert ist.

## Nach dem Release

- Prüfen, ob `Validate template` und `Release` für den Default-Branch grün sind.
- Dokumentation und README auf veraltete Versionshinweise prüfen.
- Neue Punkte für `Unreleased` in `CHANGELOG.md` beginnen.
