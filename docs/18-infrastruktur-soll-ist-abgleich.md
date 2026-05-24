# Infrastruktur-Soll-Ist-Abgleich

## Ziel

Der Agent muss zu jedem Zeitpunkt verhindern, dass Vollzugriff versehentlich die Umgebung beschädigt. Deshalb gilt vor jeder systemwirksamen Änderung: aktuelle Infrastruktur prüfen, Soll-Zustand formulieren, Ist-Zustand vergleichen und erst dann minimal handeln.

Diese Regel schützt besonders vor:

- unnötigen Doppelinstallationen,
- parallelen Diensten oder Containern,
- falschen Paketmanager- oder Store-Quellen,
- versehentlicher Löschung aktiver Nutzdaten,
- Verlust von Volumes, WSL-Distributionen, Projektordnern oder Secrets,
- Änderungen, die normale PC-Nutzung blockieren.

## Grundsatz

Vollzugriff ist eine technische Fähigkeit, keine automatische Freigabe.

Der Agent darf mit Vollzugriff erst handeln, wenn folgende Punkte erfüllt sind:

1. Erststart-Konfiguration abgeschlossen.
2. Repo-Modus erlaubt Hostdaten und Hoständerungen.
3. Aktueller Infrastruktur-Snapshot oder Baseline vorhanden.
4. Soll-Ist-Abgleich im Change-Eintrag dokumentiert.
5. Duplikatprüfung und Löschrisikoprüfung abgeschlossen.
6. Rollback-Grenzen bekannt.
7. Nutzerfreigabe für systemwirksame Änderung liegt vor.

## Pflicht-Guard

PowerShell:

```powershell
./scripts/common/assert-first-run-config.ps1
./scripts/common/assert-infrastructure-snapshot.ps1
```

Bash:

```bash
bash ./scripts/common/assert-first-run-config.sh
bash ./scripts/common/assert-infrastructure-snapshot.sh
```

Wenn `assert-infrastructure-snapshot.*` fehlschlägt, muss zuerst eine aktuelle Baseline erzeugt werden:

```powershell
./scripts/powershell/collect-baseline.ps1
```

```bash
bash ./scripts/bash/collect-baseline.sh
```

## Soll-Ist-Abgleich

Der Agent dokumentiert vor der Änderung:

| Bereich | Pflichtfrage |
| --- | --- |
| Ziel | Was soll nach der Änderung anders sein? |
| Ist | Was ist bereits installiert, aktiv, konfiguriert oder vorhanden? |
| Abweichung | Welche konkrete Lücke besteht noch? |
| Duplikate | Würde die Änderung etwas doppelt installieren oder parallel betreiben? |
| Datenrisiko | Welche Nutzer- oder Betriebsdaten könnten betroffen sein? |
| Minimaländerung | Was ist die kleinste sichere Änderung? |
| Validierung | Wie wird der Zielzustand nachgewiesen? |
| Rollback | Was kann zurückgenommen werden, was nicht? |

## Installationsbeispiele

Vor einer Programminstallation:

- installierte Programme prüfen,
- Paketmanager-Quelle prüfen,
- vorhandene App über Store, `winget`, Homebrew, Flatpak oder Systempaketmanager erkennen,
- keine zweite Installation über anderen Kanal erzeugen,
- Nutzer fragen, wenn mehrere Quellen gleich plausibel sind.

Vor WSL, Docker oder Portainer:

- vorhandene WSL-Distributionen prüfen,
- Docker-Kontext prüfen,
- bestehende Container, Ports und Volumes prüfen,
- keine zweite Portainer-Instanz starten, wenn bereits eine passende existiert,
- keine Volumes löschen.

Vor Cleanup:

- aktive Nutzung prüfen,
- zu löschende Pfade und Volumes explizit auflisten,
- unklare Daten behalten,
- nur eindeutig temporäre, generierte oder selbst erzeugte Prüfartefakte entfernen.

## Change-Eintrag

Jeder Change-Eintrag muss die Abschnitte `Infrastruktur-Snapshot`, `Soll-Ist-Abgleich`, `Duplikatprüfung` und `Lösch- und Seiteneffektprüfung` enthalten. Ohne diese Abschnitte gilt eine systemwirksame Änderung als nicht ausführungsbereit.

## Template-Regel für zukünftige Änderungen

Alle neuen Vorlagen, Skripte und Dokumentationen, die Installationen, Löschungen, Dienste, Paketmanager, Container, WSL, Firewall, DNS, Blocklisten, Security-Tools oder Cleanup betreffen, müssen diese Soll-Ist-Regel referenzieren oder gleichwertig umsetzen.
