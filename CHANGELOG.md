# Changelog

## Unreleased

- README als zentrale Einstiegsdokumentation erweitert.
- AGENTS.md um projektspezifische Codex-Regeln und dauerhafte Hygienevorgaben ergänzt.
- Öffentliches Template und private Operational-Arbeit als dauerhaftes Codex-Arbeitsmodell dokumentiert.
- `pc-agent-installer` als zentrale Codex-Ausgangsstelle mit Pflicht zur Public/Private-Einordnung jeder Aufgabe festgelegt.
- Issue-, Pull-Request- und Direkt-Push-Regeln für Agents mit und ohne Schreibrechte ergänzt.
- Standardisierte `verify-template`-Prüfung und GitHub-Actions-Workflow ergänzt.
- PowerShell-Entrypoints robuster gemacht, damit sie ohne expliziten `-RepoRoot` laufen.
- Beschädigte `rollback_required`-Zeile in den Template-Dateien korrigiert.
- Repository-Hygiene für lokale Logs und Caches ergänzt.

## 0.1.0 - 2026-05-24

- Initiales Template-Grundgerüst angelegt.
- Repo-Modi `template`, `operational` und `local-only` modelliert.
- Guard-Skripte für PowerShell und Bash ergänzt.
- Plattform-, Host-, Baseline- und Container-Erkennung als erste sichere Version ergänzt.
- Vorlagenstruktur für Windows, Linux, WSL, Container und Profile angelegt.
