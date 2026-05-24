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
