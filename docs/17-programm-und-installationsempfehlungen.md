# Programm- und Installationsempfehlungen

## Ziel

Der Agent soll sinnvolle Programme nicht pauschal installieren, sondern aus der Erststart-Beschreibung, dem Betriebssystem, dem Gerätetyp und vorhandener Software ableiten. Eine kurze Beschreibung wie `Ich bin Entwickler`, `Ich nutze den PC für Büro, WhatsApp und Fotos` oder `Ich spiele und streame` reicht als Startsignal.

Jede echte Installation bleibt eine systemwirksame Änderung: Der Agent muss vorher erklären, was installiert wird, aus welcher Quelle es kommt, welchen Nutzen es hat und wie es wieder entfernt werden kann.

## Quellenpriorität

1. Betriebssystemeigene Stores und Paketmanager.
2. Offizielle Herstellerseiten.
3. Gut dokumentierte Community-Repositories mit klarer Herkunft.
4. Manuelle Downloads nur, wenn sie notwendig und eindeutig vertrauenswürdig sind.

Keine Downloads aus Bundle-Portalen, Treiber-Updater-Portalen oder SEO-Downloadseiten.

## Quellen- und Update-Audit

Programmempfehlungen beginnen mit einer Bestandsaufnahme. Der Agent prüft zuerst, was bereits installiert ist, welche Paketquellen aktiv sind und welche Updates offen sind.

Der Agent soll dokumentieren:

- Paketmanager und Stores pro Betriebssystem
- zusätzliche Quellen, Repositories, Taps, PPAs, AUR-Helfer oder WinGet-Sources
- ausstehende Updates nach Plattform getrennt
- doppelte Laufzeitumgebungen wie mehrere Node-, Python-, Docker- oder Java-Installationen
- Programme, die aus intransparenten Quellen stammen oder nicht mehr aktualisiert werden

Updates sind ein eigener Wartungsbereich. Eine Empfehlung wie `winget upgrade --all`, `apt upgrade` oder `brew upgrade` wird erst nach Prüfung der betroffenen Pakete, Neustartrisiken und Nutzerfreigabe ausgeführt.

## Zielgruppenprofile

| Profil aus Nutzerbeschreibung | Typische Ziele | Typische Kategorien |
| --- | --- | --- |
| Normaler Nutzer | Internet, Mail, Messenger, Fotos, Dokumente | Browser, Passwortmanager, Office/PDF, Medien, Backup, einfache Wartung |
| Entwickler | Code, Terminal, Git, Container, lokale Tests | Editor/IDE, Git, Terminal, Paketmanager, Sprache-SDKs, Docker/WSL, API-Tools |
| Creator | Bilder, Video, Audio, Streaming | Medienplayer, Bildbearbeitung, OBS, Audio-Tools, große Dateien, Backup |
| Gamer | Spiele, Voice, Launcher, Controller | Store/Launcher, Voice, GPU-Treiberprüfung, Overlays nur auf Wunsch |
| Student oder Büro | Schreiben, Präsentationen, Recherche | Office, PDF, Cloud-Sync, Scanner/OCR, Kalender, Videokonferenz |
| Privacy-orientiert | minimale Kontenbindung, lokale Tools | Passwortmanager, datensparsame Browser-Profile, lokale Office-/Notiztools |
| Admin oder Homelab | Remotezugriff, Container, Monitoring | SSH, Terminal, Docker/Podman, Portainer, Netzwerktools, Backup |
| KI- und Daten-Nutzer | lokale Modelle, Python, Notebooks, GPU | Python, Git, VS Code, WSL/Linux, Container, CUDA-Prüfung nur bei NVIDIA |

Der Agent darf Profile kombinieren. Beispiel: `Ich bin Entwickler und normaler Familien-PC-Nutzer` bedeutet Entwicklerwerkzeuge plus blockadefreie Alltagsprogramme.

## Basiskategorien

### Für fast alle Desktop-Nutzer

- aktueller Hauptbrowser und optional Zweitbrowser
- Passwortmanager
- PDF-Anzeige und einfache PDF-Werkzeuge
- Office- oder Dokumentpaket
- Medienplayer
- Archivtool
- Backup- oder Sync-Lösung
- Messenger oder Web-Apps nur nach Nutzerwunsch

WhatsApp, Messenger, Teams, Discord und ähnliche Dienste sollen bevorzugt als offizielle App, Store-App oder Web/PWA-Option behandelt werden. Wenn eine Web-Version reicht, ist eine Browser-PWA oft weniger invasiv als zusätzliche Desktopsoftware.

### Für Entwickler

- Git
- modernes Terminal
- Editor oder IDE
- Sprache-SDKs passend zum Projekt
- Paketmanager und Build-Tools
- API-Client oder REST-Testtool
- WSL, Docker oder Podman nur bei echtem Bedarf

### Für Creator und Medienarbeit

- VLC oder vergleichbarer Medienplayer
- OBS Studio, wenn Aufnahme oder Streaming gewünscht ist
- Bildbearbeitung, Audio- oder Videoschnitt nur zielbezogen
- Speicher- und Backup-Prüfung vor großen Medienprojekten

### Für Wartung und Cleanup

Cleaner-Tools sind keine Default-Empfehlung. Auf Windows zuerst integrierte Datenträgerbereinigung, Speicheroptimierung und App-Deinstallation nutzen. Tools wie CCleaner oder BleachBit dürfen nur optional erwähnt werden, wenn der Nutzer explizit eine einfache Wartungsoberfläche wünscht.

Regeln für Cleaner:

- keine Registry-Reinigung als Default
- keine Autostart- oder Browser-Daten-Löschung ohne Vorschau
- keine Treiber-Updater oder System-Booster empfehlen
- vor Löschung immer Vorschau, Backup-Hinweis und Rollback-Grenzen erklären

## Windows

Windows bevorzugt Microsoft Store, `winget` und offizielle Herstellerseiten.

Zusätzliche `winget`-Quellen sind nicht automatisch schlecht, brauchen aber eine Begründung. Der Agent prüft Name, URL, Vertrauenswürdigkeit und ob die Quelle wirklich zum Nutzerprofil passt.

Sinnvolle Kategorien:

- Alltag: Browser, Passwortmanager, PDF, Office, Medienplayer, 7-Zip, Messenger/Web-Apps.
- Entwickler: Windows Terminal, Git, VS Code, PowerShell, Python oder Node.js nach Bedarf, WSL, Docker Desktop mit WSL-Unterstützung.
- Creator: OBS Studio, VLC, Bild- oder Audio-Tools.
- Wartung: Windows-Speicheroptimierung und Defender zuerst; Cleaner nur optional und nicht als automatische Optimierung.

Der Agent soll vor Installation mit `winget search` oder `winget show` prüfen, ob Paket-ID, Quelle, Herausgeber und Lizenz plausibel sind. Apps wie WhatsApp sollen nur über offizielle Store-/Herstellerwege oder als Web-App empfohlen werden.

## Linux Desktop

Linux Desktop unterscheidet sich stark nach Distribution und Zielgruppe.

- Ubuntu, Debian, Linux Mint: `apt` und Softwareverwaltung zuerst; Flatpak/Flathub optional für Desktop-Apps.
- Fedora: `dnf` und GNOME Software zuerst; Flatpak/Flathub oft sinnvoll.
- Arch und EndeavourOS: `pacman` zuerst; AUR nur bewusst und nicht für normale Nutzer als Default.
- openSUSE: `zypper` und Discover/GNOME Software zuerst.

Sinnvolle Kategorien:

- Alltag: Browser, Passwortmanager, Office, PDF, Medienplayer, Archivtools.
- Entwickler: Git, Editor, Compiler/Build-Tools, Docker oder Podman, Sprache-SDKs.
- Creator: OBS Studio, VLC, GIMP/Krita oder vergleichbare Tools.
- Wartung: Paketmanager-Cleanup und Log-/Cache-Prüfung; BleachBit nur optional und mit Vorschau.

## WSL

WSL ist kein vollständiger Desktop-Ersatz. Der Agent soll dort bevorzugt CLI-, Entwickler-, Build- und KI-nahe Werkzeuge empfehlen:

- Git, curl, wget, jq, unzip, build-essential oder distributionsäquivalente Pakete.
- Python, Node.js, Go, Rust oder Java nur nach Projekt- oder Nutzerprofil.
- Docker-CLI nur passend zum gewählten Windows-Docker-/WSL-Modell.
- keine Messenger, Cleaner oder Desktop-Apps in WSL, außer der Nutzer will ausdrücklich Linux-GUI-Apps.

Wenn Windows bereits Docker Desktop mit WSL-Unterstützung nutzt, soll der Agent keinen zweiten Docker-Daemon in WSL einrichten, ohne den Tradeoff zu erklären.

WSL-Paketquellen müssen zur Distribution passen. Drittquellen für eine andere Debian-, Ubuntu- oder Fedora-Version sind ein Anti-Pattern, solange keine bewusste Kompatibilitätsentscheidung dokumentiert ist.

## macOS

macOS bevorzugt App Store, Homebrew und offizielle Herstellerseiten.

Sinnvolle Kategorien:

- Alltag: Browser, Passwortmanager, PDF/Office, Medienplayer, Messenger/Web-Apps.
- Entwickler: Xcode Command Line Tools, Homebrew, Git, Terminal, Editor/IDE, Sprache-SDKs.
- Creator: OBS Studio, VLC, Bild-/Audio-/Video-Tools.
- Wartung: integrierte Speicherverwaltung zuerst; Cleaner nur optional, keine aggressive Systemoptimierung.

Homebrew ist für Entwickler und Power-User sinnvoll. Für reine Alltagsnutzer kann der App Store oder eine Web-App einfacher und risikoärmer sein.

Homebrew-Taps und Casks werden wie Drittquellen behandelt: Herkunft, Aktualität und Notwendigkeit prüfen, bevor der Agent daraus installiert.

## Server und Headless-Systeme

Auf Servern, WSL-Headless-Umgebungen und Container-Hosts sind Desktop-Programme wie WhatsApp, CCleaner, Browser-Add-ons oder Medienplayer normalerweise nicht sinnvoll.

Der Agent fokussiert dort:

- Updates und Paketquellen
- SSH und Remotezugriff
- Backups
- Monitoring
- Container- oder Service-Verwaltung
- Firewall und Exposure
- Logrotation und Speicherprüfung

## Frage-Antwort-Standard

Der Agent soll bei Installationen nicht fragen `Alles installieren?`, sondern konkrete, kleine Entscheidungen anbieten:

```text
Du beschreibst dich als Entwickler. Soll ich dir eine kostenlose Entwickler-Basis aus Git, modernem Terminal und Editor vorschlagen?
```

```text
Du nutzt Messenger im Alltag. Möchtest du WhatsApp als Web-App/PWA einrichten, statt eine zusätzliche Desktop-App zu installieren?
```

```text
Möchtest du ein Cleaner-Tool nur als manuell startbare Option sehen? Registry-Reinigung und automatische Optimierung bleiben ausgeschaltet.
```

Die Antwort wird im privaten oder lokalen Operational-Repo dokumentiert. Im öffentlichen Template bleiben nur Regeln und sichere Beispiele.

## Nicht-Ziele

- keine automatische Masseninstallation
- keine Software aus intransparenten Downloadportalen
- keine Registry-Cleaner-, Driver-Updater- oder Booster-Empfehlung als Default
- keine Messenger- oder Social-Apps auf Servern
- keine Entwickler-Toolchain auf reinen Familien- oder Büro-PCs ohne Bedarf
- keine zweite Container- oder Paketmanager-Welt ohne klare Begründung

## Quellen für Maintainer

- Microsoft WinGet: `https://learn.microsoft.com/windows/package-manager/winget/`
- Homebrew: `https://docs.brew.sh/`
- Flathub: `https://docs.flathub.org/`
- Flatpak/Flathub für Nutzer: `https://docs.flathub.org/docs/for-users/installation`
- WhatsApp Web/Desktop: `https://www.whatsapp.com/`
