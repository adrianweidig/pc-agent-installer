# CI/CD

## Ziel

Dieses Repository nutzt GitHub Actions für schnelle, nicht destruktive Prüfungen und für automatisierte GitHub Releases nach erfolgreicher Template-Validierung auf `main`. CI/CD darf keine Hostdaten schreiben, keine Secrets erzeugen und keine produktiven Deployments auslösen.

## Workflows

| Workflow | Datei | Zweck |
| --- | --- | --- |
| Validate template | `.github/workflows/validate.yml` | PowerShell- und Bash-Validierung des öffentlichen Templates |
| Release | `.github/workflows/release-artifact.yml` | GitHub Release mit ZIP-Archiv und vollständiger Release-Notes-Datei erzeugen |

## Validate template

Der Validierungsworkflow läuft bei Pull Requests und Pushes auf `main`.

Er prüft:

- Repo-Modus und Sichtbarkeit
- Template-Struktur
- YAML-Frontmatter der Vorlagen
- PowerShell- und Bash-Syntax
- Produktkomponenten-i18n
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

## Releases

Der Release-Workflow läuft, sobald `Validate template` nach einem Push auf `main` erfolgreich abgeschlossen wurde. Dadurch wird nicht parallel zu den Prüfungen veröffentlicht, sondern erst nach erfolgreicher Validierung. Zusätzlich kann der Workflow manuell per `workflow_dispatch` gestartet werden.

Er erzeugt:

- ein ZIP aus dem aktuellen Commit mit `git archive`
- einen eindeutigen GitHub-Release-Tag im Format `release-<short-sha>`
- einen GitHub Release, der als `latest` markiert wird
- eine `release-notes.md` mit Repository, Branch, Commit, Event, Actor, UTC-Zeitpunkt, Zusammenfassung der wichtigsten Änderungen und vollständiger Commit-Historie
- Release-Assets für ZIP und Release Notes

Er erzeugt nicht:

- Package-Veröffentlichungen
- Docker Images
- Deployments

Docker Images werden weiterhin nur ergänzt, wenn später eine echte Docker-Grundlage entsteht.

## Docker und GHCR

Dieses Repository enthält aktuell keine Docker-Grundlage. Deshalb gibt es keinen Docker-/GHCR-Workflow.

Wenn später Docker-Unterstützung ergänzt wird, darf ein GHCR-Workflow nur eingerichtet werden, wenn `Dockerfile`, Compose-Dateien, `.dockerignore` oder dokumentierte Docker-Build-Befehle vorhanden sind. Der Workflow soll `GITHUB_TOKEN` nutzen, minimale Berechtigungen setzen und keine zusätzlichen Secrets verlangen.

## Dependabot

Dependabot ist für GitHub Actions eingerichtet. Weitere Ökosysteme werden nur ergänzt, wenn passende Projektdateien vorhanden sind.
