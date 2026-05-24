# Dokumentationsstandard

Jede Änderung unter `hosts/<HOSTNAME>/changes/` enthält Metadaten, Ausgangszustand, Infrastruktur-Snapshot, Zielzustand, Soll-Ist-Abgleich, Duplikatprüfung, Lösch- und Seiteneffektprüfung, Änderung, Ort, Befehle, betroffene Dateien, Prüfung, Rollback und Risiken.

Befehlsausgaben werden redigiert, wenn sie Tokens, Secrets, Credentials oder private Schlüssel enthalten könnten.

Systemwirksame Änderungen ohne dokumentierten Soll-Ist-Abgleich gelten als nicht ausführungsbereit.
