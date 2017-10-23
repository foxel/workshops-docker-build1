FROM ubuntu:16.04

COPY start.sh /bin/start

COPY app.sh /opt/app/app

COPY app.ini /etc/app.ini

ENV OPTIONS_STRING_VALUE='default_config_value'

CMD ["/bin/start"]
