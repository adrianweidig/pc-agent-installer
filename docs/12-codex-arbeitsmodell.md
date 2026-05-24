# Codex-Arbeitsmodell

Dieses Repository ist das öffentliche Template für generische Codex- und Agenten-Arbeit. Es darf offizielle, wiederverwendbare Änderungen an Vorlagen, Skripten, Schemas und Dokumentation enthalten.

## Zwei Arbeitsbereiche

- Public Template: generische Inhalte, keine Hostdaten, keine privaten Pfade, keine lokalen Testzustände.
- Private Operational Repo oder Local-only-Klon: echte Hostdaten, Baselines, Rollbacks, Secret-Referenzen und lokale Tests.

Codex darf beide Arbeitsbereiche in einem lokalen Lauf berücksichtigen. Änderungen am öffentlichen Template müssen generisch, reproduzierbar und frei von Hostdaten sein. Änderungen an echten Rechnern oder lokalen Tests gehören in die private `hosts/`-Struktur eines sicheren Operational-Workspaces.

## Übernahme ins öffentliche Repository

Automatisch übernehmbar sind nur Änderungen, die für das Template selbst relevant sind:

- Fehlerkorrekturen in Guard-Skripten
- neue oder verbesserte Vorlagen
- Schema- und Validierungsverbesserungen
- Sicherheits-, Lizenz- und Dokumentationsregeln
- generische Beispiele ohne echte Hostdaten

Nicht übernehmbar sind lokale Codex-Aufgaben, private Testnotizen, maschinenspezifische Pfade, echte Hostnamen, interne Infrastrukturdetails und Secret-Werte.

## Prüfpflicht

Vor einem Push in das öffentliche Template müssen mindestens diese Bedingungen erfüllt sein:

- `repo-mode.yaml` bleibt im Modus `template`.
- `hosts/` enthält nur `.gitkeep`.
- Template-Validierung ist erfolgreich.
- Secret-Scan findet keine sensiblen Werte.
- Git-Diff ist geprüft.
