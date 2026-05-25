# Dokumentationsstandard

Jede Änderung unter `hosts/<HOSTNAME>/changes/` enthält Metadaten, Ausgangszustand, Infrastruktur-Snapshot, Zielzustand, Soll-Ist-Abgleich, Duplikatprüfung, Lösch- und Seiteneffektprüfung, Änderung, Ort, Befehle, betroffene Dateien, Prüfung, Rollback und Risiken.

Befehlsausgaben werden redigiert, wenn sie Tokens, Secrets, Credentials oder private Schlüssel enthalten könnten.

Alle neuen oder geänderten Textdateien werden als UTF-8 geschrieben. Deutsche Fließtexte verwenden echte Umlaute wie `für`, `prüfen`, `Änderung`, `zurück` und `vollständig`; ASCII-Umschreibungen mit `ue`, `oe` oder `ae` bleiben technischen Tokens, Pfaden, IDs oder externen Originalzitaten vorbehalten.

Systemwirksame Änderungen ohne dokumentierten Soll-Ist-Abgleich gelten als nicht ausführungsbereit.
