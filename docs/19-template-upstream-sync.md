# Template-Upstream-Sync

## Ziel

Ein privates `operational`-Repository soll dauerhaft vom öffentlichen Template profitieren, ohne Hostdaten, Secret-Referenzen oder den privaten Repo-Modus zu verlieren.

Das private Repository hat dafür zwei Remotes:

- `origin`: privates Operational-Repository
- `template`: öffentliches Template `https://github.com/adrianweidig/pc-agent-installer.git`

## Einmalige Einrichtung

PowerShell:

```powershell
git remote add template https://github.com/adrianweidig/pc-agent-installer.git
git fetch template main --tags
```

Bash:

```bash
git remote add template https://github.com/adrianweidig/pc-agent-installer.git
git fetch template main --tags
```

Wenn der Remote bereits existiert, muss er auf das öffentliche Template zeigen:

```powershell
git remote set-url template https://github.com/adrianweidig/pc-agent-installer.git
```

## Regelmäßiger Pull aus dem Template

Der sichere Standardweg im privaten Repository ist:

```powershell
./scripts/common/sync-template-upstream.ps1
```

```bash
bash ./scripts/common/sync-template-upstream.sh
```

Das Skript:

- verweigert die Ausführung im öffentlichen `template`-Modus,
- verlangt einen sauberen Arbeitsbaum,
- setzt oder aktualisiert den `template`-Remote,
- holt `template/main` und Tags,
- merged den Template-Stand,
- schützt `repo-mode.yaml`, damit `operational` oder `local-only` erhalten bleibt,
- erstellt bei konfliktfreiem Merge einen Commit `chore: synchronisiere template-upstream`.

Danach wird nur ins private Repository gepusht:

```powershell
git push origin main
```

## Konfliktregeln

Bei Konflikten gilt:

- `repo-mode.yaml` bleibt im privaten Repository `operational` oder `local-only`.
- `hosts/` bleibt privat und wird niemals aus dem öffentlichen Template überschrieben.
- Secret-Referenzen bleiben nur als Referenzen erhalten; Werte werden nicht übernommen oder ausgegeben.
- Öffentliche Template-Änderungen an `README.md`, `AGENTS.md`, `docs/`, `Vorlage/`, `scripts/`, `schemas/` und `.github/` werden übernommen, soweit sie nicht private Hostregeln verletzen.

Wenn ein Konflikt private Hostinformationen gegen generische Template-Regeln stellt, wird der generische Anteil übernommen und der private Anteil in der privaten Hoststruktur dokumentiert.

## Keine Rückrichtung

Hostdaten fließen nie zurück ins öffentliche Template. Aus dem privaten Repo dürfen nur verallgemeinerte, hostdatenfreie Verbesserungen in das öffentliche Template übernommen werden.

Gute Kandidaten für die Rückrichtung:

- bessere Guard-Regeln,
- generische Vorlagen,
- sichere Dokumentationsregeln,
- reproduzierbare Checks,
- Beispiele ohne echte Hostdaten.

Nicht geeignet:

- Hostnamen,
- private Pfade,
- Baselines,
- echte Infrastrukturdetails,
- Secret-Werte,
- lokale Testziele.
