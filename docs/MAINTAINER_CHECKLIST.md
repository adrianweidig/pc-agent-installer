# Maintainer-Checkliste

Diese Liste enthält GitHub- und Maintainer-Schritte, die nicht zuverlässig aus dem Repository heraus erledigt werden können oder eine bewusste Maintainer-Entscheidung brauchen.

## GitHub-Metadaten

- Repository-Beschreibung kurz halten: `Template für dokumentierte, rollbackfähige Rechner-Einrichtung mit Codex`
- Topics prüfen, zum Beispiel: `codex`, `automation`, `powershell`, `bash`, `template`, `infrastructure`, `documentation`, `rollback`
- Website-URL nur setzen, wenn eine echte Dokumentationsseite oder GitHub Pages existiert.
- Social Preview aus `docs/assets/pc-agent-installer-hero.svg` oder einem daraus exportierten PNG hochladen.

## Repository-Einstellungen

- Issues aktiviert lassen.
- Wiki deaktivieren, wenn alle Dokumentation im Repository bleiben soll.
- Discussions nur aktivieren, wenn Maintainer aktive Community-Diskussionen betreuen möchten.
- Branch Protection oder Rulesets für `main` konfigurieren.
- Required Status Checks auf den Workflow `Validate template` setzen.
- Pull Requests mit mindestens einem Review verlangen, wenn mehrere Maintainer beteiligt sind.

## Security

- GitHub Secret Scanning aktivieren, sofern im Plan verfügbar.
- Dependabot Security Updates aktivieren.
- Private Vulnerability Reporting aktivieren oder einen privaten Sicherheitskontakt dokumentieren.
- Code Scanning nur ergänzen, wenn ein sinnvoller Analyzer für die Projektsprachen verfügbar ist.

## Releases

- Entscheiden, ob Tags wie `v0.1.0` verwendet werden.
- Vor einem Release `CHANGELOG.md` prüfen.
- Release Notes aus dem Changelog ableiten.
- Keine Release-Automation aktivieren, solange sie nicht ausdrücklich gewünscht ist.

## Dokumentation

- Prüfen, ob GitHub Pages für `docs/` sinnvoll ist.
- Bei neuen Screenshots oder Demos nur echte, nicht vertrauliche Inhalte verwenden.
- Regelmäßig prüfen, ob README-Links und Badges noch gültig sind.

## Offene Entscheidungen

- Formales Support-Modell für Releases.
- Privater Sicherheitsmeldeweg.
- Ob Discussions als Support- oder Ideenkanal genutzt werden sollen.
- Ob ein PNG-Social-Preview-Artefakt zusätzlich zum SVG gepflegt werden soll.
