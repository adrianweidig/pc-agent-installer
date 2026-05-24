# Changelog

## Unreleased

- Automatischen GitHub-Release-Workflow nach erfolgreicher `main`-Validierung ergänzt, inklusive ZIP-Asset und vollständiger `release-notes.md` mit Commit-Historie.
- GitHub-Security-Alerts analysiert und sicherheitsrelevante `Invoke-Expression`-Nutzung in der Docker-Baseline-Erfassung entfernt.
- Globalen Codex-New-Project-Standard als wiederverwendbare Dokumentation und Bootstrap-Skript ins Template übernommen.
- Release-Automatisierung für ZIP und Release Notes ergänzt.
- README mit Hero-Grafik, korrekten GitHub-Badges, Quick-Links und klarerer Dokumentationsnavigation überarbeitet.
- Strukturierte GitHub-Issue-Templates, Pull-Request-Vorlage und Dependabot-Konfiguration für GitHub Actions ergänzt.
- `SUPPORT.md`, `CODE_OF_CONDUCT.md`, Architekturübersicht, Release-Prozess und Maintainer-Checkliste ergänzt.
- Security- und Contribution-Dokumentation für öffentliche Mitarbeit und sensible Meldewege präzisiert.
- README als zentrale Einstiegsdokumentation erweitert.
- AGENTS.md um projektspezifische Codex-Regeln und dauerhafte Hygienevorgaben ergänzt.
- Öffentliches Template und private Operational-Arbeit als dauerhaftes Codex-Arbeitsmodell dokumentiert.
- `pc-agent-installer` als zentrale Codex-Ausgangsstelle mit Pflicht zur Public/Private-Einordnung jeder Aufgabe festgelegt.
- Issue-, Pull-Request- und Direkt-Push-Regeln für Agents mit und ohne Schreibrechte ergänzt.
- Standardisierte `verify-template`-Prüfung und GitHub-Actions-Workflow ergänzt.
- Agenten-first-Nutzungsmodell in README, AGENTS.md und Codex-Dokumentation deutlicher gemacht.
- Bash-Template-Validator gegen `pipefail`-Fehlalarme bei Frontmatter-Prüfungen gehärtet.
- PowerShell-Entrypoints robuster gemacht, damit sie ohne expliziten `-RepoRoot` laufen.
- Beschädigte `rollback_required`-Zeile in den Template-Dateien korrigiert.
- Repository-Hygiene für lokale Logs und Caches ergänzt.

## 0.1.0 - 2026-05-24

- Initiales Template-Grundgerüst angelegt.
- Repo-Modi `template`, `operational` und `local-only` modelliert.
- Guard-Skripte für PowerShell und Bash ergänzt.
- Plattform-, Host-, Baseline- und Container-Erkennung als erste sichere Version ergänzt.
- Vorlagenstruktur für Windows, Linux, WSL, Container und Profile angelegt.
