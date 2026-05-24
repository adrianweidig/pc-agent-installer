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

# Basispakete installieren

Diese Datei zeigt den Frontmatter-Aufbau einer ausführbaren Vorlage.
