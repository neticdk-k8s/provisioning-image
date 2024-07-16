FROM ubuntu:22.04

ARG TARGETARCH
ARG AZ_CLI_VERSION=2.54.0
ARG TF_VERSION=1.5.7
ARG TOFU_VERSION=1.7.3
ARG KUBECTL_VERSION=1.30.2
ARG KUBELOGIN_VERSION=0.1.4

RUN apt update \
  && apt install -y \
    ca-certificates gnupg curl unzip pip git bash-completion \
  && rm -rf /var/lib/apt/lists/*

RUN apt update \
  && apt install -y --no-install-recommends \
    direnv gettext-base jq \
  && rm -rf /var/lib/apt/lists/*

RUN true \
  && TF_ARCH="$TARGETARCH" \
  && curl -s https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TF_ARCH}.zip --output /tmp/terraform.zip \
  && unzip /tmp/terraform.zip \
  && mv terraform /usr/bin \
  && rm -f terraform.zip \
  && ln -s terraform /usr/bin/tf \
  && printf '%s\n%s\n' \
    'complete -C /usr/bin/tf tf' \
    'complete -C /usr/bin/terraform terraform' \
    > /etc/bash_completion.d/terraform \
  && true

RUN true \
  && curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh \
  && chmod +x install-opentofu.sh \
  && ./install-opentofu.sh \
    --install-method standalone \
    --opentofu-version "${TOFU_VERSION}" \
    --symlink-path /usr/bin \
  && rm install-opentofu.sh \
  && printf '%s\n' \
    'complete -C /usr/bin/tofu tofu' \
    > /etc/bash_completion.d/tofu \
  && true

RUN pip install azure-cli==${AZ_CLI_VERSION}

RUN az aks install-cli --client-version "v${KUBECTL_VERSION}" --kubelogin-version "v${KUBELOGIN_VERSION}"

COPY bashrc /.bashrc
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

WORKDIR /workspace
RUN groupadd --gid 1001 nonroot \
  # user needs a home folder to store azure credentials
  && useradd --gid nonroot --create-home --uid 1001 nonroot \
  && mkdir -p /home/nonroot/.ssh \
  && chown -R nonroot:nonroot /home/nonroot \
  && chmod 0700 /home/nonroot/.ssh \
  && su nonroot --session-command "git config --global --add credential.helper store" \
  && su nonroot --session-command "git config --global --add safe.directory '*'" \
  && chown nonroot:nonroot /workspace

RUN mkdir -p /home/nonroot/.azure/cliextensions && chown -R nonroot:nonroot /home/nonroot/
ENV AZURE_EXTENSION_DIR=/home/nonroot/.azure/cliextensions
RUN az extension add --name "notification-hub"

VOLUME /workspace
USER nonroot
CMD ["bash", "--rcfile", "/.bashrc"]
