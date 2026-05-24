# Codex New Project Standard

## Zweck

Codex soll neue Projekte standardmäßig so vorbereiten, dass sie verständlich, wartbar, prüfbar und später bei Bedarf öffentlich nutzbar sind. Dieser Standard ergänzt die globale Codex-Anweisung unter `C:\Users\adria\.codex\AGENTS.md` und beschreibt, wie öffentliche Template-Repositories und private Operational-Repositories damit umgehen.

## Geltungsbereich

Der Standard gilt, wenn Codex ein neues Projekt, Repository, Tool, Paket, Service, eine App oder eine neue Codebasis anlegt oder grundlegend initialisiert.

Für das öffentliche `pc-agent-installer`-Template bedeutet das:

- Regeln, Skripte und Beispiele bleiben generisch.
- Keine Hostdaten, Secrets oder privaten Pfade werden dokumentiert.
- Neue Projektstandards werden als wiederverwendbare Vorlage gepflegt.

Für private `operational`-Repositories bedeutet das:

- Hostdaten dürfen nur nach Modus- und Sichtbarkeitsprüfung geschrieben werden.
- Klartext-Secrets bleiben verboten.
- Der Standard darf private Arbeitsfähigkeit verbessern, aber keine öffentlichen Fakten oder Releases vortäuschen.

## Typische Dateien

Codex prüft bei neuen Projekten automatisch, welche dieser Dateien sinnvoll sind:

- `README.md`
- `LICENSE` oder ein Lizenzhinweis in `docs/MAINTAINER_CHECKLIST.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `SUPPORT.md`
- `CHANGELOG.md`
- `AGENTS.md`
- `.gitignore`
- `.gitattributes`
- `.editorconfig`
- `docs/`
- `docs/assets/`
- `docs/MAINTAINER_CHECKLIST.md`
- `docs/CI_CD.md`
- `docs/RELEASE_PROCESS.md`
- `.github/workflows/ci.yml`
- `.github/workflows/release-artifact.yml`
- `.github/workflows/docker-ghcr.yml`, wenn Docker vorhanden ist
- `.github/dependabot.yml`, wenn Abhängigkeiten erkennbar sind
- `.github/ISSUE_TEMPLATE/`
- `.github/PULL_REQUEST_TEMPLATE.md`

Codex erstellt nur Dateien, die zum konkreten Projekt passen. Kleine Projekte bleiben schlank, erhalten aber keine falschen oder leeren Versprechen.

## README-Standard

Neue Projekte sollen eine professionelle README erhalten, soweit die Informationen belegbar sind:

- Projektname und kurze Beschreibung
- klarer Hero-Bereich mit lokaler Grafik, wenn sinnvoll
- korrekte Badges
- Quick Links
- Features
- Quick Start
- Installation
- Nutzung
- Konfiguration
- Beispiele
- Projektstruktur
- Entwicklung
- Tests und Build
- Docker-Nutzung, wenn vorhanden
- CI/CD- und Release-Artefakt-Hinweise
- Contribution-, Security- und Support-Hinweise
- Lizenzhinweis, wenn eindeutig vorhanden

Codex erfindet keine Features, Benchmarks, Paketveröffentlichungen, Roadmaps, Sicherheitsgarantien, Sponsoren oder Kontakte.

## GitHub Actions

### CI

Ein CI-Workflow darf nur Befehle ausführen, die wirklich vorhanden oder sicher ableitbar sind. Codex prüft dafür Projektdateien wie `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Makefile`, `Dockerfile` oder vorhandene Skripte.

Wenn kein echter Test- oder Build-Befehl existiert, ist ein Repository-Health-Check besser als ein erfundener Test.

### Release-Artefakte

Der Standard sieht ein nicht-publizierendes Release-Artefakt vor:

- Trigger bei Push auf `main` oder `master`
- manueller Start per `workflow_dispatch`
- ZIP aus dem aktuellen Commit via `git archive`, wenn möglich
- klare Root-Directory innerhalb der ZIP
- Release Notes als Datei
- Upload von ZIP und Notes als Actions-Artefakte

Der Workflow erstellt keine Tags und keine echten GitHub Releases. Das bleibt eine bewusste Maintainer-Entscheidung.

### Docker und GHCR

Ein GHCR-Workflow wird nur eingerichtet, wenn das Projekt bereits eine Docker-Grundlage hat, zum Beispiel `Dockerfile`, Compose-Dateien, `.dockerignore` oder dokumentierte Docker-Build-Befehle.

Ohne Docker-Grundlage wird kein Docker-/GHCR-Workflow erstellt.

## Dependabot

Dependabot wird nur für tatsächlich vorhandene Ökosysteme eingerichtet. GitHub Actions sind sinnvoll, sobald Workflows vorhanden sind. Weitere Ökosysteme wie npm, pip, Go Modules, Cargo, Maven, Gradle oder Docker werden nur ergänzt, wenn entsprechende Projektdateien existieren.

## Security und Kollaboration

Neue Projekte sollen, wenn sinnvoll, diese Dateien erhalten:

- `SECURITY.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SUPPORT.md`
- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/feature_request.yml`
- `.github/ISSUE_TEMPLATE/documentation.yml`
- `.github/ISSUE_TEMPLATE/config.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`

Wenn kein privater Sicherheitskontakt bekannt ist, wird keine Kontaktadresse erfunden. Die offene Entscheidung wird in `docs/MAINTAINER_CHECKLIST.md` dokumentiert.

## Manuelle Maintainer-Entscheidungen

Codex trifft diese Entscheidungen nicht automatisch:

- Lizenzwahl, wenn keine Lizenz eindeutig bekannt ist
- echte GitHub Releases oder Tag-Strategie
- GHCR-Veröffentlichung ohne Docker-Grundlage
- Branch Protection und Required Checks
- Security Contact oder Private Vulnerability Reporting
- Social Preview Upload
- Package-Registry-Veröffentlichung
- personenbezogene Maintainer-Kontakte

## Bootstrap-Skript

`scripts/apply-codex-project-standard.sh` bereitet neue Projekte vorsichtig vor:

- legt Standardordner an
- erstellt fehlende Basisdateien
- überschreibt keine vorhandenen Dateien
- erzeugt keine Secrets
- committet nicht
- pusht nicht
- veröffentlicht keine Releases oder Container Images

Verwendung aus einem neuen Projekt:

```bash
bash scripts/apply-codex-project-standard.sh
```

Oder aus diesem Repository heraus mit Zielpfad:

```bash
bash scripts/apply-codex-project-standard.sh /pfad/zum/projekt
```

## Pflege der globalen Anweisung

Die globale Codex-Anweisung liegt auf diesem Rechner unter:

```text
C:\Users\adria\.codex\AGENTS.md
```

Wenn sich dieser Standard ändert, sollen öffentliche Template-Dokumentation, private Operational-Dokumentation und die globale Codex-Anweisung inhaltlich konsistent gehalten werden. Projekt- oder hostbezogene Details bleiben dabei im privaten Operational-Repository.
