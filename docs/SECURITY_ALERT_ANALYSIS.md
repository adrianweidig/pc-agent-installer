# GitHub Security Alert Analysis

## Zusammenfassung

Analysezeitpunkt: 2026-05-24

Repository: `adrianweidig/pc-agent-installer`

Ergebnis: Es gibt aktuell keine offenen GitHub-Security-Alerts für dieses Repository. Dependabot Alerts, Secret Scanning Alerts und Repository Security Advisories liefern keine Befunde. Code Scanning und SARIF-Analysen sind nicht eingerichtet; die GitHub-API meldet deshalb `no analysis found`.

Lokale Zusatzscanner wurden temporär außerhalb des Repositories geladen, per SHA-256 geprüft und ausgeführt:

- `gitleaks` 8.30.1: keine Leaks in Git-Historie oder Arbeitsbaum
- `actionlint` 1.7.12: keine Workflow-Befunde
- `shellcheck` 0.11.0: ein Code-Hygiene-Befund in Bash-Step-Wrappern wurde behoben

## Geprüfte GitHub-Quellen

| Quelle | Ergebnis |
| --- | --- |
| Repository-Kontext | öffentliches Repository `adrianweidig/pc-agent-installer`, Default-Branch `main` |
| Code Scanning Alerts | keine Analyse vorhanden, API meldet `no analysis found` |
| Code Scanning Analyses | keine Analyse vorhanden, API meldet `no analysis found` |
| SARIF-Ergebnisse | keine lokalen SARIF-Dateien und keine GitHub Code-Scanning-Analysen vorhanden |
| Dependabot Alerts | `0` |
| Secret Scanning Alerts | `0` |
| Repository Security Advisories | `0` |
| Private Vulnerability Reporting | aktiviert |
| GitHub Actions Workflows | `Validate template`, `Release artifact` und Dependabot-Workflow aktiv |
| GitHub Actions Runs | letzte `Validate template`- und `Release artifact`-Runs erfolgreich |
| Branch Protection `main` | Required Status Checks, ein Review, Conversation Resolution, keine Force Pushes, keine Branch-Löschung |
| Offene GitHub Issues | keine offenen Issues |

## Genutzte APIs und Tools

GitHub CLI und REST-API:

```text
gh repo view adrianweidig/pc-agent-installer
gh issue list --state open --limit 20
gh api repos/adrianweidig/pc-agent-installer/code-scanning/alerts
gh api repos/adrianweidig/pc-agent-installer/code-scanning/analyses
gh api repos/adrianweidig/pc-agent-installer/dependabot/alerts
gh api repos/adrianweidig/pc-agent-installer/secret-scanning/alerts
gh api repos/adrianweidig/pc-agent-installer/security-advisories
gh api repos/adrianweidig/pc-agent-installer/private-vulnerability-reporting
gh api repos/adrianweidig/pc-agent-installer/actions/workflows
gh api repos/adrianweidig/pc-agent-installer/actions/runs
gh api repos/adrianweidig/pc-agent-installer/branches/main/protection
```

Lokale Prüfungen:

```text
gitleaks detect --source . --redact --no-banner --exit-code 1
actionlint -no-color
shellcheck -x -P scripts/bash --format=gcc
rg
git status --short --branch
git diff --check
./scripts/common/verify-template.ps1
bash ./scripts/common/verify-template.sh
bash -n scripts/apply-codex-project-standard.sh
```

Temporär geladene Scanner:

| Tool | Version | Integritätsprüfung |
| --- | --- | --- |
| `actionlint` | 1.7.12 | Release-ZIP per SHA-256 geprüft |
| `gitleaks` | 8.30.1 | Release-ZIP per SHA-256 geprüft |
| `shellcheck` | 0.11.0 | Release-ZIP per SHA-256 geprüft |

Nicht eingesetzt:

- CodeQL CLI: kein passender primärer CodeQL-Sprachworkflow für die Hauptflächen PowerShell, Bash, YAML und Markdown ableitbar.
- Dependency-Audits wie `npm audit`, `pip-audit`, `cargo audit`, `go vulncheck`, Maven oder Gradle: keine passenden Paketmanager-Manifeste vorhanden.

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

Secret Scanning meldet keine Alerts.

`gitleaks detect --source . --redact --no-banner --exit-code 1` hat 11 Commits und den Arbeitsbaum geprüft. Ergebnis: keine Leaks gefunden.

Zusätzliche lokale Pattern-Suche auf typische Token-, Private-Key- und Credential-Muster ergab keine Secret-Werte. Treffer auf Begriffe wie `GITHUB_TOKEN`, `secret` oder `token` waren Dokumentation, Redaktionslogik oder GitHub-Actions-Kontext, keine Klartext-Secrets.

### GitHub Actions und CI

Die Workflows setzen minimale Berechtigungen:

```yaml
permissions:
  contents: read
```

Es gibt keine `pull_request_target`-, `workflow_run`- oder Deployment-Trigger. Workflows verwenden keine Repository-Secrets und keine produktiven Veröffentlichungen.

Der `Release artifact`-Workflow erzeugt nur Actions-Artefakte. Er erzeugt keine Tags, keine GitHub Releases, keine Package Releases und keine Docker Images.

`actionlint` meldet keine Workflow-Befunde.

### Lokale Kommando-Wrapper

Die Skripte `apply-step`, `rollback-step` und `validate-step` sind bewusst lokale Ausführungshilfen für operatorgesteuerte Befehle. `apply-step` und `rollback-step` erfordern eine explizite Freigabe. Diese Skripte sind keine GitHub-Actions-Entrypoints und werden nicht durch externe Pull-Request-Daten gespeist.

`shellcheck` meldete `SC2050` für konstante Freigabeprüfungen in den Bash-Step-Wrappern. Die Freigabelogik wurde in eine Variable `APPROVAL_REQUIRED` überführt. Das Laufzeitverhalten bleibt unverändert:

- `apply-step.sh`: Freigabe mit `--approved` erforderlich
- `rollback-step.sh`: Freigabe mit `--approved` erforderlich
- `validate-step.sh`: keine Freigabe erforderlich

Der Scaffold-Generator wurde konsistent angepasst, damit neu generierte Bash-Step-Wrapper denselben ShellCheck-sauberen Aufbau erhalten.

## Durchgeführte Änderungen

- `scripts/bash/apply-step.sh`: konstante ShellCheck-Bedingung durch variable Freigabeprüfung ersetzt.
- `scripts/bash/rollback-step.sh`: konstante ShellCheck-Bedingung durch variable Freigabeprüfung ersetzt.
- `scripts/bash/validate-step.sh`: konstante ShellCheck-Bedingung durch variable Freigabeprüfung ersetzt.
- `scripts/dev/scaffold-initial-repo.ps1`: generierte Bash-Step-Wrapper konsistent angepasst.
- `AGENTS.md`: Security-Remediation-Standard ergänzt, damit zukünftige Agentenläufe GitHub-Alerts, lokale Scanner, Secret-Handling und Dokumentation systematisch berücksichtigen.
- `docs/SECURITY_ALERT_ANALYSIS.md`: diese Analyse aktualisiert.

## GitHub-Alert-Status

Es wurden keine GitHub Alerts dismissed, reopened oder manuell als fixed markiert, weil keine offenen Alerts vorhanden waren.

Code Scanning Alerts konnten nicht aktualisiert werden, weil keine Code-Scanning-Analyse existiert.

## Verbleibende Risiken

- CodeQL/SARIF ist nicht aktiv. Für diese Projektsprachen ist kein sinnvoller CodeQL-Workflow ableitbar; externe Scanner wie `shellcheck`, `actionlint` und `gitleaks` wurden lokal erfolgreich genutzt.
- Die lokalen `*-step`-Wrapper führen bewusst operatorgesteuerte Befehle aus. Sie dürfen nur mit vertrauenswürdigen Eingaben verwendet werden.
- GitHub Actions sind über versionierte Tags referenziert, nicht über vollständige Commit-SHAs. Das ist üblich und durch Dependabot wartbar; SHA-Pinning wäre eine strengere Supply-Chain-Härtung.
- Secret Scanning Non-Provider Patterns und Secret Scanning Validity Checks sind in der GitHub-Konfiguration nicht aktiviert.

## Manuelle Folgeschritte

- Optional `actionlint`, `shellcheck` und `gitleaks` dauerhaft in CI einführen, wenn die Projektwartung zusätzliche externe Tools in der Pipeline akzeptiert.
- Optional Actions auf vollständige Commit-SHAs pinnen, wenn maximale Supply-Chain-Härtung wichtiger ist als Dependabot-gestützte Wartbarkeit.
- Optional Secret Scanning Non-Provider Patterns und Validity Checks aktivieren, falls die GitHub-Plan- und Organisationsfunktionen das hergeben.
- Falls Code Scanning gewünscht ist, zuerst einen passenden Scanner für PowerShell/Bash/YAML auswählen und SARIF-Upload bewusst konfigurieren.
