# Sicherheitsrichtlinie

🌐 Sprachen: [Deutsch](SECURITY.md) | [English](SECURITY.en.md)

## Grundsatz

PC Agent Installer ist ein öffentliches Template. Dieses Repository darf keine Klartext-Secrets, echten Hostdaten oder vertraulichen Infrastrukturdetails enthalten.

Hostdaten dürfen nur in einem bestätigten privaten `operational`-Repository oder in einem `local-only`-Klon ohne Remote dokumentiert werden. Auch dort bleiben Klartext-Secrets verboten.

## Unterstützte Versionen

Das Projekt nutzt derzeit kein formales Release-Support-Modell. Sicherheitsrelevante Hinweise beziehen sich auf den aktuellen Stand des Default-Branches und auf veröffentlichte Releases, sofern vorhanden.

## Nicht erlaubt

- Klartext-Passwörter, Tokens, API-Keys und private Schlüssel
- ungefilterte `.env`-Dateien
- produktive Kubeconfigs mit Tokens
- SSH Private Keys und Zertifikats-Private-Keys
- rohe Secret-, Credential- oder Token-Exporte
- echte Hostnamen, private Pfade oder interne Infrastrukturdetails im öffentlichen Template

## Sicherheitsproblem melden

Bitte poste keine vertraulichen Schwachstellendetails öffentlich als Issue.

Wenn GitHub Private Vulnerability Reporting für dieses Repository aktiviert ist, nutze diesen Weg. Falls kein privater Meldeweg sichtbar ist, öffne ein öffentliches Issue nur mit einer allgemeinen Beschreibung ohne Exploit-Details, Secrets, Logauszüge oder konkrete interne Pfade.

Maintainer sollten einen privaten Sicherheitskontakt oder GitHub Private Vulnerability Reporting konfigurieren. Die dafür offenen Schritte stehen in `docs/MAINTAINER_CHECKLIST.md`.

## Erwarteter Ablauf

Nach einer Meldung sollte geprüft werden:

1. Ist das öffentliche Template betroffen?
2. Wurden Secrets, Hostdaten oder private Pfade offengelegt?
3. Müssen betroffene Secrets rotiert werden?
4. Ist ein Patch im Template nötig?
5. Muss GitHub Secret Scanning, Code Scanning oder die Repository-Historie geprüft werden?

Historienbereinigung, Force-Pushes oder andere irreversible Schritte erfolgen nur nach ausdrücklicher Maintainer-Entscheidung.

## Versehentlich committete sensible Daten

Wenn versehentlich sensible Daten committed wurden:

1. Nicht weiter pushen.
2. Betroffene Secrets sofort rotieren.
3. Öffentliche Kopien, Forks und CI-Logs prüfen.
4. Historie nur nach expliziter Freigabe bereinigen.
5. Falls ein Remote betroffen ist, GitHub Secret Scanning und Audit-Logs prüfen.

## Operational-Repositories

Private Operational-Repositories dürfen Secret-Referenzen dokumentieren, aber keine Secret-Werte. Erlaubt sind Zweck, Ablageort, Zugriffsmethode, Laufzeitvariable und Rotationshinweise.

Diese Policy gibt keine Sicherheitsgarantie. Sie beschreibt die Mindestregeln, damit das öffentliche Template und daraus abgeleitete private Arbeitsstände sauber getrennt bleiben.
