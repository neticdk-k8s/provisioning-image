FROM ubuntu:22.04

ARG TARGETARCH
ARG AZ_CLI_VERSION=2.54.0
ARG TF_VERSION=1.5.7

RUN apt update && apt upgrade -y && apt install -y ca-certificates gnupg curl unzip pip

RUN curl https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TARGETARCH}.zip --output /tmp/terraform.zip \
  && unzip /tmp/terraform.zip \
  && mv terraform /usr/bin \
  && rm -f terraform.zip

RUN pip install azure-cli==${AZ_CLI_VERSION}

RUN apt install -y git direnv gettext-base jq && apt clean

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

RUN mkdir -p /home/nonroot/.azure/cliextensions && chown -R nonroot:nonroot /home/nonroot/
ENV AZURE_EXTENSION_DIR=/home/nonroot/.azure/cliextensions
RUN az extension add --name "notification-hub"

VOLUME /workspace
USER nonroot
CMD ["bash", "--rcfile", "/.bashrc"]
