# AGENTS.md

## Rolle

Du bist ein lokaler Agent zur dokumentierten, reproduzierbaren und rollbackfähigen Einrichtung dieses Rechners. In diesem Repository arbeitest du standardmäßig am generischen Template, nicht an echten Hostdaten.

## Projektüberblick

- `repo-mode.yaml` steuert den Sicherheitsmodus.
- `Vorlage/` enthält numerisch sortierte Agenten-Vorlagen.
- `scripts/common/` enthält Repo-Guards und Template-Validierung.
- `scripts/powershell/` und `scripts/bash/` enthalten Host-, Baseline- und Change-Hilfen.
- `scripts/container/` enthält Container-Erkennung.
- `schemas/` enthält YAML-Schemas.
- `docs/`, `examples/` und `private.example/` enthalten generische Dokumentation und sichere Beispiele.
- `hosts/` bleibt im `template`-Modus leer und enthält nur `.gitkeep`.

## Arbeitsmodell

Dieses Projekt trennt dauerhaft zwei Arbeitsbereiche:

- Offizielle Template- und Codeänderungen werden im öffentlichen Template-Repository gepflegt und dürfen automatisch dorthin übernommen werden, wenn Checks erfolgreich sind.
- Rechner-, Host-, Infrastruktur- und Testdaten werden ausschließlich in einem privaten Operational-Repository oder in einem `local-only`-Klon dokumentiert.

Ein lokaler Codex-Lauf darf beide Bereiche parallel berücksichtigen: Das öffentliche Template bleibt die Quelle für generische Änderungen, der private oder lokale Operational-Workspace bleibt die Quelle für Hostzustand und Tests. Die konkrete Codex-Aufgabe oder lokale Testabsicht wird nicht als Prompt, Notiz oder Projektauftrag im öffentlichen Repository abgelegt.

## Harte Regeln

1. Prüfe zuerst den Repo-Modus und die Sichtbarkeit.
2. Schreibe keine Hostdaten in ein öffentliches oder ungeprüftes Repository.
3. Speichere niemals Klartext-Secrets im Repository.
4. Erfasse vor jeder Änderung den Ausgangszustand mit `git status --short --branch`.
5. Dokumentiere systemwirksame Änderungen in `hosts/<HOSTNAME>/changes/`, aber nur in bestätigtem `operational`- oder `local-only`-Modus.
6. Erzeuge für systemwirksame Änderungen einen Rollback-Pfad.
7. Führe keine destruktiven Aktionen ohne Nutzerfreigabe aus.
8. Arbeite Vorlagen in numerischer Reihenfolge ab.
9. Nutze nur Vorlagen, die zur erkannten Plattform passen.
10. Zeige vor Commit oder Push immer eine Zusammenfassung an.
11. Übernimm nur generische, offizielle Änderungen in das öffentliche Template-Repository.
12. Lege lokale Codex-Aufgaben, private Testziele und Hostzustände nicht im öffentlichen Repository ab.

## Ausführungsreihenfolge

1. `Vorlage/common/00-agent-regeln.md` lesen.
2. Repo-Modus mit `scripts/common/detect-repo-mode.*` erkennen.
3. Repo-Sichtbarkeit mit `scripts/common/assert-private-repo.*` prüfen, wenn Hostdaten geschrieben werden sollen.
4. Bei öffentlichem oder ungeprüftem Repo keine Hostdaten schreiben.
5. Plattform, Host, Hardwareprofil und Container-Stacks nur erfassen, wenn Hostdaten im aktuellen Modus erlaubt sind.
6. Host-Ordner nur in bestätigtem `operational`- oder `local-only`-Modus erzeugen.
7. Baseline, Änderung, Prüfung, Rollback und Abschlussnotiz dokumentieren.

## Standardbefehle

```powershell
./scripts/common/detect-repo-mode.ps1
./scripts/common/validate-template.ps1
git diff --check
```

```bash
bash ./scripts/common/detect-repo-mode.sh
bash ./scripts/common/validate-template.sh
```

`assert-private-repo.*` ist für Host-Schreibzugriffe gedacht und darf im `template`-Modus fehlschlagen. Dieser Fehler ist eine Sicherheitsgrenze, kein Template-Fehler.

## Konventionen

- Dokumentation ist deutsch, knapp und technisch eindeutig.
- Deutsche Fließtexte verwenden echte UTF-8-Umlaute; keine blinden `ue/oe/ae`-Ersetzungen in technischen Tokens, Pfaden, IDs oder Code.
- Markdown-Dateien verwenden klare Überschriften, kurze Abschnitte und relative Pfade in Codeformatierung.
- PowerShell-Skripte müssen ohne expliziten `-RepoRoot` aus dem Repository heraus laufen.
- Guard-Skripte müssen nicht destruktiv und idempotent bleiben.
- Neue Vorlagen brauchen gültiges YAML-Frontmatter und eine eindeutige numerische Position.

## Git-Regeln

- Keine destruktiven Git-Befehle ohne ausdrückliche Freigabe.
- Kein Pull, Push, Merge oder Rebase ohne vorherige Zusammenfassung.
- Bestehende Nutzeränderungen nicht zurücksetzen oder überschreiben.
- Große, generierte, lokale oder sensible Dateien nicht ungeprüft hinzufügen.
- Vor Push in ein öffentliches Template muss `repo-mode.yaml` weiterhin `template` bleiben und `hosts/` darf nur `.gitkeep` enthalten.

## Sicherheitsgrenzen

- Keine Klartext-Secrets, Tokens, Passwörter, privaten Schlüssel oder produktiven Kubeconfigs speichern.
- `.env`-Dateien, Secret-Exporte und rohe Credential-Dumps bleiben ausgeschlossen.
- Secret-Referenzen dürfen nur Zweck, Ablageort, Zugriffsmethode, Laufzeitvariable und Rotationshinweise beschreiben.
- Bei unklarer Repo-Sichtbarkeit keine Hostdaten, privaten Pfade oder Infrastrukturdetails erfassen.

## Datei-Löschungen

Lösche Dateien nur, wenn sicher ist, dass sie nicht für Template, Skripte, Dokumentation, Lizenz, Beispiele, Schemas oder spätere Operational-Nutzung benötigt werden. Unsichere Kandidaten bleiben bestehen und werden im Abschlussbericht als prüfpflichtig aufgeführt.

## Definition of Done

Eine Aufgabe ist erst abgeschlossen, wenn der Ausgangszustand geprüft, Änderungen nachvollziehbar sind und passende Checks gelaufen sind. Für reine Template-Arbeit genügt ein leerer `hosts/`-Ordner mit `.gitkeep`, erfolgreiche Template-Validierung und ein sauber geprüfter Git-Diff.

Der aktuelle saubere Zustand muss bei jeder späteren Codex-Aufgabe erhalten bleiben: Funktionalität nicht absichtlich verändern, Sicherheitsgrenzen einhalten, Dokumentation konsistent halten und alle Abweichungen klar berichten.
