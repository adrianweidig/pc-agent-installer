# AGENTS.md

## Rolle

Du bist ein lokaler Agent zur dokumentierten, reproduzierbaren und rollbackfähigen Einrichtung dieses Rechners. Dieses Repository ist als geklonte Codex-Arbeitsbasis gedacht: Der Nutzer gibt Ziele vor, aber der Agent liest die Regeln, entscheidet den passenden Arbeitsbereich und führt die eigentliche Prüfung, Änderung und Validierung aus. In diesem Repository arbeitest du standardmäßig am generischen Template, nicht an echten Hostdaten.

## Projektüberblick

- `repo-mode.yaml` steuert den Sicherheitsmodus.
- `Vorlage/` enthält numerisch sortierte Agenten-Vorlagen für Windows, Linux, WSL, macOS, Container und Profile.
- `scripts/common/` enthält Repo-Guards und Template-Validierung.
- `scripts/common/i18n.*` enthält die gemeinsame Sprachwahl für Deutsch als Standard und Englisch als Alternativsprache.
- `i18n/` enthält die zentrale Produktkomponenten-Lokalisierung für mehrsprachige Modulnamen und Kurzbeschreibungen.
- `scripts/powershell/` und `scripts/bash/` enthalten Host-, Baseline- und Change-Hilfen.
- `scripts/container/` enthält Container-Erkennung.
- `schemas/` enthält YAML-Schemas.
- `docs/`, `examples/` und `private.example/` enthalten generische Dokumentation und sichere Beispiele.
- `hosts/` bleibt im `template`-Modus leer und enthält nur `.gitkeep`.

## Arbeitsmodell

Dieses Projekt trennt dauerhaft zwei Arbeitsbereiche:

- `pc-agent-installer` ist die zentrale Codex-Ausgangsstelle. Beginne hier mit Orientierung, Regelprüfung und der Entscheidung, welcher Arbeitsbereich betroffen ist.
- Der normale Nutzerfluss ist: Template klonen, Codex im Klon starten, `AGENTS.md` lesen, Repo-Modus prüfen, dann den Agenten strukturiert arbeiten lassen.
- Offizielle Template- und Codeänderungen werden im öffentlichen Template-Repository gepflegt und dürfen automatisch dorthin übernommen werden, wenn Checks erfolgreich sind.
- Rechner-, Host-, Infrastruktur- und Testdaten werden ausschließlich in einem privaten Operational-Repository oder in einem `local-only`-Klon dokumentiert.
- Aktive Codex-Arbeitsstände sollen in einem hostabhängigen `<CODEX_WORKSPACE_ROOT>` konsolidiert werden. Das öffentliche Template beschreibt nur die portable Regel, nie einen konkreten lokalen Laufwerks- oder Benutzerpfad.

Ein lokaler Codex-Lauf darf beide Bereiche parallel berücksichtigen: Das öffentliche Template bleibt die Quelle für generische Änderungen, der private oder lokale Operational-Workspace bleibt die Quelle für Hostzustand und Tests. Die konkrete Codex-Aufgabe oder lokale Testabsicht wird nicht als Prompt, Notiz oder Projektauftrag im öffentlichen Repository abgelegt.

Private Operational-Repositories sollen das öffentliche Template als separaten `template`-Remote führen. Der aktuelle Template-Stand wird im privaten Repository mit `scripts/common/sync-template-upstream.*` geholt und gemergt. Dabei bleiben `repo-mode.yaml`, `hosts/` und Secret-Referenzen privat; Hostdaten fließen nie zurück ins öffentliche Template. Details stehen in `docs/19-template-upstream-sync.md`.

Vor jeder Aufgabe muss Codex explizit entscheiden:

- Gehört die Änderung als generische, offizielle Verbesserung in das öffentliche Template?
- Gehört sie als Host-, Test-, Infrastruktur- oder Betriebszustand in ein privates Operational-Repository oder einen `local-only`-Klon?
- Muss in beiden Arbeitsbereichen gearbeitet werden, wobei nur der generische Anteil ins öffentliche Repository übernommen wird?

## Natürliche Startsignale

Wenn der Nutzer Formulierungen wie `starte die Erstkonfiguration`, `starte die Agenten-Konfiguration für meinen PC`, `konfiguriere diesen PC`, `öffne die PC-Agent-Konfiguration erneut` oder sinngemäß ähnliche Aufforderungen verwendet, ist das ein direkter Auftrag zur Konfigurationsumgebung.

Codex muss dann nicht auf eine Skriptliste warten. Der Agent leitet selbst den passenden Ablauf ein:

1. `AGENTS.md` und `Vorlage/common/00-agent-regeln.md` als verbindliche Regeln anwenden.
2. Arbeitsbaum, Repo-Modus, Sichtbarkeit und offene Issues prüfen.
3. Entscheiden, ob Hostdaten im aktuellen Arbeitsbereich geschrieben werden dürfen.
4. Falls der aktuelle Arbeitsbereich öffentlich oder ungeprüft ist, keine Hostdaten schreiben und zuerst eine sichere private Operational-Kopie oder einen `local-only`-Klon herstellen oder anfordern.
5. In einem erlaubten Operational-Kontext `first-run-config.*` als Werkzeug starten oder erneut öffnen.
6. Danach anhand der gespeicherten Präferenzen, Vorlagen und aktuellen Baseline entscheiden, welche nächsten Schritte sinnvoll und freigabepflichtig sind.

Wenn ein Agent persistentes Memory unterstützt, darf er sich merken, dass `Agenten-Konfiguration für meinen PC` auf dieses Repository und diese Regeln verweist. Trotzdem muss jeder Lauf Repo-Modus, Sichtbarkeit, Git-Status und Host-Schreibrechte neu prüfen.

Die Skripte in `scripts/` sind Werkzeuge zur Prüfung, Erfassung und Validierung. Sie ersetzen nicht die Entscheidung des Agenten. Der Agent wählt sie anhand von `AGENTS.md`, `docs/` und `Vorlage/` gezielt aus und startet keine breite Skriptkette ohne konkreten Anlass.

## Wiederholbare Konfiguration

Die Erststart- beziehungsweise Agenten-Konfiguration ist wiederaufnehmbar. Eine vorhandene Datei `hosts/<HOSTNAME>/state/first-run-config.yaml` ist kein Abbruchgrund, sondern Vorbelegung für eine Folgekonfiguration.

Optionen in dieser Konfiguration wirken wie Präferenz-Schalter:

- Aktivieren erlaubt dem Agenten, passende Empfehlungen, Prüfungen oder freigegebene Schritte vorzubereiten.
- Deaktivieren verbietet künftige Empfehlungen oder Vorbereitungen in diesem Bereich.
- Wenn bereits eine systemwirksame Änderung umgesetzt wurde, ist Deaktivieren kein automatischer Rollback. Codex muss Change-Einträge, Rollback-Dateien, Baseline, Soll-Ist-Abgleich und Nutzdatenrisiko prüfen und danach einen sicheren Rückbau vorschlagen oder begründet davon abraten.

## Harte Regeln

1. Prüfe zuerst den Repo-Modus und die Sichtbarkeit.
2. Prüfe offene GitHub-Issues, wenn ein Remote vorhanden und GitHub erreichbar ist.
3. Schreibe keine Hostdaten in ein öffentliches oder ungeprüftes Repository.
4. Speichere niemals Klartext-Secrets im Repository.
5. Vor Host-Arbeit muss die Erststart-Konfiguration abgeschlossen sein. Wenn sie fehlt und der Nutzer nicht gerade die Konfiguration starten will, abbrechen und melden: `Die Konfiguration für den Erststart ist noch nicht abgeschlossen.`
6. Vor jeder systemwirksamen Änderung muss ein aktueller Infrastruktur-Snapshot geprüft oder erzeugt werden.
7. Vor jeder systemwirksamen Änderung muss ein Soll-Ist-Abgleich dokumentiert werden.
8. Installiere nichts doppelt, wenn eine gleichwertige funktionsfähige Komponente bereits existiert.
9. Lösche nichts, solange Nutzdaten-, Volume-, Secret-, Workspace- oder Rollback-Relevanz unklar ist.
10. Erfasse vor jeder Änderung den Ausgangszustand mit `git status --short --branch`.
11. Dokumentiere systemwirksame Änderungen in `hosts/<HOSTNAME>/changes/`, aber nur in bestätigtem `operational`- oder `local-only`-Modus.
12. Erzeuge für systemwirksame Änderungen einen Rollback-Pfad.
13. Führe keine destruktiven Aktionen ohne Nutzerfreigabe aus.
14. Arbeite Vorlagen in numerischer Reihenfolge ab.
15. Nutze nur Vorlagen, die zur erkannten Plattform passen.
16. Zeige vor Commit oder Push immer eine Zusammenfassung an.
17. Übernimm nur generische, offizielle Änderungen in das öffentliche Template-Repository.
18. Lege lokale Codex-Aufgaben, private Testziele und Hostzustände nicht im öffentlichen Repository ab.
19. Nutze `pc-agent-installer` als Startpunkt, aber schreibe private oder hostbezogene Inhalte nur in eine geprüfte private Operational-Struktur.
20. Halte README, `AGENTS.md` und Codex-Dokumentation so verständlich, dass ein neuer Nutzer erkennt: Dieses Repo wird als Basis für ein eigenes Agenten-Projekt geklont.
21. Behalte bei Workspace-Migrationen keine dauerhaften lokalen Backups, Archive oder Duplikate; lösche alte Projektstände erst nach Git-/Remote-/Pfadvalidierung.

## Ausführungsreihenfolge

1. `Vorlage/common/00-agent-regeln.md` lesen.
2. Repo-Modus mit `scripts/common/detect-repo-mode.*` erkennen.
3. Falls GitHub erreichbar ist: offene Issues prüfen und relevante Issue-Nummern in der Arbeitsnotiz oder im Commit/PR-Kontext berücksichtigen.
4. Repo-Sichtbarkeit mit `scripts/common/assert-private-repo.*` prüfen, wenn Hostdaten geschrieben werden sollen.
5. Erststart-Konfiguration mit `scripts/common/assert-first-run-config.*` prüfen, wenn Hostdaten oder Systemänderungen betroffen sind.
6. Wenn die Erststart-Konfiguration fehlt oder der Nutzer die Agenten-Konfiguration starten, ändern, deaktivieren oder erneut öffnen will, `scripts/common/first-run-config.ps1` oder `scripts/common/first-run-config.sh` als Werkzeug ausführen lassen.
7. Infrastruktur-Snapshot mit `scripts/common/assert-infrastructure-snapshot.*` prüfen, bevor Installationen, Löschungen, Dienste, Firewall, DNS, Container, WSL, Paketmanager oder Cleanup betroffen sind.
8. Wenn der Snapshot fehlt oder unvollständig ist, zuerst aktuelle Baseline mit `collect-baseline.*` erzeugen.
9. Bei öffentlichem oder ungeprüftem Repo keine Hostdaten schreiben.
10. Plattform, Host, Hardwareprofil und Container-Stacks nur erfassen, wenn Hostdaten im aktuellen Modus erlaubt sind.
11. Host-Ordner nur in bestätigtem `operational`- oder `local-only`-Modus erzeugen.
12. Soll-Zustand, Ist-Zustand, Duplikatprüfung, Löschrisiko, Änderung, Prüfung, Rollback und Abschlussnotiz dokumentieren.

## Standardbefehle

```powershell
./scripts/common/detect-repo-mode.ps1
./scripts/common/first-run-config.ps1
./scripts/common/assert-first-run-config.ps1
./scripts/common/assert-infrastructure-snapshot.ps1
./scripts/common/verify-template.ps1
gh issue list --state open --limit 20
```

```bash
bash ./scripts/common/detect-repo-mode.sh
bash ./scripts/common/first-run-config.sh
bash ./scripts/common/assert-first-run-config.sh
bash ./scripts/common/assert-infrastructure-snapshot.sh
bash ./scripts/common/verify-template.sh
```

`assert-private-repo.*` ist für Host-Schreibzugriffe gedacht und darf im `template`-Modus fehlschlagen. Dieser Fehler ist eine Sicherheitsgrenze, kein Template-Fehler.

## Entwicklungs-, Test- und Build-Befehle

Dieses Repository hat keinen Paketmanager, keine installierbaren Abhängigkeiten und keinen klassischen Build-Schritt. Die lokale Qualitätsprüfung besteht aus den Guard- und Template-Checks.

Vor Änderungen:

```powershell
git status --short --branch
./scripts/common/detect-repo-mode.ps1
```

Nach Änderungen an Vorlagen, Skripten, Schemas oder Dokumentation:

```powershell
./scripts/common/verify-template.ps1
git diff --check
```

Zusätzlich auf Bash-Pfaden:

```bash
bash ./scripts/common/detect-repo-mode.sh
bash ./scripts/common/verify-template.sh
```

Ein absichtlich fehlgeschlagenes `assert-private-repo.*` im `template`-Modus ist kein Fehler. Es bestätigt, dass Host-Schreibzugriffe im öffentlichen Template blockiert sind.

## New-Project-Standard

Die globale Codex-Anweisung auf diesem Rechner enthält einen dauerhaften Standard für neue Projekte. Dieses Repository pflegt die wiederverwendbare Projektdokumentation dazu unter `docs/CODEX_NEW_PROJECT_STANDARD.md` und das vorsichtige Bootstrap-Skript unter `scripts/apply-codex-project-standard.sh`.

Wenn Vorlagen, CI/CD-Regeln, Release-Artefakte, Docker/GHCR-Hinweise, Security- oder Kollaborationsstandards geändert werden, müssen globale Codex-Anweisung, öffentliches Template und private Operational-Dokumentation inhaltlich konsistent bleiben. Öffentliche Dateien bleiben generisch; hostbezogene Details gehören nur in geprüfte private Strukturen.

## Security-Remediation-Standard

Bei Security- oder GitHub-Alert-Aufgaben gilt zusätzlich:

- GitHub-Quellen aktiv prüfen: Code Scanning, CodeQL/SARIF, Dependabot, Secret Scanning, Repository Advisories, Actions-Runs, Workflow-Konfiguration und Branch Protection.
- Lokale Prüfungen passend zum Repository ausführen. Für dieses Template sind besonders `gitleaks`, `actionlint`, `shellcheck`, `verify-template.*` und `git diff --check` sinnvoll, wenn verfügbar oder temporär sicher nutzbar.
- Befunde direkt beheben, wenn sie generisch und template-relevant sind. Host-, Betriebs- oder Testdaten gehören nicht in das öffentliche Template.
- Secrets niemals ausgeben. Funde nur maskiert dokumentieren und Rotation oder Revocation als manuellen Folgeschritt benennen, wenn sie außerhalb des Repos liegt.
- Ergebnisse und verbleibende Risiken in `docs/SECURITY_ALERT_ANALYSIS.md` oder im Abschlussbericht nachvollziehbar dokumentieren.

## Konventionen

- Dokumentation ist deutsch, knapp und technisch eindeutig.
- Mehrsprachige Repository-Einstiege werden explizit gepflegt: `README.md` bleibt deutsch, `README.en.md` bleibt englisch, `docs/de/` und `docs/en/` sind sichtbare Spracheinstiege.
- Nutzer- oder administrationsrelevante Skriptmeldungen sollen neue Texte über die i18n-Hilfen in `scripts/common/i18n.*` beziehen, wenn der Skriptbereich bereits mehrsprachig ist.
- Produktnahe Komponentenbezeichnungen und Kurzbeschreibungen gehören in `i18n/product-components.tsv`; neue Komponenten müssen alle Sprachen aus `i18n/languages.tsv` vollständig bedienen.
- Dokumentation beschreibt den Agenten-first-Ablauf: Nutzer klont das Template, der Agent arbeitet im Klon, und Public/Private-Einordnung erfolgt vor jeder Änderung.
- Alle neuen oder geänderten Textdateien werden als UTF-8 geschrieben.
- Deutsche Fließtexte verwenden echte UTF-8-Umlaute wie `für`, `prüfen`, `Änderung`, `zurück` und `vollständig`; keine blinden `ue/oe/ae`-Ersetzungen in technischen Tokens, Pfaden, IDs oder Code.
- Markdown-Dateien verwenden klare Überschriften, kurze Abschnitte und relative Pfade in Codeformatierung.
- Öffentliche Dokumentation bleibt sachlich: keine erfundenen Features, Roadmap-Zusagen, Supportversprechen oder Sicherheitsgarantien.
- PowerShell-Skripte müssen ohne expliziten `-RepoRoot` aus dem Repository heraus laufen.
- Guard-Skripte müssen nicht destruktiv und idempotent bleiben.
- Neue Vorlagen brauchen gültiges YAML-Frontmatter und eine eindeutige numerische Position.
- Nach Änderungen an Vorlagen, Skripten, Schemas oder Dokumentation muss `verify-template.*` ausführbar bleiben.

## Git-Regeln

- Keine destruktiven Git-Befehle ohne ausdrückliche Freigabe.
- Kein Pull, Push, Merge oder Rebase ohne vorherige Zusammenfassung.
- Bestehende Nutzeränderungen nicht zurücksetzen oder überschreiben.
- Große, generierte, lokale oder sensible Dateien nicht ungeprüft hinzufügen.
- Vor Push in ein öffentliches Template muss `repo-mode.yaml` weiterhin `template` bleiben und `hosts/` darf nur `.gitkeep` enthalten.
- Wenn Schreibrechte für das öffentliche Repository vorhanden sind, dürfen kleine geprüfte Template-Änderungen direkt auf `main` committed und gepusht werden.
- Wenn keine Schreibrechte vorhanden sind oder der Push scheitert, nicht abbrechen: detailliertes Issue anlegen, Korrekturvorschlag dokumentieren und einen Pull Request aus einem Fork oder Branch vorbereiten.
- Kleine zusammenhängende Änderungen früh `git add`en und committen. Lieber mehrere nachvollziehbare Commits als einen großen Sammelcommit.

## Issues und Pull Requests

- Prüfe vor der Arbeit offene Issues auf Überschneidungen.
- Bei echten Fehlern im öffentlichen Template ein detailliertes Issue anlegen: Ist-Zustand, erwartetes Verhalten, Reproduktion, betroffene Dateien, Risiko, vorgeschlagene Lösung und ausgeführte Checks.
- Wenn ein Issue bereits existiert, dort ergänzen statt ein Duplikat zu erzeugen.
- Externe Agenten oder Nutzer ohne Push-Rechte arbeiten über Fork/Branch und Pull Request.
- Pull Requests müssen die Änderung knapp erklären, relevante Issues verlinken und die ausgeführten Checks nennen.

## Sicherheitsgrenzen

- Keine Klartext-Secrets, Tokens, Passwörter, privaten Schlüssel oder produktiven Kubeconfigs speichern.
- `.env`-Dateien, Secret-Exporte und rohe Credential-Dumps bleiben ausgeschlossen.
- Secret-Referenzen dürfen nur Zweck, Ablageort, Zugriffsmethode, Laufzeitvariable und Rotationshinweise beschreiben.
- Bei unklarer Repo-Sichtbarkeit keine Hostdaten, privaten Pfade oder Infrastrukturdetails erfassen.
- Bei normalen Nutzer-PCs gilt usability-first: Sicherheitssettings sollen kostenlose, aktuelle und seriöse Schutzmaßnahmen bevorzugen, aber normale Internet-, Download-, Store-, Game-, Entwickler- und KI-Tool-Nutzung nicht unnötig blockieren.
- Sicherheitsmaßnahmen mit Blockade-, Installations-, Dienst-, Firewall-, DNS- oder Blocklist-Wirkung brauchen eine dokumentierte Frage-Antwort-Entscheidung nach `Vorlage/common/13-interaktive-sicherheitsentscheidungen.md`.
- Vollzugriff ist keine Freigabe zum Blindflug. Vor jeder systemwirksamen Aktion gelten `Vorlage/common/16-infrastruktur-soll-ist-abgleich.md` und `docs/18-infrastruktur-soll-ist-abgleich.md`.
- Jede zukünftige Template-Änderung, die Installationen, Löschungen, Dienste, Paketmanager, Container, WSL, Firewall, DNS, Blocklisten, Security-Tools oder Cleanup betrifft, muss die Infrastruktur-Soll-Ist-Regel erhalten oder ausdrücklich referenzieren.

## Windows-, WSL- und Container-Optionen

- Die Windows-Erststart-Konfiguration darf WSL als optionales Backend anbieten.
- Docker darf im normalen Windows-Fluss nur als Option auf Basis von WSL-Unterstützung eingeplant werden.
- Portainer CE darf nur als optionale Verwaltungsoberfläche empfohlen werden, wenn Docker gewählt wurde.
- Sobald WSL gewählt wurde, müssen WSL-Vorlagen und WSL-Sicherheitsempfehlungen berücksichtigt werden.
- Sobald Docker oder Portainer gewählt wurde, müssen Container-Vorlagen, Port-/Exposure-Regeln und volume-sichere Rollback-Regeln berücksichtigt werden.
- WSL, Docker und Portainer dürfen nicht automatisch installiert, gestartet, exponiert oder als Pflichtkomponenten behandelt werden; jede systemwirksame Änderung braucht Erststart-Präferenz, Nutzerfreigabe, Rollback und Validierung.

## Programm- und Installationsempfehlungen

- Die Erststart-Konfiguration enthält eine kurze Nutzerbeschreibung wie `Ich bin Entwickler`.
- Der Agent darf daraus Zielgruppenprofile ableiten und passende Programmkategorien vorschlagen.
- Empfehlungen müssen Betriebssystem, Distribution, Desktop-/Server-Kontext, vorhandene Software und Paketmanager berücksichtigen.
- Bevorzugt werden kostenlose, aktuelle und offizielle Quellen: Store, Betriebssystem-Paketmanager, Homebrew, Flathub oder Herstellerseite.
- Programme wie WhatsApp sollen als offizielle App oder Web/PWA-Option behandelt werden; Messenger gehören nicht auf Server- oder Headless-Profile.
- Cleaner wie CCleaner oder BleachBit sind nur optionale manuelle Werkzeuge, keine Default-Optimierung. Registry-Reinigung, Driver-Updater und Booster-Funktionen nicht empfehlen.
- Keine Masseninstallation ohne konkrete Frage-Antwort-Entscheidung, Rollback-Hinweis und Validierung.

## Datei-Löschungen

Lösche Dateien nur, wenn sicher ist, dass sie nicht für Template, Skripte, Dokumentation, Lizenz, Beispiele, Schemas oder spätere Operational-Nutzung benötigt werden. Unsichere Kandidaten bleiben bestehen und werden im Abschlussbericht als prüfpflichtig aufgeführt.

## Definition of Done

Eine Aufgabe ist erst abgeschlossen, wenn der Ausgangszustand geprüft, Änderungen nachvollziehbar sind und passende Checks gelaufen sind. Für reine Template-Arbeit genügt ein leerer `hosts/`-Ordner mit `.gitkeep`, erfolgreiche `verify-template.*`-Prüfung und ein sauber geprüfter Git-Diff.

Der aktuelle saubere Zustand muss bei jeder späteren Codex-Aufgabe erhalten bleiben: Funktionalität nicht absichtlich verändern, Sicherheitsgrenzen einhalten, Dokumentation konsistent halten und alle Abweichungen klar berichten.
