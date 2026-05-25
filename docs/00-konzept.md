# Konzept

PC Agent Installer ist als agentischer Ersatz für einen echten Systemadministrator bei der Erstkonfiguration eines frisch installierten PCs oder Servers gedacht. Der Nutzer installiert das Betriebssystem, startet den Agenten in einer sicheren Operational- oder Local-only-Kopie und lässt die vollständige Grundkonfiguration durchführen.

Vollständige Grundkonfiguration bedeutet mehr als Baseline-Erfassung. Der Agent muss je nach Betriebssystem Paketquellen, Updates, Benutzer, Gruppen, Rechte, Firewall, Dienste, Sicherheitsrichtlinien, sinnvolle Programme, Baseline, Validierung und Rollback-Dokumentation behandeln.

PC Agent Installer trennt dabei Soll-Prozesse von realem Host-Zustand.

- `Vorlage/` beschreibt generische, numerisch sortierte Agentenaufgaben.
- `scripts/` enthält sichere Erkennungs-, Baseline-, Validierungs- und Rollback-Hilfen.
- `hosts/<HOSTNAME>/` dokumentiert reale Hosts ausschließlich in sicheren Operational- oder Local-only-Repositories.

Jede systemwirksame Änderung braucht Erststart-Prüfung, aktuellen Infrastruktur-Snapshot, Soll-Ist-Abgleich, Änderungsdokumentation, Prüfung und Rollback-Pfad.

Echte Ersteinrichtung braucht absolute Systemrechte. Der Agent muss den Nutzer vorab klar darauf hinweisen, dass er je nach Plattform als Administrator, root oder über sudo handeln kann. Ohne diese Rechte darf der Agent nur analysieren und vorbereiten, aber keine vollständige PC- oder Server-Einrichtung als abgeschlossen melden.
