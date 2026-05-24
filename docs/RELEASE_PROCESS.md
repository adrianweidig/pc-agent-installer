# Release-Prozess

Dieses Repository hat ein Changelog und eine initiale Version `0.1.0`. Es gibt derzeit keinen automatisierten Release-Workflow.

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

## GitHub Release

Ein manueller GitHub Release sollte enthalten:

- Tag, zum Beispiel `v0.1.0`
- kurze Zusammenfassung
- relevante Änderungen aus `CHANGELOG.md`
- ausgeführte Checks
- bekannte Grenzen

Keine produktiven Deployments oder externen Veröffentlichungen werden durch dieses Repository automatisch ausgelöst.

## Nach dem Release

- Prüfen, ob der CI-Workflow für den Tag oder Default-Branch grün ist.
- Dokumentation und README auf veraltete Versionshinweise prüfen.
- Neue Punkte für `Unreleased` in `CHANGELOG.md` beginnen.
