# Contributing

## Scope

Beiträge zum öffentlichen Template müssen generisch bleiben. Keine echten Hostnamen, privaten Pfade, internen Infrastrukturdetails oder Secrets.

## Issues zuerst

Prüfe vor einer Änderung offene Issues. Wenn du einen echten Fehler findest, lege ein detailliertes Issue an oder ergänze ein bestehendes Issue.

Ein gutes Issue enthält:

- Ist-Zustand und erwartetes Verhalten
- Reproduktionsschritte oder konkrete Fundstelle
- betroffene Dateien oder Vorlagen
- Risiko und Auswirkung
- Korrekturvorschlag
- bereits ausgeführte Checks

## Qualität

- Kleine, nachvollziehbare Änderungen bevorzugen.
- Kleine zusammenhängende Änderungen separat committen; kein großer Sammelcommit für unabhängige Themen.
- Vorlagen mit gültigem YAML-Frontmatter versehen.
- Skripte idempotent und nicht destruktiv halten.
- Destruktive Aktionen nur als dokumentierte, freigabepflichtige Schritte modellieren.

## Git-Workflow

Maintainer oder Agents mit Schreibrechten dürfen geprüfte Template-Änderungen direkt auf `main` pushen.

Externe Beitragende ohne Schreibrechte arbeiten über Fork oder Branch und Pull Request. Wenn ein direkter Push scheitert, soll die Änderung nicht verloren gehen: Issue anlegen oder aktualisieren, Korrekturvorschlag dokumentieren und Pull Request vorbereiten.

## Checks

Vor einem Pull Request sollten mindestens ausgeführt werden:

```powershell
./scripts/common/detect-repo-mode.ps1
./scripts/common/validate-template.ps1
./scripts/common/assert-private-repo.ps1
git diff --check
```

In `template`-Repos wird `assert-private-repo` bewusst fehlschlagen, weil Hostschreiben verboten ist. Das ist kein Template-Fehler.
