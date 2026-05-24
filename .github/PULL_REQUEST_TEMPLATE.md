## Zusammenfassung


## Betroffener Bereich

- [ ] Dokumentation
- [ ] Vorlagen
- [ ] PowerShell-Skripte
- [ ] Bash-Skripte
- [ ] Container-Erkennung
- [ ] Schemas
- [ ] CI oder Repository-Hygiene

## Public/Private-Einordnung

- [ ] Generische Änderung für das öffentliche Template
- [ ] Keine Hostdaten, privaten Pfade, lokalen Testzustände oder Secrets enthalten
- [ ] Private oder hostbezogene Nachweise bleiben außerhalb dieses Repositories

## Checks

- [ ] `./scripts/common/detect-repo-mode.ps1`
- [ ] `./scripts/common/verify-template.ps1`
- [ ] `bash ./scripts/common/detect-repo-mode.sh`
- [ ] `bash ./scripts/common/verify-template.sh`
- [ ] `git diff --check`
- [ ] Manuelle Secret-Prüfung

## Zugehörige Issues


## Risiken oder Grenzen


## Hinweise für Reviewer

