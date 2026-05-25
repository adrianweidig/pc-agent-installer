# Security Policy

🌐 Languages: [Deutsch](SECURITY.md) | [English](SECURITY.en.md)

## Principle

PC Agent Installer is a public template. This repository must not contain plaintext secrets, real host data, or confidential infrastructure details.

Host data may only be documented in a confirmed private `operational` repository or in a `local-only` clone without a remote. Plaintext secrets remain forbidden there as well.

## Supported Versions

The project currently has no formal release support model. Security reports refer to the current state of the default branch and to published releases, if present.

## Not Allowed

- plaintext passwords, tokens, API keys, and private keys
- unfiltered `.env` files
- production kubeconfigs with tokens
- SSH private keys and certificate private keys
- raw secret, credential, or token exports
- real host names, private paths, or internal infrastructure details in the public template

## Reporting a Security Problem

Do not post confidential vulnerability details publicly as an issue.

If GitHub Private Vulnerability Reporting is enabled for this repository, use that path. If no private reporting path is visible, open a public issue only with a general description and without exploit details, secrets, log excerpts, or concrete internal paths.

Maintainers should configure a private security contact or GitHub Private Vulnerability Reporting. Open steps are tracked in `docs/MAINTAINER_CHECKLIST.md`.

## Expected Process

After a report, check:

1. Is the public template affected?
2. Were secrets, host data, or private paths exposed?
3. Do affected secrets need rotation?
4. Is a template patch required?
5. Should GitHub Secret Scanning, Code Scanning, or repository history be checked?

History cleanup, force-pushes, or other irreversible steps require an explicit maintainer decision.

## Accidentally Committed Sensitive Data

If sensitive data was committed by accident:

1. Do not push further.
2. Rotate affected secrets immediately.
3. Check public copies, forks, and CI logs.
4. Clean history only after explicit approval.
5. If a remote is affected, check GitHub Secret Scanning and audit logs.

## Operational Repositories

Private operational repositories may document secret references, but not secret values. Purpose, storage location, access method, runtime variable, and rotation guidance are allowed.

This policy does not provide a security guarantee. It defines the minimum rules for keeping the public template and derived private workspaces cleanly separated.
