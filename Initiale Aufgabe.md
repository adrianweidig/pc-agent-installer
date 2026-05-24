# PC Agent Installer – Gesamtspezifikation

**Dokumenttyp:** Initiale vollständige Spezifikation  
**Stand:** 2026-05-24  
**Ziel:** Aufbau eines klonbaren Public-Template-Repositories und sicherer privater Operational-Repositories zur dokumentierten, reproduzierbaren und rückgängig machbaren Einrichtung von Windows-, Linux-, WSL-, Container- und Spezialhardware-Systemen.

---

## 1. Kurzfassung

Das Projekt **PC Agent Installer** ist ein Codex-/Agenten-gesteuertes Repository-Modell zur Einrichtung, Dokumentation und Pflege von Rechnern. Es besteht aus:

1. einem **öffentlichen Template-Repository**, das generische Vorlagen, Skripte, Schemas und Dokumentation enthält;
2. einem **privaten Operational-Repository**, das reale Host-Ordner, Baselines, Änderungen, Rollbacks, lokale Infrastrukturinformationen und Secret-Referenzen enthält;
3. optional einem **lokalen Git-only-Modus ohne Remote**, falls keinerlei Cloud-Remote genutzt werden soll.

Der Agent erkennt beim Start Hostname, Betriebssystem, Distribution, WSL-Status, Hardwareprofil und Container-Stacks. Danach erzeugt oder aktualisiert er unter `hosts/<HOSTNAME>/` eine nachvollziehbare Dokumentation.

**Oberstes Ziel:**  
Der Nutzer muss jederzeit wissen:

- was geändert wurde,
- wo es geändert wurde,
- warum es geändert wurde,
- mit welchem Befehl oder Skript es geändert wurde,
- wie die Änderung geprüft wurde,
- wie sie rückgängig gemacht werden kann.

Änderungen ohne Baseline, ohne Dokumentation und ohne Rollback-Strategie sind nicht zulässig.

---

## 2. Grundidee

Das Repository dient als **lokaler Agent-Installer** und zugleich als **Configuration-/State-Dokumentation**.

Beispiel:

```text
pc-agent-installer-private/
├─ Vorlage/
│  ├─ common/
│  ├─ windows/
│  ├─ linux/
│  ├─ wsl/
│  ├─ container/
│  └─ profiles/
└─ hosts/
   ├─ DESKTOP-ABC123/
   ├─ LAPTOP-XYZ789/
   └─ DGX-SPARK-01/
```

Wenn das Repo auf einem neuen Rechner geklont wird und Codex darin gestartet wird, muss der Agent erkennen:

1. Gibt es bereits einen Host-Ordner für diesen Rechner?
2. Ist das aktuelle Repository sicher, also privat oder lokal ohne öffentlichen Remote?
3. Welche Plattform liegt vor?
4. Welche Vorlagen passen?
5. Welche Baseline muss erfasst werden?
6. Welche Änderungen sind erforderlich?
7. Welche Änderungen müssen dokumentiert und rollbackfähig gemacht werden?

---

## 3. Public Template vs. Private Operational Repo

### 3.1 Öffentliches Template-Repository

Das öffentliche Repository enthält ausschließlich generische Inhalte:

- `AGENTS.md`
- Vorlagen unter `Vorlage/`
- Skripte unter `scripts/`
- Schemas unter `schemas/`
- Dokumentation unter `docs/`
- Beispiele unter `examples/`
- Lizenz, Security-Policy und Contribution-Dateien

Es darf **keine echten Hostdaten** enthalten.

### 3.2 Privates Operational-Repository

Das private Repository enthält zusätzlich:

- echte Host-Ordner,
- Baseline-Daten,
- Änderungsdokumentation,
- Rollback-Skripte,
- lokale Infrastrukturinformationen,
- Secret-Referenzen,
- sichere Hinweise auf externe Secret Stores.

### 3.3 Kein klassischer öffentlicher Fork als Private Repo

Ein öffentlicher GitHub-Fork eines öffentlichen Repositories ist in der Regel selbst öffentlich und als sicherer privater Betriebszweig ungeeignet. Stattdessen soll das Public Repo als **GitHub Template Repository** genutzt werden. Daraus wird ein neues privates Repository erzeugt.

Empfohlenes Modell:

```text
Public Upstream Template:
  github.com/<owner>/pc-agent-installer

Private Operational Copy:
  github.com/<user>/pc-agent-installer-private
  github.com/<org>/infra-agent-state
```

---

## 4. Repository-Modi

Das Projekt kennt drei Betriebsmodi.

### 4.1 Template-Modus

```yaml
repo_mode: template
visibility_required: public
allowed_to_write_hosts: false
allowed_to_document_sensitive_context: false
allowed_to_store_plaintext_secrets: false
```

Zweck:

- öffentlich klonbar,
- enthält nur generische Vorlagen,
- erzeugt keine Hostdaten,
- schreibt keine sensiblen Informationen.

### 4.2 Operational-Modus

```yaml
repo_mode: operational
visibility_required: private
allowed_to_write_hosts: true
allowed_to_document_sensitive_context: true
allowed_to_store_plaintext_secrets: false
```

Zweck:

- privates GitHub-Repository,
- Hostdaten erlaubt,
- Secret-Referenzen erlaubt,
- Klartext-Secrets weiterhin verboten.

### 4.3 Local-only-Modus

```yaml
repo_mode: local-only
visibility_required: no_remote
allowed_to_write_hosts: true
allowed_to_document_sensitive_context: true
allowed_to_store_plaintext_secrets: false
```

Zweck:

- lokales Git-Repository ohne Remote,
- geeignet für besonders sensible Hosts,
- kein Push ohne erneute Sichtbarkeitsprüfung.

---

## 5. Pflichtprüfung: Repo Visibility Guard

Codex muss bei jedem Start prüfen, ob das aktuelle Repository sicher ist.

### 5.1 Ablauf

```text
1. AGENTS.md lesen
2. Repo-Modus erkennen
3. Git-Remote prüfen
4. GitHub-Sichtbarkeit prüfen
5. Wenn Repo privat ist:
   → Host-Erfassung erlaubt

6. Wenn Repo lokal ohne Remote ist:
   → Host-Erfassung erlaubt
   → Push verboten, bis privater Remote bestätigt ist

7. Wenn Repo öffentlich ist oder Sichtbarkeit nicht sicher geprüft werden kann:
   → keine Hostdaten schreiben
   → keine Secrets dokumentieren
   → keine Baseline erzeugen
   → sichere Optionen anbieten
```

### 5.2 Verhalten bei öffentlichem Repo

```text
WARNUNG:
Dieses Repository ist öffentlich. Hostdaten, Infrastrukturinformationen,
Secrets, Tokens, private Pfade und sicherheitskritische Konfigurationen
werden hier nicht dokumentiert.

Sichere Optionen:
1. Private GitHub-Kopie aus Template erzeugen
2. Lokales Git-Repo ohne Remote verwenden
3. Abbrechen
```

### 5.3 GitHub-CLI-Prüfung

```bash
gh repo view --json isPrivate,visibility,nameWithOwner
```

### 5.4 API-/Fallback-Prüfung

Falls `gh` nicht verfügbar ist, soll Codex prüfen:

- `git remote -v`
- GitHub REST API, falls Token vorhanden
- lokale Konfiguration `repo-mode.yaml`
- ob überhaupt ein Remote existiert

Wenn keine sichere Prüfung möglich ist, gilt der Zustand als **nicht sicher bestätigt**.

---

## 6. Private Kopie erzeugen

### 6.1 Empfohlene Variante: GitHub Template

```bash
gh repo create <user>/pc-agent-installer-private \
  --template <owner>/pc-agent-installer \
  --private \
  --clone
```

Danach arbeitet Codex nur noch im privaten Repo.

### 6.2 Lokaler Git-only-Modus

```bash
git clone https://github.com/<owner>/pc-agent-installer.git pc-agent-installer-local
cd pc-agent-installer-local
git remote remove origin
git init
git add .
git commit -m "Initial local operational copy"
```

Danach darf Codex Host-Ordner lokal befüllen, aber nicht pushen, solange kein privater Remote gesetzt und geprüft wurde.

---

## 7. Lizenzmodell

Empfohlene Lizenz für das öffentliche Repository: **Apache License 2.0**.

Begründung:

- erlaubt Nutzung, Kopieren, Änderung und Weiterverteilung,
- erlaubt private und interne Nutzung,
- erlaubt abgeleitete private Operational-Repositories,
- enthält zusätzlich eine Patentlizenz,
- ist für ein öffentliches technisches Template robust geeignet.

Zusätzliche Klarstellung in `NOTICE` oder `docs/lizenzmodell.md`:

```text
Dieses Repository ist als öffentliches Template gedacht.
Die Apache-2.0-Lizenz erlaubt das Kopieren, Ändern und private Verwenden
des Projekts.

Hostdaten, private Konfigurationsstände, Secret-Referenzen, lokale
Infrastrukturinformationen und Nutzerinhalte, die in einem privaten
abgeleiteten Repository entstehen, sind nicht Teil des öffentlichen
Upstream-Projekts.

Klartext-Secrets sollen weder im öffentlichen noch im privaten Repository
gespeichert werden.
```

---

## 8. Sicherheitsmodell

### 8.1 Grundregeln

- Kein Schreiben von Hostdaten in öffentlichen Repositories.
- Kein Schreiben von sicherheitskritischen Details, solange die Repo-Sichtbarkeit nicht sicher geprüft ist.
- Keine Klartext-Secrets im Repo.
- Jede Änderung braucht Baseline, Dokumentation, Prüfung und Rollback.
- Destruktive Aktionen brauchen vorherige Nutzerfreigabe.
- Admin-/Root-/Sudo-Aktionen müssen explizit markiert werden.
- Alle Befehle müssen nachvollziehbar dokumentiert werden.
- Vorher-/Nachher-Zustand muss erfasst werden.

### 8.2 Erlaubt im privaten Repo

```text
✅ Secret-Namen
✅ Secret-Zweck
✅ Ablageort
✅ Zugriffsmethode
✅ benötigte Berechtigungen
✅ Rotationshinweise
✅ verschlüsselte Secret-Dateien, falls explizit vorgesehen
✅ lokale Pfade zu nicht versionierten Secret-Dateien
✅ Hinweise auf Vault, Passwortmanager oder OS Secret Store
```

### 8.3 Nicht erlaubt

```text
❌ Klartext-Passwörter
❌ Klartext-Tokens
❌ private Schlüssel
❌ API-Keys
❌ ungefilterte .env-Dateien
❌ kubeconfig mit produktiven Tokens
❌ SSH Private Keys
❌ Zertifikats-Private-Keys
```

### 8.4 Secret-Referenzdatei pro Host

Pfad:

```text
hosts/<HOSTNAME>/security/secret-references.md
```

Beispiel:

```md
# Secret-Referenzen

## docker-registry-token

- Zweck: Login zur privaten Container Registry
- Benötigt von: Docker Compose Projekt `xyz`
- Ablageort: lokaler Passwortmanager / OS Secret Store / Vault
- Umgebungsvariable zur Laufzeit: REGISTRY_TOKEN
- Klartext im Repo: nein
- Rotation: manuell alle 90 Tage
- Zugriff durch Agent: nur nach Nutzerfreigabe
```

Maschinenlesbare Variante:

```yaml
secrets:
  - id: docker-registry-token
    purpose: private container registry login
    value_stored_in_repo: false
    storage_backend: local-secret-store
    runtime_env_name: REGISTRY_TOKEN
    agent_access: requires_user_approval
    rotation: manual-90-days
```

---

## 9. Vollständige initiale Repo-Struktur

```text
pc-agent-installer/
├─ AGENTS.md
├─ README.md
├─ LICENSE
├─ NOTICE
├─ SECURITY.md
├─ CONTRIBUTING.md
├─ CHANGELOG.md
├─ .gitignore
├─ .gitattributes
├─ .editorconfig
│
├─ docs/
│  ├─ 00-konzept.md
│  ├─ 01-public-template-vs-private-operational-repo.md
│  ├─ 02-private-repo-erzeugen.md
│  ├─ 03-repo-visibility-guard.md
│  ├─ 04-sicherheitsmodell.md
│  ├─ 05-secrets-policy.md
│  ├─ 06-sicherer-betriebsmodus.md
│  ├─ 07-dokumentationsstandard.md
│  ├─ 08-rollback-konzept.md
│  ├─ 09-plattform-erkennung.md
│  ├─ 10-container-modell.md
│  ├─ 11-lizenzmodell.md
│  └─ 99-faq.md
│
├─ schemas/
│  ├─ host.schema.yaml
│  ├─ change-entry.schema.yaml
│  ├─ baseline.schema.yaml
│  ├─ template-frontmatter.schema.yaml
│  ├─ rollback.schema.yaml
│  ├─ repo-mode.schema.yaml
│  ├─ secret-reference.schema.yaml
│  └─ container-stack.schema.yaml
│
├─ Vorlage/
│  ├─ common/
│  │  ├─ 00-agent-regeln.md
│  │  ├─ 01-repo-modus-erkennen.md
│  │  ├─ 02-repo-visibility-prüfen.md
│  │  ├─ 03-private-repo-erzwingen.md
│  │  ├─ 04-local-only-fallback.md
│  │  ├─ 05-host-ordner-erzeugen.md
│  │  ├─ 06-baseline-pflicht.md
│  │  ├─ 07-dokumentationsstandard.md
│  │  ├─ 08-rollback-pflicht.md
│  │  ├─ 09-secrets-und-private-daten.md
│  │  ├─ 10-admin-und-sudo-regeln.md
│  │  ├─ 11-validierung-und-tests.md
│  │  ├─ 12-git-commit-regeln.md
│  │  └─ 99-abschlussbericht.md
│  │
│  ├─ windows/
│  │  ├─ common/
│  │  │  ├─ 00-detect-windows.md
│  │  │  ├─ 10-baseline-system.md
│  │  │  ├─ 11-baseline-hardware.md
│  │  │  ├─ 12-baseline-benutzer.md
│  │  │  ├─ 13-baseline-netzwerk.md
│  │  │  ├─ 14-baseline-installierte-programme.md
│  │  │  ├─ 20-winget.md
│  │  │  ├─ 21-powershell-module.md
│  │  │  ├─ 30-firewall.md
│  │  │  ├─ 31-netzwerkprofile.md
│  │  │  ├─ 40-env-variablen.md
│  │  │  ├─ 50-dienste.md
│  │  │  ├─ 60-registry.md
│  │  │  ├─ 70-autostart.md
│  │  │  ├─ 80-dateisystem.md
│  │  │  ├─ 90-windows-features.md
│  │  │  └─ 99-windows-report.md
│  │  ├─ windows-10/
│  │  │  ├─ 00-version-prüfen.md
│  │  │  ├─ 10-spezifische-features.md
│  │  │  └─ 99-report.md
│  │  ├─ windows-11/
│  │  │  ├─ 00-version-prüfen.md
│  │  │  ├─ 10-spezifische-features.md
│  │  │  ├─ 20-winget-standardpakete.md
│  │  │  └─ 99-report.md
│  │  └─ windows-server/
│  │     ├─ 00-version-prüfen.md
│  │     ├─ 10-serverrollen.md
│  │     ├─ 20-firewall-serverprofil.md
│  │     └─ 99-report.md
│  │
│  ├─ linux/
│  │  ├─ common/
│  │  │  ├─ 00-detect-linux.md
│  │  │  ├─ 10-baseline-system.md
│  │  │  ├─ 11-baseline-hardware.md
│  │  │  ├─ 12-baseline-benutzer-und-gruppen.md
│  │  │  ├─ 13-baseline-netzwerk.md
│  │  │  ├─ 14-baseline-paketmanager.md
│  │  │  ├─ 20-pakete.md
│  │  │  ├─ 30-firewall.md
│  │  │  ├─ 40-shell-env.md
│  │  │  ├─ 50-systemd.md
│  │  │  ├─ 60-ssh.md
│  │  │  ├─ 70-dateisystem.md
│  │  │  ├─ 80-kernel-und-treiber.md
│  │  │  ├─ 90-sudo-und-rechte.md
│  │  │  └─ 99-linux-report.md
│  │  ├─ debian/
│  │  │  ├─ common/
│  │  │  │  ├─ 00-detect-debian-family.md
│  │  │  │  ├─ 10-apt-baseline.md
│  │  │  │  ├─ 20-apt-sources.md
│  │  │  │  ├─ 30-apt-packages.md
│  │  │  │  ├─ 40-ufw-oder-nftables.md
│  │  │  │  └─ 99-report.md
│  │  │  ├─ debian/
│  │  │  │  ├─ 00-detect-debian.md
│  │  │  │  ├─ 10-debian-pakete.md
│  │  │  │  └─ 99-report.md
│  │  │  └─ ubuntu/
│  │  │     ├─ 00-detect-ubuntu.md
│  │  │     ├─ 10-ubuntu-pakete.md
│  │  │     ├─ 20-snap.md
│  │  │     ├─ 30-ppa-policy.md
│  │  │     └─ 99-report.md
│  │  ├─ rhel/
│  │  │  ├─ common/
│  │  │  │  ├─ 00-detect-rhel-family.md
│  │  │  │  ├─ 10-dnf-baseline.md
│  │  │  │  ├─ 20-repositories.md
│  │  │  │  ├─ 30-firewalld.md
│  │  │  │  └─ 99-report.md
│  │  │  ├─ fedora/
│  │  │  │  ├─ 00-detect-fedora.md
│  │  │  │  ├─ 10-fedora-pakete.md
│  │  │  │  └─ 99-report.md
│  │  │  ├─ rocky/
│  │  │  │  ├─ 00-detect-rocky.md
│  │  │  │  └─ 99-report.md
│  │  │  └─ almalinux/
│  │  │     ├─ 00-detect-almalinux.md
│  │  │     └─ 99-report.md
│  │  ├─ arch/
│  │  │  ├─ common/
│  │  │  │  ├─ 00-detect-arch-family.md
│  │  │  │  ├─ 10-pacman-baseline.md
│  │  │  │  ├─ 20-pacman-packages.md
│  │  │  │  ├─ 30-aur-policy.md
│  │  │  │  └─ 99-report.md
│  │  │  └─ archlinux/
│  │  │     ├─ 00-detect-archlinux.md
│  │  │     └─ 99-report.md
│  │  └─ nvidia/
│  │     ├─ common/
│  │     │  ├─ 00-detect-nvidia-hardware.md
│  │     │  ├─ 10-nvidia-smi-baseline.md
│  │     │  ├─ 20-cuda-baseline.md
│  │     │  ├─ 30-treiber-baseline.md
│  │     │  └─ 99-report.md
│  │     ├─ dgx-os/
│  │     │  ├─ 00-detect-dgx-os.md
│  │     │  ├─ 10-dgx-os-baseline.md
│  │     │  └─ 99-report.md
│  │     └─ dgx-spark/
│  │        ├─ 00-detect-dgx-spark.md
│  │        ├─ 10-dgx-spark-baseline.md
│  │        ├─ 20-gpu-container-runtime.md
│  │        └─ 99-report.md
│  │
│  ├─ wsl/
│  │  ├─ common/
│  │  │  ├─ 00-detect-wsl.md
│  │  │  ├─ 10-wsl-baseline.md
│  │  │  ├─ 20-wsl-version.md
│  │  │  ├─ 30-wsl-config.md
│  │  │  ├─ 40-windows-integration.md
│  │  │  ├─ 50-networking.md
│  │  │  ├─ 60-filesystem-mounts.md
│  │  │  └─ 99-wsl-report.md
│  │  ├─ ubuntu/
│  │  │  ├─ 00-detect-wsl-ubuntu.md
│  │  │  ├─ 10-apt-baseline.md
│  │  │  └─ 99-report.md
│  │  ├─ debian/
│  │  │  ├─ 00-detect-wsl-debian.md
│  │  │  ├─ 10-apt-baseline.md
│  │  │  └─ 99-report.md
│  │  ├─ kali/
│  │  │  ├─ 00-detect-wsl-kali.md
│  │  │  └─ 99-report.md
│  │  └─ arch/
│  │     ├─ 00-detect-wsl-arch.md
│  │     └─ 99-report.md
│  │
│  ├─ container/
│  │  ├─ common/
│  │  │  ├─ 00-detect-container-stack.md
│  │  │  ├─ 10-container-baseline.md
│  │  │  ├─ 20-container-security.md
│  │  │  ├─ 30-images.md
│  │  │  ├─ 31-containers.md
│  │  │  ├─ 32-networks.md
│  │  │  ├─ 33-volumes.md
│  │  │  ├─ 40-ports-und-exposure.md
│  │  │  ├─ 50-secrets-policy.md
│  │  │  └─ 99-container-report.md
│  │  ├─ runtime/
│  │  │  ├─ docker/
│  │  │  │  ├─ 00-detect-docker.md
│  │  │  │  ├─ 10-docker-engine-baseline.md
│  │  │  │  ├─ 20-docker-daemon-json.md
│  │  │  │  ├─ 30-docker-rootless.md
│  │  │  │  ├─ 40-docker-networks.md
│  │  │  │  ├─ 50-docker-volumes.md
│  │  │  │  ├─ 60-docker-images.md
│  │  │  │  └─ 99-docker-report.md
│  │  │  └─ podman/
│  │  │     ├─ 00-detect-podman.md
│  │  │     ├─ 10-podman-baseline.md
│  │  │     ├─ 20-podman-rootless.md
│  │  │     ├─ 30-podman-systemd.md
│  │  │     ├─ 40-podman-pods.md
│  │  │     ├─ 50-podman-networks.md
│  │  │     └─ 99-podman-report.md
│  │  ├─ compose/
│  │  │  └─ docker-compose/
│  │  │     ├─ 00-detect-compose.md
│  │  │     ├─ 10-compose-baseline.md
│  │  │     ├─ 20-compose-files.md
│  │  │     ├─ 30-compose-projects.md
│  │  │     ├─ 40-compose-env-files.md
│  │  │     ├─ 50-compose-secrets.md
│  │  │     └─ 99-compose-report.md
│  │  ├─ orchestration/
│  │  │  ├─ docker-swarm/
│  │  │  │  ├─ 00-detect-swarm.md
│  │  │  │  ├─ 10-swarm-baseline.md
│  │  │  │  ├─ 20-swarm-nodes.md
│  │  │  │  ├─ 30-swarm-services.md
│  │  │  │  ├─ 40-swarm-stacks.md
│  │  │  │  ├─ 50-swarm-secrets.md
│  │  │  │  └─ 99-swarm-report.md
│  │  │  └─ kubernetes/
│  │  │     ├─ 00-detect-kubernetes.md
│  │  │     ├─ 10-kubeconfig-contexts.md
│  │  │     ├─ 20-cluster-baseline.md
│  │  │     ├─ 30-namespaces.md
│  │  │     ├─ 40-workloads.md
│  │  │     ├─ 50-services-ingress.md
│  │  │     ├─ 60-storage.md
│  │  │     ├─ 70-rbac.md
│  │  │     ├─ 80-secrets.md
│  │  │     ├─ 90-declarative-apply.md
│  │  │     └─ 99-kubernetes-report.md
│  │  └─ hardware/
│  │     └─ nvidia/
│  │        ├─ 00-detect-nvidia-container-runtime.md
│  │        ├─ 10-nvidia-container-toolkit.md
│  │        ├─ 20-docker-gpu-runtime.md
│  │        ├─ 30-podman-gpu-runtime.md
│  │        ├─ 40-kubernetes-gpu-runtime.md
│  │        └─ 99-nvidia-container-report.md
│  │
│  └─ profiles/
│     ├─ laptop/
│     │  ├─ 00-detect-laptop.md
│     │  ├─ 10-power-management.md
│     │  ├─ 20-wifi-bluetooth.md
│     │  └─ 99-report.md
│     ├─ workstation/
│     │  ├─ 00-detect-workstation.md
│     │  ├─ 10-development-tools.md
│     │  └─ 99-report.md
│     ├─ server/
│     │  ├─ 00-detect-server.md
│     │  ├─ 10-server-baseline.md
│     │  └─ 99-report.md
│     └─ gpu-workstation/
│        ├─ 00-detect-gpu-workstation.md
│        ├─ 10-gpu-baseline.md
│        └─ 99-report.md
│
├─ scripts/
│  ├─ common/
│  │  ├─ detect-repo-mode.ps1
│  │  ├─ detect-repo-mode.sh
│  │  ├─ assert-private-repo.ps1
│  │  ├─ assert-private-repo.sh
│  │  ├─ create-private-copy.ps1
│  │  ├─ create-private-copy.sh
│  │  ├─ enable-local-only-mode.ps1
│  │  ├─ enable-local-only-mode.sh
│  │  ├─ redact-sensitive-output.ps1
│  │  └─ redact-sensitive-output.sh
│  ├─ powershell/
│  │  ├─ detect-platform.ps1
│  │  ├─ detect-host.ps1
│  │  ├─ collect-baseline.ps1
│  │  ├─ collect-windows-firewall.ps1
│  │  ├─ collect-windows-env.ps1
│  │  ├─ collect-winget.ps1
│  │  ├─ apply-step.ps1
│  │  ├─ validate-step.ps1
│  │  ├─ rollback-step.ps1
│  │  └─ write-change-entry.ps1
│  ├─ bash/
│  │  ├─ detect-platform.sh
│  │  ├─ detect-host.sh
│  │  ├─ collect-baseline.sh
│  │  ├─ collect-linux-packages.sh
│  │  ├─ collect-linux-firewall.sh
│  │  ├─ collect-systemd.sh
│  │  ├─ apply-step.sh
│  │  ├─ validate-step.sh
│  │  ├─ rollback-step.sh
│  │  └─ write-change-entry.sh
│  └─ container/
│     ├─ detect-container-stack.sh
│     ├─ detect-container-stack.ps1
│     ├─ collect-docker.sh
│     ├─ collect-docker.ps1
│     ├─ collect-podman.sh
│     ├─ collect-compose.sh
│     ├─ collect-swarm.sh
│     ├─ collect-kubernetes.sh
│     └─ collect-nvidia-container.sh
│
├─ private.example/
│  ├─ README.md
│  ├─ secret-references.example.yaml
│  ├─ vault-references.example.yaml
│  └─ local-paths.example.yaml
│
├─ examples/
│  ├─ example-host.yaml
│  ├─ example-change-entry.md
│  ├─ example-rollback.ps1
│  ├─ example-rollback.sh
│  ├─ example-container-stack.yaml
│  └─ example-template-frontmatter.md
│
└─ hosts/
   └─ .gitkeep
```

---

## 10. Zielstruktur eines erzeugten Host-Ordners

Beispiel:

```text
hosts/
└─ DESKTOP-ABC123/
   ├─ host.yaml
   ├─ README.md
   │
   ├─ baseline/
   │  ├─ system.md
   │  ├─ hardware.md
   │  ├─ users.md
   │  ├─ groups.md
   │  ├─ network.md
   │  ├─ packages.md
   │  ├─ services.md
   │  ├─ firewall.md
   │  ├─ environment.md
   │  ├─ filesystem.md
   │  ├─ security.md
   │  └─ raw/
   │     ├─ os-release.txt
   │     ├─ systeminfo.txt
   │     ├─ winget-export.json
   │     ├─ docker-info.json
   │     ├─ podman-info.json
   │     └─ kubectl-contexts.txt
   │
   ├─ changes/
   │  ├─ 2026-05-24_0001_baseline.md
   │  ├─ 2026-05-24_0002_firewall.md
   │  ├─ 2026-05-24_0003_env.md
   │  └─ 2026-05-24_0004_container.md
   │
   ├─ rollback/
   │  ├─ 2026-05-24_0002_firewall.rollback.ps1
   │  ├─ 2026-05-24_0003_env.rollback.ps1
   │  └─ 2026-05-24_0004_container.rollback.sh
   │
   ├─ security/
   │  ├─ secret-references.md
   │  ├─ secret-references.yaml
   │  └─ access-notes.md
   │
   ├─ container/
   │  ├─ container-stack.yaml
   │  ├─ docker/
   │  │  ├─ baseline.md
   │  │  ├─ daemon-json.md
   │  │  ├─ images.md
   │  │  ├─ containers.md
   │  │  ├─ networks.md
   │  │  ├─ volumes.md
   │  │  └─ ports.md
   │  ├─ compose/
   │  │  ├─ projects.md
   │  │  ├─ compose-files.md
   │  │  ├─ env-files.md
   │  │  └─ secrets.md
   │  ├─ swarm/
   │  │  ├─ baseline.md
   │  │  ├─ nodes.md
   │  │  ├─ services.md
   │  │  ├─ stacks.md
   │  │  └─ secrets.md
   │  ├─ kubernetes/
   │  │  ├─ contexts.md
   │  │  ├─ cluster.md
   │  │  ├─ namespaces.md
   │  │  ├─ workloads.md
   │  │  ├─ services-ingress.md
   │  │  ├─ storage.md
   │  │  ├─ rbac.md
   │  │  └─ secrets.md
   │  └─ podman/
   │     ├─ baseline.md
   │     ├─ containers.md
   │     ├─ pods.md
   │     ├─ networks.md
   │     ├─ volumes.md
   │     └─ systemd-units.md
   │
   ├─ logs/
   │  ├─ 2026-05-24_0001_transcript.txt
   │  ├─ 2026-05-24_0002_apply.log
   │  └─ 2026-05-24_0003_validate.log
   │
   └─ state/
      ├─ applied-templates.yaml
      ├─ detected-platform.yaml
      ├─ pending-actions.yaml
      └─ last-run.yaml
```

---

## 11. Beispiel `host.yaml`

```yaml
host_id: DESKTOP-ABC123
hostname: DESKTOP-ABC123
created_at: 2026-05-24T12:00:00+02:00
last_seen_at: 2026-05-24T12:00:00+02:00

repo:
  mode: operational
  visibility_checked: true
  visibility: private
  allowed_to_write_hosts: true

platform:
  os: windows
  environment: native
  version: "11"
  edition: "Pro"
  architecture: "x64"

linux:
  family: null
  distribution: null
  version_id: null

wsl:
  enabled: true
  distributions:
    - name: Ubuntu
      version: "2"
      default: true

hardware:
  profile: laptop
  vendor: null
  gpu_vendor: nvidia
  gpu_present: true

container:
  docker: true
  docker_compose: true
  docker_swarm: false
  kubernetes: false
  podman: false
  nvidia_container_runtime: true

template_paths_used:
  - Vorlage/common
  - Vorlage/windows/common
  - Vorlage/windows/windows-11
  - Vorlage/container/common
  - Vorlage/container/runtime/docker
  - Vorlage/container/compose/docker-compose
  - Vorlage/container/hardware/nvidia
  - Vorlage/profiles/laptop
```

---

## 12. Vorlagenmodell

Alle Vorlagen sind Markdown-Dateien. Sie sind nummeriert und werden sortiert ausgeführt.

### 12.1 Allgemeine Frontmatter-Struktur

```yaml
---
id: TEMPLATE-ID
title: Titel der Aufgabe
platform: windows|linux|any
environment: native|wsl|container|any
family: debian|rhel|arch|nvidia|none
distribution: ubuntu|debian|fedora|archlinux|dgx-os|none
version: ">=22.04"
hardware_profile: generic|laptop|workstation|server|gpu-workstation|dgx-spark
requires_admin: true
risk: niedrig|mittel|hoch
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - Vorlage/pfad
paired_scripts:
  detect: scripts/.../detect.sh
  apply: scripts/.../apply.sh
  validate: scripts/.../validate.sh
  rollback: scripts/.../rollback.sh
---
```

### 12.2 Windows-Beispiel

```yaml
---
id: WINDOWS-FW-001
title: Windows Firewall Baseline erfassen
platform: windows
environment: native
area: firewall
requires_admin: true
risk: mittel
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - windows/common
---
```

### 12.3 Linux-Ubuntu-Beispiel

```yaml
---
id: LINUX-UBUNTU-APT-001
title: Basispakete installieren
platform: linux
environment: native
family: debian
distribution: ubuntu
version: ">=22.04"
hardware_profile: generic
requires_admin: true
risk: mittel
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - linux/debian/ubuntu
depends_on:
  - linux/common/10-baseline
---
```

### 12.4 WSL-Beispiel

```yaml
---
id: WSL-UBUNTU-001
title: Ubuntu WSL Baseline erfassen
platform: linux
environment: wsl
family: debian
distribution: ubuntu
wsl_version: "2"
requires_windows_host: true
requires_admin: false
risk: niedrig
rollback_required: true
idempotent: true
applies_to:
  - wsl/ubuntu
---
```

### 12.5 DGX-Spark-Beispiel

```yaml
---
id: NVIDIA-DGX-SPARK-001
title: DGX Spark Baseline erfassen
platform: linux
environment: native
family: debian
distribution: dgx-os
hardware_profile: dgx-spark
vendor: nvidia
requires_admin: true
risk: hoch
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - linux/nvidia/dgx-spark
  - linux/nvidia/dgx-os
---
```

### 12.6 Docker-Beispiel

```yaml
---
id: CONTAINER-DOCKER-001
title: Docker Engine Baseline erfassen
platform: linux
environment: native
container_layer: runtime
container_runtime: docker
orchestrator: none
requires_admin: true
rootless_supported: true
risk: mittel
approval_required: false
rollback_required: false
idempotent: true
applies_to:
  - container/runtime/docker
depends_on:
  - linux/common/10-baseline
---
```

### 12.7 Docker Compose-Beispiel

```yaml
---
id: CONTAINER-COMPOSE-001
title: Docker Compose Projekte dokumentieren
container_layer: compose
container_runtime: docker
compose_engine: docker-compose-v2
orchestrator: none
requires_admin: false
risk: niedrig
approval_required: false
rollback_required: true
idempotent: true
applies_to:
  - container/compose/docker-compose
---
```

### 12.8 Kubernetes-Beispiel

```yaml
---
id: CONTAINER-K8S-001
title: Kubernetes Kontext und Cluster-Baseline erfassen
container_layer: orchestration
orchestrator: kubernetes
runtime: containerd/docker/cri-o/unknown
requires_admin: false
cluster_scope: true
risk: hoch
approval_required: true
rollback_required: true
idempotent: true
applies_to:
  - container/orchestration/kubernetes
---
```

---

## 13. Ausführungsreihenfolge

Codex soll immer in dieser Reihenfolge arbeiten:

```text
1. AGENTS.md lesen
2. Vorlage/common lesen
3. Repo-Modus erkennen
4. Repo-Sichtbarkeit prüfen
5. Bei öffentlichem oder ungeprüftem Repo keine Hostdaten schreiben
6. Hostname und Plattform erkennen
7. Host-Ordner unter hosts/<HOSTNAME>/ erzeugen oder öffnen
8. Baseline erfassen
9. OS-Vorlagen ausführen
10. Distribution-/Versionsvorlagen ausführen
11. WSL-Vorlagen ausführen, falls zutreffend
12. Hardwareprofile ausführen, falls zutreffend
13. Container-Stacks erkennen
14. Container-Vorlagen ausführen
15. Änderungen dokumentieren
16. Rollback-Dateien erzeugen
17. Validierung ausführen
18. Abschlussbericht erzeugen
19. Git-Status anzeigen
20. Nutzer vor Commit oder Push bestätigen lassen
```

---

## 14. Plattform-Erkennung

### 14.1 Windows

Zu erfassen:

- Hostname
- Windows-Version
- Edition
- Architektur
- PowerShell-Version
- Benutzerkontext
- Adminstatus
- Netzwerkkonfiguration
- installierte Programme
- Windows Features
- Firewall-Regeln
- Dienste
- Registry-relevante Abweichungen
- Umgebungsvariablen

### 14.2 Linux

Primäre Erkennung über:

```text
/etc/os-release
```

Relevante Felder:

```text
ID
VERSION_ID
ID_LIKE
PRETTY_NAME
VERSION_CODENAME
```

Daraus ableiten:

```text
platform: linux
family: debian|rhel|arch|nvidia|unknown
distribution: ubuntu|debian|fedora|rocky|almalinux|archlinux|dgx-os|unknown
```

### 14.3 WSL

Zu erkennen:

- läuft das System unter WSL?
- WSL 1 oder WSL 2?
- welche Distribution?
- Windows-Host-Integration?
- Mounts unter `/mnt/c`?
- Netzwerkkonfiguration?
- `.wslconfig` und `/etc/wsl.conf`, falls vorhanden?

Beispielbefehle:

```bash
cat /proc/version
cat /etc/os-release
```

Von Windows-Seite:

```powershell
wsl.exe --list --verbose
```

### 14.4 Spezialhardware

Zusätzliche Profile:

- Laptop
- Workstation
- Server
- GPU Workstation
- NVIDIA DGX OS
- DGX Spark

Erkennung unter anderem über:

```bash
nvidia-smi
lspci
lsusb
dmidecode
hostnamectl
```

---

## 15. Container-Modell

Container sind keine klassische Distribution, sondern eine eigene Runtime-/Orchestrierungs-Ebene.

Unterstützt werden:

- Docker
- Docker Compose
- Docker Swarm
- Kubernetes
- Podman
- NVIDIA Container Runtime / NVIDIA Container Toolkit

### 15.1 Erkennungslogik

```text
1. Ist Docker installiert?
   → docker version
   → docker info
   → Vorlage/container/runtime/docker

2. Ist Docker Compose installiert?
   → docker compose version
   → Suche nach compose.yaml, compose.yml, docker-compose.yaml
   → Vorlage/container/compose/docker-compose

3. Ist Docker Swarm aktiv?
   → docker info | Swarm
   → docker node ls, falls Manager
   → Vorlage/container/orchestration/docker-swarm

4. Ist Kubernetes nutzbar?
   → kubectl version
   → kubectl config current-context
   → kubectl cluster-info
   → Vorlage/container/orchestration/kubernetes

5. Ist Podman installiert?
   → podman version
   → podman info
   → Vorlage/container/runtime/podman

6. Ist NVIDIA-GPU-/Container-Support relevant?
   → nvidia-smi
   → nvidia-ctk
   → containerd/docker/podman GPU-Runtime-Konfiguration
   → Vorlage/container/hardware/nvidia
```

### 15.2 Container-Pflichtdokumentation

Der Nutzer muss pro Container-Stack sehen können:

- welche Runtime aktiv ist,
- welche Container laufen,
- welche Images lokal vorhanden sind,
- welche Volumes persistent sind,
- welche Ports exponiert sind,
- welche Netzwerke existieren,
- welche Compose-/Kubernetes-/Swarm-Definitionen zuständig sind,
- welche Secrets referenziert werden,
- wie Stop, Rollback oder Wiederherstellung erfolgen.

### 15.3 Container-Änderungsregeln

- Keine Container löschen ohne Dokumentation und Freigabe.
- Keine Images löschen ohne Impact-Bewertung.
- Keine Volumes löschen ohne explizite Freigabe und Backup-Hinweis.
- Keine Kubernetes-Ressourcen löschen ohne vorheriges Manifest/Export und Rollback-Pfad.
- Keine Compose-Env-Dateien mit Klartext-Secrets committen.
- Kubernetes-Secrets nicht ungefiltert exportieren.
- Docker-/Swarm-/Kubernetes-Secrets nur referenzieren, nicht im Klartext speichern.

---

## 16. Baseline-Pflichten

Beim ersten Lauf pro Host müssen mindestens dokumentiert werden:

### 16.1 Allgemein

- Hostname
- Betriebssystem
- Version
- Architektur
- Benutzerkontext
- Admin-/Root-/Sudo-Status
- Datum/Zeit der Erfassung
- verwendete Vorlagenpfade
- Repo-Modus
- Repo-Sichtbarkeit

### 16.2 Windows

- Systeminformationen
- Hardware
- installierte Programme
- Winget-Export, falls verfügbar
- Firewall-Regeln
- Netzwerkprofile
- Dienste
- Autostart
- Umgebungsvariablen
- relevante Registry-Bereiche
- PowerShell-Module
- Windows Features
- Transcript/Log

### 16.3 Linux

- `/etc/os-release`
- Kernel
- Paketmanager
- installierte Pakete
- Repositories
- Dienste/Systemd Units
- Firewall-Status
- SSH-Konfiguration
- Benutzer/Gruppen
- Shell-Profile
- Umgebungsvariablen
- Dateisystem/Mounts
- Treiber/Kernelmodule

### 16.4 WSL

- WSL-Version
- Distribution
- Windows-Integration
- Mounts
- Netzwerk
- `/etc/wsl.conf`
- relevante Windows-seitige WSL-Konfiguration

### 16.5 Container

- Docker-Version und `docker info`
- Docker Daemon-Konfiguration
- Docker Images
- Docker Container
- Docker Netzwerke
- Docker Volumes
- Compose-Projekte
- Swarm-Status, Nodes, Services und Stacks
- Kubernetes-Kontexte
- Kubernetes Namespaces, Workloads, Services, Ingress, Storage, RBAC
- Podman-Info, Container, Pods, Netzwerke, Volumes, Systemd Units
- NVIDIA Container Runtime, falls vorhanden

---

## 17. Änderungsdokumentation

Jede Änderung in `hosts/<HOSTNAME>/changes/` muss einheitlich aufgebaut sein.

```md
# Änderung: Kurzbeschreibung

## Metadaten
- Datum:
- Hostname:
- Repo-Modus:
- Repo-Sichtbarkeit geprüft:
- Bereich:
- Ebene: User/System/Repo/Container/Cluster
- Risiko:
- Adminrechte erforderlich:
- Nutzerfreigabe erforderlich:
- Status: geplant/ausgeführt/fehlgeschlagen/rückgängig gemacht

## Ausgangszustand
Was war vorher konfiguriert?

## Zielzustand
Was soll erreicht werden?

## Änderung
Was wurde geändert?

## Ort der Änderung
Registry-Pfad, Datei, Dienst, Firewall-Regel, Env-Variable, Container-Ressource etc.

## Ausgeführte Befehle
```powershell
# oder bash
```

## Betroffene Dateien
- Pfad 1
- Pfad 2

## Prüfung
Wie wurde validiert?

## Rollback
Exakter Rückweg inkl. Befehl oder Skript.

## Risiken und Hinweise
Bekannte Probleme, Abhängigkeiten, manuelle Schritte.
```

---

## 18. Rollback-Pflicht

Jede systemwirksame Änderung braucht:

- Vorher-Wert,
- Nachher-Wert,
- Rollback-Befehl,
- Rollback-Skript,
- Validierung des Rollbacks,
- Dokumentation in `changes/`,
- Datei unter `rollback/`.

Beispiele:

```text
Firewall-Änderung:
  hosts/<HOSTNAME>/rollback/2026-05-24_0002_firewall.rollback.ps1

Linux-Service-Änderung:
  hosts/<HOSTNAME>/rollback/2026-05-24_0005_systemd.rollback.sh

Container-Änderung:
  hosts/<HOSTNAME>/rollback/2026-05-24_0008_container.rollback.sh
```

---

## 19. Git-Regeln

### 19.1 Kein automatischer Push ohne Freigabe

Codex darf:

- `git status` ausführen,
- Änderungen zusammenfassen,
- Commit-Vorschlag machen,
- Commit vorbereiten.

Codex darf nicht ohne Freigabe:

- pushen,
- Remote ändern,
- Branch löschen,
- History rewrite ausführen,
- Secrets aus der Historie entfernen, ohne Nutzer zu informieren.

### 19.2 Commit-Konvention

Empfohlen:

```text
host(<HOSTNAME>): document baseline
host(<HOSTNAME>): update firewall documentation
host(<HOSTNAME>): document docker stack
repo: update template structure
security: update secret reference policy
```

---

## 20. `.gitignore`-Grundlage

```gitignore
# Secrets
.env
.env.*
*.pem
*.key
*.pfx
*.p12
id_rsa
id_ed25519
kubeconfig
kubeconfig.*

# Lokale Dumps
*.dump
*.bak
*.tmp
*.log.sensitive

# OS
.DS_Store
Thumbs.db

# Editor
.vscode/settings.json
.idea/

# Optional: rohe sensitive Exporte
hosts/**/baseline/raw/*secret*
hosts/**/baseline/raw/*token*
hosts/**/baseline/raw/*credential*
```

Wichtig: Logs sind nicht grundsätzlich ausgeschlossen, weil Logs Teil der Nachvollziehbarkeit sind. Stattdessen müssen sensible Logs gefiltert oder explizit als nicht versionierbar markiert werden.

---

## 21. AGENTS.md – globale Regeln

In `AGENTS.md` sollten mindestens diese Regeln stehen:

```md
# AGENTS.md

## Rolle
Du bist ein lokaler Agent zur dokumentierten, reproduzierbaren und rollbackfähigen Einrichtung dieses Rechners.

## Harte Regeln
1. Prüfe zuerst den Repo-Modus und die Sichtbarkeit.
2. Schreibe keine Hostdaten in ein öffentliches oder ungeprüftes Repository.
3. Speichere niemals Klartext-Secrets im Repository.
4. Erfasse vor jeder Änderung den Ausgangszustand.
5. Dokumentiere jede Änderung in `hosts/<HOSTNAME>/changes/`.
6. Erzeuge für systemwirksame Änderungen einen Rollback-Pfad.
7. Führe keine destruktiven Aktionen ohne Nutzerfreigabe aus.
8. Arbeite Vorlagen in numerischer Reihenfolge ab.
9. Nutze nur Vorlagen, die zur erkannten Plattform passen.
10. Zeige vor Commit oder Push immer eine Zusammenfassung an.

## Definition of Done
Eine Aufgabe ist erst abgeschlossen, wenn Baseline, Änderung, Prüfung, Rollback und Abschlussnotiz dokumentiert sind.
```

---

## 22. Namenskonventionen

### 22.1 Vorlagen

```text
00-detect-*.md
10-baseline-*.md
20-install-oder-config-*.md
30-security-*.md
40-network-*.md
50-services-*.md
90-validation-*.md
99-report.md
```

### 22.2 Änderungen

```text
YYYY-MM-DD_0001_bereich.md
YYYY-MM-DD_0002_firewall.md
YYYY-MM-DD_0003_env.md
YYYY-MM-DD_0004_docker.md
```

### 22.3 Rollback

```text
YYYY-MM-DD_0001_bereich.rollback.ps1
YYYY-MM-DD_0001_bereich.rollback.sh
```

---

## 23. Designprinzip

```text
Soll-Prozess   → Vorlage/
Ist-Zustand    → hosts/<HOSTNAME>/baseline/
Änderungen     → hosts/<HOSTNAME>/changes/
Rückbau        → hosts/<HOSTNAME>/rollback/
Nachweise      → hosts/<HOSTNAME>/logs/
Sicherheit     → hosts/<HOSTNAME>/security/
Laufstatus     → hosts/<HOSTNAME>/state/
```

`Vorlage/` beschreibt, **was Codex tun soll**.  
`hosts/<HOSTNAME>/` beschreibt, **was auf diesem konkreten Rechner tatsächlich erkannt, geändert, geprüft oder rückgängig gemacht wurde**.

---

## 24. Akzeptanzkriterien für die initiale Version

Die erste Version gilt als brauchbar, wenn:

- ein öffentliches Template-Repo ohne Hostdaten existiert,
- eine private Kopie daraus erzeugt werden kann,
- Codex öffentliche Repos erkennt und Hostschreiben verhindert,
- Codex lokale Git-only-Repos ohne Remote erlaubt,
- Host-Ordner automatisch erzeugt werden,
- Windows, Linux und WSL grundsätzlich erkannt werden,
- Linux nach Distribution/Familie sortiert wird,
- WSL nach Distribution sortiert wird,
- Container-Stacks separat erkannt werden,
- Docker, Compose, Swarm, Kubernetes und Podman eigene Vorlagenbereiche haben,
- NVIDIA/DGX/GPU-Profile separat modelliert sind,
- jede Änderung dokumentiert wird,
- Rollback-Dateien erzeugt werden,
- Secrets nicht im Klartext gespeichert werden,
- ein Abschlussbericht erzeugt wird,
- Git-Status und Commit-Vorschlag angezeigt werden.

---

## 25. Priorisierte Umsetzung

### Phase 1 – Repo-Grundgerüst

- Public Template Repo erzeugen
- Apache-2.0 Lizenz ergänzen
- `AGENTS.md` schreiben
- `docs/`, `schemas/`, `Vorlage/`, `scripts/`, `examples/`, `hosts/` anlegen
- `.gitignore` und `SECURITY.md` ergänzen

### Phase 2 – Repo-Sicherheitsprüfung

- `detect-repo-mode.ps1/.sh`
- `assert-private-repo.ps1/.sh`
- `enable-local-only-mode.ps1/.sh`
- `repo-mode.yaml` Schema
- Verhalten bei öffentlichem Repo definieren

### Phase 3 – Plattform-Erkennung

- Windows-Erkennung
- Linux-Erkennung über `/etc/os-release`
- WSL-Erkennung
- Hardwareprofil-Erkennung

### Phase 4 – Host-Baseline

- Host-Ordner automatisch erzeugen
- `host.yaml`
- Baseline-Dateien
- Logs
- State-Dateien

### Phase 5 – Container-Erkennung

- Docker
- Docker Compose
- Docker Swarm
- Kubernetes
- Podman
- NVIDIA Container Toolkit / GPU Runtime

### Phase 6 – Änderungs- und Rollback-System

- `write-change-entry.*`
- Rollback-Skriptgenerator
- Validierungslogik
- Abschlussbericht

---

## 26. Quellen und Referenzen

Die folgenden Quellen wurden als fachliche Grundlage für die Spezifikation herangezogen oder sind relevante Primärdokumentation:

- OpenAI Codex `AGENTS.md`: https://developers.openai.com/codex/guides/agents-md
- GitHub Repositories / Sichtbarkeit: https://docs.github.com/en/repositories/creating-and-managing-repositories/about-repositories
- GitHub Repository aus Template erzeugen: https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template
- GitHub CLI `repo create`: https://cli.github.com/manual/gh_repo_create
- GitHub CLI `repo view`: https://cli.github.com/manual/gh_repo_view
- GitHub Secret Scanning: https://docs.github.com/code-security/secret-scanning/about-secret-scanning
- GitHub sensible Daten entfernen: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
- Apache License 2.0: https://www.apache.org/licenses/LICENSE-2.0
- MIT License: https://opensource.org/license/mit
- Microsoft PowerShell DSC: https://learn.microsoft.com/en-us/powershell/dsc/overview/dscforengineers
- Microsoft WinGet Export: https://learn.microsoft.com/en-us/windows/package-manager/winget/export
- Microsoft Windows Firewall PowerShell: https://learn.microsoft.com/en-us/powershell/module/netsecurity/get-netfirewallrule
- Microsoft PowerShell Environment Variables: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables
- Microsoft PowerShell Start-Transcript: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.host/start-transcript
- Microsoft WSL: https://learn.microsoft.com/en-us/windows/wsl/install
- freedesktop.org `os-release`: https://www.freedesktop.org/software/systemd/man/os-release.html
- Debian Paketmanagement: https://www.debian.org/doc/manuals/debian-reference/ch02.en.html
- Docker Compose: https://docs.docker.com/compose/
- Docker Compose Application Model: https://docs.docker.com/compose/intro/compose-application-model/
- Docker Rootless Mode: https://docs.docker.com/engine/security/rootless/
- Docker Compose Secrets: https://docs.docker.com/compose/how-tos/use-secrets/
- Docker Swarm Secrets: https://docs.docker.com/engine/swarm/secrets/
- Kubernetes Declarative Management: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/
- Kubernetes Secrets: https://kubernetes.io/docs/concepts/configuration/secret/
- NVIDIA Container Toolkit: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
- NVIDIA DGX Spark / DGX OS: https://docs.nvidia.com/dgx/dgx-spark/dgx-os.html

---

## 27. Finale Zieldefinition

/goal Das Projekt besteht aus einem öffentlichen, klonbaren Template-Repository und privaten operationalen Nutzer-Repositories. Das öffentliche Repo enthält ausschließlich generische Agentenlogik, Vorlagen, Schemas, Skripte und Dokumentation. Produktive Host-Ordner, private Infrastrukturdetails, Secret-Referenzen und sicherheitskritische Betriebsdaten dürfen nur in privaten Repositories oder lokalen Git-Repositories ohne öffentlichen Remote geschrieben werden.

Codex muss bei jedem Start prüfen, ob das aktuelle Repository privat oder lokal sicher ist. Ist es öffentlich oder kann die Sichtbarkeit nicht sicher bestätigt werden, darf Codex keine Hostdaten oder sensiblen Informationen schreiben. Stattdessen bietet Codex an, eine private GitHub-Kopie aus dem Template zu erzeugen oder das Projekt lokal ohne Remote zu versionieren.

Das Repository unterstützt Windows, natives Linux, WSL, Container-Stacks und Spezialhardware wie DGX Spark. Die Vorlagen sind nach Betriebssystem, Umgebung, Distributionsfamilie, Distribution, Version, Hardwareprofil und Container-Stack sortiert. Codex erkennt beim Start automatisch Hostname, Plattform, Distribution, Version, Architektur, Hardwareprofil und Container-Stacks. Danach erzeugt oder aktualisiert er einen Host-Ordner und dokumentiert jede relevante Abweichung und Änderung nachvollziehbar, einheitlich, prüfbar und rollbackfähig.
