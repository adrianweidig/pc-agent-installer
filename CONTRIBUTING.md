# Contributing

## Scope

Beiträge zum öffentlichen Template müssen generisch bleiben. Keine echten Hostnamen, privaten Pfade, internen Infrastrukturdetails oder Secrets.

## Qualität

- Kleine, nachvollziehbare Änderungen bevorzugen.
- Vorlagen mit gültigem YAML-Frontmatter versehen.
- Skripte idempotent und nicht destruktiv halten.
- Destruktive Aktionen nur als dokumentierte, freigabepflichtige Schritte modellieren.

## Checks

Vor einem Pull Request sollten mindestens ausgeführt werden:

```powershell
./scripts/common/detect-repo-mode.ps1
./scripts/common/validate-template.ps1
./scripts/common/assert-private-repo.ps1
git diff --check
```

In `template`-Repos wird `assert-private-repo` bewusst fehlschlagen, weil Hostschreiben verboten ist. Das ist kein Template-Fehler.
