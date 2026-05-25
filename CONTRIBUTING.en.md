# Contributing

🌐 Languages: [Deutsch](CONTRIBUTING.md) | [English](CONTRIBUTING.en.md)

Thank you for your interest in PC Agent Installer. This repository is a public template, so contributions must remain generic, reproducible, and free of host data.

## Contribution Types

Welcome contributions include:

- improvements to guard and validation scripts
- new or more precise agent templates
- documentation improvements
- safe examples without real host data
- reproducible bug reports
- small fixes to schemas, CI, and repository hygiene

Real host names, private paths, internal infrastructure details, local test notes, secrets, tokens, production kubeconfigs, and raw credential dumps do not belong in this public repository.

## Before Changing Files

1. Read `AGENTS.md`.
2. Check the working tree:

   ```powershell
   git status --short --branch
   ```

3. Detect repository mode:

   ```powershell
   ./scripts/common/detect-repo-mode.ps1
   ```

4. Check open issues if GitHub is reachable:

   ```powershell
   gh issue list --state open --limit 20
   ```

## Development Environment

There is no package manager and no external project dependency. Local work needs:

- Git
- PowerShell
- Bash
- optionally GitHub CLI `gh`

## Branches and Commits

- Keep changes small and coherent.
- Use clear commit messages, for example `docs: improve onboarding` or `test: harden template validation`.
- Do not mix template changes with private operational data.
- Do not run destructive Git commands unless explicitly agreed.

Maintainers or agents with write access may merge verified template changes through `main` when project rules allow it. External contributors work through a fork or branch and pull request.

## Checks

Before a pull request, run at least:

```powershell
./scripts/common/detect-repo-mode.ps1
./scripts/common/verify-template.ps1
git diff --check
```

Also useful:

```bash
bash ./scripts/common/detect-repo-mode.sh
bash ./scripts/common/verify-template.sh
```

`assert-private-repo.*` may fail in `template` mode. That is a safety boundary, not a template defect.

## Templates and Style

- New templates need valid YAML frontmatter.
- Numeric positions in `Vorlage/` must remain unique.
- German is the default documentation language.
- German prose uses real UTF-8 umlauts.
- Markdown paths use relative links for repository files.
- PowerShell scripts must run from the repository without explicit `-RepoRoot`.
- Guard scripts remain non-destructive and idempotent.

## Pull Requests

A good pull request contains:

- short summary
- affected files or areas
- public/private classification
- checks that were run
- open risks or intentional boundaries
- link to relevant issues, if any

Use `.github/PULL_REQUEST_TEMPLATE.md`. The template is intentionally bilingual because GitHub does not automatically switch PR templates by user language.

## Issues

A good bug report contains:

- current state and expected behavior
- reproduction steps or concrete location
- affected files or templates
- risk and impact
- checks already run

For security problems, do not create a public issue with confidential details. Follow `SECURITY.en.md`.

## Communication

Stay respectful, concrete, and solution-oriented. Different workflows are fine; what matters is that changes remain understandable, testable, and safe for a public template.
