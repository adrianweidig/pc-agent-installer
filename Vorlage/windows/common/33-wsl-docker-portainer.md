---
id: WINDOWS-COMMON-33-WSL-DOCKER-PORTAINER
title: Windows WSL-, Docker- und Portainer-Optionen
platform: windows
environment: native
area: windows/common
requires_admin: true
risk: mittel
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - windows/common
  - wsl/common
  - container/common
---

# Windows WSL-, Docker- und Portainer-Optionen

## Zweck

Diese Vorlage beschreibt optionale Windows-Zusatzkomponenten, die im Erststart bewusst ausgewählt werden müssen:

- WSL als Linux-Backend für Entwicklungs-, KI-, Shell- und Container-nahe Workflows.
- Docker mit WSL-Unterstützung, wenn der Nutzer Container verwenden möchte.
- Portainer CE als lokale Verwaltungsoberfläche für Docker, wenn Docker ausgewählt wurde.

Der Normalzustand für einen Nutzer-PC bleibt blockadefrei: nichts wird installiert, aktiviert, veröffentlicht oder als Dienst eingerichtet, bevor der Nutzer die Option in der Erststart-Konfiguration gewählt und eine systemwirksame Änderung bestätigt hat.

## Erststart-Fragen

Der Agent muss die Fragen verständlich und abhängig voneinander stellen:

1. Möchtest du ein WSL-Backend für Linux-Tools und Entwickler- oder KI-Workflows vorbereiten?
2. Wenn ja: Soll Docker mit WSL-Unterstützung eingeplant werden?
3. Wenn ja: Möchtest du Portainer CE als kostenlose Docker-Verwaltungsoberfläche empfohlen bekommen?

In `hosts/<HOSTNAME>/state/first-run-config.yaml` werden dafür diese Präferenzen gespeichert:

```yaml
preferences:
  windows_wsl_backend: true
  windows_wsl_with_docker: false
  windows_portainer_ui: false
  windows_wsl_recommendations: true
```

Wenn `windows_wsl_backend` `false` ist, müssen Docker- und Portainer-Optionen ebenfalls `false` bleiben. Wenn Docker nicht ausgewählt ist, darf Portainer nicht automatisch empfohlen oder installiert werden.

## Empfehlungen

### WSL

WSL ist sinnvoll, wenn der Nutzer Linux-CLI-Tools, lokale KI-/Entwicklungswerkzeuge, Container-nahe Workflows oder reproduzierbare Linux-Shells auf Windows nutzen möchte. Der Agent darf WSL nur nach Nutzerfreigabe vorbereiten und muss vorab prüfen:

- Windows-Version und Admin-Kontext.
- vorhandene WSL-Installation mit `wsl --status` und `wsl --list --verbose`.
- ob ein Neustart erforderlich sein kann.
- ob der Nutzer eine Distribution bewusst auswählen möchte.

Für normale Windows-PCs ist der sichere Standard: offizielle WSL-Installation über Windows-Funktionen oder `wsl --install`, keine manuellen Fremdquellen und keine ungefragten Kernel-, Netzwerk- oder Dienständerungen.

### Docker mit WSL

Docker ist sinnvoll, wenn der Nutzer Container, lokale Services, KI-Stacks, Datenbank-Stacks oder reproduzierbare Testumgebungen nutzen möchte. Für normale Windows-PCs soll der Agent Docker Desktop mit WSL-2-Backend als bevorzugten, nutzerfreundlichen Weg dokumentieren, sofern Lizenz- und Nutzungskontext passen.

Vor Docker-Änderungen muss der Agent prüfen:

- ob WSL aktiv und stabil ist.
- ob Docker bereits installiert ist.
- ob `docker version` und `docker compose version` funktionieren.
- ob Docker in Windows und innerhalb der gewünschten WSL-Distribution erreichbar sein soll.
- ob Ressourcenlimits oder Autostart-Einstellungen gewünscht sind.

Der Agent darf keine produktiven Container, Volumes oder Images löschen. Cleanup bleibt immer separat freizugeben und volume-sensitiv zu dokumentieren.

### Portainer CE

Portainer CE ist sinnvoll, wenn der Nutzer Docker lieber über eine lokale Weboberfläche verwalten möchte. Portainer soll als optionale Empfehlung erscheinen, wenn Docker ausgewählt wurde. Der Agent darf Portainer nur nach Nutzerfreigabe als Container einplanen und muss dokumentieren:

- welchen Docker-Kontext Portainer verwaltet.
- auf welchem lokalen Port die Oberfläche erreichbar sein soll.
- dass die Oberfläche standardmäßig nicht öffentlich exponiert wird.
- wie der Portainer-Container gestoppt, aktualisiert oder entfernt werden kann.

Ohne Docker-Auswahl darf Portainer nicht installiert, gestartet oder als Pflichtkomponente behandelt werden.

## Vorlagenkopplung

Sobald WSL im Erststart gewählt wurde, muss der Agent zusätzlich zu `Vorlage/windows/common` auch `Vorlage/wsl/common` berücksichtigen. Bei Docker oder Portainer muss zusätzlich `Vorlage/container/common` berücksichtigt werden.

Wichtige Folgeprüfungen:

- `Vorlage/wsl/common/00-detect-wsl.md`
- `Vorlage/wsl/common/10-wsl-baseline.md`
- `Vorlage/wsl/common/70-klassische-sicherheitseinstellungen.md`
- `Vorlage/container/common/00-detect-container-stack.md`
- `Vorlage/container/common/20-container-security.md`
- `Vorlage/container/common/40-ports-und-exposure.md`

## Sicherheitsregeln

- Keine Installation ohne dokumentierte Frage-Antwort-Entscheidung.
- Keine Autostart- oder Dienständerung ohne Freigabe.
- Keine öffentlichen Portfreigaben für Docker, Portainer oder WSL-Services ohne separate Freigabe.
- Keine Secret-Werte, API-Keys, Registry-Tokens oder Portainer-Passwörter speichern.
- Keine Container-Volumes löschen, bevor Nutzung, Backup-Status und Rollback geklärt sind.
- Bei WSL/Docker-Problemen zuerst Dienst- und Kontextstatus prüfen, nicht blind neu installieren.

## Validierung

Nach einer freigegebenen Einrichtung oder Änderung muss der Agent passende Prüfungen dokumentieren:

```powershell
wsl --status
wsl --list --verbose
docker version
docker compose version
docker ps
```

Für Portainer zusätzlich:

```powershell
docker ps --filter name=portainer
```

Die Validierung muss klar zwischen Windows-Host, WSL-Distribution und Docker-Kontext unterscheiden.

## Rollback

Der Rollback-Pfad muss mindestens enthalten:

- deaktivierte oder entfernte Autostart-Einstellungen.
- Stoppen optionaler Container wie Portainer.
- Rücknahme lokaler Portfreigaben oder Firewall-Regeln.
- Hinweis, ob ein Neustart nötig ist.
- keine automatische Löschung von Docker-Volumes oder WSL-Distributionen ohne separate Freigabe.
