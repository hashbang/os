FROM hashbang/aosp-build@sha256:af0a3a46b2b6008ce070ca7a76f1d1dce975b1c302f1b11f2a3deec06724b76b

USER root
RUN \
    apt-get update && \
    apt-get install -y \
        python-six \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
USER build
