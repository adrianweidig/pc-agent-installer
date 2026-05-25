# Product Components i18n

## Principle

The detailed templates under `Vorlage/` remain the canonical technical source. Product-facing names and summaries are localized centrally so agents, documentation, onboarding, and later interfaces use the same terms.

## Language Set

The base language set lives in `i18n/languages.tsv` and contains twelve directly integrated product languages:

| Code | Language |
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

German remains the canonical default language. English is the primary alternative language. The additional languages cover common software and product localization needs and can be extended without changing host or safety logic.

## Product Component Catalog

The catalog lives in `i18n/product-components.tsv`. Each product component needs, for every language:

- `name`: visible product or module name
- `summary`: short description of purpose and safety boundary

Currently covered components:

- agent workspace
- repository mode guard
- visibility guard
- first-run configuration
- infrastructure snapshot
- target/current-state comparison
- template library
- application recommendations
- security decisions
- baseline collection
- change documentation
- rollback path
- validation suite
- template upstream sync
- private operational repository
- WSL and container support
- documentation portal

## Agent Usage

Agents should not freely translate product-facing names. They should query the catalog:

```powershell
./scripts/common/list-product-components.ps1 -Language es
```

```bash
bash ./scripts/common/list-product-components.sh es
```

Unsupported or empty language codes fall back to German. `zh`, `zh-cn`, and `zh-hans` resolve to `zh-Hans`.

## Validation

Product i18n is checked on both platform paths:

```powershell
./scripts/common/validate-product-i18n.ps1
./scripts/common/verify-template.ps1
```

```bash
bash ./scripts/common/validate-product-i18n.sh
bash ./scripts/common/verify-template.sh
```

Validation enforces:

- at least ten product languages
- all required languages
- complete `name` and `summary` entries per component
- no empty translations
- consistent TSV structure

## Extension Rule

New product components are added first as stable technical IDs. Then `name` and `summary` must be filled for all languages and validation must pass. New language codes are added to `i18n/languages.tsv` first and then completed in the component catalog.
