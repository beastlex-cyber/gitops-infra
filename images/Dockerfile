ARG BASE_RUNNER_VERSION=v0.16.4

FROM ghcr.io/flux-iac/tf-runner:${BASE_RUNNER_VERSION}-base

USER 0:0

ARG TF_VERSION=1.15.6
ARG DECORT_PROVIDER_VERSION=4.11.3
ARG TARGETARCH=amd64

RUN wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TARGETARCH}.zip \
  && unzip terraform_${TF_VERSION}_linux_${TARGETARCH}.zip \
  && mv -v terraform /usr/local/bin/terraform \
  && chmod +x /usr/local/bin/terraform \
  && rm -f terraform_${TF_VERSION}_linux_${TARGETARCH}.zip

COPY entrypoint.sh required_providers.tf /
RUN chmod +x /entrypoint.sh

ENV TF_PLUGIN_CACHE_DIR="/opt/terraform.d/plugin-cache"

RUN mkdir -p /opt/terraform.d/plugin-cache \
  && terraform init \
  && rm -rf required_providers.tf /.terraform /.terraform.lock.hcl /LICENSE.txt

# Install custom DECORT provider (dev_overrides — no registry lookup)
RUN mkdir -p /opt/decort-provider \
  && wget -q https://repository.basistech.ru/BASIS/terraform-provider-decort/releases/download/${DECORT_PROVIDER_VERSION}/terraform-provider-decort_${DECORT_PROVIDER_VERSION}_linux_${TARGETARCH}.zip \
  && unzip -q terraform-provider-decort_${DECORT_PROVIDER_VERSION}_linux_${TARGETARCH}.zip -d /tmp/decort-provider \
  && mv /tmp/decort-provider/bin/* /opt/decort-provider/terraform-provider-decort \
  && chmod +x /opt/decort-provider/terraform-provider-decort \
  && rm -rf terraform-provider-decort_${DECORT_PROVIDER_VERSION}_linux_${TARGETARCH}.zip /tmp/decort-provider

# Terraform CLI config — skip registry lookup for custom DECORT provider
RUN echo 'provider_installation {' > /etc/terraformrc \
  && echo '  dev_overrides {' >> /etc/terraformrc \
  && echo '    "basis/decort/decort" = "/opt/decort-provider"' >> /etc/terraformrc \
  && echo '  }' >> /etc/terraformrc \
  && echo '  direct {}' >> /etc/terraformrc \
  && echo '}' >> /etc/terraformrc

ENV TF_CLI_CONFIG_FILE=/etc/terraformrc

RUN chown -R 65532:65532 /opt/terraform.d /opt/decort-provider \
  && rm -rf /opt/providers \
  && ln -s /opt/terraform.d/plugin-cache /opt/providers

USER 65532:65532

ENTRYPOINT ["/entrypoint.sh"]
