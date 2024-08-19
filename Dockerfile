FROM ubuntu:latest
LABEL authors="notdevcody"

RUN apt-get update \
    && apt-get install -y bash git wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chown -R ${USER}:${USER} /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]