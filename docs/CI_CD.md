# CI/CD

## Ziel

Dieses Repository nutzt GitHub Actions für schnelle, nicht destruktive Prüfungen und für automatisierte GitHub Releases nach erfolgreicher Template-Validierung auf `main`. CI/CD darf keine Hostdaten schreiben, keine Secrets erzeugen und keine produktiven Deployments auslösen.

## Workflows

| Workflow | Datei | Zweck |
| --- | --- | --- |
| Validate template | `.github/workflows/validate.yml` | PowerShell- und Bash-Validierung des öffentlichen Templates |
| Release | `.github/workflows/release-artifact.yml` | GitHub Release mit ZIP-Archiv und vollständiger Release-Notes-Datei erzeugen |
| Docker image | `.github/workflows/docker-ghcr.yml` | Validierungsimage bauen und nach erfolgreicher `main`-Validierung in GHCR veröffentlichen |

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
- Deployments

Das zugehörige GHCR-Image wird über den separaten Docker-Workflow veröffentlicht, nachdem `Validate template` für `main` erfolgreich war.

## Docker und GHCR

Dieses Repository veröffentlicht ein generisches Validierungsimage unter:

```text
ghcr.io/adrianweidig/pc-agent-installer
```

Das Image enthält eine Kopie des öffentlichen Templates und führt standardmäßig die strukturelle PowerShell-/Bash-Template-Validierung aus. Es ist kein Host-Konfigurationslauf, schreibt keine Hostdaten und ersetzt keine lokale `verify-template`-Prüfung im Git-Checkout.

Der Workflow:

- baut bei Pull Requests ohne Push
- veröffentlicht nach erfolgreichem `Validate template` auf `main`
- nutzt `GITHUB_TOKEN` und minimale Berechtigungen
- setzt die Tags `sha-<short-sha>`, `main` und `latest`
- setzt OCI-Labels mit Source, Revision und Version

## Dependabot

Dependabot ist für GitHub Actions eingerichtet. Weitere Ökosysteme werden nur ergänzt, wenn passende Projektdateien vorhanden sind.
