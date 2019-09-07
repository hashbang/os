FROM hashbang/aosp-build@sha256:53ea03cb5e67821159f57685e9a202349a5ef9c42b81567e5f467ff3c2f0c89d

USER root
RUN \
    apt-get update && \
    apt-get install -y \
        python-six \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
USER build
