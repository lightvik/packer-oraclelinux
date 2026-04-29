FROM oraclelinux:10-slim

ARG PACKER_VERSION=1.15.3

# hadolint ignore=DL3041
RUN microdnf install -y \
    curl \
    unzip \
    qemu-kvm \
    qemu-img \
    xorriso \
    edk2-ovmf \
  && microdnf clean all

RUN curl -fsSL "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
    -o /tmp/packer.zip \
  && unzip /tmp/packer.zip -d /usr/local/bin \
  && rm /tmp/packer.zip

WORKDIR /workspace

# Скачиваем плагины заранее, чтобы образ был самодостаточным
COPY plugins.pkr.hcl /workspace/
RUN packer init /workspace/plugins.pkr.hcl

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
