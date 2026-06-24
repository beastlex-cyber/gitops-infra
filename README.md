## GitOps инфраструктура с flux-cd, flux-tofu-controller и runner с кастомным провайдером

1. ✅ Создаем локальный кластер с помощью kind
   - Установка kind (latest):
     ```bash
     sudo curl -fsSL -o /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.32.0/kind-linux-amd64
     chmod +x /usr/local/bin/kind
     kind version
     ```
   - Создание кластера (см. `clusters/local.yaml`):
     ```bash
     kind create cluster --config clusters/local.yaml
     ```
     Контекст: `kind-gitops-test`, K8s `v1.36.1`
2. Устанавливаем flux cd через flux bootstrap
   - Установка Flux CLI (если нет):
     ```bash
     curl -s https://fluxcd.io/install.sh | sudo bash
     ```
   - Bootstrap в репозиторий:
     ```bash
     flux bootstrap github \
       --owner=beastlex-cyber \
       --repository=gitops-infra \
       --branch=main \
       --path=./clusters/gitops-test \
       --personal
     ```
   - Проверка:
     ```bash
     flux get all
     ```
3. Создаем кастомный runner для flux tofu controller
4. Через HelmRelease ставим flux tofu controller
5. Создаем наши ресурсы через ресурс Terraform в кластере