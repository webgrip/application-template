FROM bitnami/postgresql:17.4.0

USER root
RUN install_packages wget ca-certificates \
 && wget -O /usr/local/bin/wal-g \
    https://github.com/wal-g/wal-g/releases/download/v3.0.5/wal-g-pg-ubuntu-22.04-amd64 \
 && chmod +x /usr/local/bin/wal-g
