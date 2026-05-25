# Produktkomponenten-i18n

## Grundsatz

Die ausführlichen Vorlagen unter `Vorlage/` bleiben die kanonische technische Quelle. Produktnahe Bezeichnungen und Kurzbeschreibungen werden dagegen zentral lokalisiert, damit Agenten, Dokumentation, Onboarding und spätere Oberflächen dieselben Begriffe verwenden.

## Sprachset

Das Basis-Sprachset liegt in `i18n/languages.tsv` und enthält zwölf direkt integrierte Produktsprachen:

| Code | Sprache |
| --- | --- |
| `de` | Deutsch |
| `en` | English |
| `es` | Español |
| `fr` | Français |
| `it` | Italiano |
| `pt` | Português |
| `nl` | Nederlands |
| `pl` | Polski |
| `tr` | Türkçe |
| `ru` | Русский |
| `zh-Hans` | 简体中文 |
| `ja` | 日本語 |

Deutsch bleibt die kanonische Standardsprache. Englisch ist die primäre Alternativsprache. Die weiteren Sprachen decken gängige Software- und Produktlokalisierungen ab und können ohne Änderung der Host- oder Sicherheitslogik erweitert werden.

## Produktkomponenten-Katalog

Der Katalog liegt in `i18n/product-components.tsv`. Jede Produktkomponente braucht für jede Sprache:

- `name`: sichtbarer Produktname oder Modulname
- `summary`: kurze Beschreibung des Nutzens und der Sicherheitsgrenze

Aktuell abgedeckte Komponenten:

- Agenten-Arbeitsbereich
- Repo-Modus-Guard
- Sichtbarkeits-Guard
- Erststart-Konfiguration
- Infrastruktur-Snapshot
- Soll-Ist-Abgleich
- Vorlagenbibliothek
- Programmempfehlungen
- Sicherheitsentscheidungen
- Baseline-Erfassung
- Änderungsdokumentation
- Rollback-Pfad
- Validierungssuite
- Template-Upstream-Sync
- Privates Operational-Repository
- WSL- und Container-Unterstützung
- Dokumentationsportal

## Agentische Nutzung

Agenten sollen produktnahe Namen nicht frei übersetzen, sondern den Katalog abfragen:

```powershell
./scripts/common/list-product-components.ps1 -Language es
```

```bash
bash ./scripts/common/list-product-components.sh es
```

Nicht unterstützte oder leer übergebene Sprachcodes fallen auf Deutsch zurück. Für `zh`, `zh-cn` und `zh-hans` wird `zh-Hans` verwendet.

## Validierung

Die Produkt-i18n wird über beide Plattformpfade geprüft:

```powershell
./scripts/common/validate-product-i18n.ps1
./scripts/common/verify-template.ps1
```

```bash
bash ./scripts/common/validate-product-i18n.sh
bash ./scripts/common/verify-template.sh
```

Die Prüfung erzwingt:

- mindestens zehn Produktsprachen
- alle definierten Pflichtsprachen
- vollständige `name`- und `summary`-Einträge pro Komponente
- keine leeren Übersetzungen
- konsistente TSV-Struktur

## Erweiterungsregel

Neue Produktkomponenten werden zuerst als stabile technische ID ergänzt. Danach müssen `name` und `summary` für alle Sprachen eingetragen und die Validierungen ausgeführt werden. Neue Sprachcodes werden zuerst in `i18n/languages.tsv` ergänzt und anschließend vollständig im Komponenten-Katalog nachgezogen.
