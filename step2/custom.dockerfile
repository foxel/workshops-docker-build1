FROM ubuntu:16.04

COPY message.txt /opt/message.txt

CMD ["base64", "-d", "/opt/message.txt"]
