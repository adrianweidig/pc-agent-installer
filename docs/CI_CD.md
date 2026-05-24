# CI/CD

## Ziel

Dieses Repository nutzt GitHub Actions für schnelle, nicht destruktive Prüfungen und für nicht-publizierende Release-Artefakte. CI/CD darf keine Hostdaten schreiben, keine Secrets erzeugen und keine produktiven Deployments auslösen.

## Workflows

| Workflow | Datei | Zweck |
| --- | --- | --- |
| Validate template | `.github/workflows/validate.yml` | PowerShell- und Bash-Validierung des öffentlichen Templates |
| Release artifact | `.github/workflows/release-artifact.yml` | ZIP-Archiv und Release Notes als Actions-Artefakte erzeugen |

## Validate template

Der Validierungsworkflow läuft bei Pull Requests und Pushes auf `main`.

Er prüft:

- Repo-Modus und Sichtbarkeit
- Template-Struktur
- YAML-Frontmatter der Vorlagen
- PowerShell- und Bash-Syntax
- Encoding-Regeln
- typische Secret-Pattern
- Git-Diff-Whitespace

Lokale Entsprechung:

```powershell
./scripts/common/verify-template.ps1
```

```bash
bash ./scripts/common/verify-template.sh
```

## Release-Artefakte

Der Release-Artefakt-Workflow läuft bei Pushes auf `main` oder `master` und manuell per `workflow_dispatch`.

Er erzeugt:

- ein ZIP aus dem aktuellen Commit mit `git archive`
- eine `release-notes.md` mit Repository, Branch, Commit, Event, Actor, UTC-Zeitpunkt und Commit-Historie
- ein GitHub-Actions-Artefakt mit ZIP und Release Notes

Er erzeugt nicht:

- Tags
- GitHub Releases
- Package-Veröffentlichungen
- Docker Images
- Deployments

Echte Releases bleiben eine bewusste Maintainer-Entscheidung und sind in `docs/RELEASE_PROCESS.md` beschrieben.

## Docker und GHCR

Dieses Repository enthält aktuell keine Docker-Grundlage. Deshalb gibt es keinen Docker-/GHCR-Workflow.

Wenn später Docker-Unterstützung ergänzt wird, darf ein GHCR-Workflow nur eingerichtet werden, wenn `Dockerfile`, Compose-Dateien, `.dockerignore` oder dokumentierte Docker-Build-Befehle vorhanden sind. Der Workflow soll `GITHUB_TOKEN` nutzen, minimale Berechtigungen setzen und keine zusätzlichen Secrets verlangen.

## Dependabot

Dependabot ist für GitHub Actions eingerichtet. Weitere Ökosysteme werden nur ergänzt, wenn passende Projektdateien vorhanden sind.
