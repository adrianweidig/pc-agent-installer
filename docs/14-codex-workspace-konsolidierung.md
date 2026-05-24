# Codex-Workspace-Konsolidierung

Eine Codex-Umgebung soll genau einen kanonischen lokalen Arbeitsbereich haben. Der konkrete Pfad ist hostabhängig und wird als `<CODEX_WORKSPACE_ROOT>` dokumentiert, nicht als fest verdrahtetes Laufwerk.

Empfohlene Zielstruktur:

```text
<CODEX_WORKSPACE_ROOT>/
├── repos
├── projects
├── configs
└── migration
```

- `repos/` enthält aktive Git-Repositories.
- `projects/` enthält aktive, nicht sinnvoll versionierbare Projektstände.
- `configs/` enthält notwendige, nicht systemgebundene Agenten- oder Tool-Konfigurationen.
- `migration/` enthält nur kleine Inventar- und Abschlussberichte.

## Grundsätze

- Pro Projekt bleibt lokal genau ein aktueller, geprüfter Arbeitsstand erhalten.
- Versionierbare Projekte werden vor dem Löschen alter Kopien committed und, wenn ein Remote vorhanden ist, gepusht.
- Neue Remotes für Operational-Daten müssen privat sein; das öffentliche Template bleibt frei von Hostdaten.
- Lokale Backups, Archive, Scratch-Ordner und doppelte Projektkopien sind kein Dauerzustand.
- Temporäre Kopien sind nur technische Zwischenschritte und werden nach erfolgreicher Validierung gelöscht.
- Codex- und Tool-Konfigurationen zeigen nach einer Migration auf `<CODEX_WORKSPACE_ROOT>`, nicht auf alte Quellpfade.
- Hostnamen, konkrete lokale Pfade, Secret-Referenzen und Infrastrukturdetails gehören nur in ein geprüft privates Operational-Repository oder einen `local-only`-Klon.

## Löschfreigabe

Alte Projektstände dürfen erst entfernt werden, wenn alle Punkte erfüllt sind:

1. Der Zielordner unter `<CODEX_WORKSPACE_ROOT>` existiert und ist vollständig.
2. `git status --short --branch` ist sauber oder die Abweichung ist dokumentiert.
3. Der Remote- und Push-Status ist geprüft oder eine begründete Ausnahme ist dokumentiert.
4. Sensible und generierte Dateien sind nicht versehentlich versioniert.
5. Aktive Codex-, IDE-, Shell- und Tool-Konfigurationen referenzieren nicht mehr den alten Pfad.
6. Es gibt keine laufenden Prozesse oder Handles, die den alten Pfad produktiv nutzen.

## Abschlussbericht

Jede größere Konsolidierung erzeugt genau einen kompakten Bericht unter `<CODEX_WORKSPACE_ROOT>/migration/`. Der Bericht enthält Inventar, Entscheidungen, GitHub-Status, aktualisierte Pfade, sensible Ausschlüsse, gelöschte Altstände, Validierungsergebnisse und offene manuelle Entscheidungen.
