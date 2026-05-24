# GitHub Security Alert Analysis

## Zusammenfassung

Analysezeitpunkt: 2026-05-24

Repository: `adrianweidig/pc-agent-installer`

Ergebnis: Es gibt aktuell keine offenen GitHub-Security-Alerts für dieses Repository. Code Scanning und SARIF-Analysen sind nicht eingerichtet; die GitHub-API meldet deshalb `no analysis found`. Dependabot Alerts, Secret Scanning Alerts und Repository Security Advisories liefern jeweils keine offenen Befunde.

Ein lokaler, sicherheitsrelevanter Code-Hygiene-Befund wurde behoben: `scripts/container/collect-docker.ps1` nutzte `Invoke-Expression` für eine feste Docker-Befehlsliste. Die Ausführung wurde auf strukturierte `FilePath`/`ArgumentList`-Aufrufe umgestellt. Der Scaffold-Generator wurde konsistent angepasst.

## Geprüfte GitHub-Quellen

| Quelle | Ergebnis |
| --- | --- |
| Code Scanning Alerts | keine Analyse vorhanden, API meldet `no analysis found` |
| Code Scanning Analyses | keine Analyse vorhanden, API meldet `no analysis found` |
| SARIF-Ergebnisse | keine SARIF-Uploads vorhanden |
| Dependabot Alerts, offen | `0` |
| Dependabot Alerts, fixed | `0` |
| Dependabot Alerts, dismissed | `0` |
| Secret Scanning Alerts, offen | `0` |
| Secret Scanning Alerts, resolved | `0` |
| Repository Security Advisories | `0` |
| GitHub Actions Runs | letzte `Validate template`- und `Release artifact`-Runs erfolgreich |

## Genutzte APIs und Tools

GitHub CLI und REST-API:

```text
gh repo view adrianweidig/pc-agent-installer
gh run list --repo adrianweidig/pc-agent-installer
gh api repos/adrianweidig/pc-agent-installer/code-scanning/alerts
gh api repos/adrianweidig/pc-agent-installer/code-scanning/analyses
gh api repos/adrianweidig/pc-agent-installer/dependabot/alerts
gh api repos/adrianweidig/pc-agent-installer/secret-scanning/alerts
gh api repos/adrianweidig/pc-agent-installer/security-advisories
gh api repos/adrianweidig/pc-agent-installer/branches/main/protection
```

Lokale Prüfungen:

```text
rg
git status --short --branch
git diff --check
./scripts/common/verify-template.ps1
bash ./scripts/common/verify-template.sh
bash -n scripts/apply-codex-project-standard.sh
```

Nicht verfügbare lokale Zusatzscanner:

- `gitleaks`
- `trufflehog`
- `semgrep`
- `shellcheck`
- `actionlint`
- `yamllint`
- PowerShell-Modul `PSScriptAnalyzer`

## GitHub-Security-Konfiguration

Aktiviert:

- Security Policy
- Private Vulnerability Reporting
- Dependabot Security Updates
- Secret Scanning
- Secret Scanning Push Protection
- Branch Protection auf `main`
- Required Status Checks: `PowerShell verification`, `Bash verification`
- Conversation Resolution vor Merge
- ein verpflichtendes Review vor Merge

Nicht eingerichtet:

- CodeQL/Code Scanning
- SARIF Uploads

CodeQL wurde nicht ergänzt, weil das Repository primär aus PowerShell-, Bash-, YAML- und Markdown-Dateien besteht und kein sinnvoller CodeQL-Sprachworkflow für die Hauptflächen ableitbar ist.

## Lokale Befundvalidierung

### GHSA-/CVE-/Dependency-Fläche

Das Repository enthält keine klassischen Paketmanager-Manifeste wie `package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml` oder `build.gradle`.

Dependabot ist für GitHub Actions konfiguriert. Die verwendeten Actions sind:

- `actions/checkout@v4`
- `actions/upload-artifact@v4`

GitHub Dependabot Alerts: keine Befunde.

### Secret-Fläche

Secret Scanning meldet keine offenen oder resolved Alerts.

Lokale Pattern-Suche auf typische Token-, Private-Key- und Credential-Muster ergab keine Secret-Werte. Treffer auf Begriffe wie `GITHUB_TOKEN`, `secret` oder `token` waren Dokumentation, Redaktionslogik oder GitHub-Actions-Kontext, keine Klartext-Secrets.

### GitHub Actions und CI

Die Workflows setzen minimale Berechtigungen:

```yaml
permissions:
  contents: read
```

Es gibt keine `pull_request_target`-, `workflow_run`- oder Deployment-Trigger. Workflows verwenden keine Repository-Secrets und keine produktiven Veröffentlichungen.

Der `Release artifact`-Workflow erzeugt nur Actions-Artefakte. Er erzeugt keine Tags, keine GitHub Releases, keine Package Releases und keine Docker Images.

### Lokale Kommando-Wrapper

Die Skripte `apply-step`, `rollback-step` und `validate-step` sind bewusst lokale Ausführungshilfen für operatorgesteuerte Befehle. `apply-step` und `rollback-step` erfordern eine explizite Freigabe. Diese Skripte sind keine GitHub-Actions-Entrypoints und werden nicht durch externe Pull-Request-Daten gespeist.

Ein unnötiger `Invoke-Expression`-Einsatz in `scripts/container/collect-docker.ps1` wurde entfernt, weil dort nur eine feste Docker-Befehlsliste ausgeführt wird.

## Durchgeführte Änderungen

- `scripts/container/collect-docker.ps1`: feste Docker-Befehle werden nun über `FilePath` und `ArgumentList` aufgerufen, nicht mehr über `Invoke-Expression`.
- `scripts/dev/scaffold-initial-repo.ps1`: generierter Inhalt für `scripts/container/collect-docker.ps1` konsistent angepasst.
- Diese Analyse unter `docs/SECURITY_ALERT_ANALYSIS.md` dokumentiert.

## GitHub-Alert-Status

Es wurden keine GitHub Alerts dismissed, reopened oder manuell als fixed markiert, weil keine offenen Alerts vorhanden waren.

Code Scanning Alerts konnten nicht aktualisiert werden, weil keine Code-Scanning-Analyse existiert.

## Verbleibende Risiken

- CodeQL/SARIF ist nicht aktiv. Für diese Projektsprachen ist kein sinnvoller CodeQL-Workflow ableitbar; externe Scanner wie `shellcheck`, `actionlint`, `gitleaks` oder `semgrep` können bei Bedarf zusätzlich in CI ergänzt werden.
- Die lokalen `*-step`-Wrapper führen bewusst operatorgesteuerte Befehle aus. Sie dürfen nur mit vertrauenswürdigen Eingaben verwendet werden.
- GitHub Actions sind über versionierte Tags referenziert, nicht über vollständige Commit-SHAs. Das ist üblich, aber SHA-Pinning wäre eine strengere Supply-Chain-Härtung.

## Manuelle Folgeschritte

- Optional `actionlint` und `shellcheck` als zusätzliche lokale oder CI-Prüfungen einführen, wenn die Projektwartung diese Zusatzabhängigkeiten akzeptiert.
- Optional Actions auf vollständige Commit-SHAs pinnen, wenn maximale Supply-Chain-Härtung wichtiger ist als Wartbarkeit.
- Falls Code Scanning gewünscht ist, zuerst einen passenden Scanner für PowerShell/Bash/YAML auswählen und SARIF-Upload bewusst konfigurieren.
