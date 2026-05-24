[CmdletBinding()]
param(
    [string]$RepoRoot
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$Utf8Bom = [System.Text.UTF8Encoding]::new($true)

function Write-RepoFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content
    )
    $fullPath = Join-Path $RepoRoot $Path
    $parent = Split-Path -Parent $fullPath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $encoding = if ([System.IO.Path]::GetExtension($fullPath) -ieq '.ps1') { $Utf8Bom } else { $Utf8NoBom }
    [System.IO.File]::WriteAllText($fullPath, ($Content.TrimEnd() + "`n"), $encoding)
}

function New-TemplateContent {
    param(
        [string]$Path,
        [string]$Title
    )

    $area = ($Path -replace '^Vorlage/', '') -replace '/[^/]+$', ''
    $id = ($Path -replace '^Vorlage/', '' -replace '\.md$', '' -replace '[^A-Za-z0-9]+', '-').Trim('-').ToUpperInvariant()
    $platform = 'any'
    if ($Path -like 'Vorlage/windows/*') { $platform = 'windows' }
    elseif ($Path -like 'Vorlage/linux/*') { $platform = 'linux' }

    $environment = 'any'
    if ($Path -like 'Vorlage/wsl/*') { $environment = 'wsl'; $platform = 'linux' }
    elseif ($Path -like 'Vorlage/container/*') { $environment = 'container' }
    elseif ($platform -in @('windows', 'linux')) { $environment = 'native' }

    $risk = 'niedrig'
    $requiresAdmin = 'false'
    $approval = 'false'
    $rollback = 'false'
    if ($Path -match '(firewall|registry|features|systemd|ssh|sudo|kernel|treiber|pakete|serverrollen|docker|podman|swarm|kubernetes|nvidia|dgx|gpu)') {
        $risk = 'mittel'
        $requiresAdmin = 'true'
    }
    if ($Path -match '(install|pakete|firewall|registry|systemd|ssh|sudo|kubernetes|swarm|dgx|gpu|treiber)') {
        $approval = 'true'
        $rollback = 'true'
    }
    if ($Path -match '(baseline|detect|report|secret|images|containers|networks|volumes|contexts|namespaces|workloads|services|rbac|storage|ports|projects|files)') {
        $rollback = 'false'
    }

    return @"
---
id: $id
title: $Title
platform: $platform
environment: $environment
area: $area
requires_admin: $requiresAdmin
risk: $risk
approval_required: $approval
rollback_required: $rollback
idempotent: true
applies_to:
  - $area
---

# $Title

## Zweck
Diese Vorlage beschreibt den generischen Soll-Prozess für `$area`.

## Sicherheitsregeln
- Vor Ausführung Repo-Modus und Sichtbarkeit prüfen.
- Keine Klartext-Secrets erfassen oder speichern.
- Vor systemwirksamen Änderungen Ausgangszustand dokumentieren.
- Änderungen nur mit passender Validierung und Rollback-Pfad ausführen.

## Ablauf
1. Plattform- und Host-Kontext erkennen.
2. Relevante Baseline-Dateien unter `hosts/<HOSTNAME>/baseline/` prüfen oder erzeugen.
3. Geplante Änderung unter `hosts/<HOSTNAME>/changes/` dokumentieren.
4. Falls ``rollback_required: true``, Rollback-Datei unter ``hosts/<HOSTNAME>/rollback/`` anlegen.
5. Validierung ausführen und Ergebnis im Change-Eintrag festhalten.

## Erwartete Nachweise
- Baseline- oder Reportdatei im passenden Host-Unterordner.
- Ausgeführte Befehle mit redigierten Ausgaben.
- Abschlussstatus mit offener Risiko- oder Freigabeliste.
"@
}

$topLevel = @{
    'AGENTS.md' = @'
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
- Aktive Codex-Arbeitsstände sollen in einem hostabhängigen `<CODEX_WORKSPACE_ROOT>` konsolidiert werden. Das öffentliche Template beschreibt nur die portable Regel, nie einen konkreten lokalen Laufwerks- oder Benutzerpfad.

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
13. Behalte bei Workspace-Migrationen keine dauerhaften lokalen Backups, Archive oder Duplikate; lösche alte Projektstände erst nach Git-/Remote-/Pfadvalidierung.

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
- Bei unklarer Repo-Sichtbarkeit keine Hostdaten, privaten Pfade oder Infrastrukturdetails erfassen.

## Datei-Löschungen
Lösche Dateien nur, wenn sicher ist, dass sie nicht für Template, Skripte, Dokumentation, Lizenz, Beispiele, Schemas oder spätere Operational-Nutzung benötigt werden. Unsichere Kandidaten bleiben bestehen und werden im Abschlussbericht als prüfpflichtig aufgeführt.

## Definition of Done
Eine Aufgabe ist erst abgeschlossen, wenn der Ausgangszustand geprüft, Änderungen nachvollziehbar sind und passende Checks gelaufen sind. Für reine Template-Arbeit genügt ein leerer `hosts/`-Ordner mit `.gitkeep`, erfolgreiche Template-Validierung und ein sauber geprüfter Git-Diff.

Der aktuelle saubere Zustand muss bei jeder späteren Codex-Aufgabe erhalten bleiben: Funktionalität nicht absichtlich verändern, Sicherheitsgrenzen einhalten, Dokumentation konsistent halten und alle Abweichungen klar berichten.
'@
    'README.md' = @'
# PC Agent Installer

PC Agent Installer ist ein Template für dokumentierte, reproduzierbare und rollbackfähige Rechner-Einrichtung mit Codex oder anderen lokalen Agenten. Das Repository trennt generische Vorlagen und Skripte von echten Hostdaten, damit ein öffentliches Template nutzbar bleibt, ohne private Infrastrukturinformationen zu speichern.

## Status

- Aktueller Modus: `template`, siehe `repo-mode.yaml`.
- Hostdaten sind in diesem Modus gesperrt.
- `hosts/` bleibt im Template leer und enthält nur `.gitkeep`.
- Die PowerShell- und Bash-Guard-Skripte prüfen vor Host-Schreibzugriffen Modus und Sichtbarkeit.

## Betriebsmodi

- `template`: Öffentliches Template. Keine Hostdaten, keine sensiblen Kontextdaten.
- `operational`: Privates Remote-Repository. Hostdaten und Secret-Referenzen erlaubt, Klartext-Secrets verboten.
- `local-only`: Lokales Git-Repository ohne Remote. Hostdaten erlaubt, Push erst nach erneuter Sichtbarkeitsprüfung.

Der aktuelle Default ist `template`, siehe `repo-mode.yaml`.

## Arbeitsmodell

Das Projekt ist so gedacht, dass Codex generische Template-Änderungen im öffentlichen Repository pflegen kann, während echte Rechner- und Hostdaten in einem getrennten privaten oder lokalen Operational-Workspace bleiben.

- Offizielle Änderungen: Vorlagen, Skripte, Schemas, Dokumentation, Beispiele, Lizenz- und Sicherheitsregeln im öffentlichen Template.
- Private Änderungen: Host-Baselines, lokale Infrastruktur, Secret-Referenzen, Testzustände und maschinenspezifische Änderungen in einem privaten `operational`-Repo oder `local-only`-Klon.
- Lokale Codex-Aufgaben: nicht als Prompt oder Projektauftrag im öffentlichen Repo speichern; nur generische, wiederverwendbare Regeln in `AGENTS.md` und Dokumentation übernehmen.
- Workspace-Hygiene: aktive Codex-Projekte sollen unter einem hostabhängigen `<CODEX_WORKSPACE_ROOT>` konsolidiert werden. Der Pfad wird nicht im öffentlichen Template fest verdrahtet; pro Projekt bleibt lokal genau ein aktueller Arbeitsstand.

## Projektstruktur

- `AGENTS.md`: verbindliche Arbeitsregeln für Codex und andere Agenten.
- `Vorlage/`: numerisch sortierte Aufgaben-Vorlagen für Windows, Linux, WSL, Container und Hardwareprofile.
- `scripts/common/`: Repo-Modus, Sichtbarkeitsprüfung, Template-Validierung und Moduswechsel.
- `scripts/powershell/` und `scripts/bash/`: Host-Erkennung, Baseline- und Änderungsdokumentation.
- `scripts/container/`: Container-, Compose-, Swarm-, Kubernetes-, Podman- und NVIDIA-Erkennung.
- `schemas/`: YAML-Schemas für Host-, Baseline-, Change-, Rollback- und Repo-Modus-Daten.
- `docs/`: Konzept-, Sicherheits-, Betriebs- und Lizenzdokumentation.
- `examples/`: sichere Beispielartefakte ohne echte Hostdaten.
- `private.example/`: Beispiele für private Konfigurationen und Secret-Referenzen.
- `hosts/`: Zielordner für Hostdaten in sicheren Operational- oder Local-only-Repositories.

## Voraussetzungen

- Git
- PowerShell für Windows-Workflows
- Bash für Linux-, WSL- und Unix-nahe Workflows
- Optional: GitHub CLI `gh`, wenn Remote-Sichtbarkeit über GitHub geprüft oder eine private Kopie erstellt werden soll

Es gibt keinen Paketmanager, keine externen Laufzeitabhängigkeiten und keinen klassischen Build-Schritt.

## Schnellstart

Repo-Modus prüfen:

```powershell
./scripts/common/detect-repo-mode.ps1
```

```bash
./scripts/common/detect-repo-mode.sh
```

Template validieren:

```powershell
./scripts/common/validate-template.ps1
```

```bash
./scripts/common/validate-template.sh
```

Host-Schreibrechte prüfen:

```powershell
./scripts/common/assert-private-repo.ps1
```

```bash
./scripts/common/assert-private-repo.sh
```

Im `template`-Modus schlägt `assert-private-repo` absichtlich fehl. Das schützt vor versehentlichem Schreiben von Hostdaten in ein öffentliches oder ungeprüftes Repository.

## Private Nutzung

Private Operational-Kopie über GitHub CLI erzeugen:

```powershell
./scripts/common/create-private-copy.ps1 -Template owner/pc-agent-installer -Destination user/pc-agent-installer-private
```

Lokalen Operational-Modus ohne Remote aktivieren:

```powershell
./scripts/common/enable-local-only-mode.ps1
```

## Entwicklung und Prüfung

```powershell
git status --short --branch
./scripts/common/detect-repo-mode.ps1
./scripts/common/validate-template.ps1
git diff --check
```

Es gibt aktuell keinen separaten Test-, Lint-, Typecheck- oder Format-Befehl. Die relevanten Projektchecks sind Guard-Skripte, Template-Validierung, Git-Diff-Prüfung und gezielte Skript-Syntaxprüfungen.

## Codex- und Agenten-Hinweise

Agenten müssen zuerst `AGENTS.md` lesen, danach Repo-Modus und Sichtbarkeit prüfen. Im `template`-Modus sind nur generische Template-, Dokumentations-, Skript- und Hygieneänderungen erlaubt. Echte Hostnamen, private Pfade, produktive Infrastrukturdetails, Secret-Werte und sensible lokale Kontexte dürfen nicht dokumentiert werden.

Der saubere Zustand dieses Repositorys soll bei jeder späteren Codex-Aufgabe erhalten bleiben: kleine Diffs, keine destruktiven Git-Befehle, keine ungeprüften Hostdaten, Template-Validierung nach relevanten Änderungen und klare Trennung zwischen sicheren Änderungen und prüfpflichtigen Punkten.

## Lizenz

Das öffentliche Template steht unter Apache License 2.0, siehe `LICENSE` und `NOTICE`. Private Operational-Repositories, Hostdaten, lokale Infrastrukturinformationen und Nutzerinhalte, die aus dem Template entstehen, sind nicht Teil des öffentlichen Upstream-Projekts.
'@
    'LICENSE' = @'
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS
'@
    'NOTICE' = @'
PC Agent Installer

Dieses Repository ist als öffentliches Template gedacht. Die Apache-2.0-Lizenz erlaubt das Kopieren, Ändern und private Verwenden des Projekts.

Hostdaten, private Konfigurationsstände, Secret-Referenzen, lokale Infrastrukturinformationen und Nutzerinhalte, die in einem privaten abgeleiteten Repository entstehen, sind nicht Teil des öffentlichen Upstream-Projekts.

Klartext-Secrets sollen weder im öffentlichen noch im privaten Repository gespeichert werden.
'@
    'SECURITY.md' = @'
# Security Policy

## Grundsatz

Dieses Repository darf keine Klartext-Secrets enthalten. Hostdaten dürfen nur in einem bestätigten privaten Operational-Repository oder in einem lokalen Git-only-Repository ohne Remote geschrieben werden.

## Nicht erlaubt

- Klartext-Passwörter, Tokens, API-Keys und private Schlüssel
- ungefilterte `.env`-Dateien
- produktive Kubeconfigs mit Tokens
- SSH Private Keys und Zertifikats-Private-Keys
- rohe Secret-, Credential- oder Token-Exporte

## Meldung sensibler Daten

Wenn versehentlich sensible Daten committed wurden:

1. Nicht weiter pushen.
2. Betroffene Secrets sofort rotieren.
3. Historie nur nach expliziter Freigabe bereinigen.
4. Falls ein Remote betroffen ist, GitHub Secret Scanning und Audit-Logs prüfen.

## Operational-Repositories

Private Operational-Repositories dürfen Secret-Referenzen dokumentieren, aber keine Secret-Werte. Erlaubt sind Zweck, Ablageort, Zugriffsmethode, Laufzeitvariable und Rotationshinweise.
'@
    'CONTRIBUTING.md' = @'
# Contributing

## Scope

Beiträge zum öffentlichen Template müssen generisch bleiben. Keine echten Hostnamen, privaten Pfade, internen Infrastrukturdetails oder Secrets.

## Qualität

- Kleine, nachvollziehbare Änderungen bevorzugen.
- Vorlagen mit gültigem YAML-Frontmatter versehen.
- Skripte idempotent und nicht destruktiv halten.
- Destruktive Aktionen nur als dokumentierte, freigabepflichtige Schritte modellieren.

## Checks

Vor einem Pull Request sollten mindestens ausgeführt werden:

```powershell
./scripts/common/detect-repo-mode.ps1
./scripts/common/validate-template.ps1
./scripts/common/assert-private-repo.ps1
git diff --check
```

In `template`-Repos wird `assert-private-repo` bewusst fehlschlagen, weil Hostschreiben verboten ist. Das ist kein Template-Fehler.
'@
    'CHANGELOG.md' = @'
# Changelog

## Unreleased

- README als zentrale Einstiegsdokumentation erweitert.
- AGENTS.md um projektspezifische Codex-Regeln und dauerhafte Hygienevorgaben ergänzt.
- Öffentliches Template und private Operational-Arbeit als dauerhaftes Codex-Arbeitsmodell dokumentiert.
- PowerShell-Entrypoints robuster gemacht, damit sie ohne expliziten `-RepoRoot` laufen.
- Beschädigte `rollback_required`-Zeile in den Template-Dateien korrigiert.
- Repository-Hygiene für lokale Logs und Caches ergänzt.

## 0.1.0 - 2026-05-24

- Initiales Template-Grundgerüst angelegt.
- Repo-Modi `template`, `operational` und `local-only` modelliert.
- Guard-Skripte für PowerShell und Bash ergänzt.
- Plattform-, Host-, Baseline- und Container-Erkennung als erste sichere Version ergänzt.
- Vorlagenstruktur für Windows, Linux, WSL, Container und Profile angelegt.
'@
    '.gitignore' = @'
# Secrets
.env
.env.*
*.pem
*.key
*.pfx
*.p12
id_rsa
id_ed25519
kubeconfig
kubeconfig.*

# Lokale Dumps und Laufzeitartefakte
*.dump
*.bak
*.tmp
*.log
*.log.sensitive

# Lokale Caches
.cache/
__pycache__/
*.pyc
.pytest_cache/
.mypy_cache/
.ruff_cache/

# OS
.DS_Store
Thumbs.db

# Editor
.vscode/settings.json
.idea/

# Optional: rohe sensitive Exporte
hosts/**/baseline/raw/*secret*
hosts/**/baseline/raw/*token*
hosts/**/baseline/raw/*credential*
'@
    '.gitattributes' = @'
* text=auto
*.sh text eol=lf
*.ps1 text eol=crlf
*.md text eol=lf
*.yaml text eol=lf
*.yml text eol=lf
'@
    '.editorconfig' = @'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.ps1]
charset = utf-8-bom
end_of_line = crlf
indent_size = 4

[*.md]
trim_trailing_whitespace = false
'@
    'repo-mode.yaml' = @'
repo_mode: template
visibility_required: public
allowed_to_write_hosts: false
allowed_to_document_sensitive_context: false
allowed_to_store_plaintext_secrets: false
'@
    'hosts/.gitkeep' = ''
}

foreach ($entry in $topLevel.GetEnumerator()) {
    Write-RepoFile -Path $entry.Key -Content $entry.Value
}

$docs = @{
    'docs/00-konzept.md' = @'
# Konzept

PC Agent Installer trennt Soll-Prozesse von realem Host-Zustand.

- `Vorlage/` beschreibt generische, numerisch sortierte Agentenaufgaben.
- `scripts/` enthält sichere Erkennungs-, Baseline-, Validierungs- und Rollback-Hilfen.
- `hosts/<HOSTNAME>/` dokumentiert reale Hosts ausschließlich in sicheren Operational- oder Local-only-Repositories.

Jede systemwirksame Änderung braucht Baseline, Änderungsdokumentation, Prüfung und Rollback-Pfad.
'@
    'docs/01-public-template-vs-private-operational-repo.md' = @'
# Public Template vs. Private Operational Repo

Das öffentliche Template enthält nur generische Inhalte. Reale Hostdaten, private Pfade, Infrastrukturdetails und Secret-Referenzen gehören in ein privates Operational-Repository oder in einen lokalen Git-only-Klon ohne Remote.

Ein klassischer öffentlicher Fork ist kein sicherer Betriebszweig. Für produktive Nutzung soll aus dem Template ein neues privates Repository erzeugt werden.
'@
    'docs/02-private-repo-erzeugen.md' = @'
# Private Repo Erzeugen

Empfohlener Weg:

```bash
gh repo create <user>/pc-agent-installer-private --template <owner>/pc-agent-installer --private --clone
```

Alternativ lokal ohne Remote:

```bash
git clone https://github.com/<owner>/pc-agent-installer.git pc-agent-installer-local
cd pc-agent-installer-local
git remote remove origin
git init
git add .
git commit -m "Initial local operational copy"
```

Danach `repo-mode.yaml` auf `operational` oder `local-only` setzen und die Guard-Skripte ausführen.
'@
    'docs/03-repo-visibility-guard.md' = @'
# Repo Visibility Guard

Vor Host-Schreibzugriffen gilt:

1. `repo-mode.yaml` lesen.
2. Git-Remotes prüfen.
3. Falls Remote vorhanden, GitHub-Sichtbarkeit mit `gh repo view --json isPrivate,visibility,nameWithOwner` prüfen.
4. Hostdaten nur erlauben, wenn `operational` plus private Sichtbarkeit oder `local-only` plus kein Remote bestätigt ist.

Bei öffentlichem oder ungeprüftem Remote werden keine Hostdaten geschrieben.
'@
    'docs/04-sicherheitsmodell.md' = @'
# Sicherheitsmodell

- Keine Hostdaten in öffentlichen oder ungeprüften Repositories.
- Keine Klartext-Secrets im Repository.
- Keine destruktiven Aktionen ohne Freigabe.
- Admin-, Root- und Sudo-Aktionen explizit markieren.
- Vorher-/Nachher-Zustand dokumentieren.
- Rollback-Pfad für systemwirksame Änderungen erzeugen.
'@
    'docs/05-secrets-policy.md' = @'
# Secrets Policy

Erlaubt sind Secret-Referenzen: Name, Zweck, Ablageort, Zugriffsmethode, benötigte Berechtigungen und Rotationshinweise.

Verboten sind Secret-Werte: Passwörter, Tokens, API-Keys, private Schlüssel, ungefilterte `.env`-Dateien, produktive Kubeconfigs und Zertifikats-Private-Keys.

Secret-Referenzen pro Host liegen unter `hosts/<HOSTNAME>/security/`.
'@
    'docs/06-sicherer-betriebsmodus.md' = @'
# Sicherer Betriebsmodus

`template` ist der sichere Default für öffentliche Repositories. Hostdaten bleiben deaktiviert.

`operational` setzt eine bestätigte private Remote-Sichtbarkeit voraus.

`local-only` setzt voraus, dass kein Git-Remote existiert. Push ist gesperrt, bis ein privater Remote erneut geprüft wurde.
'@
    'docs/07-dokumentationsstandard.md' = @'
# Dokumentationsstandard

Jede Änderung unter `hosts/<HOSTNAME>/changes/` enthält Metadaten, Ausgangszustand, Zielzustand, Änderung, Ort, Befehle, betroffene Dateien, Prüfung, Rollback und Risiken.

Befehlsausgaben werden redigiert, wenn sie Tokens, Secrets, Credentials oder private Schlüssel enthalten könnten.
'@
    'docs/08-rollback-konzept.md' = @'
# Rollback-Konzept

Systemwirksame Änderungen brauchen:

- Vorher-Wert
- Nachher-Wert
- Rollback-Befehl
- Rollback-Skript
- Rollback-Validierung
- Change-Eintrag

Rollback-Dateien liegen unter `hosts/<HOSTNAME>/rollback/`.
'@
    'docs/09-plattform-erkennung.md' = @'
# Plattform-Erkennung

Windows wird über PowerShell, CIM und optionale WSL-Abfragen erkannt.

Linux wird primär über `/etc/os-release` erkannt und in Distributionsfamilien wie Debian, RHEL oder Arch einsortiert.

WSL wird über `/proc/version`, `/etc/os-release` und Windows-seitig optional über `wsl.exe --list --verbose` erkannt.
'@
    'docs/10-container-modell.md' = @'
# Container-Modell

Container werden als eigene Runtime- und Orchestrierungsebene dokumentiert:

- Docker
- Docker Compose
- Docker Swarm
- Kubernetes
- Podman
- NVIDIA Container Toolkit

Secrets werden nur referenziert. Volumes und produktive Ressourcen werden nicht gelöscht, verändert oder bereinigt, ohne dass Freigabe, Baseline und Rollback-Pfad dokumentiert sind.
'@
    'docs/11-lizenzmodell.md' = @'
# Lizenzmodell

Das öffentliche Template steht unter Apache License 2.0.

Private Operational-Repositories, Hostdaten, lokale Infrastrukturinformationen und Nutzerinhalte, die aus dem Template entstehen, sind nicht Teil des öffentlichen Upstream-Projekts.
'@
    'docs/12-codex-arbeitsmodell.md' = @'
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
'@
    'docs/14-codex-workspace-konsolidierung.md' = @'
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
'@
    'docs/99-faq.md' = @'
# FAQ

## Warum schreibt das Template keine Hostdaten?

Weil öffentliche oder ungeprüfte Repositories keine privaten Host- und Infrastrukturinformationen enthalten dürfen.

## Warum schlägt `assert-private-repo` im Template fehl?

Das ist beabsichtigt. Der Guard schützt Host-Schreibzugriffe. Template-Arbeit bleibt trotzdem möglich.

## Darf ich `.env` committen?

Nein. Nutze Secret-Referenzen und externe Secret Stores.
'@
}

foreach ($entry in $docs.GetEnumerator()) {
    Write-RepoFile -Path $entry.Key -Content $entry.Value
}

$schemas = @{
    'schemas/repo-mode.schema.yaml' = @'
$schema: https://json-schema.org/draft/2020-12/schema
title: PC Agent Installer Repo Mode
type: object
required:
  - repo_mode
  - visibility_required
  - allowed_to_write_hosts
  - allowed_to_document_sensitive_context
  - allowed_to_store_plaintext_secrets
properties:
  repo_mode:
    type: string
    enum: [template, operational, local-only]
  visibility_required:
    type: string
    enum: [public, private, no_remote]
  allowed_to_write_hosts:
    type: boolean
  allowed_to_document_sensitive_context:
    type: boolean
  allowed_to_store_plaintext_secrets:
    type: boolean
additionalProperties: false
'@
    'schemas/host.schema.yaml' = @'
$schema: https://json-schema.org/draft/2020-12/schema
title: PC Agent Installer Host
type: object
required: [host_id, hostname, created_at, last_seen_at, repo, platform]
properties:
  host_id:
    type: string
  hostname:
    type: string
  created_at:
    type: string
    format: date-time
  last_seen_at:
    type: string
    format: date-time
  repo:
    type: object
    required: [mode, visibility_checked, visibility, allowed_to_write_hosts]
    properties:
      mode:
        type: string
        enum: [template, operational, local-only]
      visibility_checked:
        type: boolean
      visibility:
        type: string
      allowed_to_write_hosts:
        type: boolean
  platform:
    type: object
    required: [os, environment, architecture]
    properties:
      os:
        type: string
      environment:
        type: string
      version:
        type: [string, 'null']
      edition:
        type: [string, 'null']
      architecture:
        type: string
  template_paths_used:
    type: array
    items:
      type: string
additionalProperties: true
'@
    'schemas/change-entry.schema.yaml' = @'
$schema: https://json-schema.org/draft/2020-12/schema
title: PC Agent Installer Change Entry Metadata
type: object
required: [datum, hostname, repo_modus, bereich, ebene, risiko, status]
properties:
  datum:
    type: string
  hostname:
    type: string
  repo_modus:
    type: string
  repo_sichtbarkeit_geprueft:
    type: boolean
  bereich:
    type: string
  ebene:
    type: string
    enum: [User, System, Repo, Container, Cluster]
  risiko:
    type: string
    enum: [niedrig, mittel, hoch]
  adminrechte_erforderlich:
    type: boolean
  nutzerfreigabe_erforderlich:
    type: boolean
  status:
    type: string
    enum: [geplant, ausgeführt, fehlgeschlagen, rückgängig gemacht]
additionalProperties: false
'@
    'schemas/baseline.schema.yaml' = @'
$schema: https://json-schema.org/draft/2020-12/schema
title: PC Agent Installer Baseline
type: object
required: [hostname, collected_at, repo, platform, sections]
properties:
  hostname:
    type: string
  collected_at:
    type: string
    format: date-time
  repo:
    type: object
  platform:
    type: object
  sections:
    type: array
    items:
      type: string
additionalProperties: true
'@
    'schemas/template-frontmatter.schema.yaml' = @'
$schema: https://json-schema.org/draft/2020-12/schema
title: PC Agent Installer Template Frontmatter
type: object
required: [id, title, platform, environment, requires_admin, risk, rollback_required, idempotent, applies_to]
properties:
  id:
    type: string
  title:
    type: string
  platform:
    type: string
    enum: [windows, linux, any]
  environment:
    type: string
    enum: [native, wsl, container, any]
  family:
    type: [string, 'null']
  distribution:
    type: [string, 'null']
  version:
    type: [string, 'null']
  hardware_profile:
    type: [string, 'null']
  requires_admin:
    type: boolean
  risk:
    type: string
    enum: [niedrig, mittel, hoch]
  approval_required:
    type: boolean
  rollback_required:
    type: boolean
  idempotent:
    type: boolean
  applies_to:
    type: array
    items:
      type: string
additionalProperties: true
'@
    'schemas/rollback.schema.yaml' = @'
$schema: https://json-schema.org/draft/2020-12/schema
title: PC Agent Installer Rollback
type: object
required: [id, change_entry, created_at, commands, validation]
properties:
  id:
    type: string
  change_entry:
    type: string
  created_at:
    type: string
    format: date-time
  commands:
    type: array
    items:
      type: string
  validation:
    type: array
    items:
      type: string
  requires_approval:
    type: boolean
additionalProperties: false
'@
    'schemas/secret-reference.schema.yaml' = @'
$schema: https://json-schema.org/draft/2020-12/schema
title: PC Agent Installer Secret References
type: object
required: [secrets]
properties:
  secrets:
    type: array
    items:
      type: object
      required: [id, purpose, value_stored_in_repo, storage_backend, agent_access]
      properties:
        id:
          type: string
        purpose:
          type: string
        value_stored_in_repo:
          type: boolean
          const: false
        storage_backend:
          type: string
        runtime_env_name:
          type: [string, 'null']
        agent_access:
          type: string
        rotation:
          type: [string, 'null']
additionalProperties: false
'@
    'schemas/container-stack.schema.yaml' = @'
$schema: https://json-schema.org/draft/2020-12/schema
title: PC Agent Installer Container Stack
type: object
required: [detected_at, runtimes]
properties:
  detected_at:
    type: string
    format: date-time
  runtimes:
    type: object
    properties:
      docker:
        type: boolean
      docker_compose:
        type: boolean
      docker_swarm:
        type: boolean
      kubernetes:
        type: boolean
      podman:
        type: boolean
      nvidia_container_runtime:
        type: boolean
  compose_files:
    type: array
    items:
      type: string
  notes:
    type: array
    items:
      type: string
additionalProperties: true
'@
}

foreach ($entry in $schemas.GetEnumerator()) {
    Write-RepoFile -Path $entry.Key -Content $entry.Value
}

$privateExamples = @{
    'private.example/README.md' = @'
# Private Examples

Diese Dateien zeigen, wie private Operational-Repositories Secret-Referenzen dokumentieren können. Sie enthalten keine Secret-Werte.
'@
    'private.example/secret-references.example.yaml' = @'
secrets:
  - id: docker-registry-token
    purpose: Login zur privaten Container Registry
    value_stored_in_repo: false
    storage_backend: local-secret-store
    runtime_env_name: REGISTRY_TOKEN
    agent_access: requires_user_approval
    rotation: manual-90-days
'@
    'private.example/vault-references.example.yaml' = @'
vaults:
  - id: primary-vault
    purpose: Zentrale Secret-Ablage
    backend: password-manager-or-vault
    value_stored_in_repo: false
    access: user-mediated
'@
    'private.example/local-paths.example.yaml' = @'
local_paths:
  - id: runtime-env-file
    purpose: Nicht versionierte Laufzeitvariablen
    path: C:/path/to/local/.env
    value_stored_in_repo: false
    commit_allowed: false
'@
}

foreach ($entry in $privateExamples.GetEnumerator()) {
    Write-RepoFile -Path $entry.Key -Content $entry.Value
}

$examples = @{
    'examples/example-host.yaml' = @'
host_id: DESKTOP-ABC123
hostname: DESKTOP-ABC123
created_at: 2026-05-24T12:00:00+02:00
last_seen_at: 2026-05-24T12:00:00+02:00
repo:
  mode: operational
  visibility_checked: true
  visibility: private
  allowed_to_write_hosts: true
platform:
  os: windows
  environment: native
  version: "11"
  edition: "Pro"
  architecture: x64
linux:
  family: null
  distribution: null
  version_id: null
wsl:
  enabled: true
  distributions:
    - name: Ubuntu
      version: "2"
      default: true
hardware:
  profile: laptop
  vendor: null
  gpu_vendor: nvidia
  gpu_present: true
container:
  docker: true
  docker_compose: true
  docker_swarm: false
  kubernetes: false
  podman: false
  nvidia_container_runtime: true
template_paths_used:
  - Vorlage/common
  - Vorlage/windows/common
  - Vorlage/windows/windows-11
'@
    'examples/example-change-entry.md' = @'
# Änderung: Beispiel Firewall-Dokumentation

## Metadaten
- Datum: 2026-05-24
- Hostname: DESKTOP-ABC123
- Repo-Modus: operational
- Repo-Sichtbarkeit geprüft: ja
- Bereich: firewall
- Ebene: System
- Risiko: mittel
- Adminrechte erforderlich: ja
- Nutzerfreigabe erforderlich: ja
- Status: geplant

## Ausgangszustand
Noch nicht erfasst.

## Zielzustand
Firewall-Regel nachvollziehbar dokumentieren.

## Änderung
Keine Beispieländerung ausgeführt.

## Ort der Änderung
Windows Firewall.

## Ausgeführte Befehle
```powershell
Get-NetFirewallRule
```

## Betroffene Dateien
- hosts/DESKTOP-ABC123/baseline/firewall.md

## Prüfung
Regelliste wurde redigiert und abgelegt.

## Rollback
Nicht erforderlich, weil keine Änderung ausgeführt wurde.

## Risiken und Hinweise
Keine Klartext-Secrets in Logs übernehmen.
'@
    'examples/example-rollback.ps1' = @'
[CmdletBinding(SupportsShouldProcess = $true)]
param()

Write-Host "Beispiel-Rollback. Keine produktive Änderung enthalten."
'@
    'examples/example-rollback.sh' = @'
#!/usr/bin/env bash
set -euo pipefail

echo "Beispiel-Rollback. Keine produktive Änderung enthalten."
'@
    'examples/example-container-stack.yaml' = @'
detected_at: 2026-05-24T12:00:00+02:00
runtimes:
  docker: true
  docker_compose: true
  docker_swarm: false
  kubernetes: false
  podman: false
  nvidia_container_runtime: true
compose_files:
  - /srv/example/compose.yaml
notes:
  - Secrets nur referenzieren, nicht exportieren.
'@
    'examples/example-template-frontmatter.md' = @'
---
id: LINUX-UBUNTU-APT-001
title: Basispakete installieren
platform: linux
environment: native
family: debian
distribution: ubuntu
version: ">=22.04"
hardware_profile: generic
requires_admin: true
risk: mittel
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - linux/debian/ubuntu
depends_on:
  - linux/common/10-baseline
---

# Basispakete installieren

Diese Datei zeigt den Frontmatter-Aufbau einer ausführbaren Vorlage.
'@
}

foreach ($entry in $examples.GetEnumerator()) {
    Write-RepoFile -Path $entry.Key -Content $entry.Value
}

$templateFiles = [ordered]@{
    'Vorlage/common/00-agent-regeln.md' = 'Agent-Regeln'
    'Vorlage/common/01-repo-modus-erkennen.md' = 'Repo-Modus erkennen'
    'Vorlage/common/02-repo-visibility-prüfen.md' = 'Repo-Sichtbarkeit prüfen'
    'Vorlage/common/03-private-repo-erzwingen.md' = 'Private Repo-Nutzung erzwingen'
    'Vorlage/common/04-local-only-fallback.md' = 'Local-only-Fallback'
    'Vorlage/common/05-host-ordner-erzeugen.md' = 'Host-Ordner erzeugen'
    'Vorlage/common/06-baseline-pflicht.md' = 'Baseline-Pflicht'
    'Vorlage/common/07-dokumentationsstandard.md' = 'Dokumentationsstandard'
    'Vorlage/common/08-rollback-pflicht.md' = 'Rollback-Pflicht'
    'Vorlage/common/09-secrets-und-private-daten.md' = 'Secrets und private Daten'
    'Vorlage/common/10-admin-und-sudo-regeln.md' = 'Admin- und Sudo-Regeln'
    'Vorlage/common/11-validierung-und-tests.md' = 'Validierung und Tests'
    'Vorlage/common/12-git-commit-regeln.md' = 'Git-Commit-Regeln'
    'Vorlage/common/99-abschlussbericht.md' = 'Abschlussbericht'
    'Vorlage/windows/common/00-detect-windows.md' = 'Windows erkennen'
    'Vorlage/windows/common/10-baseline-system.md' = 'Windows System-Baseline'
    'Vorlage/windows/common/11-baseline-hardware.md' = 'Windows Hardware-Baseline'
    'Vorlage/windows/common/12-baseline-benutzer.md' = 'Windows Benutzer-Baseline'
    'Vorlage/windows/common/13-baseline-netzwerk.md' = 'Windows Netzwerk-Baseline'
    'Vorlage/windows/common/14-baseline-installierte-programme.md' = 'Installierte Programme erfassen'
    'Vorlage/windows/common/20-winget.md' = 'WinGet erfassen'
    'Vorlage/windows/common/21-powershell-module.md' = 'PowerShell-Module erfassen'
    'Vorlage/windows/common/30-firewall.md' = 'Windows Firewall erfassen'
    'Vorlage/windows/common/31-netzwerkprofile.md' = 'Windows Netzwerkprofile erfassen'
    'Vorlage/windows/common/40-env-variablen.md' = 'Windows Umgebungsvariablen erfassen'
    'Vorlage/windows/common/50-dienste.md' = 'Windows Dienste erfassen'
    'Vorlage/windows/common/60-registry.md' = 'Windows Registry dokumentieren'
    'Vorlage/windows/common/70-autostart.md' = 'Windows Autostart erfassen'
    'Vorlage/windows/common/80-dateisystem.md' = 'Windows Dateisystem erfassen'
    'Vorlage/windows/common/90-windows-features.md' = 'Windows Features erfassen'
    'Vorlage/windows/common/99-windows-report.md' = 'Windows Abschlussreport'
    'Vorlage/windows/windows-10/00-version-prüfen.md' = 'Windows 10 Version prüfen'
    'Vorlage/windows/windows-10/10-spezifische-features.md' = 'Windows 10 spezifische Features'
    'Vorlage/windows/windows-10/99-report.md' = 'Windows 10 Report'
    'Vorlage/windows/windows-11/00-version-prüfen.md' = 'Windows 11 Version prüfen'
    'Vorlage/windows/windows-11/10-spezifische-features.md' = 'Windows 11 spezifische Features'
    'Vorlage/windows/windows-11/20-winget-standardpakete.md' = 'Windows 11 WinGet-Standardpakete'
    'Vorlage/windows/windows-11/99-report.md' = 'Windows 11 Report'
    'Vorlage/windows/windows-server/00-version-prüfen.md' = 'Windows Server Version prüfen'
    'Vorlage/windows/windows-server/10-serverrollen.md' = 'Windows Serverrollen erfassen'
    'Vorlage/windows/windows-server/20-firewall-serverprofil.md' = 'Windows Server-Firewallprofil'
    'Vorlage/windows/windows-server/99-report.md' = 'Windows Server Report'
    'Vorlage/linux/common/00-detect-linux.md' = 'Linux erkennen'
    'Vorlage/linux/common/10-baseline-system.md' = 'Linux System-Baseline'
    'Vorlage/linux/common/11-baseline-hardware.md' = 'Linux Hardware-Baseline'
    'Vorlage/linux/common/12-baseline-benutzer-und-gruppen.md' = 'Linux Benutzer und Gruppen erfassen'
    'Vorlage/linux/common/13-baseline-netzwerk.md' = 'Linux Netzwerk-Baseline'
    'Vorlage/linux/common/14-baseline-paketmanager.md' = 'Linux Paketmanager erfassen'
    'Vorlage/linux/common/20-pakete.md' = 'Linux Pakete erfassen'
    'Vorlage/linux/common/30-firewall.md' = 'Linux Firewall erfassen'
    'Vorlage/linux/common/40-shell-env.md' = 'Linux Shell-Environment erfassen'
    'Vorlage/linux/common/50-systemd.md' = 'Systemd erfassen'
    'Vorlage/linux/common/60-ssh.md' = 'SSH erfassen'
    'Vorlage/linux/common/70-dateisystem.md' = 'Linux Dateisystem erfassen'
    'Vorlage/linux/common/80-kernel-und-treiber.md' = 'Kernel und Treiber erfassen'
    'Vorlage/linux/common/90-sudo-und-rechte.md' = 'Sudo und Rechte erfassen'
    'Vorlage/linux/common/99-linux-report.md' = 'Linux Report'
    'Vorlage/linux/debian/common/00-detect-debian-family.md' = 'Debian-Familie erkennen'
    'Vorlage/linux/debian/common/10-apt-baseline.md' = 'APT Baseline'
    'Vorlage/linux/debian/common/20-apt-sources.md' = 'APT Sources erfassen'
    'Vorlage/linux/debian/common/30-apt-packages.md' = 'APT Pakete erfassen'
    'Vorlage/linux/debian/common/40-ufw-oder-nftables.md' = 'UFW oder nftables erfassen'
    'Vorlage/linux/debian/common/99-report.md' = 'Debian-Familie Report'
    'Vorlage/linux/debian/debian/00-detect-debian.md' = 'Debian erkennen'
    'Vorlage/linux/debian/debian/10-debian-pakete.md' = 'Debian Pakete erfassen'
    'Vorlage/linux/debian/debian/99-report.md' = 'Debian Report'
    'Vorlage/linux/debian/ubuntu/00-detect-ubuntu.md' = 'Ubuntu erkennen'
    'Vorlage/linux/debian/ubuntu/10-ubuntu-pakete.md' = 'Ubuntu Pakete erfassen'
    'Vorlage/linux/debian/ubuntu/20-snap.md' = 'Snap erfassen'
    'Vorlage/linux/debian/ubuntu/30-ppa-policy.md' = 'PPA Policy erfassen'
    'Vorlage/linux/debian/ubuntu/99-report.md' = 'Ubuntu Report'
    'Vorlage/linux/rhel/common/00-detect-rhel-family.md' = 'RHEL-Familie erkennen'
    'Vorlage/linux/rhel/common/10-dnf-baseline.md' = 'DNF Baseline'
    'Vorlage/linux/rhel/common/20-repositories.md' = 'RHEL Repositories erfassen'
    'Vorlage/linux/rhel/common/30-firewalld.md' = 'Firewalld erfassen'
    'Vorlage/linux/rhel/common/99-report.md' = 'RHEL-Familie Report'
    'Vorlage/linux/rhel/fedora/00-detect-fedora.md' = 'Fedora erkennen'
    'Vorlage/linux/rhel/fedora/10-fedora-pakete.md' = 'Fedora Pakete erfassen'
    'Vorlage/linux/rhel/fedora/99-report.md' = 'Fedora Report'
    'Vorlage/linux/rhel/rocky/00-detect-rocky.md' = 'Rocky Linux erkennen'
    'Vorlage/linux/rhel/rocky/99-report.md' = 'Rocky Linux Report'
    'Vorlage/linux/rhel/almalinux/00-detect-almalinux.md' = 'AlmaLinux erkennen'
    'Vorlage/linux/rhel/almalinux/99-report.md' = 'AlmaLinux Report'
    'Vorlage/linux/arch/common/00-detect-arch-family.md' = 'Arch-Familie erkennen'
    'Vorlage/linux/arch/common/10-pacman-baseline.md' = 'Pacman Baseline'
    'Vorlage/linux/arch/common/20-pacman-packages.md' = 'Pacman Pakete erfassen'
    'Vorlage/linux/arch/common/30-aur-policy.md' = 'AUR Policy erfassen'
    'Vorlage/linux/arch/common/99-report.md' = 'Arch-Familie Report'
    'Vorlage/linux/arch/archlinux/00-detect-archlinux.md' = 'Arch Linux erkennen'
    'Vorlage/linux/arch/archlinux/99-report.md' = 'Arch Linux Report'
    'Vorlage/linux/nvidia/common/00-detect-nvidia-hardware.md' = 'NVIDIA Hardware erkennen'
    'Vorlage/linux/nvidia/common/10-nvidia-smi-baseline.md' = 'nvidia-smi Baseline'
    'Vorlage/linux/nvidia/common/20-cuda-baseline.md' = 'CUDA Baseline'
    'Vorlage/linux/nvidia/common/30-treiber-baseline.md' = 'NVIDIA Treiber Baseline'
    'Vorlage/linux/nvidia/common/99-report.md' = 'NVIDIA Report'
    'Vorlage/linux/nvidia/dgx-os/00-detect-dgx-os.md' = 'DGX OS erkennen'
    'Vorlage/linux/nvidia/dgx-os/10-dgx-os-baseline.md' = 'DGX OS Baseline'
    'Vorlage/linux/nvidia/dgx-os/99-report.md' = 'DGX OS Report'
    'Vorlage/linux/nvidia/dgx-spark/00-detect-dgx-spark.md' = 'DGX Spark erkennen'
    'Vorlage/linux/nvidia/dgx-spark/10-dgx-spark-baseline.md' = 'DGX Spark Baseline'
    'Vorlage/linux/nvidia/dgx-spark/20-gpu-container-runtime.md' = 'DGX Spark GPU Container Runtime'
    'Vorlage/linux/nvidia/dgx-spark/99-report.md' = 'DGX Spark Report'
    'Vorlage/wsl/common/00-detect-wsl.md' = 'WSL erkennen'
    'Vorlage/wsl/common/10-wsl-baseline.md' = 'WSL Baseline'
    'Vorlage/wsl/common/20-wsl-version.md' = 'WSL Version erfassen'
    'Vorlage/wsl/common/30-wsl-config.md' = 'WSL Konfiguration erfassen'
    'Vorlage/wsl/common/40-windows-integration.md' = 'WSL Windows-Integration erfassen'
    'Vorlage/wsl/common/50-networking.md' = 'WSL Networking erfassen'
    'Vorlage/wsl/common/60-filesystem-mounts.md' = 'WSL Filesystem Mounts erfassen'
    'Vorlage/wsl/common/99-wsl-report.md' = 'WSL Report'
    'Vorlage/wsl/ubuntu/00-detect-wsl-ubuntu.md' = 'Ubuntu WSL erkennen'
    'Vorlage/wsl/ubuntu/10-apt-baseline.md' = 'Ubuntu WSL APT Baseline'
    'Vorlage/wsl/ubuntu/99-report.md' = 'Ubuntu WSL Report'
    'Vorlage/wsl/debian/00-detect-wsl-debian.md' = 'Debian WSL erkennen'
    'Vorlage/wsl/debian/10-apt-baseline.md' = 'Debian WSL APT Baseline'
    'Vorlage/wsl/debian/99-report.md' = 'Debian WSL Report'
    'Vorlage/wsl/kali/00-detect-wsl-kali.md' = 'Kali WSL erkennen'
    'Vorlage/wsl/kali/99-report.md' = 'Kali WSL Report'
    'Vorlage/wsl/arch/00-detect-wsl-arch.md' = 'Arch WSL erkennen'
    'Vorlage/wsl/arch/99-report.md' = 'Arch WSL Report'
    'Vorlage/container/common/00-detect-container-stack.md' = 'Container-Stack erkennen'
    'Vorlage/container/common/10-container-baseline.md' = 'Container Baseline'
    'Vorlage/container/common/20-container-security.md' = 'Container Security erfassen'
    'Vorlage/container/common/30-images.md' = 'Container Images erfassen'
    'Vorlage/container/common/31-containers.md' = 'Container erfassen'
    'Vorlage/container/common/32-networks.md' = 'Container Netzwerke erfassen'
    'Vorlage/container/common/33-volumes.md' = 'Container Volumes erfassen'
    'Vorlage/container/common/40-ports-und-exposure.md' = 'Container Ports und Exposure erfassen'
    'Vorlage/container/common/50-secrets-policy.md' = 'Container Secrets Policy'
    'Vorlage/container/common/99-container-report.md' = 'Container Report'
    'Vorlage/container/runtime/docker/00-detect-docker.md' = 'Docker erkennen'
    'Vorlage/container/runtime/docker/10-docker-engine-baseline.md' = 'Docker Engine Baseline'
    'Vorlage/container/runtime/docker/20-docker-daemon-json.md' = 'Docker daemon.json erfassen'
    'Vorlage/container/runtime/docker/30-docker-rootless.md' = 'Docker Rootless erfassen'
    'Vorlage/container/runtime/docker/40-docker-networks.md' = 'Docker Netzwerke erfassen'
    'Vorlage/container/runtime/docker/50-docker-volumes.md' = 'Docker Volumes erfassen'
    'Vorlage/container/runtime/docker/60-docker-images.md' = 'Docker Images erfassen'
    'Vorlage/container/runtime/docker/99-docker-report.md' = 'Docker Report'
    'Vorlage/container/runtime/podman/00-detect-podman.md' = 'Podman erkennen'
    'Vorlage/container/runtime/podman/10-podman-baseline.md' = 'Podman Baseline'
    'Vorlage/container/runtime/podman/20-podman-rootless.md' = 'Podman Rootless erfassen'
    'Vorlage/container/runtime/podman/30-podman-systemd.md' = 'Podman Systemd erfassen'
    'Vorlage/container/runtime/podman/40-podman-pods.md' = 'Podman Pods erfassen'
    'Vorlage/container/runtime/podman/50-podman-networks.md' = 'Podman Netzwerke erfassen'
    'Vorlage/container/runtime/podman/99-podman-report.md' = 'Podman Report'
    'Vorlage/container/compose/docker-compose/00-detect-compose.md' = 'Docker Compose erkennen'
    'Vorlage/container/compose/docker-compose/10-compose-baseline.md' = 'Docker Compose Baseline'
    'Vorlage/container/compose/docker-compose/20-compose-files.md' = 'Compose-Dateien erfassen'
    'Vorlage/container/compose/docker-compose/30-compose-projects.md' = 'Compose-Projekte erfassen'
    'Vorlage/container/compose/docker-compose/40-compose-env-files.md' = 'Compose Env-Dateien erfassen'
    'Vorlage/container/compose/docker-compose/50-compose-secrets.md' = 'Compose Secrets dokumentieren'
    'Vorlage/container/compose/docker-compose/99-compose-report.md' = 'Compose Report'
    'Vorlage/container/orchestration/docker-swarm/00-detect-swarm.md' = 'Docker Swarm erkennen'
    'Vorlage/container/orchestration/docker-swarm/10-swarm-baseline.md' = 'Docker Swarm Baseline'
    'Vorlage/container/orchestration/docker-swarm/20-swarm-nodes.md' = 'Swarm Nodes erfassen'
    'Vorlage/container/orchestration/docker-swarm/30-swarm-services.md' = 'Swarm Services erfassen'
    'Vorlage/container/orchestration/docker-swarm/40-swarm-stacks.md' = 'Swarm Stacks erfassen'
    'Vorlage/container/orchestration/docker-swarm/50-swarm-secrets.md' = 'Swarm Secrets dokumentieren'
    'Vorlage/container/orchestration/docker-swarm/99-swarm-report.md' = 'Swarm Report'
    'Vorlage/container/orchestration/kubernetes/00-detect-kubernetes.md' = 'Kubernetes erkennen'
    'Vorlage/container/orchestration/kubernetes/10-kubeconfig-contexts.md' = 'Kubeconfig-Kontexte erfassen'
    'Vorlage/container/orchestration/kubernetes/20-cluster-baseline.md' = 'Kubernetes Cluster Baseline'
    'Vorlage/container/orchestration/kubernetes/30-namespaces.md' = 'Kubernetes Namespaces erfassen'
    'Vorlage/container/orchestration/kubernetes/40-workloads.md' = 'Kubernetes Workloads erfassen'
    'Vorlage/container/orchestration/kubernetes/50-services-ingress.md' = 'Kubernetes Services und Ingress erfassen'
    'Vorlage/container/orchestration/kubernetes/60-storage.md' = 'Kubernetes Storage erfassen'
    'Vorlage/container/orchestration/kubernetes/70-rbac.md' = 'Kubernetes RBAC erfassen'
    'Vorlage/container/orchestration/kubernetes/80-secrets.md' = 'Kubernetes Secrets referenzieren'
    'Vorlage/container/orchestration/kubernetes/90-declarative-apply.md' = 'Kubernetes deklarativ anwenden'
    'Vorlage/container/orchestration/kubernetes/99-kubernetes-report.md' = 'Kubernetes Report'
    'Vorlage/container/hardware/nvidia/00-detect-nvidia-container-runtime.md' = 'NVIDIA Container Runtime erkennen'
    'Vorlage/container/hardware/nvidia/10-nvidia-container-toolkit.md' = 'NVIDIA Container Toolkit erfassen'
    'Vorlage/container/hardware/nvidia/20-docker-gpu-runtime.md' = 'Docker GPU Runtime erfassen'
    'Vorlage/container/hardware/nvidia/30-podman-gpu-runtime.md' = 'Podman GPU Runtime erfassen'
    'Vorlage/container/hardware/nvidia/40-kubernetes-gpu-runtime.md' = 'Kubernetes GPU Runtime erfassen'
    'Vorlage/container/hardware/nvidia/99-nvidia-container-report.md' = 'NVIDIA Container Report'
    'Vorlage/profiles/laptop/00-detect-laptop.md' = 'Laptop-Profil erkennen'
    'Vorlage/profiles/laptop/10-power-management.md' = 'Laptop Power Management erfassen'
    'Vorlage/profiles/laptop/20-wifi-bluetooth.md' = 'Laptop WLAN und Bluetooth erfassen'
    'Vorlage/profiles/laptop/99-report.md' = 'Laptop Report'
    'Vorlage/profiles/workstation/00-detect-workstation.md' = 'Workstation-Profil erkennen'
    'Vorlage/profiles/workstation/10-development-tools.md' = 'Workstation Entwicklungstools erfassen'
    'Vorlage/profiles/workstation/99-report.md' = 'Workstation Report'
    'Vorlage/profiles/server/00-detect-server.md' = 'Server-Profil erkennen'
    'Vorlage/profiles/server/10-server-baseline.md' = 'Server Baseline'
    'Vorlage/profiles/server/99-report.md' = 'Server Report'
    'Vorlage/profiles/gpu-workstation/00-detect-gpu-workstation.md' = 'GPU-Workstation-Profil erkennen'
    'Vorlage/profiles/gpu-workstation/10-gpu-baseline.md' = 'GPU Baseline'
    'Vorlage/profiles/gpu-workstation/99-report.md' = 'GPU-Workstation Report'
}

foreach ($entry in $templateFiles.GetEnumerator()) {
    Write-RepoFile -Path $entry.Key -Content (New-TemplateContent -Path $entry.Key -Title $entry.Value)
}

$commonPs = @'
Set-StrictMode -Version Latest

try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    $OutputEncoding = [Console]::OutputEncoding
} catch {}

function Get-AgentRepoRoot {
    param([string]$StartPath = (Get-Location).Path)
    $current = Resolve-Path $StartPath
    while ($current) {
        if (Test-Path -LiteralPath (Join-Path $current '.git')) { return $current.Path }
        $parent = Split-Path -Parent $current.Path
        if (-not $parent -or $parent -eq $current.Path) { break }
        $current = Resolve-Path $parent
    }
    return (Resolve-Path $StartPath).Path
}

function Write-AgentUtf8 {
    param([string]$Path, [string]$Content)
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $encoding = if ([System.IO.Path]::GetExtension($Path) -ieq '.ps1') {
        [System.Text.UTF8Encoding]::new($true)
    } else {
        [System.Text.UTF8Encoding]::new($false)
    }
    [System.IO.File]::WriteAllText($Path, ($Content.TrimEnd() + "`n"), $encoding)
}

function Get-AgentRepoModeConfig {
    param([string]$RepoRoot)
    $configPath = Join-Path $RepoRoot 'repo-mode.yaml'
    $mode = 'template'
    $visibilityRequired = 'public'
    if (Test-Path -LiteralPath $configPath) {
        foreach ($line in Get-Content -LiteralPath $configPath) {
            if ($line -match '^\s*repo_mode:\s*["'']?([^"''#\s]+)') { $mode = $Matches[1] }
            if ($line -match '^\s*visibility_required:\s*["'']?([^"''#\s]+)') { $visibilityRequired = $Matches[1] }
        }
    }
    [pscustomobject]@{
        repo_mode = $mode
        visibility_required = $visibilityRequired
    }
}

function Get-AgentRepoGuard {
    param([string]$RepoRoot)
    $config = Get-AgentRepoModeConfig -RepoRoot $RepoRoot
    $remoteLines = @()
    try {
        $remoteLines = @(git -C $RepoRoot remote -v 2>$null)
    } catch {
        $remoteLines = @()
    }
    $remoteUrls = @($remoteLines | ForEach-Object {
        if ($_ -match '\s+([^\s]+)\s+\((fetch|push)\)$') { $Matches[1] }
    } | Sort-Object -Unique)

    $visibility = 'unknown'
    $visibilityChecked = $false
    $repoName = $null
    $isPrivate = $false

    if ($remoteUrls.Count -eq 0) {
        $visibility = 'no_remote'
        $visibilityChecked = $true
    } elseif (Get-Command gh -ErrorAction SilentlyContinue) {
        try {
            Push-Location $RepoRoot
            $raw = gh repo view --json isPrivate,visibility,nameWithOwner 2>$null
            Pop-Location
            if ($raw) {
                $gh = $raw | ConvertFrom-Json
                $visibility = ([string]$gh.visibility).ToLowerInvariant()
                $visibilityChecked = $true
                $repoName = $gh.nameWithOwner
                $isPrivate = [bool]$gh.isPrivate
            }
        } catch {
            try { Pop-Location } catch {}
        }
    }

    if (-not $visibilityChecked -and $remoteUrls.Count -gt 0 -and $env:GITHUB_TOKEN) {
        $firstRemote = [string]$remoteUrls[0]
        $ownerRepo = $null
        if ($firstRemote -match 'github\.com[:/](?<repo>[^/]+/.+?)(?:\.git)?$') {
            $ownerRepo = $Matches['repo'] -replace '\.git$', ''
        }
        if ($ownerRepo) {
            try {
                $headers = @{
                    Accept = 'application/vnd.github+json'
                    Authorization = "Bearer $env:GITHUB_TOKEN"
                    'X-GitHub-Api-Version' = '2022-11-28'
                }
                $api = Invoke-RestMethod -Uri "https://api.github.com/repos/$ownerRepo" -Headers $headers -Method Get
                $isPrivate = [bool]$api.private
                $visibility = if ($isPrivate) { 'private' } else { 'public' }
                $visibilityChecked = $true
                $repoName = $api.full_name
            } catch {}
        }
    }

    $allowed = $false
    $pushAllowed = $false
    if ($config.repo_mode -eq 'operational' -and $visibilityChecked -and ($isPrivate -or $visibility -eq 'private')) {
        $allowed = $true
        $pushAllowed = $true
    } elseif ($config.repo_mode -eq 'local-only' -and $visibilityChecked -and $visibility -eq 'no_remote') {
        $allowed = $true
    }

    if ($config.repo_mode -eq 'template') {
        $allowed = $false
        $pushAllowed = $false
    }

    [pscustomobject]@{
        repo_mode = $config.repo_mode
        visibility_required = $config.visibility_required
        visibility_checked = $visibilityChecked
        visibility = $visibility
        github_repo = $repoName
        remotes = $remoteUrls
        allowed_to_write_hosts = $allowed
        allowed_to_document_sensitive_context = $allowed
        allowed_to_store_plaintext_secrets = $false
        push_allowed = $pushAllowed
    }
}

function Assert-AgentHostWriteAllowed {
    param([string]$RepoRoot)
    $guard = Get-AgentRepoGuard -RepoRoot $RepoRoot
    if ($guard.allowed_to_write_hosts) { return $guard }
    $message = @"
WARNUNG:
Dieses Repository ist nicht als sicherer Hostdaten-Zielort bestätigt.
Modus: $($guard.repo_mode)
Sichtbarkeit: $($guard.visibility)
Sichtbarkeit geprüft: $($guard.visibility_checked)

Hostdaten, Infrastrukturinformationen, Secrets, Tokens, private Pfade und sicherheitskritische Konfigurationen werden hier nicht dokumentiert.

Sichere Optionen:
1. Private GitHub-Kopie aus Template erzeugen.
2. Lokales Git-Repo ohne Remote verwenden und local-only aktivieren.
3. Abbrechen.
"@
    Write-Error $message
    exit 10
}

function ConvertTo-AgentYamlScalar {
    param($Value)
    if ($null -eq $Value -or $Value -eq '') { return 'null' }
    $text = [string]$Value
    $escaped = $text.Replace('\', '\\').Replace('"', '\"')
    return '"' + $escaped + '"'
}

function Protect-AgentSecretText {
    param([string]$Text)
    if ($null -eq $Text) { return $null }
    $patterns = @(
        '(?i)(password|passwd|pwd|secret|token|api[_-]?key|credential|private[_-]?key)(\s*[:=]\s*)(\S+)',
        '(?i)(Authorization:\s*Bearer\s+)(\S+)',
        '(?i)(BEGIN\s+(RSA|OPENSSH|EC|DSA)?\s*PRIVATE\s+KEY)[\s\S]*?(END\s+(RSA|OPENSSH|EC|DSA)?\s*PRIVATE\s+KEY)'
    )
    $result = $Text
    foreach ($pattern in $patterns) {
        $result = [regex]::Replace($result, $pattern, {
            param($m)
            if ($m.Groups.Count -ge 4) { return $m.Groups[1].Value + $m.Groups[2].Value + '[REDACTED]' }
            return '[REDACTED-PRIVATE-KEY]'
        })
    }
    return $result
}

function New-AgentHostTree {
    param([string]$RepoRoot, [string]$HostName)
    $hostRoot = Join-Path $RepoRoot (Join-Path 'hosts' $HostName)
    $dirs = @(
        'baseline/raw', 'changes', 'rollback', 'security', 'container/docker',
        'container/compose', 'container/swarm', 'container/kubernetes',
        'container/podman', 'logs', 'state'
    )
    foreach ($dir in $dirs) {
        New-Item -ItemType Directory -Path (Join-Path $hostRoot $dir) -Force | Out-Null
    }
    return $hostRoot
}
'@

Write-RepoFile -Path 'scripts/powershell/AgentInstaller.Common.ps1' -Content $commonPs

$detectRepoPs = @'
[CmdletBinding()]
param([string]$RepoRoot)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

. (Join-Path $PSScriptRoot '..\powershell\AgentInstaller.Common.ps1')
Get-AgentRepoGuard -RepoRoot $RepoRoot | ConvertTo-Json -Depth 5
'@
Write-RepoFile -Path 'scripts/common/detect-repo-mode.ps1' -Content $detectRepoPs

$assertRepoPs = @'
[CmdletBinding()]
param([string]$RepoRoot)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

. (Join-Path $PSScriptRoot '..\powershell\AgentInstaller.Common.ps1')
$guard = Assert-AgentHostWriteAllowed -RepoRoot $RepoRoot
$guard | ConvertTo-Json -Depth 5
'@
Write-RepoFile -Path 'scripts/common/assert-private-repo.ps1' -Content $assertRepoPs

$createPrivatePs = @'
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Template,
    [Parameter(Mandatory = $true)][string]$Destination
)

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'GitHub CLI gh ist nicht verfügbar.'
}

gh repo create $Destination --template $Template --private --clone
'@
Write-RepoFile -Path 'scripts/common/create-private-copy.ps1' -Content $createPrivatePs

$enableLocalPs = @'
[CmdletBinding()]
param([string]$RepoRoot)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$remotes = @(git -C $RepoRoot remote -v 2>$null)
if ($remotes.Count -gt 0) {
    throw 'Local-only-Modus wird nicht aktiviert, solange Git-Remotes vorhanden sind. Remote nicht automatisch entfernen.'
}

$content = @"
repo_mode: local-only
visibility_required: no_remote
allowed_to_write_hosts: true
allowed_to_document_sensitive_context: true
allowed_to_store_plaintext_secrets: false
"@
[System.IO.File]::WriteAllText((Join-Path $RepoRoot 'repo-mode.yaml'), ($content.TrimEnd() + "`n"), [System.Text.UTF8Encoding]::new($false))
Write-Host 'Local-only-Modus aktiviert. Push bleibt verboten, bis ein privater Remote geprüft wurde.'
'@
Write-RepoFile -Path 'scripts/common/enable-local-only-mode.ps1' -Content $enableLocalPs

$redactPs = @'
[CmdletBinding()]
param([Parameter(ValueFromPipeline = $true)][string]$InputObject)

begin {
    . (Join-Path $PSScriptRoot '..\powershell\AgentInstaller.Common.ps1')
}
process {
    Protect-AgentSecretText -Text $InputObject
}
'@
Write-RepoFile -Path 'scripts/common/redact-sensitive-output.ps1' -Content $redactPs

$detectPlatformPs = @'
[CmdletBinding()]
param()

$isWindowsHost = $IsWindows -or $env:OS -eq 'Windows_NT'
$result = [ordered]@{
    detected_at = (Get-Date).ToString('o')
    os = if ($isWindowsHost) { 'windows' } else { 'unknown' }
    environment = 'native'
    hostname = [System.Net.Dns]::GetHostName()
    architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
    powershell = $PSVersionTable.PSVersion.ToString()
    admin = $false
    windows = $null
    wsl = $null
    hardware_profile = 'unknown'
}

if ($isWindowsHost) {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $result.admin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $cs = Get-CimInstance Win32_ComputerSystem
        $chassis = Get-CimInstance Win32_SystemEnclosure
        $isLaptop = @($chassis.ChassisTypes) | Where-Object { $_ -in @(8, 9, 10, 14, 30, 31, 32) }
        $result.windows = [ordered]@{
            caption = $os.Caption
            version = $os.Version
            build_number = $os.BuildNumber
            edition = $os.OperatingSystemSKU
            manufacturer = $cs.Manufacturer
            model = $cs.Model
        }
        $result.hardware_profile = if ($isLaptop) { 'laptop' } else { 'workstation' }
    } catch {}
    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        $wslRaw = ((& wsl.exe --list --verbose 2>$null) -join "`n").Replace([string][char]0, '')
        $result.wsl = $wslRaw
    }
}

$result | ConvertTo-Json -Depth 6
'@
Write-RepoFile -Path 'scripts/powershell/detect-platform.ps1' -Content $detectPlatformPs

$detectHostPs = @'
[CmdletBinding()]
param()

& (Join-Path $PSScriptRoot 'detect-platform.ps1')
'@
Write-RepoFile -Path 'scripts/powershell/detect-host.ps1' -Content $detectHostPs

$collectBaselinePs = @'
[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$HostName = $env:COMPUTERNAME
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

. (Join-Path $PSScriptRoot 'AgentInstaller.Common.ps1')
$guard = Assert-AgentHostWriteAllowed -RepoRoot $RepoRoot
if (-not $HostName) { $HostName = [System.Net.Dns]::GetHostName() }
$hostRoot = New-AgentHostTree -RepoRoot $RepoRoot -HostName $HostName
$now = (Get-Date).ToString('o')
$platform = & (Join-Path $PSScriptRoot 'detect-platform.ps1') | ConvertFrom-Json

$hostYaml = @"
host_id: $HostName
hostname: $HostName
created_at: $now
last_seen_at: $now
repo:
  mode: $($guard.repo_mode)
  visibility_checked: $($guard.visibility_checked.ToString().ToLowerInvariant())
  visibility: $($guard.visibility)
  allowed_to_write_hosts: $($guard.allowed_to_write_hosts.ToString().ToLowerInvariant())
platform:
  os: $($platform.os)
  environment: $($platform.environment)
  version: $(ConvertTo-AgentYamlScalar $platform.windows.version)
  edition: $(ConvertTo-AgentYamlScalar $platform.windows.caption)
  architecture: $(ConvertTo-AgentYamlScalar $platform.architecture)
hardware:
  profile: $(ConvertTo-AgentYamlScalar $platform.hardware_profile)
container:
  docker: $(([bool](Get-Command docker -ErrorAction SilentlyContinue)).ToString().ToLowerInvariant())
  docker_compose: false
  docker_swarm: false
  kubernetes: $(([bool](Get-Command kubectl -ErrorAction SilentlyContinue)).ToString().ToLowerInvariant())
  podman: $(([bool](Get-Command podman -ErrorAction SilentlyContinue)).ToString().ToLowerInvariant())
  nvidia_container_runtime: $(([bool](Get-Command nvidia-ctk -ErrorAction SilentlyContinue)).ToString().ToLowerInvariant())
template_paths_used:
  - Vorlage/common
  - Vorlage/windows/common
"@
Write-AgentUtf8 -Path (Join-Path $hostRoot 'host.yaml') -Content $hostYaml

$system = @"
# System-Baseline

- Erfasst am: $now
- Hostname: $HostName
- Repo-Modus: $($guard.repo_mode)
- Repo-Sichtbarkeit: $($guard.visibility)
- Betriebssystem: $($platform.os)
- Architektur: $($platform.architecture)
- PowerShell: $($platform.powershell)
- Admin: $($platform.admin)
"@
Write-AgentUtf8 -Path (Join-Path $hostRoot 'baseline/system.md') -Content $system
Write-AgentUtf8 -Path (Join-Path $hostRoot 'baseline/hardware.md') -Content "# Hardware-Baseline`n`nProfil: $($platform.hardware_profile)"
Write-AgentUtf8 -Path (Join-Path $hostRoot 'baseline/security.md') -Content "# Sicherheits-Baseline`n`nKlartext-Secrets wurden nicht erfasst."
Write-AgentUtf8 -Path (Join-Path $hostRoot 'security/secret-references.md') -Content "# Secret-Referenzen`n`nNoch keine Secret-Referenzen dokumentiert."
Write-AgentUtf8 -Path (Join-Path $hostRoot 'security/secret-references.yaml') -Content "secrets: []"
Write-AgentUtf8 -Path (Join-Path $hostRoot 'state/last-run.yaml') -Content "last_run_at: $now`nstatus: baseline_collected"

try { systeminfo | Out-File -FilePath (Join-Path $hostRoot 'baseline/raw/systeminfo.txt') -Encoding utf8 } catch {}
try { Get-Service -ErrorAction SilentlyContinue | Sort-Object Name | Out-String | Out-File -FilePath (Join-Path $hostRoot 'baseline/services.md') -Encoding utf8 } catch {}
try { Get-NetIPConfiguration | Out-String | Out-File -FilePath (Join-Path $hostRoot 'baseline/network.md') -Encoding utf8 } catch {}
try { Get-NetFirewallRule | Select-Object DisplayName,Enabled,Direction,Action,Profile | Out-String | Out-File -FilePath (Join-Path $hostRoot 'baseline/firewall.md') -Encoding utf8 } catch {}
try { Get-ChildItem Env: | Sort-Object Name | ForEach-Object { "$($_.Name)=[REDACTED]" } | Out-File -FilePath (Join-Path $hostRoot 'baseline/environment.md') -Encoding utf8 } catch {}

Write-Host "Baseline erzeugt: $hostRoot"
'@
Write-RepoFile -Path 'scripts/powershell/collect-baseline.ps1' -Content $collectBaselinePs

$collectorPsMap = @{
    'scripts/powershell/collect-windows-firewall.ps1' = 'Get-NetFirewallRule | Select-Object DisplayName,Enabled,Direction,Action,Profile'
    'scripts/powershell/collect-windows-env.ps1' = 'Get-ChildItem Env: | Sort-Object Name | ForEach-Object { "$($_.Name)=[REDACTED]" }'
    'scripts/powershell/collect-winget.ps1' = 'if (Get-Command winget -ErrorAction SilentlyContinue) { winget export --accept-source-agreements --output "$OutputPath" } else { "winget nicht verfügbar" }'
}

foreach ($item in $collectorPsMap.GetEnumerator()) {
    $content = @"
[CmdletBinding()]
param([string]`$OutputPath)

if (-not `$OutputPath) { `$OutputPath = Join-Path (Get-Location) 'collector-output.txt' }
`$collectorOutput = & {
    $($item.Value)
}
`$collectorOutput | Out-File -FilePath `$OutputPath -Encoding utf8
Write-Host "Erfasst: `$OutputPath"
"@
    Write-RepoFile -Path $item.Key -Content $content
}

$writeChangePs = @'
[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$HostName = $env:COMPUTERNAME,
    [Parameter(Mandatory = $true)][string]$Area,
    [Parameter(Mandatory = $true)][string]$Summary,
    [ValidateSet('User','System','Repo','Container','Cluster')][string]$Layer = 'System',
    [ValidateSet('niedrig','mittel','hoch')][string]$Risk = 'niedrig',
    [ValidateSet('geplant','ausgeführt','fehlgeschlagen','rückgängig gemacht')][string]$Status = 'geplant'
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

. (Join-Path $PSScriptRoot 'AgentInstaller.Common.ps1')
$guard = Assert-AgentHostWriteAllowed -RepoRoot $RepoRoot
$hostRoot = New-AgentHostTree -RepoRoot $RepoRoot -HostName $HostName
$date = Get-Date -Format 'yyyy-MM-dd'
$existing = @(Get-ChildItem -LiteralPath (Join-Path $hostRoot 'changes') -Filter "$date*.md" -ErrorAction SilentlyContinue)
$seq = ('{0:0000}' -f ($existing.Count + 1))
$slug = ($Area.ToLowerInvariant() -replace '[^a-z0-9]+','-').Trim('-')
$path = Join-Path $hostRoot "changes/$date`_$seq`_$slug.md"
$content = @"
# Änderung: $Summary

## Metadaten
- Datum: $date
- Hostname: $HostName
- Repo-Modus: $($guard.repo_mode)
- Repo-Sichtbarkeit geprüft: $($guard.visibility_checked)
- Bereich: $Area
- Ebene: $Layer
- Risiko: $Risk
- Adminrechte erforderlich: nein
- Nutzerfreigabe erforderlich: nein
- Status: $Status

## Ausgangszustand
Noch zu dokumentieren.

## Zielzustand
Noch zu dokumentieren.

## Änderung
Noch nicht ausgeführt.

## Ort der Änderung
Noch zu dokumentieren.

## Ausgeführte Befehle
````powershell
# Noch keine Befehle dokumentiert.
````

## Betroffene Dateien
- Noch zu dokumentieren.

## Prüfung
Noch zu dokumentieren.

## Rollback
Noch zu dokumentieren.

## Risiken und Hinweise
Keine Klartext-Secrets aufnehmen.
"@
Write-AgentUtf8 -Path $path -Content $content
Write-Host "Change-Eintrag erzeugt: $path"
'@
Write-RepoFile -Path 'scripts/powershell/write-change-entry.ps1' -Content $writeChangePs

$stepPs = @{
    'scripts/powershell/apply-step.ps1' = 'apply'
    'scripts/powershell/validate-step.ps1' = 'validate'
    'scripts/powershell/rollback-step.ps1' = 'rollback'
}
foreach ($item in $stepPs.GetEnumerator()) {
    $requires = if ($item.Value -in @('apply','rollback')) { '$true' } else { '$false' }
    $content = @"
[CmdletBinding()]
param(
    [Parameter(Mandatory = `$true)][string]`$Command,
    [switch]`$Approved
)

`$requiresApproval = $requires
if (`$requiresApproval -and -not `$Approved) {
    throw '$($item.Value)-step benötigt explizite Freigabe per -Approved.'
}
Write-Host 'Führe $($item.Value)-step aus:'
Write-Host `$Command
Invoke-Expression `$Command
"@
    Write-RepoFile -Path $item.Key -Content $content
}

$commonSh = @'
#!/usr/bin/env bash
set -euo pipefail

agent_repo_root() {
  local start="${1:-$PWD}"
  local current
  current="$(cd "$start" && pwd)"
  while [[ "$current" != "/" ]]; do
    if [[ -d "$current/.git" ]]; then
      printf '%s\n' "$current"
      return 0
    fi
    current="$(dirname "$current")"
  done
  printf '%s\n' "$start"
}

agent_repo_mode() {
  local root="$1"
  if [[ -f "$root/repo-mode.yaml" ]]; then
    awk -F: '/^[[:space:]]*repo_mode:/ {gsub(/[ "]/,"",$2); print $2; found=1} END {if (!found) print "template"}' "$root/repo-mode.yaml"
  else
    printf 'template\n'
  fi
}

agent_visibility_required() {
  local root="$1"
  if [[ -f "$root/repo-mode.yaml" ]]; then
    awk -F: '/^[[:space:]]*visibility_required:/ {gsub(/[ "]/,"",$2); print $2; found=1} END {if (!found) print "public"}' "$root/repo-mode.yaml"
  else
    printf 'public\n'
  fi
}

agent_detect_repo_guard() {
  local root="$1"
  local mode visibility_required remote_count visibility visibility_checked is_private push_allowed allowed gh_json repo_name
  mode="$(agent_repo_mode "$root")"
  visibility_required="$(agent_visibility_required "$root")"
  remote_count="$(git -C "$root" remote 2>/dev/null | wc -l | tr -d ' ')"
  visibility="unknown"
  visibility_checked=false
  is_private=false
  repo_name=""
  if [[ "$remote_count" == "0" ]]; then
    visibility="no_remote"
    visibility_checked=true
  elif command -v gh >/dev/null 2>&1; then
    if gh_json="$(cd "$root" && gh repo view --json isPrivate,visibility,nameWithOwner 2>/dev/null)"; then
      visibility_checked=true
      if printf '%s' "$gh_json" | grep -q '"isPrivate":true'; then is_private=true; visibility="private"; fi
      if printf '%s' "$gh_json" | grep -q '"visibility":"PUBLIC"'; then visibility="public"; fi
      repo_name="$(printf '%s' "$gh_json" | sed -n 's/.*"nameWithOwner":"\([^"]*\)".*/\1/p')"
    fi
  fi
  if [[ "$visibility_checked" != "true" && "$remote_count" != "0" && -n "${GITHUB_TOKEN:-}" ]] && command -v curl >/dev/null 2>&1; then
    remote_url="$(git -C "$root" remote get-url origin 2>/dev/null || true)"
    owner_repo=""
    case "$remote_url" in
      *github.com*) owner_repo="$(printf '%s' "$remote_url" | sed -E 's#.*github.com[:/]([^/]+/[^ ]+)$#\1#; s#\.git$##')" ;;
    esac
    if [[ -n "$owner_repo" ]]; then
      api_json="$(curl -fsS \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/${owner_repo}" 2>/dev/null || true)"
      if [[ -n "$api_json" ]]; then
        visibility_checked=true
        repo_name="$(printf '%s' "$api_json" | sed -n 's/.*"full_name":[[:space:]]*"\([^"]*\)".*/\1/p')"
        if printf '%s' "$api_json" | grep -q '"private":[[:space:]]*true'; then
          is_private=true
          visibility="private"
        else
          visibility="public"
        fi
      fi
    fi
  fi
  allowed=false
  push_allowed=false
  if [[ "$mode" == "operational" && "$visibility_checked" == "true" && "$is_private" == "true" ]]; then
    allowed=true
    push_allowed=true
  elif [[ "$mode" == "local-only" && "$visibility_checked" == "true" && "$visibility" == "no_remote" ]]; then
    allowed=true
  fi
  if [[ "$mode" == "template" ]]; then
    allowed=false
    push_allowed=false
  fi
  printf '{"repo_mode":"%s","visibility_required":"%s","visibility_checked":%s,"visibility":"%s","github_repo":"%s","allowed_to_write_hosts":%s,"allowed_to_document_sensitive_context":%s,"allowed_to_store_plaintext_secrets":false,"push_allowed":%s}\n' \
    "$mode" "$visibility_required" "$visibility_checked" "$visibility" "$repo_name" "$allowed" "$allowed" "$push_allowed"
}

agent_assert_host_write_allowed() {
  local root="$1" guard
  guard="$(agent_detect_repo_guard "$root")"
  if printf '%s' "$guard" | grep -q '"allowed_to_write_hosts":true'; then
    printf '%s\n' "$guard"
    return 0
  fi
  cat >&2 <<EOF
WARNUNG:
Dieses Repository ist nicht als sicherer Hostdaten-Zielort bestätigt.
Hostdaten, Infrastrukturinformationen, Secrets, Tokens, private Pfade und sicherheitskritische Konfigurationen werden hier nicht dokumentiert.

Sichere Optionen:
1. Private GitHub-Kopie aus Template erzeugen.
2. Lokales Git-Repo ohne Remote verwenden und local-only aktivieren.
3. Abbrechen.
EOF
  return 10
}

agent_redact() {
  sed -E \
    -e 's/((password|passwd|pwd|secret|token|api[_-]?key|credential|private[_-]?key)[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/(Authorization:[[:space:]]*Bearer[[:space:]]+)[^[:space:]]+/\1[REDACTED]/Ig'
}
'@

Write-RepoFile -Path 'scripts/bash/agent-installer-common.sh' -Content $commonSh

$detectRepoSh = @'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../bash/agent-installer-common.sh
source "$SCRIPT_DIR/../bash/agent-installer-common.sh"
ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"
agent_detect_repo_guard "$ROOT"
'@
Write-RepoFile -Path 'scripts/common/detect-repo-mode.sh' -Content $detectRepoSh

$assertRepoSh = @'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../bash/agent-installer-common.sh
source "$SCRIPT_DIR/../bash/agent-installer-common.sh"
ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"
agent_assert_host_write_allowed "$ROOT"
'@
Write-RepoFile -Path 'scripts/common/assert-private-repo.sh' -Content $assertRepoSh

$createPrivateSh = @'
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <owner/template-repo> <owner/private-repo>" >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI gh ist nicht verfügbar." >&2
  exit 1
fi

gh repo create "$2" --template "$1" --private --clone
'@
Write-RepoFile -Path 'scripts/common/create-private-copy.sh' -Content $createPrivateSh

$enableLocalSh = @'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../bash/agent-installer-common.sh
source "$SCRIPT_DIR/../bash/agent-installer-common.sh"
ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"

if [[ "$(git -C "$ROOT" remote | wc -l | tr -d ' ')" != "0" ]]; then
  echo "Local-only-Modus wird nicht aktiviert, solange Git-Remotes vorhanden sind. Remote nicht automatisch entfernen." >&2
  exit 1
fi

cat > "$ROOT/repo-mode.yaml" <<'YAML'
repo_mode: local-only
visibility_required: no_remote
allowed_to_write_hosts: true
allowed_to_document_sensitive_context: true
allowed_to_store_plaintext_secrets: false
YAML

echo "Local-only-Modus aktiviert. Push bleibt verboten, bis ein privater Remote geprüft wurde."
'@
Write-RepoFile -Path 'scripts/common/enable-local-only-mode.sh' -Content $enableLocalSh

$redactSh = @'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../bash/agent-installer-common.sh
source "$SCRIPT_DIR/../bash/agent-installer-common.sh"
agent_redact
'@
Write-RepoFile -Path 'scripts/common/redact-sensitive-output.sh' -Content $redactSh

$detectPlatformSh = @'
#!/usr/bin/env bash
set -euo pipefail

os="linux"
environment="native"
if grep -qi microsoft /proc/version 2>/dev/null; then environment="wsl"; fi
hostname_value="$(hostname 2>/dev/null || printf unknown)"
arch_value="$(uname -m 2>/dev/null || printf unknown)"
kernel_value="$(uname -r 2>/dev/null || printf unknown)"
distribution="unknown"
version_id=""
family="unknown"
pretty_name=""

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  distribution="${ID:-unknown}"
  version_id="${VERSION_ID:-}"
  pretty_name="${PRETTY_NAME:-}"
  case " ${ID_LIKE:-} ${ID:-} " in
    *debian*|*ubuntu*) family="debian" ;;
    *rhel*|*fedora*|*rocky*|*almalinux*) family="rhel" ;;
    *arch*) family="arch" ;;
  esac
fi

printf '{"detected_at":"%s","os":"%s","environment":"%s","hostname":"%s","architecture":"%s","kernel":"%s","linux":{"family":"%s","distribution":"%s","version_id":"%s","pretty_name":"%s"},"root":%s}\n' \
  "$(date -Iseconds)" "$os" "$environment" "$hostname_value" "$arch_value" "$kernel_value" "$family" "$distribution" "$version_id" "$pretty_name" "$(if [[ "$(id -u)" == "0" ]]; then echo true; else echo false; fi)"
'@
Write-RepoFile -Path 'scripts/bash/detect-platform.sh' -Content $detectPlatformSh

$detectHostSh = @'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/detect-platform.sh"
'@
Write-RepoFile -Path 'scripts/bash/detect-host.sh' -Content $detectHostSh

$collectBaselineSh = @'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent-installer-common.sh
source "$SCRIPT_DIR/agent-installer-common.sh"
ROOT="${1:-$(agent_repo_root "$SCRIPT_DIR")}"
HOSTNAME_VALUE="${HOSTNAME:-$(hostname)}"
agent_assert_host_write_allowed "$ROOT" >/dev/null

HOST_ROOT="$ROOT/hosts/$HOSTNAME_VALUE"
mkdir -p "$HOST_ROOT"/{baseline/raw,changes,rollback,security,container/docker,container/compose,container/swarm,container/kubernetes,container/podman,logs,state}
NOW="$(date -Iseconds)"
PLATFORM_JSON="$("$SCRIPT_DIR/detect-platform.sh")"

cat > "$HOST_ROOT/host.yaml" <<YAML
host_id: $HOSTNAME_VALUE
hostname: $HOSTNAME_VALUE
created_at: $NOW
last_seen_at: $NOW
repo:
  mode: local-or-operational
  visibility_checked: true
  allowed_to_write_hosts: true
platform:
  os: linux
  environment: $(printf '%s' "$PLATFORM_JSON" | sed -n 's/.*"environment":"\([^"]*\)".*/\1/p')
  architecture: "$(uname -m)"
template_paths_used:
  - Vorlage/common
  - Vorlage/linux/common
YAML

cat > "$HOST_ROOT/baseline/system.md" <<MD
# System-Baseline

- Erfasst am: $NOW
- Hostname: $HOSTNAME_VALUE
- Kernel: $(uname -a)
- Root: $(if [[ "$(id -u)" == "0" ]]; then echo ja; else echo nein; fi)
MD

cp /etc/os-release "$HOST_ROOT/baseline/raw/os-release.txt" 2>/dev/null || true
mount > "$HOST_ROOT/baseline/filesystem.md" 2>/dev/null || true
ip addr > "$HOST_ROOT/baseline/network.md" 2>/dev/null || true
systemctl list-unit-files > "$HOST_ROOT/baseline/services.md" 2>/dev/null || true
env | agent_redact > "$HOST_ROOT/baseline/environment.md"
cat > "$HOST_ROOT/security/secret-references.yaml" <<'YAML'
secrets: []
YAML
printf 'last_run_at: %s\nstatus: baseline_collected\n' "$NOW" > "$HOST_ROOT/state/last-run.yaml"
echo "Baseline erzeugt: $HOST_ROOT"
'@
Write-RepoFile -Path 'scripts/bash/collect-baseline.sh' -Content $collectBaselineSh

$bashCollectors = @{
    'scripts/bash/collect-linux-packages.sh' = 'if command -v dpkg >/dev/null 2>&1; then dpkg-query -W; elif command -v rpm >/dev/null 2>&1; then rpm -qa; elif command -v pacman >/dev/null 2>&1; then pacman -Q; else echo "Kein unterstützter Paketmanager gefunden"; fi'
    'scripts/bash/collect-linux-firewall.sh' = 'if command -v ufw >/dev/null 2>&1; then ufw status verbose; elif command -v firewall-cmd >/dev/null 2>&1; then firewall-cmd --list-all; elif command -v nft >/dev/null 2>&1; then nft list ruleset; else echo "Keine bekannte Firewall-CLI gefunden"; fi'
    'scripts/bash/collect-systemd.sh' = 'if command -v systemctl >/dev/null 2>&1; then systemctl list-unit-files; else echo "systemctl nicht verfügbar"; fi'
}
foreach ($item in $bashCollectors.GetEnumerator()) {
    $content = @"
#!/usr/bin/env bash
set -euo pipefail
$($item.Value)
"@
    Write-RepoFile -Path $item.Key -Content $content
}

$writeChangeSh = @'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent-installer-common.sh
source "$SCRIPT_DIR/agent-installer-common.sh"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <area> <summary>" >&2
  exit 2
fi

ROOT="$(agent_repo_root "$SCRIPT_DIR")"
HOSTNAME_VALUE="${HOSTNAME:-$(hostname)}"
AREA="$1"
SUMMARY="$2"
agent_assert_host_write_allowed "$ROOT" >/dev/null
HOST_ROOT="$ROOT/hosts/$HOSTNAME_VALUE"
mkdir -p "$HOST_ROOT/changes"
DATE="$(date +%F)"
COUNT="$(find "$HOST_ROOT/changes" -maxdepth 1 -name "$DATE*.md" | wc -l | tr -d ' ')"
SEQ="$(printf '%04d' "$((COUNT + 1))")"
SLUG="$(printf '%s' "$AREA" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g')"
PATH_OUT="$HOST_ROOT/changes/${DATE}_${SEQ}_${SLUG}.md"

cat > "$PATH_OUT" <<MD
# Änderung: $SUMMARY

## Metadaten
- Datum: $DATE
- Hostname: $HOSTNAME_VALUE
- Bereich: $AREA
- Ebene: System
- Risiko: niedrig
- Adminrechte erforderlich: nein
- Nutzerfreigabe erforderlich: nein
- Status: geplant

## Ausgangszustand
Noch zu dokumentieren.

## Zielzustand
Noch zu dokumentieren.

## Änderung
Noch nicht ausgeführt.

## Ort der Änderung
Noch zu dokumentieren.

## Ausgeführte Befehle
\`\`\`bash
# Noch keine Befehle dokumentiert.
\`\`\`

## Betroffene Dateien
- Noch zu dokumentieren.

## Prüfung
Noch zu dokumentieren.

## Rollback
Noch zu dokumentieren.

## Risiken und Hinweise
Keine Klartext-Secrets aufnehmen.
MD

echo "Change-Eintrag erzeugt: $PATH_OUT"
'@
Write-RepoFile -Path 'scripts/bash/write-change-entry.sh' -Content $writeChangeSh

$bashStepMap = @{
    'scripts/bash/apply-step.sh' = 'true'
    'scripts/bash/rollback-step.sh' = 'true'
    'scripts/bash/validate-step.sh' = 'false'
}
foreach ($item in $bashStepMap.GetEnumerator()) {
    $stepName = [System.IO.Path]::GetFileNameWithoutExtension($item.Key)
    $approvalRequired = $item.Value
    $content = @"
#!/usr/bin/env bash
set -euo pipefail
if [[ `$# -lt 1 ]]; then
  echo "Usage: `$0 <command> [--approved]" >&2
  exit 2
fi
COMMAND="`$1"
APPROVED="`${2:-}"
APPROVAL_REQUIRED="$approvalRequired"
if [[ "`$APPROVAL_REQUIRED" == "true" && "`$APPROVED" != "--approved" ]]; then
  echo "$stepName benötigt explizite Freigabe mit --approved." >&2
  exit 1
fi
echo "Führe $stepName aus: `$COMMAND"
bash -lc "`$COMMAND"
"@
    Write-RepoFile -Path $item.Key -Content $content
}

$containerPs = @'
[CmdletBinding()]
param()

$docker = [bool](Get-Command docker -ErrorAction SilentlyContinue)
$compose = $false
$swarm = $false
if ($docker) {
    try { docker compose version *> $null; $compose = $true } catch {}
    try {
        $swarmState = docker info --format '{{.Swarm.LocalNodeState}}' 2>$null
        $swarm = $swarmState -and $swarmState -ne 'inactive'
    } catch {}
}

[ordered]@{
    detected_at = (Get-Date).ToString('o')
    docker = $docker
    docker_compose = $compose
    docker_swarm = [bool]$swarm
    kubernetes = [bool](Get-Command kubectl -ErrorAction SilentlyContinue)
    podman = [bool](Get-Command podman -ErrorAction SilentlyContinue)
    nvidia_container_runtime = [bool](Get-Command nvidia-ctk -ErrorAction SilentlyContinue)
} | ConvertTo-Json -Depth 4
'@
Write-RepoFile -Path 'scripts/container/detect-container-stack.ps1' -Content $containerPs

$containerSh = @'
#!/usr/bin/env bash
set -euo pipefail
docker_available=false
compose_available=false
swarm_active=false
kubernetes_available=false
podman_available=false
nvidia_available=false

if command -v docker >/dev/null 2>&1; then
  docker_available=true
  if docker compose version >/dev/null 2>&1; then compose_available=true; fi
  if [[ "$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || true)" != "inactive" ]]; then swarm_active=true; fi
fi
if command -v kubectl >/dev/null 2>&1; then kubernetes_available=true; fi
if command -v podman >/dev/null 2>&1; then podman_available=true; fi
if command -v nvidia-ctk >/dev/null 2>&1 || command -v nvidia-smi >/dev/null 2>&1; then nvidia_available=true; fi

printf '{"detected_at":"%s","docker":%s,"docker_compose":%s,"docker_swarm":%s,"kubernetes":%s,"podman":%s,"nvidia_container_runtime":%s}\n' \
  "$(date -Iseconds)" "$docker_available" "$compose_available" "$swarm_active" "$kubernetes_available" "$podman_available" "$nvidia_available"
'@
Write-RepoFile -Path 'scripts/container/detect-container-stack.sh' -Content $containerSh

$collectDockerPs = @'
[CmdletBinding()]
param([string]$OutputPath = 'docker-baseline.md')

$commands = @(
    @{ Title = 'docker version'; FilePath = 'docker'; ArgumentList = @('version') },
    @{ Title = 'docker info'; FilePath = 'docker'; ArgumentList = @('info') },
    @{ Title = 'docker ps -a'; FilePath = 'docker'; ArgumentList = @('ps', '-a') },
    @{ Title = 'docker images'; FilePath = 'docker'; ArgumentList = @('images') },
    @{ Title = 'docker network ls'; FilePath = 'docker'; ArgumentList = @('network', 'ls') },
    @{ Title = 'docker volume ls'; FilePath = 'docker'; ArgumentList = @('volume', 'ls') }
)
$parts = @('# Docker Baseline')
foreach ($cmd in $commands) {
    $parts += "`n## $($cmd.Title)`n```text"
    try { $parts += (& $cmd.FilePath @($cmd.ArgumentList) 2>&1 | Out-String) } catch { $parts += $_.Exception.Message }
    $parts += '```'
}
$parts -join "`n" | Out-File -FilePath $OutputPath -Encoding utf8
Write-Host "Erfasst: $OutputPath"
'@
Write-RepoFile -Path 'scripts/container/collect-docker.ps1' -Content $collectDockerPs

$collectDockerSh = @'
#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-docker-baseline.md}"
{
  echo "# Docker Baseline"
  for cmd in "docker version" "docker info" "docker ps -a" "docker images" "docker network ls" "docker volume ls"; do
    echo
    echo "## $cmd"
    echo '```text'
    bash -lc "$cmd" 2>&1 || true
    echo '```'
  done
} > "$OUT"
echo "Erfasst: $OUT"
'@
Write-RepoFile -Path 'scripts/container/collect-docker.sh' -Content $collectDockerSh

$collectPodmanSh = @'
#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-podman-baseline.md}"
{
  echo "# Podman Baseline"
  for cmd in "podman version" "podman info" "podman ps -a" "podman images" "podman network ls" "podman volume ls" "podman pod ls"; do
    echo
    echo "## $cmd"
    echo '```text'
    bash -lc "$cmd" 2>&1 || true
    echo '```'
  done
} > "$OUT"
echo "Erfasst: $OUT"
'@
Write-RepoFile -Path 'scripts/container/collect-podman.sh' -Content $collectPodmanSh

$collectComposeSh = @'
#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-compose-baseline.md}"
{
  echo "# Docker Compose Baseline"
  echo
  echo "## Version"
  echo '```text'
  docker compose version 2>&1 || true
  echo '```'
  echo
  echo "## Compose-Dateien"
  echo '```text'
  find "${2:-.}" -type f \( -name 'compose.yaml' -o -name 'compose.yml' -o -name 'docker-compose.yaml' -o -name 'docker-compose.yml' \) 2>/dev/null
  echo '```'
  echo
  echo "Hinweis: .env-Inhalte werden nicht exportiert."
} > "$OUT"
echo "Erfasst: $OUT"
'@
Write-RepoFile -Path 'scripts/container/collect-compose.sh' -Content $collectComposeSh

$collectSwarmSh = @'
#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-swarm-baseline.md}"
{
  echo "# Docker Swarm Baseline"
  for cmd in "docker info --format '{{.Swarm.LocalNodeState}}'" "docker node ls" "docker service ls" "docker stack ls" "docker secret ls"; do
    echo
    echo "## $cmd"
    echo '```text'
    bash -lc "$cmd" 2>&1 || true
    echo '```'
  done
  echo
  echo "Secret-Werte werden nicht exportiert."
} > "$OUT"
echo "Erfasst: $OUT"
'@
Write-RepoFile -Path 'scripts/container/collect-swarm.sh' -Content $collectSwarmSh

$collectKubernetesSh = @'
#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-kubernetes-baseline.md}"
{
  echo "# Kubernetes Baseline"
  for cmd in "kubectl config current-context" "kubectl config get-contexts" "kubectl get namespaces" "kubectl get workloads --all-namespaces" "kubectl get svc,ingress --all-namespaces" "kubectl get pv,pvc --all-namespaces" "kubectl get roles,rolebindings,clusterroles,clusterrolebindings --all-namespaces"; do
    echo
    echo "## $cmd"
    echo '```text'
    bash -lc "$cmd" 2>&1 || true
    echo '```'
  done
  echo
  echo "Kubernetes-Secrets werden nicht exportiert."
} > "$OUT"
echo "Erfasst: $OUT"
'@
Write-RepoFile -Path 'scripts/container/collect-kubernetes.sh' -Content $collectKubernetesSh

$collectNvidiaSh = @'
#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-nvidia-container-baseline.md}"
{
  echo "# NVIDIA Container Baseline"
  for cmd in "nvidia-smi" "nvidia-ctk --version" "docker info" "podman info"; do
    echo
    echo "## $cmd"
    echo '```text'
    bash -lc "$cmd" 2>&1 || true
    echo '```'
  done
} > "$OUT"
echo "Erfasst: $OUT"
'@
Write-RepoFile -Path 'scripts/container/collect-nvidia-container.sh' -Content $collectNvidiaSh

$collectContainerPsAliases = @{
    'scripts/container/collect-compose.ps1' = 'docker compose version'
    'scripts/container/collect-podman.ps1' = 'podman info'
    'scripts/container/collect-swarm.ps1' = 'docker info --format "{{.Swarm.LocalNodeState}}"'
    'scripts/container/collect-kubernetes.ps1' = 'kubectl config get-contexts'
    'scripts/container/collect-nvidia-container.ps1' = 'if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) { nvidia-smi } elseif (Get-Command nvidia-ctk -ErrorAction SilentlyContinue) { nvidia-ctk --version } else { "NVIDIA Tooling nicht verfügbar" }'
}
foreach ($item in $collectContainerPsAliases.GetEnumerator()) {
    $content = @"
[CmdletBinding()]
param([string]`$OutputPath = 'container-baseline.md')

try {
    `$collectorOutput = & {
        $($item.Value)
    }
    `$collectorOutput | Out-File -FilePath `$OutputPath -Encoding utf8
} catch {
    `$_.Exception.Message | Out-File -FilePath `$OutputPath -Encoding utf8
}
Write-Host "Erfasst: `$OutputPath"
"@
    Write-RepoFile -Path $item.Key -Content $content
}

$validatePs = @'
[CmdletBinding()]
param([string]$RepoRoot)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$required = @(
    'AGENTS.md',
    'README.md',
    'LICENSE',
    'repo-mode.yaml',
    'schemas/host.schema.yaml',
    'schemas/repo-mode.schema.yaml',
    'scripts/common/detect-repo-mode.ps1',
    'scripts/common/detect-repo-mode.sh',
    'scripts/powershell/collect-baseline.ps1',
    'scripts/bash/collect-baseline.sh',
    'scripts/container/detect-container-stack.ps1',
    'scripts/container/detect-container-stack.sh',
    'hosts/.gitkeep'
)

$missing = @()
foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $path))) { $missing += $path }
}

$hostChildren = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'hosts') -Force | Where-Object { $_.Name -ne '.gitkeep' })
$templateFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'Vorlage') -Recurse -Filter '*.md')
$badFrontmatter = @()
foreach ($file in $templateFiles) {
    $first = Get-Content -LiteralPath $file.FullName -TotalCount 1
    if ($first -ne '---') { $badFrontmatter += $file.FullName }
}

$result = [ordered]@{
    required_missing = $missing
    hosts_has_only_gitkeep = ($hostChildren.Count -eq 0)
    template_file_count = $templateFiles.Count
    template_frontmatter_missing = $badFrontmatter
    ok = ($missing.Count -eq 0 -and $hostChildren.Count -eq 0 -and $badFrontmatter.Count -eq 0)
}

$result | ConvertTo-Json -Depth 4
if (-not $result.ok) { exit 1 }
'@
Write-RepoFile -Path 'scripts/common/validate-template.ps1' -Content $validatePs

$validateSh = @'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
missing=0
for path in AGENTS.md README.md LICENSE repo-mode.yaml schemas/host.schema.yaml scripts/common/detect-repo-mode.sh hosts/.gitkeep; do
  if [[ ! -e "$ROOT/$path" ]]; then
    echo "Fehlt: $path" >&2
    missing=1
  fi
done
if find "$ROOT/hosts" -mindepth 1 -maxdepth 1 ! -name .gitkeep | grep -q .; then
  echo "hosts/ enthält Hostdaten; Template muss leer bleiben." >&2
  missing=1
fi
count="$(find "$ROOT/Vorlage" -type f -name '*.md' | wc -l | tr -d ' ')"
echo "template_file_count=$count"
exit "$missing"
'@
Write-RepoFile -Path 'scripts/common/validate-template.sh' -Content $validateSh

Write-Host "Initiales Repo-Grundgerüst erzeugt in $RepoRoot"
