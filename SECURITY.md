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
