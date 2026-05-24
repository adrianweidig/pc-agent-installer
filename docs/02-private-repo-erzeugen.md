# Private Repo Erzeugen

Empfohlener Weg:

```bash
gh repo create <user>/pc-agent-installer-private --template <owner>/pc-agent-installer --private --clone
```

Alternativ lokal ohne Remote:

```bash
git clone https://github.com/<owner>/pc-agent-installer.git pc-agent-installer-local
cd pc-agent-installer-local
git remote remove origin
git init
git add .
git commit -m "Initial local operational copy"
```

Danach `repo-mode.yaml` auf `operational` oder `local-only` setzen und die Guard-Skripte ausführen.
