# Codex-Arbeitsmodell

Dieses Repository ist das öffentliche Template für generische Codex- und Agenten-Arbeit. Es darf offizielle, wiederverwendbare Änderungen an Vorlagen, Skripten, Schemas und Dokumentation enthalten.

`pc-agent-installer` ist die zentrale Codex-Ausgangsstelle. Codex beginnt hier mit Orientierung, Regelprüfung und der Entscheidung, ob eine Aufgabe das öffentliche Template, ein privates Operational-Repository oder beide Arbeitsbereiche betrifft.

## Agenten-first-Nutzung

Das Repository soll beim ersten Kontakt klar als Basis für ein eigenes Codex- oder Agenten-Projekt wirken. Der Nutzer klont das Template nicht, um alle Schritte manuell abzuarbeiten, sondern um einen lokalen Agenten in einer vorbereiteten, geprüften Struktur arbeiten zu lassen.

Der erwartete Einstieg ist eine natürliche Agentenaufforderung, zum Beispiel:

```text
Codex, lies dieses Repository und starte die Agenten-Konfiguration für meinen PC.
Codex, in diesem Verzeichnis: starte die Erstkonfiguration.
Codex, öffne die Agenten-Konfiguration erneut und deaktiviere WSL- oder Docker-Empfehlungen.
```

Der Agent darf daraus direkt den passenden Ablauf ableiten. Die Skripte sind dabei entdeckbare Werkzeuge, nicht die Benutzeroberfläche des Projekts.

Der erwartete Ablauf ist:

1. Template klonen oder daraus ein eigenes Repository erstellen.
2. Codex im geklonten Repository starten.
3. `AGENTS.md` als verbindliche Projektanweisung lesen.
4. Repo-Modus, Sichtbarkeit, offene Issues und Git-Status prüfen.
5. Aufgabe in Public-Template-Anteil und private Operational-Anteile trennen.
6. Wenn eine PC-Konfiguration gewünscht ist, eine sichere private Operational-Kopie oder einen `local-only`-Klon nutzen, bevor Hostdaten entstehen.
7. Die Agenten-Konfiguration starten oder erneut öffnen und vorhandene Präferenzen als Vorbelegung behandeln.
8. Änderungen klein ausführen, prüfen, dokumentieren und nur den passenden Anteil committen oder pushen.

Die öffentliche Dokumentation muss diesen Ablauf erhalten. Neue Hinweise, Vorlagen und Tests sollen deshalb immer erklären, wie ein Agent sie wiederholbar nutzt.

## Agenten-Konfiguration statt Skriptmodus

Dieses Repository soll nicht als Sammlung manuell abzuarbeitender Skripte wirken. Ein Agent muss die Markdown-Regeln lesen und entscheiden, welche Werkzeuge für den nächsten Schritt notwendig sind.

Der Werkzeugpfad ist bewusst klein:

- `detect-repo-mode.*` erkennt Modus, Sichtbarkeit und Schreibgrenzen.
- `assert-private-repo.*` schützt Hostdaten vor öffentlichen oder ungeprüften Repositories.
- `first-run-config.*` startet oder aktualisiert die Agenten-Konfiguration.
- `assert-first-run-config.*` und `assert-infrastructure-snapshot.*` sind harte Gates vor Host-Arbeit.
- `verify-template.*` prüft das öffentliche Template nach Änderungen.

Alle weiteren Skripte sind Hilfen für konkrete, vom Agenten begründete Schritte. Sie dürfen nicht als blinde Kette gestartet werden.

## Folgekonfiguration und Schalter

Die Agenten-Konfiguration kann jederzeit erneut geöffnet werden. Vorhandene Werte aus `hosts/<HOSTNAME>/state/first-run-config.yaml` dienen als Defaults.

Aktivierte Optionen erlauben Empfehlungen und spätere freigegebene Arbeiten in diesem Bereich. Deaktivierte Optionen sperren künftige Empfehlungen oder Vorbereitungen. Wenn eine deaktivierte Option bereits zu einer tatsächlichen Systemänderung geführt hat, muss der Agent zuerst Change-Einträge, Rollback-Dateien, Baseline und Soll-Ist-Abgleich prüfen. Ein Rückbau wird nur nach konkreter Risiko- und Nutzdatenprüfung vorgeschlagen oder ausgeführt.

Persistentes Agenten-Memory darf die natürliche Startphrase mit diesem Repository verknüpfen. Es ersetzt aber niemals die aktuelle Repo-Modus-, Sichtbarkeits- und Git-Status-Prüfung.

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
