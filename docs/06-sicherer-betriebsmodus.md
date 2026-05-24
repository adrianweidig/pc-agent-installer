# Sicherer Betriebsmodus

`template` ist der sichere Default für öffentliche Repositories. Hostdaten bleiben deaktiviert.

`operational` setzt eine bestätigte private Remote-Sichtbarkeit voraus.

`local-only` setzt voraus, dass kein Git-Remote existiert. Push ist gesperrt, bis ein privater Remote erneut geprüft wurde.

## Vollzugriff

Ein Agent darf in einer privaten oder lokalen Operational-Kopie technisch mit Vollzugriff arbeiten. Vollzugriff hebt aber keine Sicherheitsprüfung auf.

Vor jeder systemwirksamen Änderung muss der Agent:

1. Erststart-Konfiguration prüfen.
2. Aktuelle Infrastruktur mit `assert-infrastructure-snapshot.*` prüfen.
3. Bei fehlender oder unvollständiger Baseline zuerst `collect-baseline.*` ausführen.
4. Soll-Ist-Abgleich dokumentieren.
5. Duplikate und Löschrisiko prüfen.
6. Rollback-Grenzen festhalten.
7. Nutzerfreigabe einholen.

Wenn eine dieser Bedingungen fehlt, darf der Agent nicht installieren, löschen, migrieren, Dienste ändern, Container bereinigen, Volumes anfassen, Firewall-/DNS-Regeln ändern oder Paketmanager-Aktionen ausführen.
