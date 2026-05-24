# Sicherheitsmodell

- Keine Hostdaten in öffentlichen oder ungeprüften Repositories.
- Keine Klartext-Secrets im Repository.
- Keine destruktiven Aktionen ohne Freigabe.
- Admin-, Root- und Sudo-Aktionen explizit markieren.
- Vorher-/Nachher-Zustand dokumentieren.
- Rollback-Pfad für systemwirksame Änderungen erzeugen.

## Usability-first Sicherheitsbaseline

Für normale Nutzer-PCs gilt: Sicherheit soll die Alltagsnutzung nicht unnötig blockieren. Browser, Downloads, Updates, Store, Games, Entwicklerwerkzeuge, KI-Tools und seriöse Internetsoftware sollen grundsätzlich nutzbar bleiben.

Deshalb bevorzugt dieses Template:

- eingebaute Betriebssystemfunktionen vor zusätzlichen Security-Suites,
- aktuelle kostenlose Tools aus offiziellen Quellen vor intransparenten Bundle-Installern,
- Microsoft Defender, SmartScreen, Firewall und Updates als Windows-Basis,
- dokumentierte Empfehlungen statt blinder Installation,
- profilbasierte Programmempfehlungen anhand der Erststart-Beschreibung statt pauschaler Masseninstallation,
- optionale Pilotmaßnahmen mit Rollback statt harter Default-Blockaden.

Störanfällige Maßnahmen wie Controlled Folder Access, harte DNS-Filter, App-Control-Regeln, ausgehende Firewall-Blockaden oder zusätzliche Echtzeit-Antivirus-Suiten sind keine Default-Härtung. Sie werden nur bewusst, testweise und rollbackfähig eingesetzt.

Details stehen in `docs/15-klassische-sicherheitseinstellungen.md`.

Programm- und Installationsempfehlungen stehen in `docs/17-programm-und-installationsempfehlungen.md`.
