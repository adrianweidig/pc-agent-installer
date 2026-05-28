# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/powershell:7.5-debian-12

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PC_AGENT_CONTAINER=true \
    PC_AGENT_REPO_ROOT=/opt/pc-agent-installer

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      coreutils \
      findutils \
      gawk \
      git \
      grep \
      python3 \
      ripgrep \
      sed \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/pc-agent-installer
COPY . .

CMD ["bash", "-lc", "pwsh -NoLogo -NoProfile -File scripts/common/validate-template.ps1 && bash scripts/common/validate-template.sh"]
