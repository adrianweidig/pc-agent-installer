# Konzept

PC Agent Installer trennt Soll-Prozesse von realem Host-Zustand.

- `Vorlage/` beschreibt generische, numerisch sortierte Agentenaufgaben.
- `scripts/` enthält sichere Erkennungs-, Baseline-, Validierungs- und Rollback-Hilfen.
- `hosts/<HOSTNAME>/` dokumentiert reale Hosts ausschließlich in sicheren Operational- oder Local-only-Repositories.

Jede systemwirksame Änderung braucht Erststart-Prüfung, aktuellen Infrastruktur-Snapshot, Soll-Ist-Abgleich, Änderungsdokumentation, Prüfung und Rollback-Pfad.
