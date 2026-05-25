# Mitwirken

🌐 Sprachen: [Deutsch](CONTRIBUTING.md) | [English](CONTRIBUTING.en.md)

Danke für dein Interesse an PC Agent Installer. Dieses Repository ist ein öffentliches Template; Beiträge müssen deshalb generisch, reproduzierbar und frei von Hostdaten bleiben.

## Beitragsarten

Willkommen sind insbesondere:

- Verbesserungen an Guard- und Validierungsskripten
- neue oder präzisere Agenten-Vorlagen
- Dokumentationsverbesserungen
- sichere Beispiele ohne echte Hostdaten
- reproduzierbare Fehlerberichte
- kleine Korrekturen an Schemas, CI und Repository-Hygiene

Nicht in dieses öffentliche Repository gehören echte Hostnamen, private Pfade, interne Infrastrukturdetails, lokale Testnotizen, Secrets, Tokens, produktive Kubeconfigs oder rohe Credential-Dumps.

## Vor der Änderung

1. Lies `AGENTS.md`.
2. Prüfe den aktuellen Arbeitsbaum:

   ```powershell
   git status --short --branch
   ```

3. Prüfe den Repo-Modus:

   ```powershell
   ./scripts/common/detect-repo-mode.ps1
   ```

4. Prüfe offene Issues, wenn GitHub erreichbar ist:

   ```powershell
   gh issue list --state open --limit 20
   ```

## Entwicklungsumgebung

Es gibt keinen Paketmanager und keine externen Projektabhängigkeiten. Für lokale Arbeit reichen:

- Git
- PowerShell
- Bash
- optional GitHub CLI `gh`

## Branches und Commits

- Halte Änderungen klein und fachlich zusammenhängend.
- Nutze klare Commitnachrichten, zum Beispiel `docs: verbessere onboarding` oder `test: haerte template-validierung`.
- Vermische keine Template-Änderungen mit privaten Operational-Daten.
- Führe keine destruktiven Git-Befehle aus, wenn nicht ausdrücklich vereinbart.

Maintainer oder Agents mit Schreibrechten dürfen geprüfte Template-Änderungen direkt auf `main` übernehmen, wenn die Projektregeln das erlauben. Externe Beitragende arbeiten über Fork oder Branch und Pull Request.

## Checks

Vor einem Pull Request sollten mindestens diese Checks laufen:

```powershell
./scripts/common/detect-repo-mode.ps1
./scripts/common/verify-template.ps1
git diff --check
```

Zusätzlich sinnvoll:

```bash
bash ./scripts/common/detect-repo-mode.sh
bash ./scripts/common/verify-template.sh
```

`assert-private-repo.*` darf im `template`-Modus fehlschlagen. Das ist eine Sicherheitsgrenze und kein Template-Fehler.

## Vorlagen und Stil

- Neue Vorlagen brauchen gültiges YAML-Frontmatter.
- Numerische Positionen in `Vorlage/` müssen eindeutig bleiben.
- Dokumentation ist deutsch, knapp und technisch eindeutig.
- Deutsche Fließtexte verwenden echte UTF-8-Umlaute.
- Pfade in Markdown werden relativ angegeben, wenn sie auf Repository-Dateien zeigen.
- PowerShell-Skripte müssen ohne expliziten `-RepoRoot` aus dem Repository heraus laufen.
- Guard-Skripte bleiben nicht destruktiv und idempotent.

## Pull Requests

Ein guter Pull Request enthält:

- kurze Zusammenfassung
- betroffene Dateien oder Bereiche
- Public/Private-Einordnung
- ausgeführte Checks
- offene Risiken oder bewusste Grenzen
- Link auf relevante Issues, falls vorhanden

Nutze die Vorlage in `.github/PULL_REQUEST_TEMPLATE.md`. Die Vorlage ist bewusst zweisprachig, weil GitHub Pull-Request-Templates nicht automatisch nach Nutzersprache umschaltet.

## Issues

Ein guter Fehlerbericht enthält:

- Ist-Zustand und erwartetes Verhalten
- Reproduktionsschritte oder konkrete Fundstelle
- betroffene Dateien oder Vorlagen
- Risiko und Auswirkung
- bereits ausgeführte Checks

Für Sicherheitsprobleme bitte kein öffentliches Issue mit vertraulichen Details erstellen. Folge stattdessen `SECURITY.md`.

## Kommunikation

Bleib respektvoll, konkret und lösungsorientiert. Unterschiedliche Arbeitsweisen sind in Ordnung; entscheidend ist, dass Änderungen nachvollziehbar, prüfbar und sicher für ein öffentliches Template bleiben.
