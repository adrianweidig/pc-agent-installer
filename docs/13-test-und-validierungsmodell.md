# Test- und Validierungsmodell

Dieses Repository ist ein skriptbasiertes Template ohne Paketmanager, Build-Artefakte oder klassische Unit-Test-Suite. Die Testbarkeit besteht aus Guard-, Struktur-, Syntax-, i18n-, Encoding-, Secret- und Git-Hygieneprüfungen.

## Standardprüfung

PowerShell:

```powershell
./scripts/common/verify-template.ps1
```

Bash:

```bash
bash ./scripts/common/verify-template.sh
```

Diese Befehle sind die bevorzugten Einstiegspunkte für lokale Codex-Läufe und CI. Sie bündeln die wichtigsten schnellen Prüfungen.

Für neue Agenten-Läufe gilt: Erst `AGENTS.md` lesen, dann Repo-Modus und Git-Status prüfen, danach `verify-template.*` ausführen. So bleibt der Klon als Codex-Projektbasis wiederholbar testbar.

## Einzelprüfungen

Repo-Modus erkennen:

```powershell
./scripts/common/detect-repo-mode.ps1
```

```bash
bash ./scripts/common/detect-repo-mode.sh
```

Template-Struktur validieren:

```powershell
./scripts/common/validate-template.ps1
```

```bash
bash ./scripts/common/validate-template.sh
```

Produktkomponenten-i18n validieren:

```powershell
./scripts/common/validate-product-i18n.ps1
```

```bash
bash ./scripts/common/validate-product-i18n.sh
```

Whitespace im Git-Diff prüfen:

```powershell
git diff --check
```

Offene Issues prüfen:

```powershell
gh issue list --state open --limit 20
```

## Geprüfte Bereiche

- Pflichtdateien und zentrale Skripte
- leerer `hosts/`-Ordner im `template`-Modus
- Anzahl und Frontmatter-Pflichtfelder der Vorlagen
- beschädigte Steuerzeichen in Template-Feldern
- Produktkomponenten-Katalog mit mindestens zehn Sprachen
- vollständige Produktnamen und Kurzbeschreibungen je Sprache
- PowerShell-Syntax und PowerShell-Encoding
- Bash-Syntax
- typische Secret-Pattern
- Git-Diff-Whitespace

## CI

`.github/workflows/validate.yml` führt die Standardprüfung auf Windows und Ubuntu aus. Dadurch werden sowohl PowerShell- als auch Bash-Pfade geprüft.

## Grenzen

Die Verify-Skripte führen keine systemwirksamen Host-Aktionen aus und erzeugen keine Host-Baselines. Solche Tests gehören in ein privates `operational`-Repository oder einen `local-only`-Klon.

## Host-Änderungsbereitschaft

Vor systemwirksamer Arbeit in einem privaten oder lokalen Operational-Repository müssen zusätzlich die Laufzeit-Guards erfolgreich sein:

```powershell
./scripts/common/assert-first-run-config.ps1
./scripts/common/assert-infrastructure-snapshot.ps1
```

```bash
bash ./scripts/common/assert-first-run-config.sh
bash ./scripts/common/assert-infrastructure-snapshot.sh
```

Diese Checks ersetzen keine Validierung nach der Änderung. Sie verhindern nur, dass der Agent ohne aktuelle Infrastrukturprüfung, Baseline und Soll-Ist-Abgleich in den Vollzug geht.
