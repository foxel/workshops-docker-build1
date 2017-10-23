FROM ubuntu:16.04

RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y crudini && \
    rm -rf /var/lib/apt/lists/*

COPY start.sh /bin/start

COPY app.sh /opt/app/app

COPY app.ini /etc/app.ini

ENV OPTIONS_STRING_VALUE='default_config_value'

CMD ["/bin/start"]
