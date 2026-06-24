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
     flux bootstrap git \
     --url=ssh://git@github.com/beastlex-cyber/gitops-infra \
     --branch=main \
     --private-key-file=/home/user/.ssh/id_rsa_new \
     --path=clusters/gitops-test
     ```
   - Проверка:
     ```bash
     flux get all
     ```
3. Создаем кастомный runner для flux tofu controller
   - Сборка образа (из `images/`):
     ```bash
     docker build -t tf-runner-decort:v0.16.4 images/
     ```
   - Загрузка в kind-кластер:
     ```bash
     kind load docker-image tf-runner-decort:v0.16.4 --name gitops-test
     ```
   - Проверка:
     ```bash
     docker exec -it gitops-test-control-plane crictl images | grep tf-runner
     ```
4. Через HelmRelease ставим flux tofu controller
   - Применяем манифесты из `clusters/gitops-test/`:
     ```bash
     kubectl apply -f clusters/gitops-test/helmrepository.yaml
     kubectl apply -f clusters/gitops-test/helmrelease.yaml
     ```
   - Проверка:
     ```bash
     kubectl get pods -n flux-system
     ```
5. Создаем наши ресурсы через ресурс Terraform в кластере