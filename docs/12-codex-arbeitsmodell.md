# Codex-Arbeitsmodell

Dieses Repository ist das öffentliche Template für generische Codex- und Agenten-Arbeit. Es darf offizielle, wiederverwendbare Änderungen an Vorlagen, Skripten, Schemas und Dokumentation enthalten.

`pc-agent-installer` ist die zentrale Codex-Ausgangsstelle. Codex beginnt hier mit Orientierung, Regelprüfung und der Entscheidung, ob eine Aufgabe das öffentliche Template, ein privates Operational-Repository oder beide Arbeitsbereiche betrifft.

## Zwei Arbeitsbereiche

- Public Template: generische Inhalte, keine Hostdaten, keine privaten Pfade, keine lokalen Testzustände.
- Private Operational Repo oder Local-only-Klon: echte Hostdaten, Baselines, Rollbacks, Secret-Referenzen und lokale Tests.

Codex darf beide Arbeitsbereiche in einem lokalen Lauf berücksichtigen. Änderungen am öffentlichen Template müssen generisch, reproduzierbar und frei von Hostdaten sein. Änderungen an echten Rechnern oder lokalen Tests gehören in die private `hosts/`-Struktur eines sicheren Operational-Workspaces.

Vor jeder Aufgabe ist die Trennung bewusst zu prüfen:

- Generische Verbesserungen an Vorlagen, Skripten, Schemas und Dokumentation gehören ins öffentliche Template.
- Host-, Test-, Infrastruktur- und Betriebszustände gehören in ein privates Operational-Repository oder einen `local-only`-Klon.
- Wenn beides relevant ist, wird im öffentlichen Repository nur der wiederverwendbare generische Anteil geändert; private Nachweise und Hostzustände bleiben privat.

## Übernahme ins öffentliche Repository

Automatisch übernehmbar sind nur Änderungen, die für das Template selbst relevant sind:

- Fehlerkorrekturen in Guard-Skripten
- neue oder verbesserte Vorlagen
- Schema- und Validierungsverbesserungen
- Sicherheits-, Lizenz- und Dokumentationsregeln
- generische Beispiele ohne echte Hostdaten

Nicht übernehmbar sind lokale Codex-Aufgaben, private Testnotizen, maschinenspezifische Pfade, echte Hostnamen, interne Infrastrukturdetails und Secret-Werte.

## Issues, Commits und Pull Requests

Jeder Agent prüft vor der Arbeit offene Issues, sofern GitHub erreichbar ist. Echte Fehler im öffentlichen Template werden als detaillierte Issues dokumentiert. Ein gutes Issue enthält:

- Ist-Zustand und erwartetes Verhalten
- Reproduktionsschritte oder konkrete Fundstelle
- betroffene Dateien oder Vorlagen
- Risiko und Auswirkung
- Korrekturvorschlag
- bereits ausgeführte Checks

Wenn ein Agent Schreibrechte auf das öffentliche Repository hat, darf er kleine geprüfte Template-Änderungen direkt auf `main` committen und pushen. Wenn keine Schreibrechte vorhanden sind oder ein Push scheitert, wird nicht still abgebrochen: Der Agent legt ein Issue an, dokumentiert den Korrekturvorschlag und erstellt einen Pull Request über Fork oder Branch, soweit das mit den vorhandenen Rechten möglich ist.

Änderungen werden in kleine zusammenhängende Commits aufgeteilt. Ein Agent soll lieber mehrere nachvollziehbare Commits erzeugen als viele unabhängige Änderungen in einem großen Sammelcommit zu bündeln.

## Prüfpflicht

Vor einem Push in das öffentliche Template müssen mindestens diese Bedingungen erfüllt sein:

- `repo-mode.yaml` bleibt im Modus `template`.
- `hosts/` enthält nur `.gitkeep`.
- `verify-template.*` ist erfolgreich.
- Secret-Scan findet keine sensiblen Werte.
- Git-Diff ist geprüft.
