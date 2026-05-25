FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PC_AGENT_DEBIAN_FIRSTCONFIG_SOURCE=/opt/pc-agent-installer-source
ENV PC_AGENT_DEBIAN_FIRSTCONFIG_OUTPUT=/test-output

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      findutils \
      git \
      iproute2 \
      jq \
      net-tools \
      passwd \
      procps \
      python3 \
      python3-pytest \
      sudo \
      util-linux \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/pc-agent-installer-source
COPY . /opt/pc-agent-installer-source

RUN mkdir -p /test-output/artifacts /test-output/reports

CMD ["python3", "-m", "pytest", "-q", "tests/debian-firstconfig"]
