FROM ubuntu:16.04

RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y unzip wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ARG consul_version

# this is only to have version available inside container later
ENV CONSUL_VERSION="${consul_version}"

RUN wget -O- \
    "https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip" | \
    funzip > "/bin/consul" && \
    chmod +x /bin/consul

CMD ["/bin/consul"]
