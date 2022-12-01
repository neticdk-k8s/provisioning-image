FROM ubuntu:20.04

ARG TARGETARCH
ARG AZ_CLI_VERSION=2.40.0
ARG TF_VERSION=1.2.8

ENV TZ=Europe \
    DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y ca-certificates gnupg curl unzip lastpass-cli git direnv gettext-base jq
RUN echo "deb [arch=${TARGETARCH}] https://packages.microsoft.com/repos/azure-cli/ focal main" | tee /etc/apt/sources.list.d/azure-cli.list

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
RUN apt update && apt install -y azure-cli && apt clean


RUN curl https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TARGETARCH}.zip --output /tmp/terraform.zip \
  && unzip /tmp/terraform.zip \
  && mv terraform /usr/bin \
  && rm -f terraform.zip

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

RUN echo "eval \"\$(direnv hook bash)\"" >> /.bashrc
WORKDIR /workspace
RUN groupadd --gid 1001 nonroot \
  # user needs a home folder to store azure credentials
  && useradd --gid nonroot --create-home --uid 1001 nonroot \
  && mkdir -p /home/nonroot/.ssh \
  && chown -R nonroot:nonroot /home/nonroot \
  && chmod 0700 /home/nonroot/.ssh \
  && chown nonroot:nonroot /workspace
VOLUME /workspace
USER nonroot
CMD ["bash", "--rcfile", "/.bashrc"]
