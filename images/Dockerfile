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

ENV TF_PLUGIN_CACHE_DIR="/opt/terraform.d/plugin-cache"

RUN mkdir -p /opt/terraform.d/plugin-cache \
  && terraform init \
  && rm -rf required_providers.tf /.terraform /.terraform.lock.hcl /LICENSE.txt

# Install custom DECORT provider
RUN mkdir -p /opt/terraform.d/plugin-cache/basis/decort/decort/${DECORT_PROVIDER_VERSION}/linux_${TARGETARCH} \
  && wget -q https://repository.basistech.ru/BASIS/terraform-provider-decort/releases/download/${DECORT_PROVIDER_VERSION}/terraform-provider-decort_${DECORT_PROVIDER_VERSION}_linux_${TARGETARCH}.zip \
  && unzip -q terraform-provider-decort_${DECORT_PROVIDER_VERSION}_linux_${TARGETARCH}.zip -d /tmp/decort-provider \
  && mv /tmp/decort-provider/bin/* /opt/terraform.d/plugin-cache/basis/decort/decort/${DECORT_PROVIDER_VERSION}/linux_${TARGETARCH}/ \
  && rm -rf terraform-provider-decort_${DECORT_PROVIDER_VERSION}_linux_${TARGETARCH}.zip /tmp/decort-provider

RUN chown -R 65532:65532 /opt/terraform.d \
  && rm -rf /opt/providers \
  && ln -s /opt/terraform.d/plugin-cache /opt/providers

USER 65532:65532

ENTRYPOINT ["/entrypoint.sh"]
