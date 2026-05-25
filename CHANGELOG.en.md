# Changelog

🌐 Languages: [Deutsch](CHANGELOG.md) | [English](CHANGELOG.en.md)

## Unreleased

- Added internationalization with German as the default language, an English README, multilingual documentation entry points, community files, and PowerShell/Bash i18n tests.
- Added automatic GitHub release workflow after successful `main` validation, including ZIP asset and complete `release-notes.md` with commit history.
- Analyzed GitHub security alerts and removed security-relevant `Invoke-Expression` use from Docker baseline collection.
- Added the global Codex new-project standard as reusable documentation and bootstrap script.
- Added release automation for ZIP files and release notes.
- Improved README with hero image, correct GitHub badges, quick links, and clearer documentation navigation.
- Added structured GitHub issue templates, pull request template, and Dependabot configuration for GitHub Actions.
- Added `SUPPORT.md`, `CODE_OF_CONDUCT.md`, architecture overview, release process, and maintainer checklist.
- Clarified security and contribution documentation for public collaboration and sensitive reporting paths.
- Expanded README as the central entry documentation.
- Extended `AGENTS.md` with project-specific Codex rules and durable hygiene guidance.
- Documented the public template and private operational work as a durable Codex working model.
- Defined `pc-agent-installer` as the central Codex starting point with mandatory public/private classification for every task.
- Added issue, pull request, and direct-push rules for agents with and without write access.
- Added standardized `verify-template` checks and GitHub Actions workflow.
- Clarified the agent-first usage model in README, `AGENTS.md`, and Codex documentation.
- Hardened Bash template validation against `pipefail` false positives during frontmatter checks.
- Made PowerShell entry points more robust so they work without explicit `-RepoRoot`.
- Fixed corrupted `rollback_required` line in template files.
- Added repository hygiene for local logs and caches.

## 0.1.0 - 2026-05-24

- Created the initial template structure.
- Modeled repository modes `template`, `operational`, and `local-only`.
- Added guard scripts for PowerShell and Bash.
- Added first safe version of platform, host, baseline, and container detection.
- Added template structure for Windows, Linux, WSL, containers, and profiles.
