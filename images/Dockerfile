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

# Install custom DECORT provider into a local filesystem mirror.
# Layout: HOSTNAME/NAMESPACE/TYPE/VERSION/TARGET — recognized by `terraform init`.
ARG DECORT_PROVIDER_SOURCE=basis/decort/decort
RUN decort_mirror_dir="/opt/decort-provider/${DECORT_PROVIDER_SOURCE}/${DECORT_PROVIDER_VERSION}/linux_${TARGETARCH}" \
  && mkdir -p "${decort_mirror_dir}" \
  && wget -q https://repository.basistech.ru/BASIS/terraform-provider-decort/releases/download/${DECORT_PROVIDER_VERSION}/terraform-provider-decort_${DECORT_PROVIDER_VERSION}_linux_${TARGETARCH}.zip \
  && unzip -q terraform-provider-decort_${DECORT_PROVIDER_VERSION}_linux_${TARGETARCH}.zip -d /tmp/decort-provider \
  && mv /tmp/decort-provider/bin/* "${decort_mirror_dir}/terraform-provider-decort_v${DECORT_PROVIDER_VERSION}" \
  && chmod +x "${decort_mirror_dir}/terraform-provider-decort_v${DECORT_PROVIDER_VERSION}" \
  && rm -rf terraform-provider-decort_${DECORT_PROVIDER_VERSION}_linux_${TARGETARCH}.zip /tmp/decort-provider

# Terraform CLI config — serve custom DECORT provider from the local mirror,
# everything else from the upstream registries.
RUN printf '%s\n' \
  'provider_installation {' \
  '  filesystem_mirror {' \
  '    path    = "/opt/decort-provider"' \
  "    include = [\"${DECORT_PROVIDER_SOURCE}\"]" \
  '  }' \
  '  direct {' \
  "    exclude = [\"${DECORT_PROVIDER_SOURCE}\"]" \
  '  }' \
  '}' > /etc/terraformrc

ENV TF_CLI_CONFIG_FILE=/etc/terraformrc

# Runner runs with a read-only root filesystem, so the build-time plugin cache
# under /opt is not writable. The local filesystem mirror already serves the
# provider offline, making the cache redundant — disable it for runtime.
ENV TF_PLUGIN_CACHE_DIR=""

RUN chown -R 65532:65532 /opt/terraform.d /opt/decort-provider \
  && rm -rf /opt/providers \
  && ln -s /opt/terraform.d/plugin-cache /opt/providers

USER 65532:65532

ENTRYPOINT ["/entrypoint.sh"]
